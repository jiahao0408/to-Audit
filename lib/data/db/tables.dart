import 'package:drift/drift.dart';

import '../../domain/enums.dart';

/// Columns shared by every table except [ChangeLog] and [SettingsTable].
mixin CommonColumns on Table {
  TextColumn get id => text()();
  TextColumn get createdAt => text()();
  TextColumn get updatedAt => text()();
  TextColumn get author => text().withDefault(const Constant('owner'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DayData')
class Days extends Table with CommonColumns {
  @override
  String get tableName => 'dia_caja';

  TextColumn get date => text().unique()();
  TextColumn get status => textEnum<DayStatus>()();
  IntColumn get openingFloatCents => integer()();
  IntColumn get countedCashCents => integer().nullable()();
  TextColumn get denominationCounts => text().nullable()();
  IntColumn get terminalTotalCents => integer().nullable()();
  IntColumn get cashTipsCents => integer().withDefault(const Constant(0))();
  IntColumn get cardTipsCents => integer().withDefault(const Constant(0))();
  IntColumn get cashDiffCents => integer().nullable()();
  IntColumn get cardDiffCents => integer().nullable()();
  TextColumn get comment => text().nullable()();
  TextColumn get closedAt => text().nullable()();
}

@DataClassName('PaymentMethodData')
class PaymentMethods extends Table with CommonColumns {
  @override
  String get tableName => 'forma_pago';

  TextColumn get code => text().nullable()();
  TextColumn get name => text()();
  TextColumn get kind => textEnum<PaymentKind>()();
  IntColumn get sortOrder => integer()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

@DataClassName('SaleData')
class Sales extends Table with CommonColumns {
  @override
  String get tableName => 'venta';

  TextColumn get dayId => text().references(Days, #id)();
  TextColumn get shift => textEnum<Shift>()();
  TextColumn get paymentMethodId => text().references(PaymentMethods, #id)();
  IntColumn get amountCents => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {dayId, shift, paymentMethodId},
      ];
}

@DataClassName('CoverData')
class Covers extends Table with CommonColumns {
  @override
  String get tableName => 'comensales';

  TextColumn get dayId => text().references(Days, #id)();
  TextColumn get shift => textEnum<Shift>()();
  IntColumn get count => integer()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {dayId, shift},
      ];
}

@DataClassName('ExpenseCategoryData')
class ExpenseCategories extends Table with CommonColumns {
  @override
  String get tableName => 'categoria_gasto';

  TextColumn get code => text().nullable()();
  TextColumn get name => text()();
  TextColumn get kind => textEnum<CategoryKind>()();
  IntColumn get sortOrder => integer()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

@DataClassName('SupplierData')
class Suppliers extends Table with CommonColumns {
  @override
  String get tableName => 'proveedor';

  TextColumn get name => text()();
  TextColumn get taxId => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get categoryId =>
      text().nullable().references(ExpenseCategories, #id)();
}

@DataClassName('FixedCostData')
class FixedCosts extends Table with CommonColumns {
  @override
  String get tableName => 'gasto_fijo';

  TextColumn get concept => text()();
  TextColumn get categoryId => text().references(ExpenseCategories, #id)();
  IntColumn get plannedAmountCents => integer()();
  IntColumn get vatPct => integer().withDefault(const Constant(0))();
  TextColumn get periodicity => textEnum<Periodicity>()();
  IntColumn get chargeDay => integer()();
  TextColumn get startMonth => text()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

@DataClassName('ExpenseData')
class Expenses extends Table with CommonColumns {
  @override
  String get tableName => 'gasto';

  TextColumn get date => text()();
  TextColumn get supplierId => text().nullable().references(Suppliers, #id)();
  TextColumn get categoryId => text().references(ExpenseCategories, #id)();
  TextColumn get invoiceNumber => text().nullable()();
  IntColumn get baseCents => integer()();
  IntColumn get vatPct => integer().withDefault(const Constant(0))();
  IntColumn get vatCents => integer().withDefault(const Constant(0))();
  IntColumn get totalCents => integer()();
  TextColumn get paymentMethodId =>
      text().nullable().references(PaymentMethods, #id)();
  TextColumn get paidInCashDayId => text().nullable().references(Days, #id)();
  TextColumn get paymentStatus => textEnum<PaymentStatus>()();
  TextColumn get dueDate => text().nullable()();
  TextColumn get origin => textEnum<ExpenseOrigin>()();
  TextColumn get fixedCostId =>
      text().nullable().references(FixedCosts, #id)();
  TextColumn get fixedStatus => textEnum<FixedStatus>().nullable()();
  BoolColumn get voided => boolean().withDefault(const Constant(false))();
  TextColumn get voidReason => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {fixedCostId, date},
      ];
}

@DataClassName('ReceiptData')
class Receipts extends Table with CommonColumns {
  @override
  String get tableName => 'justificante';

  TextColumn get expenseId => text().references(Expenses, #id)();
  TextColumn get relativePath => text()();
  TextColumn get kind => textEnum<ReceiptKind>()();
  IntColumn get sizeBytes => integer()();
}

@DataClassName('EmployeeData')
class Employees extends Table with CommonColumns {
  @override
  String get tableName => 'empleado';

  TextColumn get name => text()();
  TextColumn get position => text().nullable()();
  TextColumn get hireDate => text().nullable()();
  TextColumn get terminationDate => text().nullable()();
}

@DataClassName('PayrollPaymentData')
class PayrollPayments extends Table with CommonColumns {
  @override
  String get tableName => 'pago_nomina';

  TextColumn get employeeId => text().references(Employees, #id)();
  TextColumn get month => text()();
  IntColumn get grossCents => integer()();
  IntColumn get netCents => integer()();
  IntColumn get employerSsCents => integer()();
  TextColumn get paymentMethodId =>
      text().nullable().references(PaymentMethods, #id)();
  BoolColumn get voided => boolean().withDefault(const Constant(false))();
  TextColumn get voidReason => text().nullable()();
}

@DataClassName('WithdrawalTypeData')
class WithdrawalTypes extends Table with CommonColumns {
  @override
  String get tableName => 'tipo_retirada';

  TextColumn get code => text().nullable()();
  TextColumn get name => text()();
  IntColumn get sortOrder => integer()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
}

@DataClassName('WithdrawalData')
class Withdrawals extends Table with CommonColumns {
  @override
  String get tableName => 'retirada';

  TextColumn get dayId => text().references(Days, #id)();
  IntColumn get amountCents => integer()();
  TextColumn get withdrawalTypeId => text().references(WithdrawalTypes, #id)();
  TextColumn get note => text().nullable()();
  BoolColumn get voided => boolean().withDefault(const Constant(false))();
  TextColumn get voidReason => text().nullable()();
}

@DataClassName('PeriodData')
class Periods extends Table with CommonColumns {
  @override
  String get tableName => 'periodo';

  TextColumn get month => text().unique()();
  TextColumn get status => textEnum<PeriodStatus>()();
  TextColumn get closedAt => text().nullable()();
}

@DataClassName('ChangeLogData')
class ChangeLog extends Table {
  @override
  String get tableName => 'historial_cambio';

  TextColumn get id => text()();
  TextColumn get at => text()();
  TextColumn get entity => text()();
  TextColumn get recordId => text()();
  TextColumn get field => text()();
  TextColumn get oldValue => text().nullable()();
  TextColumn get newValue => text().nullable()();
  TextColumn get reason => text().nullable()();
  TextColumn get author => text()();
  TextColumn get prevHash => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SettingData')
class SettingsTable extends Table {
  @override
  String get tableName => 'ajustes';

  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}
