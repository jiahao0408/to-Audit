import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:to_audit/data/audit/audit_writer.dart';
import 'package:to_audit/data/audit/period_guard.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/files/receipt_store.dart';
import 'package:to_audit/data/repositories/expenses_repository.dart';
import 'package:to_audit/data/repositories/periods_repository.dart';
import 'package:to_audit/data/repositories/suppliers_repository.dart';
import 'package:to_audit/data/security/key_store.dart';
import 'package:to_audit/domain/dates.dart';
import 'package:to_audit/domain/enums.dart';
import 'package:to_audit/domain/money.dart';
import 'package:to_audit/features/expenses/expense_form_screen.dart';
import 'package:to_audit/features/expenses/expenses_list_screen.dart';
import 'package:to_audit/features/expenses/receipt_picker.dart';
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

/// Hands back the file it was given, without touching a platform channel.
class FakePicker implements ReceiptPicker {
  FakePicker(this.result);

  final PickedReceipt result;
  final List<ReceiptSource> asked = [];

  @override
  Future<PickedReceipt?> pick(ReceiptSource source) async {
    asked.add(source);
    return result;
  }
}

void main() {
  late AppDatabase db;
  late Directory docs;
  late ExpensesRepository expenses;
  late SuppliersRepository suppliers;
  late GoRouter router;

  setUp(() async {
    db = AppDatabase.memory();
    docs = await Directory.systemTemp.createTemp('expense_form_test');
    final audit = AuditWriter(db);
    expenses = ExpensesRepository(
      db,
      audit: audit,
      guard: PeriodGuard(db),
      receipts: ReceiptStore(docs),
    );
    suppliers = SuppliersRepository(db, audit: audit);
  });
  tearDown(() async {
    await db.close();
    await docs.delete(recursive: true);
  });

  Future<String> category(String code) async => (await (db.select(
    db.expenseCategories,
  )..where((c) => c.code.equals(code))).getSingle()).id;

  Future<String> cardMethod() async => (await (db.select(
    db.paymentMethods,
  )..where((m) => m.code.equals('card'))).getSingle()).id;

  Future<String> createExpense(DateTime date, {String cat = 'drinks'}) async {
    final split = VatCalc.fromBase(const Money(1000), 10);
    return expenses.create(
      ExpenseInput(
        date: date,
        categoryId: await category(cat),
        base: const Money(1000),
        vatPct: 10,
        vat: split.vat,
        total: split.total,
        paymentMethodId: await cardMethod(),
        paymentStatus: PaymentStatus.paid,
      ),
    );
  }

  Future<void> pumpApp(
    WidgetTester tester, {
    String initial = '/expenses/new',
    ReceiptPicker? picker,
  }) async {
    tester.view.physicalSize = const Size(800, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    router = GoRouter(
      initialLocation: initial,
      routes: [
        GoRoute(
          path: '/expenses',
          builder: (_, _) => const ExpensesListScreen(),
          routes: [
            GoRoute(path: 'new', builder: (_, _) => const ExpenseFormScreen()),
            GoRoute(
              path: ':id',
              builder: (_, state) =>
                  ExpenseFormScreen(id: state.pathParameters['id']),
            ),
          ],
        ),
        GoRoute(
          path: '/suppliers',
          builder: (_, _) => const Scaffold(body: Text('suppliers page')),
        ),
      ],
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
            documents: docs,
          ),
          if (picker != null) receiptPickerProvider.overrideWithValue(picker),
        ],
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

  Future<void> openAllTab(WidgetTester tester) async {
    await tester.tap(find.text('Todos'));
    await settle(tester);
  }

  Future<void> disposeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  }

  String textOf(WidgetTester tester, String key) => tester
      .widget<TextField>(
        find.descendant(
          of: find.byKey(ValueKey(key)),
          matching: find.byType(TextField),
        ),
      )
      .controller!
      .text;

  Future<void> chooseCategory(WidgetTester tester, String label) async {
    await tester.tap(find.byKey(const ValueKey('expense-category')));
    await settle(tester);
    await tester.tap(find.text(label).last);
    await settle(tester);
  }

  testWidgets('base 100,00 with 21 % VAT gives a total of 121,00 EUR', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.enterText(
      find.byKey(const ValueKey('expense-base')),
      '100,00',
    );
    await tester.tap(find.text('21 %'));
    await settle(tester);

    expect(textOf(tester, 'expense-total'), '121,00');
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('expense-summary-total')),
        matching: find.text(es(const Money(12100))),
      ),
      findsOneWidget,
    );
    await disposeApp(tester);
  });

  testWidgets('total 110,00 with 10 % VAT gives a base of 100,00', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.enterText(
      find.byKey(const ValueKey('expense-total')),
      '110,00',
    );
    await tester.tap(find.text('10 %'));
    await settle(tester);

    expect(textOf(tester, 'expense-base'), '100,00');
    await disposeApp(tester);
  });

  testWidgets('changing the VAT keeps the field edited last', (tester) async {
    await pumpApp(tester);
    await tester.enterText(
      find.byKey(const ValueKey('expense-total')),
      '121,00',
    );
    await tester.tap(find.text('21 %'));
    await settle(tester);
    expect(textOf(tester, 'expense-base'), '100,00');

    await tester.tap(find.text('10 %'));
    await settle(tester);
    // The total stays at 121,00; the base follows.
    expect(textOf(tester, 'expense-total'), '121,00');
    expect(textOf(tester, 'expense-base'), '110,00');
    await disposeApp(tester);
  });

  testWidgets(
    'saving without a receipt works and the list marks it Incompleto',
    (tester) async {
      await pumpApp(tester, initial: '/expenses');
      await openAllTab(tester);

      await tester.tap(find.byKey(const ValueKey('add-expense')));
      await settle(tester);
      await tester.enterText(
        find.byKey(const ValueKey('expense-base')),
        '100,00',
      );
      await chooseCategory(tester, 'Bebidas');
      await tester.tap(find.byKey(const ValueKey('expense-save')));
      await settle(tester);

      final rows = await tester.runAsync(() => db.select(db.expenses).get());
      expect(rows!.single.totalCents, 12100);
      expect(rows.single.date, '2026-11-09');
      expect(find.text('Incompleto'), findsOneWidget);
      expect(find.text(es(const Money(12100))), findsWidgets);
      await disposeApp(tester);
    },
  );

  testWidgets('a receipt picked before saving is attached', (tester) async {
    final pdf = File('${docs.path}/in.pdf')..writeAsBytesSync([1, 2, 3]);
    final picker = FakePicker(PickedReceipt(pdf, ReceiptKind.pdf));
    await pumpApp(tester, initial: '/expenses', picker: picker);
    await openAllTab(tester);

    await tester.tap(find.byKey(const ValueKey('add-expense')));
    await settle(tester);
    await tester.enterText(find.byKey(const ValueKey('expense-base')), '50');
    await chooseCategory(tester, 'Carne');
    await tester.tap(find.byKey(const ValueKey('receipt-pdf')));
    await settle(tester);
    expect(picker.asked, [ReceiptSource.pdf]);
    expect(find.byKey(const ValueKey('expense-receipts')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('expense-save')));
    await settle(tester);

    final saved = await tester.runAsync(
      () => expenses
          .watchRange(
            DateRange(DateTime.utc(2026, 11), DateTime.utc(2026, 11, 30)),
          )
          .first,
    );
    expect(saved!.single.receiptCount, 1);
    expect(find.text('Incompleto'), findsNothing);
    await disposeApp(tester);
  });

  testWidgets('choosing a supplier fills in its default category', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await suppliers.create(
        SupplierInput(
          name: 'Carnes Paco',
          defaultCategoryId: await category('meat'),
        ),
      );
    });
    await pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('expense-supplier-pick')));
    await settle(tester);
    await tester.tap(find.text('Carnes Paco'));
    await settle(tester);

    expect(find.text('Carne'), findsOneWidget);
    expect(find.text('Carnes Paco'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('a quick new supplier is created and chosen', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byKey(const ValueKey('expense-supplier-pick')));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('supplier-new')));
    await settle(tester);
    await tester.enterText(
      find.byKey(const ValueKey('supplier-name')),
      'Pescados Lola',
    );
    await tester.tap(find.byKey(const ValueKey('supplier-save')));
    await settle(tester);

    expect(find.text('Pescados Lola'), findsOneWidget);
    final all = await tester.runAsync(() => suppliers.search('lola'));
    expect(all!.single.name, 'Pescados Lola');
    await disposeApp(tester);
  });

  testWidgets('voiding asks for a reason and the expense is struck through', (
    tester,
  ) async {
    final id = await tester.runAsync(
      () => createExpense(DateTime.utc(2026, 11, 3)),
    );
    await pumpApp(tester, initial: '/expenses');
    await openAllTab(tester);
    await tester.tap(find.byKey(ValueKey('expense-$id')));
    await settle(tester);

    await tester.tap(find.byKey(const ValueKey('expense-void')));
    await settle(tester);
    await tester.enterText(find.byType(TextField).last, 'duplicada');
    await tester.pump();
    await tester.tap(find.text('Aceptar'));
    await settle(tester);

    final row = await tester.runAsync(() => db.select(db.expenses).getSingle());
    expect(row!.voided, isTrue);
    expect(row.voidReason, 'duplicada');
    // Back on the list, struck through.
    final title = tester.widget<Text>(find.text('Bebidas').first);
    expect(title.style?.decoration, TextDecoration.lineThrough);
    expect(find.text('Anulado'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('an expense in a closed month opens read only with a lock', (
    tester,
  ) async {
    final id = await tester.runAsync(() async {
      final id = await createExpense(DateTime.utc(2026, 10, 3));
      await PeriodsRepository(
        db,
        audit: AuditWriter(db),
      ).closeMonth('2026-10', today: DateTime.utc(2026, 11, 9));
      return id;
    });
    await pumpApp(tester, initial: '/expenses/$id');

    expect(find.byKey(const ValueKey('expense-lock')), findsOneWidget);
    expect(find.byKey(const ValueKey('expense-save')), findsNothing);
    expect(find.byKey(const ValueKey('expense-void')), findsNothing);
    expect(textOf(tester, 'expense-total'), '11,00');
    await disposeApp(tester);
  });

  testWidgets('the month tab shows totals by supplier and category', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final paco = await suppliers.create(
        const SupplierInput(name: 'Carnes Paco'),
      );
      final cat = await category('meat');
      final card = await cardMethod();
      for (final total in [1100, 2200]) {
        final split = VatCalc.fromTotal(Money(total), 10);
        await expenses.create(
          ExpenseInput(
            date: DateTime.utc(2026, 11, 2),
            supplierId: paco,
            categoryId: cat,
            base: split.base,
            vatPct: 10,
            vat: split.vat,
            total: Money(total),
            paymentMethodId: card,
            paymentStatus: PaymentStatus.paid,
          ),
        );
      }
    });
    await pumpApp(tester, initial: '/expenses');
    await openAllTab(tester);

    await tester.tap(find.text('Totales por proveedor y categoría'));
    await settle(tester);

    // 33,00 EUR under the supplier and again under the category.
    expect(find.text(es(const Money(3300))), findsNWidgets(2));
    await tester.tap(find.byTooltip('Mes anterior'));
    await settle(tester);
    expect(find.text('No hay gastos'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('editing only the invoice number keeps the stored amounts', (
    tester,
  ) async {
    // Stored base 10,00 + VAT 0,99 = 10,99 at 10 %: fromTotal(10,99) would
    // give base 9,99 / VAT 1,00, so a recompute would drift by a cent.
    late String id;
    await tester.runAsync(() async {
      id = await expenses.create(
        ExpenseInput(
          date: DateTime.utc(2026, 11, 3),
          categoryId: await category('drinks'),
          base: const Money(1000),
          vatPct: 10,
          vat: const Money(99),
          total: const Money(1099),
          paymentMethodId: await cardMethod(),
          paymentStatus: PaymentStatus.paid,
        ),
      );
    });
    await pumpApp(tester, initial: '/expenses/$id');
    await tester.enterText(
      find.byKey(const ValueKey('expense-invoice')),
      'F-9',
    );
    await tester.tap(find.byKey(const ValueKey('expense-save')));
    await settle(tester);

    final row = await tester.runAsync(() => db.select(db.expenses).getSingle());
    expect(row!.invoiceNumber, 'F-9');
    expect(row.baseCents, 1000);
    expect(row.vatCents, 99);
    expect(row.totalCents, 1099);
    await disposeApp(tester);
  });
}
