import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:to_audit/data/audit/audit_writer.dart';
import 'package:to_audit/data/audit/period_guard.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/files/receipt_store.dart';
import 'package:to_audit/data/repositories/days_repository.dart';
import 'package:to_audit/data/repositories/expenses_repository.dart';
import 'package:to_audit/data/repositories/settings_repository.dart';
import 'package:to_audit/data/repositories/withdrawals_repository.dart';
import 'package:to_audit/data/security/key_store.dart';
import 'package:to_audit/domain/enums.dart';
import 'package:to_audit/domain/money.dart';
import 'package:to_audit/features/day_close/day_close_screen.dart';
import 'package:to_audit/l10n/app_localizations.dart';

import '../../support/app_harness.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

String es(Money m) => m.format('es');

void main() {
  late AppDatabase db;
  late GoRouter router;
  late DaysRepository days;
  late WithdrawalsRepository withdrawals;
  late ExpensesRepository expenses;
  final day = DateTime.utc(2026, 11, 5);

  setUp(() {
    db = AppDatabase.memory();
    final audit = AuditWriter(db);
    final guard = PeriodGuard(db);
    days = DaysRepository(
      db,
      audit: audit,
      guard: guard,
      settings: SettingsRepository(db, audit),
    );
    withdrawals = WithdrawalsRepository(db, audit: audit, guard: guard);
    expenses = ExpensesRepository(
      db,
      audit: audit,
      guard: guard,
      receipts: ReceiptStore(Directory.systemTemp),
    );
  });
  tearDown(() => db.close());

  Future<String> method(String code) async => (await (db.select(
    db.paymentMethods,
  )..where((m) => m.code.equals(code))).getSingle()).id;

  /// The figures of the Task 3 scenario: expected cash 517,10 EUR.
  Future<void> seedScenario(WidgetTester tester, {Money? counted}) =>
      tester.runAsync(() async {
        final cash = await method('cash');
        final card = await method('card');
        final record = await days.openDay(day);
        await days.saveDraft(
          record.id,
          DayDraft(
            openingFloat: const Money(20000),
            countedCash: counted,
            terminalTotal: const Money(150000),
            cashTips: const Money(1200),
            sales: [
              SaleLine(
                paymentMethodId: cash,
                shift: Shift.lunch,
                amount: const Money(50000),
              ),
              SaleLine(
                paymentMethodId: cash,
                shift: Shift.dinner,
                amount: const Money(35040),
              ),
              SaleLine(
                paymentMethodId: card,
                shift: Shift.lunch,
                amount: const Money(150000),
              ),
            ],
          ),
        );
        final bank = await (db.select(
          db.withdrawalTypes,
        )..where((t) => t.code.equals('bank_deposit'))).getSingle();
        await withdrawals.add(
          dayId: record.id,
          amount: const Money(50000),
          typeId: bank.id,
        );
        final category = await (db.select(
          db.expenseCategories,
        )..where((c) => c.code.equals('groceries'))).getSingle();
        final split = VatCalc.fromTotal(const Money(4530), 10);
        await expenses.create(
          ExpenseInput(
            date: day,
            categoryId: category.id,
            base: split.base,
            vatPct: 10,
            vat: split.vat,
            total: const Money(4530),
            paymentMethodId: cash,
            paidInCashDayId: record.id,
            paymentStatus: PaymentStatus.paid,
          ),
        );
      });

  Future<void> pumpDay(
    WidgetTester tester, {
    String ymdText = '2026-11-05',
  }) async {
    tester.view.physicalSize = const Size(800, 5000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    router = GoRouter(
      initialLocation: '/day/$ymdText',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('home page')),
        ),
        GoRoute(
          path: '/day/:ymd',
          builder: (context, state) {
            final text = state.pathParameters['ymd']!;
            return DayCloseScreen(key: ValueKey(text), ymd: text);
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: appOverrides(
          db: db,
          keyStore: MemoryKeyStore(),
          biometrics: FakeBiometricAuth(),
          clock: () => DateTime(2026, 11, 9, 10),
          documents: Directory.systemTemp,
        ),
        child: MaterialApp.router(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> disposeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  }

  String location() => router.routerDelegate.currentConfiguration.uri.path;

  FilledButton closeButton(WidgetTester tester) => tester.widget<FilledButton>(
    find.byKey(const ValueKey('close-day-button')),
  );

  testWidgets(
    'a 1 cent shortfall shows -0,01 EUR and Falta and needs a comment',
    (tester) async {
      await seedScenario(tester);
      await pumpDay(tester);

      // Expected cash is 517,10 EUR.
      expect(find.text(es(const Money(51710))), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('counted-total')),
        '517,09',
      );
      await settle(tester);

      expect(find.text(es(const Money(-1))), findsOneWidget);
      expect(find.text('Falta'), findsOneWidget);
      expect(closeButton(tester).onPressed, isNull);

      await tester.enterText(
        find.byKey(const ValueKey('day-comment')),
        'Falta un céntimo',
      );
      await settle(tester);
      expect(closeButton(tester).onPressed, isNotNull);

      await tester.tap(find.byKey(const ValueKey('close-day-button')));
      await settle(tester);

      final stored = await tester.runAsync(() => days.getDay(day));
      expect(stored!.status, DayStatus.closed);
      expect(stored.cashDiff, const Money(-1));
      expect(stored.draft.comment, 'Falta un céntimo');
      expect(location(), '/day/2026-11-06');
      await disposeApp(tester);
    },
  );

  testWidgets('a balanced day closes without a comment and opens the next', (
    tester,
  ) async {
    await seedScenario(tester, counted: const Money(51710));
    await pumpDay(tester);

    expect(find.text('Cuadrado'), findsNWidgets(2));
    expect(closeButton(tester).onPressed, isNotNull);

    await tester.tap(find.byKey(const ValueKey('close-day-button')));
    await settle(tester);

    final stored = await tester.runAsync(() => days.getDay(day));
    expect(stored!.status, DayStatus.closed);
    expect(location(), '/day/2026-11-06');
    await disposeApp(tester);
  });

  testWidgets('closing the last pending day goes home with a message', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final record = await days.openDay(DateTime.utc(2026, 11, 9));
      await days.saveDraft(
        record.id,
        const DayDraft(
          openingFloat: Money.zero,
          countedCash: Money.zero,
          terminalTotal: Money.zero,
        ),
      );
    });
    await pumpDay(tester, ymdText: '2026-11-09');

    await tester.tap(find.byKey(const ValueKey('close-day-button')));
    await settle(tester);

    expect(location(), '/');
    expect(find.text('Día cerrado. No quedan días pendientes'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('1.234,56 in an amount shows the form error', (tester) async {
    await pumpDay(tester);
    final cash = await tester.runAsync(() => method('cash'));

    await tester.enterText(
      find.byKey(ValueKey('sale-$cash-lunch')),
      '1.234,56',
    );
    await tester.pump();

    expect(find.text('Importe no válido'), findsOneWidget);

    // The invalid amount also stops the close.
    await tester.enterText(find.byKey(const ValueKey('counted-total')), '0');
    await tester.enterText(find.byKey(const ValueKey('terminal-total')), '0');
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('close-day-button')));
    await settle(tester);
    expect(find.text('Revisa los importes marcados'), findsOneWidget);
    final stored = await tester.runAsync(() => days.getDay(day));
    expect(stored!.status, DayStatus.open);
    await disposeApp(tester);
  });

  testWidgets('3 x 50 EUR and 2 x 20 EUR count 190,00 EUR', (tester) async {
    await pumpDay(tester);

    await tester.tap(find.text('Billetes y monedas'));
    await settle(tester);
    await tester.enterText(find.byKey(const ValueKey('denom-5000')), '3');
    await tester.enterText(find.byKey(const ValueKey('denom-2000')), '2');
    await settle(tester);

    expect(
      tester.widget<Text>(find.byKey(const ValueKey('denom-total'))).data,
      es(const Money(19000)),
    );
    final stored = await tester.runAsync(() => days.getDay(day));
    expect(stored!.draft.countedCash, const Money(19000));
    expect(stored.draft.denominationCounts, {5000: 3, 2000: 2});
    await disposeApp(tester);
  });

  testWidgets('a quick withdrawal lowers the expected cash', (tester) async {
    await seedScenario(tester, counted: const Money(51710));
    await pumpDay(tester);

    await tester.tap(find.byKey(const ValueKey('add-withdrawal')));
    await settle(tester);
    await tester.enterText(
      find.byKey(const ValueKey('withdrawal-amount')),
      '10',
    );
    await tester.tap(find.byKey(const ValueKey('withdrawal-type')));
    await settle(tester);
    await tester.tap(find.text('Cambio').last);
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('withdrawal-save')));
    await settle(tester);

    // Expected cash fell by 10,00 EUR, so the cash discrepancy is +10,00.
    expect(find.text(es(const Money(50710))), findsOneWidget);
    expect(find.text('+${es(const Money(1000))}'), findsOneWidget);
    expect(find.text('Sobra'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('a quick cash expense splits the VAT and counts as cash out', (
    tester,
  ) async {
    await seedScenario(tester, counted: const Money(51710));
    await pumpDay(tester);

    await tester.tap(find.byKey(const ValueKey('add-cash-expense')));
    await settle(tester);
    await tester.enterText(find.byKey(const ValueKey('expense-amount')), '11');
    await tester.tap(find.byKey(const ValueKey('expense-category')));
    await settle(tester);
    await tester.tap(find.text('Bebidas').last);
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('expense-save')));
    await settle(tester);

    final saved = await tester.runAsync(
      () => (db.select(
        db.expenses,
      )..where((e) => e.totalCents.equals(1100))).getSingle(),
    );
    expect(saved!.baseCents, 1000);
    expect(saved.vatCents, 100);
    expect(saved.vatPct, 10);
    expect(saved.paymentStatus, PaymentStatus.paid);
    expect(saved.date, '2026-11-05');
    // Expected cash 517,10 - 11,00.
    expect(find.text(es(const Money(50610))), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('a closed day is read only and offers Reabrir', (tester) async {
    await seedScenario(tester, counted: const Money(51710));
    await tester.runAsync(() async {
      final record = (await days.getDay(day))!;
      await days.closeDay(record.id);
    });
    await pumpDay(tester);

    expect(find.text('Día cerrado'), findsOneWidget);
    expect(find.text('Reabrir'), findsOneWidget);
    expect(find.byKey(const ValueKey('close-day-button')), findsNothing);
    expect(find.byType(TextFormField), findsNothing);
    await disposeApp(tester);
  });
}
