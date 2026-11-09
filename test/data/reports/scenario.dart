import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:to_audit/data/audit/audit_writer.dart';
import 'package:to_audit/data/audit/period_guard.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/files/receipt_store.dart';
import 'package:to_audit/data/reports/alerts_service.dart';
import 'package:to_audit/data/reports/report_service.dart';
import 'package:to_audit/data/repositories/catalog_repository.dart';
import 'package:to_audit/data/repositories/days_repository.dart';
import 'package:to_audit/data/repositories/expenses_repository.dart';
import 'package:to_audit/data/repositories/fixed_costs_repository.dart';
import 'package:to_audit/data/repositories/payroll_repository.dart';
import 'package:to_audit/data/repositories/periods_repository.dart';
import 'package:to_audit/data/repositories/settings_repository.dart';
import 'package:to_audit/data/repositories/suppliers_repository.dart';
import 'package:to_audit/data/repositories/withdrawals_repository.dart';
import 'package:to_audit/domain/enums.dart';
import 'package:to_audit/domain/money.dart';

/// The November 2026 scenario of Task 14, shared with the export tests.
class ReportScenario {
  ReportScenario._(this.db, this.tmp);

  final AppDatabase db;
  final Directory tmp;
  late final DaysRepository days;
  late final ExpensesRepository expenses;
  late final PayrollRepository payroll;
  late final WithdrawalsRepository withdrawals;
  late final CatalogRepository catalog;
  late final FixedCostsRepository fixedCosts;
  late final PeriodsRepository periods;
  late final SettingsRepository settings;
  late final SuppliersRepository suppliers;
  late final ReceiptStore store;
  late final ReportService reports;
  late final AlertsService alerts;
  late final String supplierId;
  late final String meatExpenseId;

  static DateTime d(int day) => DateTime.utc(2026, 11, day);

  static Future<ReportScenario> create() async {
    final s = ReportScenario._(
      AppDatabase.memory(),
      await Directory.systemTemp.createTemp('report_scenario'),
    );
    await s._build();
    return s;
  }

  Future<void> dispose() async {
    await db.close();
    await tmp.delete(recursive: true);
  }

  Future<void> _build() async {
    final audit = AuditWriter(db);
    final guard = PeriodGuard(db);
    settings = SettingsRepository(db, audit);
    store = ReceiptStore(
      tmp,
      compressor: (s, {int maxSide = 1600, int quality = 75}) async => [1],
    );
    days = DaysRepository(db, audit: audit, guard: guard, settings: settings);
    expenses = ExpensesRepository(
      db,
      audit: audit,
      guard: guard,
      receipts: store,
    );
    payroll = PayrollRepository(db, audit: audit, guard: guard);
    withdrawals = WithdrawalsRepository(db, audit: audit, guard: guard);
    catalog = CatalogRepository(db, audit);
    fixedCosts = FixedCostsRepository(
      db,
      audit: audit,
      guard: guard,
      expenses: expenses,
    );
    periods = PeriodsRepository(db, audit: audit);
    suppliers = SuppliersRepository(db, audit: audit);
    reports = ReportService(
      db: db,
      days: days,
      expenses: expenses,
      payroll: payroll,
      withdrawals: withdrawals,
      catalog: catalog,
    );
    alerts = AlertsService(
      days: days,
      expenses: expenses,
      periods: periods,
      settings: settings,
      fixedCosts: fixedCosts,
      clock: () => d(8),
    );

    final pms = await db.select(db.paymentMethods).get();
    final cats = await db.select(db.expenseCategories).get();
    final wts = await (db.select(
      db.withdrawalTypes,
    )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
    String pm(String code) => pms.firstWhere((p) => p.code == code).id;
    String cat(String code) => cats.firstWhere((c) => c.code == code).id;

    supplierId = await suppliers.create(
      const SupplierInput(name: '蔬菜店 / Hnos. García'),
    );

    Future<void> closeDay(
      DateTime date,
      int sales,
      int covers, {
      int withdrawn = 0,
      int cashShort = 0,
    }) async {
      final day = await days.openDay(date);
      if (withdrawn > 0) {
        await withdrawals.add(
          dayId: day.id,
          amount: Money(withdrawn),
          typeId: wts.first.id,
        );
      }
      await days.saveDraft(
        day.id,
        DayDraft(
          openingFloat: day.draft.openingFloat,
          countedCash: Money(
            day.draft.openingFloat.cents - withdrawn - cashShort,
          ),
          terminalTotal: Money(sales),
          comment: 'ok',
          sales: [
            SaleLine(
              paymentMethodId: pm('card'),
              shift: Shift.lunch,
              amount: Money(sales),
            ),
          ],
          covers: {Shift.lunch: covers},
        ),
      );
      await days.closeDay(day.id);
    }

    await closeDay(d(3), 150000, 50, withdrawn: 1000, cashShort: 200);
    await closeDay(d(5), 120000, 40);

    // An open day whose sales must not count.
    final open = await days.openDay(d(7));
    await days.saveDraft(
      open.id,
      DayDraft(
        openingFloat: open.draft.openingFloat,
        sales: [
          SaleLine(
            paymentMethodId: pm('card'),
            shift: Shift.lunch,
            amount: const Money(99999),
          ),
        ],
        covers: const {Shift.lunch: 7},
      ),
    );

    ExpenseInput input(
      DateTime date,
      String categoryId,
      int total, {
      String? supplier,
    }) {
      final split = VatCalc.fromTotal(Money(total), 21);
      return ExpenseInput(
        date: date,
        categoryId: categoryId,
        supplierId: supplier,
        base: split.base,
        vatPct: 21,
        vat: split.vat,
        total: Money(total),
        paymentMethodId: pm('card'),
        paymentStatus: PaymentStatus.paid,
      );
    }

    meatExpenseId = await expenses.create(
      input(d(3), cat('meat'), 30000, supplier: supplierId),
    );
    await expenses.create(input(d(5), cat('cleaning'), 5000));

    final rent = await fixedCosts.create(
      FixedCostInput(
        concept: 'Alquiler',
        categoryId: cat('rent'),
        plannedAmount: const Money(90000),
        vatPct: 21,
        periodicity: Periodicity.monthly,
        chargeDay: 1,
        startMonth: '2026-11',
      ),
    );
    await fixedCosts.create(
      FixedCostInput(
        concept: 'Luz',
        categoryId: cat('utilities'),
        plannedAmount: const Money(20000),
        vatPct: 21,
        periodicity: Periodicity.monthly,
        chargeDay: 2,
        startMonth: '2026-11',
      ),
    );
    await fixedCosts.generateDue(d(8));
    final generated = await db.select(db.expenses).get();
    final rentExpense = generated.firstWhere((e) => e.fixedCostId == rent);
    await fixedCosts.confirm(rentExpense.id, const Money(100000));

    final emp = await payroll.createEmployee(
      EmployeeInput(
        name: 'Ana',
        role: 'Cocina',
        hiredOn: DateTime.utc(2026, 1, 1),
      ),
    );
    await payroll.savePayment(
      employeeId: emp,
      month: '2026-11',
      gross: const Money(70000),
      net: const Money(55000),
      employerSs: const Money(20000),
      paymentMethodId: pm('card'),
    );
  }
}
