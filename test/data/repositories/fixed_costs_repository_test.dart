import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/audit/audit_writer.dart';
import 'package:to_audit/data/audit/period_guard.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/files/receipt_store.dart';
import 'package:to_audit/data/repositories/expenses_repository.dart';
import 'package:to_audit/data/repositories/fixed_costs_repository.dart';
import 'package:to_audit/domain/enums.dart';
import 'package:to_audit/domain/money.dart';

void main() {
  late AppDatabase db;
  late Directory tmp;
  late ExpensesRepository expenses;
  late FixedCostsRepository repo;
  late String catId;

  DateTime d(int y, int m, int day) => DateTime.utc(y, m, day);

  setUp(() async {
    db = AppDatabase.memory();
    tmp = await Directory.systemTemp.createTemp('fixed_costs_test');
    final audit = AuditWriter(db);
    final guard = PeriodGuard(db);
    expenses = ExpensesRepository(
      db,
      audit: audit,
      guard: guard,
      receipts: ReceiptStore(
        tmp,
        compressor: (s, {int maxSide = 1600, int quality = 75}) async => [1],
      ),
    );
    repo = FixedCostsRepository(
      db,
      audit: audit,
      guard: guard,
      expenses: expenses,
    );
    final cats = await (db.select(
      db.expenseCategories,
    )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
    catId = cats.first.id;
  });
  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  FixedCostInput input({
    String concept = 'Alquiler',
    String? categoryId,
    int planned = 12100,
    int vatPct = 21,
    Periodicity periodicity = Periodicity.monthly,
    int chargeDay = 5,
    String startMonth = '2026-01',
  }) => FixedCostInput(
    concept: concept,
    categoryId: categoryId ?? catId,
    plannedAmount: Money(planned),
    vatPct: vatPct,
    periodicity: periodicity,
    chargeDay: chargeDay,
    startMonth: startMonth,
  );

  Future<List<ExpenseData>> expenseRows() => (db.select(
    db.expenses,
  )..orderBy([(t) => OrderingTerm.asc(t.date)])).get();

  test('quarterly from 2026-09 day 31 generates 09-30 and 12-31', () async {
    await repo.create(
      input(
        periodicity: Periodicity.quarterly,
        chargeDay: 31,
        startMonth: '2026-09',
      ),
    );
    expect(await repo.generateDue(d(2026, 12, 5)), 2);
    final rows = await expenseRows();
    expect(rows.map((e) => e.date), ['2026-09-30', '2026-12-31']);
    for (final e in rows) {
      expect(e.origin, ExpenseOrigin.fixed);
      expect(e.fixedStatus, FixedStatus.planned);
      expect(e.paymentStatus, PaymentStatus.pending);
      expect(e.dueDate, e.date);
      expect(e.baseCents, 10000);
      expect(e.vatCents, 2100);
      expect(e.totalCents, 12100);
      expect(e.fixedCostId, isNotNull);
    }
    final card = await (db.select(
      db.paymentMethods,
    )..where((p) => p.code.equals('card'))).getSingle();
    expect(rows.first.paymentMethodId, card.id);
  });

  test('running generateDue twice does not duplicate', () async {
    await repo.create(input(startMonth: '2026-10'));
    expect(await repo.generateDue(d(2026, 11, 20)), 2);
    expect(await repo.generateDue(d(2026, 11, 20)), 0);
    expect(await expenseRows(), hasLength(2));
  });

  test('a voided generated expense is not regenerated', () async {
    await repo.create(input(startMonth: '2026-11'));
    await repo.generateDue(d(2026, 11, 20));
    final row = (await expenseRows()).single;
    await (db.update(db.expenses)..where((e) => e.id.equals(row.id))).write(
      const ExpensesCompanion(voided: Value(true)),
    );
    expect(await repo.generateDue(d(2026, 11, 20)), 0);
  });

  test('monthly from 2026-02 day 31 gives 2026-02-28', () async {
    await repo.create(input(chargeDay: 31, startMonth: '2026-02'));
    await repo.generateDue(d(2026, 3, 1));
    final rows = await expenseRows();
    expect(rows.map((e) => e.date), ['2026-02-28', '2026-03-31']);
  });

  test('inactive generate nothing; closed months are skipped', () async {
    final id = await repo.create(input(startMonth: '2026-10'));
    await repo.setActive(id, false);
    expect(await repo.generateDue(d(2026, 11, 20)), 0);
    await repo.setActive(id, true);
    final now = nowIso();
    await db
        .into(db.periods)
        .insert(
          PeriodsCompanion.insert(
            id: newId(),
            createdAt: now,
            updatedAt: now,
            month: '2026-10',
            status: PeriodStatus.closed,
          ),
        );
    expect(await repo.generateDue(d(2026, 11, 20)), 1);
    expect((await expenseRows()).single.date, '2026-11-05');
  });

  test('confirm recalculates base and VAT from the actual total', () async {
    await repo.create(input(planned: 5000, startMonth: '2026-11'));
    await repo.generateDue(d(2026, 11, 20));
    final row = (await expenseRows()).single;
    await repo.confirm(row.id, const Money(12100));
    final after = (await expenseRows()).single;
    expect(after.fixedStatus, FixedStatus.confirmed);
    expect(after.baseCents, 10000);
    expect(after.vatCents, 2100);
    expect(after.totalCents, 12100);
    final log = await db.select(db.changeLog).get();
    expect(
      log.where((l) => l.entity == 'gasto' && l.field == 'fixedStatus'),
      isNotEmpty,
    );
  });

  test('confirm rejects manual expenses', () async {
    final pay = await db.select(db.paymentMethods).get();
    final id = await expenses.create(
      ExpenseInput(
        date: d(2026, 11, 1),
        categoryId: catId,
        base: const Money(1000),
        vatPct: 0,
        vat: Money.zero,
        total: const Money(1000),
        paymentMethodId: pay.first.id,
        paymentStatus: PaymentStatus.paid,
      ),
    );
    await expectLater(repo.confirm(id, const Money(500)), throwsStateError);
  });

  test('create audits and validates', () async {
    final id = await repo.create(input());
    final log = await db.select(db.changeLog).get();
    expect(
      log.any((l) => l.entity == 'gasto_fijo' && l.recordId == id),
      isTrue,
    );
    await expectLater(repo.create(input(concept: ' ')), throwsArgumentError);
    await expectLater(repo.create(input(chargeDay: 0)), throwsArgumentError);
    await expectLater(repo.create(input(chargeDay: 32)), throwsArgumentError);
    await expectLater(repo.create(input(planned: 0)), throwsArgumentError);
    await expectLater(repo.create(input(vatPct: 7)), throwsArgumentError);
    await expectLater(
      repo.create(input(startMonth: '2026-13')),
      throwsArgumentError,
    );
    await expectLater(
      repo.create(input(startMonth: '26-1')),
      throwsArgumentError,
    );
    await expectLater(
      repo.create(input(categoryId: 'nope')),
      throwsArgumentError,
    );
  });

  test('update and watchAll', () async {
    final id = await repo.create(input());
    await repo.update(id, input(concept: 'Luz', planned: 9000));
    final all = await repo.watchAll().first;
    expect(all.single.concept, 'Luz');
    expect(all.single.plannedAmount, const Money(9000));
    expect(all.single.active, isTrue);
    await expectLater(repo.update('nope', input()), throwsArgumentError);
  });
}
