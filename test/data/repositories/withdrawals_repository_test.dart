import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/audit/audit_writer.dart';
import 'package:to_audit/data/audit/period_guard.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/repositories/days_repository.dart';
import 'package:to_audit/data/repositories/settings_repository.dart';
import 'package:to_audit/data/repositories/withdrawals_repository.dart';
import 'package:to_audit/domain/dates.dart';
import 'package:to_audit/domain/money.dart';

void main() {
  late AppDatabase db;
  late DaysRepository days;
  late WithdrawalsRepository repo;
  late String bankId;
  late String ownerId;

  DateTime d(int month, int day) => DateTime.utc(2026, month, day);

  setUp(() async {
    db = AppDatabase.memory();
    final audit = AuditWriter(db);
    final guard = PeriodGuard(db);
    days = DaysRepository(
      db,
      audit: audit,
      guard: guard,
      settings: SettingsRepository(db, audit),
    );
    repo = WithdrawalsRepository(db, audit: audit, guard: guard);
    final types = await (db.select(
      db.withdrawalTypes,
    )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
    bankId = types[0].id;
    ownerId = types[1].id;
  });
  tearDown(() => db.close());

  Future<void> closeDay(String dayId) async {
    await days.saveDraft(
      dayId,
      const DayDraft(
        openingFloat: Money.zero,
        countedCash: Money.zero,
        terminalTotal: Money.zero,
        comment: 'x',
      ),
    );
    await days.closeDay(dayId);
  }

  Future<String> add(String dayId, int cents, [String? typeId]) =>
      repo.add(dayId: dayId, amount: Money(cents), typeId: typeId ?? bankId);

  test('add stores the withdrawal with the day date and audits it', () async {
    final day = await days.openDay(d(10, 1));
    final id = await repo.add(
      dayId: day.id,
      amount: const Money(50000),
      typeId: bankId,
      note: 'ingreso',
    );
    final list = await repo.watchDay(day.id).first;
    expect(list, hasLength(1));
    expect(list.single.id, id);
    expect(list.single.dayId, day.id);
    expect(list.single.date, d(10, 1));
    expect(list.single.amount, const Money(50000));
    expect(list.single.typeId, bankId);
    expect(list.single.note, 'ingreso');
    expect(list.single.voided, isFalse);
    final log = await db.select(db.changeLog).get();
    expect(
      log.where((l) => l.entity == 'retirada' && l.recordId == id),
      hasLength(1),
    );
  });

  test('add on a closed day throws PeriodLockedException', () async {
    final day = await days.openDay(d(10, 1));
    await closeDay(day.id);
    await expectLater(add(day.id, 100), throwsA(isA<PeriodLockedException>()));
    expect(await db.select(db.withdrawals).get(), isEmpty);
  });

  test('add validates amount, day and type', () async {
    final day = await days.openDay(d(10, 1));
    await expectLater(add(day.id, 0), throwsArgumentError);
    await expectLater(add(day.id, -5), throwsArgumentError);
    await expectLater(add('nope', 100), throwsArgumentError);
    await expectLater(add(day.id, 100, 'nope'), throwsArgumentError);
    await (db.update(db.withdrawalTypes)..where((t) => t.id.equals(ownerId)))
        .write(const WithdrawalTypesCompanion(active: Value(false)));
    await expectLater(add(day.id, 100, ownerId), throwsArgumentError);
  });

  test('update changes fields, audits them and validates', () async {
    final day = await days.openDay(d(10, 1));
    final id = await add(day.id, 1000);
    await repo.update(
      id,
      amount: const Money(2500),
      typeId: ownerId,
      note: 'socio',
    );
    final w = (await repo.watchDay(day.id).first).single;
    expect(w.amount, const Money(2500));
    expect(w.typeId, ownerId);
    expect(w.note, 'socio');
    final log = await db.select(db.changeLog).get();
    expect(
      log.where(
        (l) =>
            l.entity == 'retirada' &&
            l.field == 'amountCents' &&
            l.oldValue == '1000' &&
            l.newValue == '2500',
      ),
      hasLength(1),
    );
    await expectLater(repo.update(id, amount: Money.zero), throwsArgumentError);
    await expectLater(repo.update(id, typeId: 'nope'), throwsArgumentError);
    await expectLater(
      repo.update('nope', amount: const Money(1)),
      throwsArgumentError,
    );
  });

  test('update keeps an inactive type on an existing row', () async {
    final day = await days.openDay(d(10, 1));
    final id = await add(day.id, 1000, ownerId);
    await (db.update(db.withdrawalTypes)..where((t) => t.id.equals(ownerId)))
        .write(const WithdrawalTypesCompanion(active: Value(false)));
    await repo.update(id, amount: const Money(1500), typeId: ownerId);
    expect(
      (await repo.watchDay(day.id).first).single.amount,
      const Money(1500),
    );
  });

  test('update and void on a closed day throw PeriodLockedException', () async {
    final day = await days.openDay(d(10, 1));
    final id = await add(day.id, 1000);
    await closeDay(day.id);
    await expectLater(
      repo.update(id, amount: const Money(2000)),
      throwsA(isA<PeriodLockedException>()),
    );
    await expectLater(
      repo.voidRecord(id, 'motivo'),
      throwsA(isA<PeriodLockedException>()),
    );
  });

  test('voiding removes it from totals and the day summary', () async {
    final day = await days.openDay(d(10, 1));
    final keep = await add(day.id, 3000);
    final gone = await add(day.id, 700);
    final range = DateRange(d(10, 1), d(10, 31));
    expect((await days.summary(day.id)).withdrawals, const Money(3700));
    expect((await repo.totalsByType(range))[bankId], const Money(3700));

    await repo.voidRecord(gone, '  error  ');
    expect((await days.summary(day.id)).withdrawals, const Money(3000));
    expect(await repo.totalsByType(range), {bankId: const Money(3000)});

    final all = await repo.watchDay(day.id).first;
    expect(all.map((w) => w.id), [keep, gone]);
    expect(all.last.voided, isTrue);
    expect(all.last.voidReason, 'error');
    final log = await db.select(db.changeLog).get();
    expect(
      log.where(
        (l) =>
            l.entity == 'retirada' &&
            l.recordId == gone &&
            l.field == 'voided' &&
            l.reason == 'error',
      ),
      hasLength(1),
    );
  });

  test('voidRecord validates reason and state', () async {
    final day = await days.openDay(d(10, 1));
    final id = await add(day.id, 100);
    await expectLater(repo.voidRecord(id, '  '), throwsArgumentError);
    await expectLater(repo.voidRecord('nope', 'x'), throwsArgumentError);
    await repo.voidRecord(id, 'x');
    await expectLater(repo.voidRecord(id, 'again'), throwsStateError);
    await expectLater(
      repo.update(id, amount: const Money(5)),
      throwsStateError,
    );
  });

  test('watchRange orders by date then creation and keeps voided', () async {
    final two = await days.openDay(d(10, 2));
    final one = await days.openDay(d(10, 1));
    final outside = await days.openDay(d(11, 1));
    final a = await add(two.id, 200);
    final b = await add(one.id, 100, ownerId);
    final c = await add(one.id, 300);
    await add(outside.id, 999);
    await repo.voidRecord(c, 'x');
    final range = DateRange(d(10, 1), d(10, 31));
    final list = await repo.watchRange(range).first;
    expect(list.map((w) => w.id), [b, c, a]);
    expect(list.map((w) => w.date), [d(10, 1), d(10, 1), d(10, 2)]);
    expect(list[1].voided, isTrue);

    expect(await repo.totalsByType(range), {
      bankId: const Money(200),
      ownerId: const Money(100),
    });
  });

  test('watchDay re-emits after a change', () async {
    final day = await days.openDay(d(10, 1));
    final emissions = <int>[];
    final sub = repo.watchDay(day.id).listen((l) => emissions.add(l.length));
    await pumpEventQueue();
    await add(day.id, 100);
    await pumpEventQueue();
    await sub.cancel();
    expect(emissions, containsAllInOrder([0, 1]));
  });
}
