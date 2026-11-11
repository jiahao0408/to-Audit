import 'dart:io';
import 'dart:typed_data';


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/providers.dart';
import 'package:to_audit/data/repositories/expenses_repository.dart';
import 'package:to_audit/data/reports/report_service.dart';
import 'package:to_audit/domain/enums.dart';
import 'package:to_audit/features/common/platform_services.dart';
import 'package:to_audit/data/security/key_store.dart';
import 'package:to_audit/domain/dates.dart';
import 'package:to_audit/domain/money.dart';
import 'package:to_audit/domain/pnl_calc.dart';
import 'package:to_audit/features/reports/reports_screen.dart';
import 'package:to_audit/l10n/app_localizations.dart';

import '../../support/app_harness.dart';

/// Fake ReportService returns a fixed [ReportData] built from the T14 scenario:
/// sales 2700 €, profit 450 €, pending fixed 200 €.
class _FakeReportService extends Fake implements ReportService {
  _FakeReportService();

  final List<DateRange> asked = [];
  List<ExpenseRecord> expenses = const [];

  @override
  Future<ReportData> build(DateRange range) async {
    asked.add(range);
    final pnl = computePnl(
      PnlInputs(
        range: range,
        sales: const Money(270000), // 2700 €
        purchases: const Money(30000), // 300 €
        fixedCosts: const Money(100000), // 1000 €
        otherExpenses: const Money(5000), // 50 €
        pendingFixed: const Money(20000), // 200 €
        vatPaid: const Money(0),
        covers: 90,
        payroll: [PayrollMonth('2026-11', const Money(90000))],
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
      expenses: expenses,
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

class FakeSharer implements FileSharer {
  final List<String> shared = [];
  final List<String?> mimes = [];
  final List<String> saved = [];

  @override
  Future<bool> shareFile(File file, {String? mimeType}) async {
    expect(file.existsSync(), isTrue, reason: 'file exists while sharing');
    shared.add(file.uri.pathSegments.last);
    mimes.add(mimeType);
    return true;
  }

  @override
  Future<void> savePdf(Uint8List bytes, String filename) async =>
      saved.add(filename);
}

/// Matches Text widgets that display [text], ignoring non-breaking spaces.
Finder money(String text) => find.byWidgetPredicate(
  (w) => w is Text && (w.data ?? '').replaceAll(' ', ' ') == text,
);

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Pumps until the export spinner is gone (real file IO needs real time).
Future<void> settleExport(WidgetTester tester) async {
  for (var i = 0; i < 200; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) return;
  }
}

void main() {
  late _FakeReportService fakeReports;
  late FakeSharer sharer;
  late int pdfCalls;
  late Directory tempRoot;
  late AppDatabase db;

  setUp(() {
    fakeReports = _FakeReportService();
    sharer = FakeSharer();
    pdfCalls = 0;
    tempRoot = Directory.systemTemp.createTempSync('reports_test');
    db = AppDatabase.memory();
  });

  tearDown(() async {
    await db.close();
    tempRoot.deleteSync(recursive: true);
  });

  Future<void> pumpReports(WidgetTester tester, {String locale = 'es'}) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [GoRoute(path: '/', builder: (_, _) => const ReportsScreen())],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...appOverrides(
            db: db,
            keyStore: MemoryKeyStore(),
            biometrics: FakeBiometricAuth(),
            clock: () => DateTime(2026, 11, 9, 10),
            documents: Directory.systemTemp,
          ),
          reportServiceProvider.overrideWithValue(fakeReports),
          fileSharerProvider.overrideWithValue(sharer),
          tempRootProvider.overrideWithValue(tempRoot),
          pdfReportBuilderProvider.overrideWithValue(({
            required data,
            required restaurant,
            required locale,
            required generatedAt,
            required labels,
          }) async {
            pdfCalls++;
            expect(generatedAt, DateTime(2026, 11, 9, 10));
            return Uint8List.fromList([1, 2, 3]);
          }),
          localeProvider.overrideWith((_) => Stream.value(locale)),
        ],
        child: MaterialApp.router(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await settle(tester);
  }

  testWidgets('shows 450,00 € profit and 200,00 € pending fixed', (
    tester,
  ) async {
    await pumpReports(tester);
    // The summary card should be visible.
    expect(find.text('Ventas totales'), findsOneWidget);
    expect(find.text('Beneficio'), findsOneWidget);
    expect(money('450,00 €'), findsOneWidget);
    expect(find.text('Fijos pendientes de confirmar'), findsOneWidget);
    expect(money('200,00 €'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('period selector defaults to "Este mes" and switches', (
    tester,
  ) async {
    await pumpReports(tester);
    expect(find.text('Este mes'), findsOneWidget);

    // Tap "Mes anterior".
    await tester.tap(find.text('Mes anterior'));
    await settle(tester);
    // Should request a different range (previous month).
    expect(fakeReports.asked.length, greaterThanOrEqualTo(2));
    final last = fakeReports.asked.last;
    expect(last.start.month, lessThan(11)); // October or earlier
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('export buttons are shown when data is available', (
    tester,
  ) async {
    await pumpReports(tester);
    expect(find.text('PDF'), findsOneWidget);
    expect(find.text('Excel'), findsOneWidget);
    expect(find.text('CSV'), findsOneWidget);
    expect(find.text('Gestor ZIP'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('PDF button builds the report and shares a pdf file', (
    tester,
  ) async {
    await pumpReports(tester);
    await tester.tap(find.text('PDF'));
    await settleExport(tester);
    expect(pdfCalls, 1);
    expect(sharer.shared, ['informe-2026-11-09.pdf']);
    expect(sharer.mimes, ['application/pdf']);
    // The temp file is removed once sharing returned.
    expect(tempRoot.listSync(), isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Guardar PDF saves through the system dialog', (tester) async {
    await pumpReports(tester);
    await tester.tap(find.text('Guardar PDF'));
    await settleExport(tester);
    expect(pdfCalls, 1);
    expect(sharer.saved, ['informe-2026-11-09.pdf']);
    expect(sharer.shared, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Excel and CSV are written and shared', (tester) async {
    await pumpReports(tester);
    await tester.tap(find.text('Excel'));
    await settleExport(tester);
    await tester.tap(find.text('CSV'));
    await settleExport(tester);
    expect(sharer.shared, [
      'informe-2026-11-09.xlsx',
      'informe-2026-11-09.zip',
    ]);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('Gestor ZIP warns with the count of missing receipts', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final now = nowIso();
      final category = (await db.select(db.expenseCategories).get()).first.id;
      await db
          .into(db.expenses)
          .insert(
            ExpensesCompanion.insert(
              id: 'e1',
              createdAt: now,
              updatedAt: now,
              date: '2026-11-03',
              categoryId: category,
              baseCents: 1000,
              totalCents: 1210,
              paymentStatus: PaymentStatus.paid,
              origin: ExpenseOrigin.manual,
            ),
          );
      await db
          .into(db.receipts)
          .insert(
            ReceiptsCompanion.insert(
              id: 'r1',
              createdAt: now,
              updatedAt: now,
              expenseId: 'e1',
              relativePath: 'receipts/missing.jpg',
              kind: ReceiptKind.photo,
              sizeBytes: 10,
            ),
          );
    });
    fakeReports.expenses = [
      ExpenseRecord(
        id: 'e1',
        date: DateTime.utc(2026, 11, 3),
        supplierId: null,
        categoryId: 'x',
        invoiceNumber: null,
        base: const Money(1000),
        vatPct: 21,
        vat: const Money(210),
        total: const Money(1210),
        paymentMethodId: null,
        paidInCashDayId: null,
        paymentStatus: PaymentStatus.paid,
        dueDate: null,
        origin: ExpenseOrigin.manual,
        fixedCostId: null,
        fixedStatus: null,
        voided: false,
        voidReason: null,
        receiptCount: 1,
      ),
    ];
    await pumpReports(tester);
    await tester.tap(find.text('Gestor ZIP'));
    await settleExport(tester);
    expect(
      find.text('Advertencia: 1 justificante no encontrado'),
      findsOneWidget,
    );
    expect(sharer.shared, ['gestor-2026-11-09.zip']);
    expect(tempRoot.listSync(), isEmpty);
    await tester.pumpWidget(const SizedBox());
  });
}
