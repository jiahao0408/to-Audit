import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/providers.dart';
import 'package:to_audit/data/repositories/days_repository.dart';
import 'package:to_audit/domain/dates.dart';
import 'package:to_audit/domain/enums.dart';
import 'package:to_audit/domain/money.dart';
import 'package:to_audit/features/day_close/day_close_controller.dart';

/// Counts how many times the draft is written.
class CountingDays extends DaysRepository {
  CountingDays(
    super.db, {
    required super.audit,
    required super.guard,
    required super.settings,
  });

  int saves = 0;
  int failNext = 0;

  @override
  Future<void> saveDraft(String dayId, DayDraft draft) {
    saves++;
    if (failNext > 0) {
      failNext--;
      return Future.error(StateError('disk'));
    }
    return super.saveDraft(dayId, draft);
  }
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  final date = DateTime.utc(2026, 11, 5);

  setUp(() {
    db = AppDatabase.memory();
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWith(() => DatabaseNotifier(db)),
        documentsDirProvider.overrideWithValue(Directory.systemTemp),
        clockProvider.overrideWithValue(() => DateTime(2026, 11, 9, 10)),
        daysRepositoryProvider.overrideWith(
          (ref) => CountingDays(
            ref.watch(databaseProvider),
            audit: ref.watch(auditWriterProvider),
            guard: ref.watch(periodGuardProvider),
            settings: ref.watch(settingsRepositoryProvider),
          ),
        ),
      ],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<String> methodId(String code) async => (await (db.select(
    db.paymentMethods,
  )..where((m) => m.code.equals(code))).getSingle()).id;

  Future<DayCloseController> load() async {
    container.listen(dayCloseControllerProvider(date), (_, _) {});
    await container.read(dayCloseControllerProvider(date).future);
    return container.read(dayCloseControllerProvider(date).notifier);
  }

  DayCloseState current() =>
      container.read(dayCloseControllerProvider(date)).requireValue;

  Future<void> pause([int ms = 600]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  test('quick changes are grouped into one saveDraft', () async {
    final c = await load();
    final cash = await methodId('cash');
    final days = container.read(daysRepositoryProvider) as CountingDays;

    c.setSale(cash, Shift.lunch, const Money(1000));
    c.setSale(cash, Shift.lunch, const Money(2000));
    c.setCovers(Shift.lunch, 12);
    c.setTips(cash: const Money(300));
    expect(days.saves, 0);
    await pause();

    expect(days.saves, 1);
    final stored = (await days.getDay(date))!;
    expect(stored.draft.sales, [
      SaleLine(
        paymentMethodId: cash,
        shift: Shift.lunch,
        amount: const Money(2000),
      ),
    ]);
    expect(stored.draft.covers, {Shift.lunch: 12});
    expect(stored.draft.cashTips, const Money(300));
    // The summary was recomputed after the save.
    expect(current().summary.cashSales, const Money(2000));
  });

  test(
    'close with a discrepancy and no comment sets commentRequired',
    () async {
      final c = await load();
      final cash = await methodId('cash');
      c.setOpeningFloat(const Money(20000));
      c.setSale(cash, Shift.lunch, const Money(10000));
      // Expected 300,00; counting 299,99 is 1 cent short.
      c.setCountedTotal(const Money(29999));
      c.setTerminalTotal(Money.zero);

      final next = await c.close();

      expect(next, isNull);
      expect(current().error, DayCloseError.commentRequired);
      expect(current().status, DayStatus.open);
    },
  );

  test('close without counted cash sets countedMissing', () async {
    final c = await load();
    c.setTerminalTotal(Money.zero);
    expect(await c.close(), isNull);
    expect(current().error, DayCloseError.countedMissing);
  });

  test('a balanced day closes and returns the next pending date', () async {
    final c = await load();
    final cash = await methodId('cash');
    c.setOpeningFloat(const Money(20000));
    c.setSale(cash, Shift.dinner, const Money(5000));
    c.setCountedTotal(const Money(25000));
    c.setTerminalTotal(Money.zero);

    final next = await c.close();

    expect(next, dateOnly(DateTime(2026, 11, 6)));
    expect(current().status, DayStatus.closed);
    expect(current().error, isNull);
  });

  test('denominations set the counted cash', () async {
    final c = await load();
    c.setDenominations({5000: 3, 2000: 2});
    expect(current().countedCash, const Money(19000));
    expect(current().byDenominations, isTrue);
    await pause();
    final stored = (await container.read(daysRepositoryProvider).getDay(date))!;
    expect(stored.draft.denominationCounts, {5000: 3, 2000: 2});
    expect(stored.draft.countedCash, const Money(19000));
  });

  test('reopen opens a closed day again', () async {
    final c = await load();
    c.setCountedTotal(Money.zero);
    c.setTerminalTotal(Money.zero);
    c.setOpeningFloat(Money.zero);
    await c.close();
    expect(current().status, DayStatus.closed);

    await c.reopen('error de importe');

    expect(current().status, DayStatus.open);
  });

  test('a pending change is saved when the controller is disposed', () async {
    final c = await load();
    final cash = await methodId('cash');
    final days = container.read(daysRepositoryProvider) as CountingDays;
    c.setSale(cash, Shift.lunch, const Money(777));
    container.dispose();
    await pause(200);
    expect(days.saves, 1);
    // A fresh container reads what was saved.
    final stored = (await days.getDay(date))!;
    expect(stored.draft.sales.single.amount, const Money(777));
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWith(() => DatabaseNotifier(db)),
        documentsDirProvider.overrideWithValue(Directory.systemTemp),
      ],
    );
  });

  test('a failed save is retried and close never uses a stale draft', () async {
    final c = await load();
    final days = container.read(daysRepositoryProvider) as CountingDays;
    c.setOpeningFloat(Money.zero);
    c.setCountedTotal(Money.zero);
    c.setTerminalTotal(Money.zero);
    days.failNext = 1;

    expect(await c.close(), isNull);
    expect(current().error, DayCloseError.saveFailed);
    expect(current().status, DayStatus.open);

    // The change stayed pending: the next close flushes it and succeeds.
    expect(await c.close(), isNotNull);
    expect(current().status, DayStatus.closed);
  });

  test('keeps working after the database provider is replaced', () async {
    final c = await load();
    // Two databases at once is the point of this test.
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final other = AppDatabase.memory();
    addTearDown(other.close);
    final cash = (await (other.select(
      other.paymentMethods,
    )..where((m) => m.code.equals('cash'))).getSingle()).id;

    container.read(databaseProvider.notifier).replace(other);
    await container.read(dayCloseControllerProvider(date).future);
    c.setSale(cash, Shift.lunch, const Money(500));
    await pause();

    final stored = await container.read(daysRepositoryProvider).getDay(date);
    expect(stored!.draft.sales.single.amount, const Money(500));
    expect(current().summary.cashSales, const Money(500));
  });
}
