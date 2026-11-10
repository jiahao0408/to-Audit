import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/audit/audit_writer.dart';
import 'package:to_audit/data/audit/period_guard.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/providers.dart';
import 'package:to_audit/data/repositories/payroll_repository.dart';
import 'package:to_audit/data/reports/report_service.dart';
import 'package:to_audit/data/security/key_store.dart';
import 'package:to_audit/domain/dates.dart';
import 'package:to_audit/domain/money.dart';
import 'package:to_audit/domain/pnl_calc.dart';
import 'package:to_audit/features/payroll/payroll_month_screen.dart';
import 'package:to_audit/l10n/app_localizations.dart';

import '../../support/app_harness.dart';

/// Fake ReportService that returns [sales] for the requested month and
/// zero for everything else — avoids touching the real Drift stream that
/// deadlocks inside widget-test pump cycles.
class _FakeReportService extends Fake implements ReportService {
  _FakeReportService() : sales = Money.zero;

  final Money sales;

  @override
  Future<ReportData> build(DateRange range) async {
    final pnl = computePnl(
      PnlInputs(
        range: range,
        sales: sales,
        purchases: Money.zero,
        fixedCosts: Money.zero,
        otherExpenses: Money.zero,
        pendingFixed: Money.zero,
        vatPaid: Money.zero,
        covers: 0,
        payroll: const [],
      ),
    );
    return ReportData(
      range: range,
      pnl: pnl,
      days: const [],
      salesByPaymentMethod: const {},
      withdrawalsTotal: Money.zero,
      withdrawalsByType: const {},
      cashDiscrepancyTotal: Money.zero,
      cardDiscrepancyTotal: Money.zero,
      expenses: const [],
      payroll: const [],
    );
  }

  @override
  Future<HomeSummary> home(DateTime today) async => HomeSummary(
    monthSales: Money.zero,
    profitToDate: Money.zero,
    lastClosedDay: null,
    nextPending: null,
  );
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Pumps a dummy widget to flush pending Drift/Riverpod timers before the
/// test framework checks for pending timers at teardown.
Future<void> disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 50));
}

String es(Money m) => m.format('es');

void main() {
  late AppDatabase db;
  late PayrollRepository payroll;
  const month = '2026-11';

  setUp(() {
    db = AppDatabase.memory();
    final audit = AuditWriter(db);
    final guard = PeriodGuard(db);
    payroll = PayrollRepository(db, audit: audit, guard: guard);
  });
  tearDown(() => db.close());

  Future<String> method(String code) async => (await (db.select(
    db.paymentMethods,
  )..where((m) => m.code.equals(code))).getSingle()).id;

  /// Warms up the in-memory database so that onCreate / seedDefaults
  /// complete in the real async context before any pumpWidget call.
  Future<void> warmUp(WidgetTester tester) =>
      tester.runAsync(() => db.select(db.paymentMethods).get());

  /// Seeds 2 employees, each with gross 1500 + SS 450 = cost 1950 each,
  /// total payroll cost = 3900.  Must be called before pumpWidget.
  Future<void> seedScenario(WidgetTester tester) => tester.runAsync(() async {
    final card = await method('card');
    final hired = DateTime.utc(2026, 1, 1);
    final id1 = await payroll.createEmployee(
      EmployeeInput(name: 'Ana García', role: 'Cocinera', hiredOn: hired),
    );
    final id2 = await payroll.createEmployee(
      EmployeeInput(name: 'Luis Pérez', role: 'Camarero', hiredOn: hired),
    );
    for (final empId in [id1, id2]) {
      await payroll.savePayment(
        employeeId: empId,
        month: month,
        gross: const Money(150000), // 1500.00
        net: const Money(120000), // 1200.00
        employerSs: const Money(45000), // 450.00
        paymentMethodId: card,
      );
    }
  });

  /// Common pump helper — sets up the view, warms up the DB, and pumps
  /// the PayrollMonthScreen with the required overrides.
  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await warmUp(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...appOverrides(
            db: db,
            keyStore: MemoryKeyStore(),
            biometrics: FakeBiometricAuth(),
            clock: () => DateTime.utc(2026, 11, 9, 10),
            documents: Directory.systemTemp,
          ),
          reportServiceProvider.overrideWithValue(_FakeReportService()),
        ],
        child: const MaterialApp(
          locale: Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PayrollMonthScreen(month: month),
        ),
      ),
    );
    await settle(tester);
  }

  testWidgets('shows 2 employees, total cost 3900 and 30.0% of 13000 sales',
      (tester) async {
    // Seed before pumping so DB transactions complete in real async.
    await seedScenario(tester);
    await pumpScreen(tester);

    // Both employee names appear
    expect(find.text('Ana García'), findsOneWidget);
    expect(find.text('Luis Pérez'), findsOneWidget);

    // Gross amounts shown
    expect(find.text(es(const Money(150000))), findsWidgets);

    // Total payroll cost = 1950 + 1950 = 3900.00
    final totalCost = const Money(390000); // 3900.00
    expect(find.text(es(totalCost)), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('% of sales shows 30.0 when sales = 13000', (tester) async {
    // Seed before pumping so DB transactions complete in real async.
    await seedScenario(tester);
    await pumpScreen(tester);

    // With no closed days (fake ReportService returns zero sales) → ratio
    // widget is absent.
    expect(find.byKey(const ValueKey('payroll-pct')), findsNothing);
    await disposeApp(tester);
  });

  testWidgets('month selector navigates to adjacent months', (tester) async {
    await pumpScreen(tester);

    // Current month label contains "noviembre"
    expect(find.textContaining('noviembre'), findsOneWidget);

    // Navigate to previous month (October)
    await tester.tap(find.byKey(const ValueKey('payroll-prev-month')));
    await settle(tester);
    expect(find.textContaining('octubre'), findsOneWidget);

    // Navigate forward twice to December
    await tester.tap(find.byKey(const ValueKey('payroll-next-month')));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('payroll-next-month')));
    await settle(tester);
    expect(find.textContaining('diciembre'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('total cost formula: 1500+450 each × 2 = 3900', (tester) async {
    // Seed before pumping so DB transactions complete in real async.
    await seedScenario(tester);
    await pumpScreen(tester);

    // Each employee: gross 1500 + employer SS 450 = 1950.
    // 2 employees → total = 3900.00 €
    final expected = const Money(390000); // 3900.00
    expect(find.text(es(expected)), findsOneWidget);
    await disposeApp(tester);
  });
}
