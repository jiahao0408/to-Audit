import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/audit/audit_writer.dart';
import 'package:to_audit/data/audit/period_guard.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/repositories/payroll_repository.dart';
import 'package:to_audit/data/security/key_store.dart';
import 'package:to_audit/domain/enums.dart';
import 'package:to_audit/features/payroll/payroll_month_screen.dart';
import 'package:to_audit/l10n/app_localizations.dart';

import '../../support/app_harness.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
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

void main() {
  late AppDatabase db;
  late PayrollRepository payroll;
  const month = '2026-11';

  setUp(() {
    db = AppDatabase.memory();
    payroll = PayrollRepository(
      db,
      audit: AuditWriter(db),
      guard: PeriodGuard(db),
    );
  });
  tearDown(() => db.close());

  /// Two active employees and, when [sales] is given, one closed day of
  /// November with that many cents of sales (so the real report service
  /// computes the month's sales).
  Future<List<String>> seed(WidgetTester tester, {int? sales}) async {
    final ids = <String>[];
    await tester.runAsync(() async {
      final hired = DateTime.utc(2026, 1, 1);
      ids.add(
        await payroll.createEmployee(
          EmployeeInput(name: 'Ana García', role: 'Cocinera', hiredOn: hired),
        ),
      );
      ids.add(
        await payroll.createEmployee(
          EmployeeInput(name: 'Luis Pérez', role: 'Camarero', hiredOn: hired),
        ),
      );
      if (sales != null) {
        final now = nowIso();
        final cash = (await db.select(db.paymentMethods).get())
            .firstWhere((m) => m.code == 'cash')
            .id;
        await db
            .into(db.days)
            .insert(
              DaysCompanion.insert(
                id: 'dclosed',
                createdAt: now,
                updatedAt: now,
                date: '2026-11-05',
                status: DayStatus.closed,
                openingFloatCents: 0,
              ),
            );
        await db
            .into(db.sales)
            .insert(
              SalesCompanion.insert(
                id: 's1',
                createdAt: now,
                updatedAt: now,
                dayId: 'dclosed',
                shift: Shift.lunch,
                paymentMethodId: cash,
                amountCents: sales,
              ),
            );
      }
    });
    return ids;
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(() => db.select(db.paymentMethods).get());
    await tester.pumpWidget(
      ProviderScope(
        overrides: appOverrides(
          db: db,
          keyStore: MemoryKeyStore(),
          biometrics: FakeBiometricAuth(),
          clock: () => DateTime.utc(2026, 11, 9, 10),
          documents: Directory.systemTemp,
        ),
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

  /// Types the payment of one employee through the payment sheet.
  Future<void> enterPayment(WidgetTester tester, String employeeId) async {
    await tester.tap(find.byKey(ValueKey('payroll-add-$employeeId')));
    await settle(tester);
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('payroll-field-gross')),
        matching: find.byType(TextFormField),
      ),
      '1500,00',
    );
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('payroll-field-net')),
        matching: find.byType(TextFormField),
      ),
      '1200,00',
    );
    await tester.enterText(
      find.descendant(
        of: find.byKey(const ValueKey('payroll-field-ss')),
        matching: find.byType(TextFormField),
      ),
      '450,00',
    );
    await tester.tap(find.byKey(const ValueKey('payroll-field-method')));
    await settle(tester);
    await tester.tap(find.text('Efectivo').last);
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('payroll-save-payment')));
    await settle(tester);
  }

  testWidgets(
    'two employees paid 1.500,00 + 450,00 SS: total 3.900,00 € and 30,0 % of '
    '13.000,00 € sales',
    (tester) async {
      final ids = await seed(tester, sales: 1300000);
      await pumpScreen(tester);
      expect(find.text('Ana García'), findsOneWidget);
      expect(find.text('Luis Pérez'), findsOneWidget);

      for (final id in ids) {
        await enterPayment(tester, id);
      }

      expect(find.text('3.900,00 €'), findsOneWidget);
      expect(find.text('30,0 %'), findsOneWidget);
      await disposeApp(tester);
    },
  );

  testWidgets('without sales the percentage is a dash', (tester) async {
    final ids = await seed(tester);
    await pumpScreen(tester);
    await enterPayment(tester, ids.first);
    expect(find.text('1.950,00 €'), findsWidgets);
    expect(find.text('—'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('a new employee appears in the list', (tester) async {
    await seed(tester);
    await pumpScreen(tester);
    await tester.runAsync(
      () => payroll.createEmployee(
        EmployeeInput(
          name: 'Marta Ruiz',
          role: 'Sala',
          hiredOn: DateTime.utc(2026, 2, 1),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('payroll-add-employee')));
    await settle(tester);
    // The form is open; closing it must refresh the month.
    await tester.tap(find.byIcon(Icons.close));
    await settle(tester);
    expect(find.text('Marta Ruiz'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('month selector navigates to adjacent months', (tester) async {
    await pumpScreen(tester);
    expect(find.textContaining('noviembre'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('payroll-prev-month')));
    await settle(tester);
    expect(find.textContaining('octubre'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('payroll-next-month')));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('payroll-next-month')));
    await settle(tester);
    expect(find.textContaining('diciembre'), findsOneWidget);
    await disposeApp(tester);
  });
}
