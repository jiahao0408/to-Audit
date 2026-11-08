import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/audit/audit_writer.dart';
import 'package:to_audit/data/audit/period_guard.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/repositories/days_repository.dart';
import 'package:to_audit/data/repositories/settings_repository.dart';
import 'package:to_audit/domain/dates.dart';
import 'package:to_audit/domain/enums.dart';
import 'package:to_audit/domain/money.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository settings;
  late DaysRepository repo;
  late String cashId;
  late String cardId;
  late String bizumId;

  DateTime d(int month, int day) => DateTime.utc(2026, month, day);

  setUp(() async {
    db = AppDatabase.memory();
    final audit = AuditWriter(db);
    settings = SettingsRepository(db, audit);
    repo = DaysRepository(
      db,
      audit: audit,
      guard: PeriodGuard(db),
      settings: settings,
    );
    Future<String> pm(String code) async => (await (db.select(
      db.paymentMethods,
    )..where((p) => p.code.equals(code))).getSingle()).id;
    cashId = await pm('cash');
    cardId = await pm('card');
    bizumId = await pm('bizum');
  });
  tearDown(() => db.close());

  Future<void> addWithdrawal(
    String dayId,
    int cents, {
    bool voided = false,
  }) async {
    final type = await db.select(db.withdrawalTypes).get();
    await db
        .into(db.withdrawals)
        .insert(
          WithdrawalsCompanion.insert(
            id: newId(),
            createdAt: nowIso(),
            updatedAt: nowIso(),
            dayId: dayId,
            amountCents: cents,
            withdrawalTypeId: type.first.id,
            voided: Value(voided),
          ),
        );
  }

  Future<void> addCashExpense(String dayId, int cents) async {
    final cat = await db.select(db.expenseCategories).get();
    await db
        .into(db.expenses)
        .insert(
          ExpensesCompanion.insert(
            id: newId(),
            createdAt: nowIso(),
            updatedAt: nowIso(),
            date: '2026-10-31',
            categoryId: cat.first.id,
            baseCents: cents,
            totalCents: cents,
            paymentStatus: PaymentStatus.paid,
            origin: ExpenseOrigin.manual,
            paidInCashDayId: Value(dayId),
          ),
        );
  }

  DayDraft draft({
    int float = 20000,
    int? counted,
    int? terminal,
    int cashTips = 0,
    String? comment,
    List<SaleLine> sales = const [],
    Map<int, int>? counts,
  }) => DayDraft(
    openingFloat: Money(float),
    countedCash: counted == null ? null : Money(counted),
    terminalTotal: terminal == null ? null : Money(terminal),
    cashTips: Money(cashTips),
    comment: comment,
    sales: sales,
    denominationCounts: counts,
  );

  SaleLine sale(String pm, int cents, [Shift shift = Shift.lunch]) =>
      SaleLine(paymentMethodId: pm, shift: shift, amount: Money(cents));

  /// Opens, fills and closes a clean day with [counted] cash in the till.
  Future<String> closedDay(DateTime date, int counted) async {
    final day = await repo.openDay(date);
    await repo.saveDraft(
      day.id,
      draft(
        float: day.draft.openingFloat.cents,
        counted: counted,
        terminal: 0,
        comment: 'ok',
      ),
    );
    await repo.closeDay(day.id);
    return day.id;
  }

  test('first day uses the initial float', () async {
    await settings.setInitialFloat(const Money(15000));
    final day = await repo.openDay(d(10, 1));
    expect(day.status, DayStatus.open);
    expect(day.draft.openingFloat, const Money(15000));
    expect((await repo.openDay(d(10, 1))).id, day.id);
  });

  test('day after a closed day inherits its counted cash', () async {
    await settings.setInitialFloat(const Money(15000));
    await closedDay(d(10, 1), 33300);
    final next = await repo.openDay(d(10, 2));
    expect(next.draft.openingFloat, const Money(33300));
  });

  test('Task 3 example through the repository', () async {
    final day = await repo.openDay(d(10, 31));
    await addWithdrawal(day.id, 50000);
    await addWithdrawal(day.id, 99999, voided: true);
    await addCashExpense(day.id, 4530);
    await repo.saveDraft(
      day.id,
      draft(
        float: 20000,
        counted: 51709,
        terminal: 30000,
        cashTips: 1200,
        sales: [sale(cashId, 85040), sale(cardId, 30000), sale(bizumId, 700)],
      ),
    );
    final s = await repo.summary(day.id);
    expect(s.cashSales, const Money(85040));
    expect(s.cardSales, const Money(30000));
    expect(s.totalSales, const Money(115740));
    expect(s.cashExpenses, const Money(4530));
    expect(s.withdrawals, const Money(50000));
    expect(s.expected, const Money(51710));
    expect(s.cashDiff, const Money(-1));
    expect(s.cardDiff, Money.zero);
    expect(s.commentRequired, isTrue);

    await expectLater(
      repo.closeDay(day.id),
      throwsA(isA<CommentRequiredException>()),
    );
    expect((await repo.byId(day.id)).status, DayStatus.open);

    await repo.saveDraft(
      day.id,
      draft(
        float: 20000,
        counted: 51709,
        terminal: 30000,
        cashTips: 1200,
        comment: 'un céntimo',
        sales: [sale(cashId, 85040), sale(cardId, 30000), sale(bizumId, 700)],
      ),
    );
    await repo.closeDay(day.id);
    final closed = await repo.byId(day.id);
    expect(closed.status, DayStatus.closed);
    expect(closed.cashDiff, const Money(-1));
    expect(closed.cardDiff, Money.zero);
    expect(closed.closedAt, isNotNull);
    final log = await db.select(db.changeLog).get();
    expect(
      log.where(
        (l) =>
            l.entity == 'dia_caja' &&
            l.recordId == day.id &&
            l.field == 'status' &&
            l.oldValue == 'open' &&
            l.newValue == 'closed',
      ),
      hasLength(1),
    );
  });

  test('closing needs counted cash and terminal total', () async {
    final day = await repo.openDay(d(10, 1));
    await expectLater(
      repo.closeDay(day.id),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('counted cash is not set'),
        ),
      ),
    );
    await repo.saveDraft(day.id, draft(counted: 20000));
    await expectLater(
      repo.closeDay(day.id),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('terminal total is not set'),
        ),
      ),
    );
  });

  test('closing 31 Oct updates an open 1 Nov opening float', () async {
    final oct = await repo.openDay(d(10, 31));
    final nov = await repo.openDay(d(11, 1));
    expect(nov.draft.openingFloat, Money.zero);
    await repo.saveDraft(
      oct.id,
      draft(float: 0, counted: 44400, terminal: 0, comment: 'x'),
    );
    await repo.closeDay(oct.id);
    expect((await repo.byId(nov.id)).draft.openingFloat, const Money(44400));
  });

  test('reclosing a reopened day does not touch a closed next day', () async {
    final first = await closedDay(d(10, 1), 30000);
    final secondId = await closedDay(d(10, 2), 41000);
    await repo.reopenDay(first, 'error al contar');
    final reopened = await repo.byId(first);
    expect(reopened.status, DayStatus.open);
    expect(reopened.closedAt, isNull);
    await repo.saveDraft(
      first,
      draft(counted: 35000, terminal: 0, comment: 'recontado'),
    );
    await repo.closeDay(first);
    final second = await repo.byId(secondId);
    expect(second.draft.openingFloat, const Money(30000));
    expect(second.status, DayStatus.closed);
    final log = await db.select(db.changeLog).get();
    expect(
      log.where((l) => l.field == 'status' && l.reason == 'error al contar'),
      hasLength(1),
    );
  });

  test('reopenDay validates reason and status', () async {
    final id = await closedDay(d(10, 1), 30000);
    await expectLater(() => repo.reopenDay(id, '  '), throwsArgumentError);
    final open = await repo.openDay(d(10, 2));
    await expectLater(repo.reopenDay(open.id, 'x'), throwsStateError);
  });

  test('saveDraft on a closed day throws DayNotOpenException', () async {
    final id = await closedDay(d(10, 1), 30000);
    await expectLater(
      repo.saveDraft(id, draft(counted: 1)),
      throwsA(isA<DayNotOpenException>()),
    );
  });

  test('stored discrepancy survives a threshold change', () async {
    final day = await repo.openDay(d(10, 1));
    await repo.saveDraft(
      day.id,
      draft(counted: 19999, terminal: 0, comment: 'x'),
    );
    await repo.closeDay(day.id);
    await settings.setThreshold(const Money(100));
    expect((await repo.byId(day.id)).cashDiff, const Money(-1));
    expect(
      (await repo.snapshots(DateRange(d(10, 1), d(10, 1)))).single.cashDiff,
      const Money(-1),
    );
  });

  test('summary counts sales of a deactivated payment method', () async {
    final day = await repo.openDay(d(10, 1));
    await repo.saveDraft(
      day.id,
      draft(
        counted: 30000,
        terminal: 0,
        comment: 'x',
        sales: [sale(cashId, 10000)],
      ),
    );
    await repo.closeDay(day.id);
    await (db.update(db.paymentMethods)..where((p) => p.id.equals(cashId)))
        .write(const PaymentMethodsCompanion(active: Value(false)));
    final s = await repo.summary(day.id);
    expect(s.cashSales, const Money(10000));
    expect(s.totalSales, const Money(10000));
  });

  test(
    'markNoActivity creates the day and the next inherits the float',
    () async {
      await closedDay(d(10, 1), 30000);
      await repo.markNoActivity(d(10, 2));
      final skipped = await repo.getDay(d(10, 2));
      expect(skipped!.status, DayStatus.noActivity);
      expect(skipped.draft.openingFloat, const Money(30000));
      expect(skipped.draft.sales, isEmpty);
      expect(skipped.closedAt, isNotNull);
      final next = await repo.openDay(d(10, 3));
      expect(next.draft.openingFloat, const Money(30000));
    },
  );

  test('markNoActivity updates an existing open day and propagates', () async {
    await closedDay(d(10, 1), 30000);
    final two = await repo.openDay(d(10, 2));
    final three = await repo.openDay(d(10, 3));
    await repo.markNoActivity(d(10, 2));
    expect((await repo.byId(two.id)).status, DayStatus.noActivity);
    expect((await repo.byId(three.id)).draft.openingFloat, const Money(30000));
  });

  test('markNoActivity rejects a day with sales', () async {
    final day = await repo.openDay(d(10, 1));
    await repo.saveDraft(day.id, draft(sales: [sale(cashId, 500)]));
    await expectLater(repo.markNoActivity(d(10, 1)), throwsStateError);
  });

  test('markNoActivity rejects a closed day', () async {
    await closedDay(d(10, 1), 30000);
    await expectLater(repo.markNoActivity(d(10, 1)), throwsStateError);
  });

  test('summary of a closed day returns the stored diffs', () async {
    final day = await repo.openDay(d(10, 1));
    await repo.saveDraft(
      day.id,
      draft(counted: 19999, terminal: 0, comment: 'x'),
    );
    await repo.closeDay(day.id);
    // A later change to the data must not alter the closed day's figures.
    await addWithdrawal(day.id, 5000);
    await settings.setThreshold(const Money(100));
    final s = await repo.summary(day.id);
    expect(s.cashDiff, const Money(-1));
    expect(s.cardDiff, Money.zero);
    expect(s.commentRequired, isFalse);
  });

  test('markNoActivity after a reopen clears the stale figures', () async {
    final id = await closedDay(d(10, 1), 12345);
    await repo.reopenDay(id, 'error');
    await repo.markNoActivity(d(10, 1));
    final row = await (db.select(
      db.days,
    )..where((x) => x.id.equals(id))).getSingle();
    expect(row.status, DayStatus.noActivity);
    expect(row.countedCashCents, isNull);
    expect(row.terminalTotalCents, isNull);
    expect(row.cashDiffCents, isNull);
    expect(row.cardDiffCents, isNull);
    expect(row.comment, isNull);
    expect(row.denominationCounts, isNull);
  });

  test('nextPendingDate skips closed days', () async {
    await closedDay(d(10, 1), 30000);
    await closedDay(d(10, 2), 30000);
    expect(
      await repo.nextPendingDate(after: d(9, 30), today: d(10, 4)),
      d(10, 3),
    );
    await repo.markNoActivity(d(10, 3));
    await closedDay(d(10, 4), 30000);
    expect(
      await repo.nextPendingDate(after: d(9, 30), today: d(10, 4)),
      isNull,
    );
  });

  test('denominationCounts must match countedCash', () async {
    final day = await repo.openDay(d(10, 1));
    await expectLater(
      () => repo.saveDraft(
        day.id,
        draft(counted: 1000, counts: {500: 1, 100: 2}),
      ),
      throwsArgumentError,
    );
    await repo.saveDraft(day.id, draft(counted: 700, counts: {500: 1, 100: 2}));
    final saved = await repo.byId(day.id);
    expect(saved.draft.denominationCounts, {500: 1, 100: 2});
    expect(saved.draft.countedCash, const Money(700));
  });

  test('saveDraft upserts sales and covers and audits changes', () async {
    final day = await repo.openDay(d(10, 1));
    await repo.saveDraft(
      day.id,
      DayDraft(
        openingFloat: const Money(20000),
        sales: [sale(cashId, 1000), sale(cashId, 2000, Shift.dinner)],
        covers: const {Shift.lunch: 10, Shift.dinner: 20},
      ),
    );
    await repo.saveDraft(
      day.id,
      DayDraft(
        openingFloat: const Money(20000),
        sales: [sale(cashId, 1500), sale(cashId, 2000, Shift.dinner)],
        covers: const {Shift.lunch: 12, Shift.dinner: 20},
      ),
    );
    final saved = (await repo.byId(day.id)).draft;
    expect(saved.sales, hasLength(2));
    expect(
      saved.sales.firstWhere((s) => s.shift == Shift.lunch).amount,
      const Money(1500),
    );
    expect(saved.covers, {Shift.lunch: 12, Shift.dinner: 20});
    expect(await db.select(db.sales).get(), hasLength(2));
    final log = await db.select(db.changeLog).get();
    expect(
      log.where(
        (l) =>
            l.entity == 'venta' &&
            l.field == 'amountCents' &&
            l.oldValue == '1000' &&
            l.newValue == '1500',
      ),
      hasLength(1),
    );
    expect(
      log.where(
        (l) =>
            l.entity == 'comensales' &&
            l.oldValue == '10' &&
            l.newValue == '12',
      ),
      hasLength(1),
    );
  });

  test('watchRange emits days in range ordered by date', () async {
    await repo.openDay(d(10, 3));
    await repo.openDay(d(10, 1));
    await repo.openDay(d(11, 1));
    final days = await repo.watchRange(DateRange(d(10, 1), d(10, 31))).first;
    expect(days.map((x) => x.date), [d(10, 1), d(10, 3)]);
  });
}
