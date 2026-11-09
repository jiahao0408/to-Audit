import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/audit/audit_writer.dart';
import 'package:to_audit/data/audit/period_guard.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/files/receipt_store.dart';
import 'package:to_audit/data/repositories/days_repository.dart';
import 'package:to_audit/data/repositories/expenses_repository.dart';
import 'package:to_audit/data/repositories/periods_repository.dart';
import 'package:to_audit/data/repositories/settings_repository.dart';
import 'package:to_audit/domain/enums.dart';
import 'package:to_audit/domain/money.dart';

void main() {
  late AppDatabase db;
  late Directory tmp;
  late DaysRepository days;
  late ExpensesRepository expenses;
  late PeriodsRepository repo;

  DateTime d(int m, int day) => DateTime.utc(2026, m, day);

  setUp(() async {
    db = AppDatabase.memory();
    tmp = await Directory.systemTemp.createTemp('periods_repo_test');
    final audit = AuditWriter(db);
    final guard = PeriodGuard(db);
    days = DaysRepository(
      db,
      audit: audit,
      guard: guard,
      settings: SettingsRepository(db, audit),
    );
    expenses = ExpensesRepository(
      db,
      audit: audit,
      guard: guard,
      receipts: ReceiptStore(
        tmp,
        compressor: (s, {int maxSide = 1600, int quality = 75}) async => [1],
      ),
    );
    repo = PeriodsRepository(db, audit: audit);
  });
  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  /// Marks the days [from]..[to] of [month] as no activity.
  Future<void> fill(int month, int from, int to) async {
    for (var day = from; day <= to; day++) {
      await days.markNoActivity(d(month, day));
    }
  }

  test('closes October when all days are closed or no activity', () async {
    await fill(10, 1, 31);
    await repo.closeMonth('2026-10', today: d(11, 2));
    expect(await repo.isClosed('2026-10'), isTrue);
    expect(await repo.watchClosed().first, {'2026-10'});
    final row = await db.select(db.periods).getSingle();
    expect(row.closedAt, isNotNull);
    final log = await db.select(db.changeLog).get();
    expect(
      log.where((l) => l.entity == 'periodo' && l.field == 'status'),
      hasLength(1),
    );
  });

  test('a closed month locks days and expenses', () async {
    await fill(10, 1, 31);
    final oct5 = (await days.getDay(d(10, 5)))!;
    await repo.closeMonth('2026-10', today: d(11, 2));
    await expectLater(
      days.reopenDay(oct5.id, 'motivo'),
      throwsA(
        isA<PeriodLockedException>().having((e) => e.kind, 'kind', 'month'),
      ),
    );
    final pay = (await (db.select(
      db.paymentMethods,
    )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get()).first;
    final cat = (await db.select(db.expenseCategories).get()).first;
    await expectLater(
      expenses.create(
        ExpenseInput(
          date: d(10, 10),
          categoryId: cat.id,
          base: const Money(1000),
          vatPct: 0,
          vat: Money.zero,
          total: const Money(1000),
          paymentMethodId: pay.id,
          paymentStatus: PaymentStatus.paid,
        ),
      ),
      throwsA(isA<PeriodLockedException>()),
    );
  });

  test('reopenMonth needs a reason and a closed month', () async {
    await fill(10, 1, 31);
    await expectLater(repo.reopenMonth('2026-10', ' '), throwsArgumentError);
    await expectLater(repo.reopenMonth('2026-10', 'x'), throwsStateError);
    await repo.closeMonth('2026-10', today: d(11, 2));
    await expectLater(repo.reopenMonth('2026-10', ''), throwsArgumentError);
    await repo.reopenMonth('2026-10', 'corrección');
    expect(await repo.isClosed('2026-10'), isFalse);
    expect(await repo.watchClosed().first, isEmpty);
    final log = await db.select(db.changeLog).get();
    expect(
      log.any((l) => l.entity == 'periodo' && l.reason == 'corrección'),
      isTrue,
    );
    // It can be closed again: the row is updated, not duplicated.
    await repo.closeMonth('2026-10', today: d(11, 2));
    expect(await db.select(db.periods).get(), hasLength(1));
  });

  test('November with day 3 unregistered is not ready', () async {
    await fill(11, 1, 2);
    await fill(11, 4, 5);
    await expectLater(
      repo.closeMonth('2026-11', today: d(11, 5)),
      throwsA(
        isA<MonthNotReadyException>().having((e) => e.pendingDates, 'dates', [
          d(11, 3),
        ]),
      ),
    );
    expect(await repo.isClosed('2026-11'), isFalse);
  });

  test('open days are pending; counting starts at first recorded', () async {
    await days.openDay(d(10, 20));
    await fill(10, 21, 31);
    await expectLater(
      repo.closeMonth('2026-10', today: d(11, 2)),
      throwsA(
        isA<MonthNotReadyException>().having((e) => e.pendingDates, 'dates', [
          d(10, 20),
        ]),
      ),
    );
    await days.markNoActivity(d(10, 20));
    await repo.closeMonth('2026-10', today: d(11, 2));
    expect(await repo.isClosed('2026-10'), isTrue);
  });

  test('month before first recorded day closes; future month throws', () async {
    await days.markNoActivity(d(11, 1));
    await repo.closeMonth('2026-09', today: d(11, 2));
    expect(await repo.isClosed('2026-09'), isTrue);
    await expectLater(
      repo.closeMonth('2026-12', today: d(11, 2)),
      throwsArgumentError,
    );
  });
}
