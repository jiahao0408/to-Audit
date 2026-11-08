import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums.dart';
import 'tables.dart';

part 'app_database.g.dart';

const _uuid = Uuid();

/// New random uuid v4 string used as primary key.
String newId() => _uuid.v4();

/// Current instant as UTC ISO-8601 text.
String nowIso() => DateTime.now().toUtc().toIso8601String();

@DriftDatabase(
  tables: [
    Days,
    Sales,
    Covers,
    PaymentMethods,
    Suppliers,
    ExpenseCategories,
    Expenses,
    Receipts,
    FixedCosts,
    Employees,
    PayrollPayments,
    Withdrawals,
    WithdrawalTypes,
    Periods,
    ChangeLog,
    SettingsTable,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  factory AppDatabase.memory() => AppDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await seedDefaults();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// Inserts the default catalogs. Only meant to run once, on creation.
  Future<void> seedDefaults() async {
    final now = nowIso();

    const payments = <(String, String, PaymentKind)>[
      ('cash', 'Efectivo', PaymentKind.cash),
      ('card', 'Tarjeta CaixaBank', PaymentKind.card),
      ('bizum', 'Bizum', PaymentKind.other),
      ('vouchers', 'Vales', PaymentKind.other),
      ('glovo', 'Glovo', PaymentKind.other),
      ('justeat', 'Just Eat', PaymentKind.other),
      ('ubereats', 'Uber Eats', PaymentKind.other),
    ];
    const categories = <(String, String, CategoryKind)>[
      ('meat', 'Carne', CategoryKind.purchase),
      ('fish', 'Pescado', CategoryKind.purchase),
      ('vegetables', 'Verdura', CategoryKind.purchase),
      ('drinks', 'Bebidas', CategoryKind.purchase),
      ('groceries', 'Alimentación', CategoryKind.purchase),
      ('cleaning', 'Limpieza', CategoryKind.other),
      ('utilities', 'Suministros', CategoryKind.other),
      ('rent', 'Alquiler', CategoryKind.other),
      ('insurance', 'Seguros', CategoryKind.other),
      ('selfemployed', 'Autónomos', CategoryKind.other),
      ('advisor', 'Gestoría', CategoryKind.other),
      ('other', 'Otros', CategoryKind.other),
    ];
    const withdrawalSeeds = <(String, String)>[
      ('bank_deposit', 'Ingreso en banco'),
      ('owner', 'Retirada del dueño'),
      ('cash_payment', 'Pago en mano'),
      ('change', 'Cambio'),
    ];

    await batch((b) {
      b.insertAll(paymentMethods, [
        for (final (i, p) in payments.indexed)
          PaymentMethodsCompanion.insert(
            id: newId(),
            createdAt: now,
            updatedAt: now,
            code: Value(p.$1),
            name: p.$2,
            kind: p.$3,
            sortOrder: i,
          ),
      ]);
      b.insertAll(expenseCategories, [
        for (final (i, c) in categories.indexed)
          ExpenseCategoriesCompanion.insert(
            id: newId(),
            createdAt: now,
            updatedAt: now,
            code: Value(c.$1),
            name: c.$2,
            kind: c.$3,
            sortOrder: i,
          ),
      ]);
      b.insertAll(withdrawalTypes, [
        for (final (i, t) in withdrawalSeeds.indexed)
          WithdrawalTypesCompanion.insert(
            id: newId(),
            createdAt: now,
            updatedAt: now,
            code: Value(t.$1),
            name: t.$2,
            sortOrder: i,
          ),
      ]);
    });
  }
}
