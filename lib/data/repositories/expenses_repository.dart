// Named constructor parameters cannot be private, hence the initializer list.
// ignore_for_file: prefer_initializing_formals

import 'dart:io';

import 'package:drift/drift.dart';

import '../../domain/alerts_calc.dart';
import '../../domain/dates.dart';
import '../../domain/enums.dart';
import '../../domain/money.dart';
import '../audit/audit_writer.dart';
import '../audit/period_guard.dart';
import '../db/app_database.dart';
import '../files/receipt_store.dart';

/// The user-editable fields of an expense (invoice or cash purchase).
class ExpenseInput {
  const ExpenseInput({
    required this.date,
    required this.categoryId,
    required this.base,
    required this.vatPct,
    required this.vat,
    required this.total,
    required this.paymentMethodId,
    required this.paymentStatus,
    this.supplierId,
    this.invoiceNumber,
    this.paidInCashDayId,
    this.dueDate,
  });

  final DateTime date;
  final String? supplierId;
  final String categoryId;
  final String? invoiceNumber;
  final Money base;
  final int vatPct;
  final Money vat;
  final Money total;
  final String paymentMethodId;

  /// The cash day whose till paid this expense, if it was paid in cash.
  final String? paidInCashDayId;
  final PaymentStatus paymentStatus;
  final DateTime? dueDate;
}

class ExpenseRecord {
  const ExpenseRecord({
    required this.id,
    required this.date,
    required this.supplierId,
    required this.categoryId,
    required this.invoiceNumber,
    required this.base,
    required this.vatPct,
    required this.vat,
    required this.total,
    required this.paymentMethodId,
    required this.paidInCashDayId,
    required this.paymentStatus,
    required this.dueDate,
    required this.origin,
    required this.fixedCostId,
    required this.fixedStatus,
    required this.voided,
    required this.voidReason,
    required this.receiptCount,
  });

  final String id;
  final DateTime date;
  final String? supplierId;
  final String categoryId;
  final String? invoiceNumber;
  final Money base;
  final int vatPct;
  final Money vat;
  final Money total;
  final String? paymentMethodId;
  final String? paidInCashDayId;
  final PaymentStatus paymentStatus;
  final DateTime? dueDate;
  final ExpenseOrigin origin;
  final String? fixedCostId;
  final FixedStatus? fixedStatus;
  final bool voided;
  final String? voidReason;
  final int receiptCount;

  /// An expense without any receipt attached.
  bool get incomplete => receiptCount == 0;
}

/// Expenses (invoices and cash purchases) and their receipts.
class ExpensesRepository {
  ExpensesRepository(
    this._db, {
    required AuditWriter audit,
    required PeriodGuard guard,
    required ReceiptStore receipts,
  }) : _audit = audit,
       _guard = guard,
       _store = receipts;

  final AppDatabase _db;
  final AuditWriter _audit;
  final PeriodGuard _guard;
  final ReceiptStore _store;

  static const _entity = 'gasto';
  static const _receiptEntity = 'justificante';
  static const _vatRates = {0, 4, 10, 21};

  // ---------------------------------------------------------------- reads

  static final OrderingTerm _rowOrder = OrderingTerm.asc(
    const CustomExpression<int>('gasto.rowid'),
  );

  Expression<int> get _receiptCount => _db.receipts.id.count();

  Stream<List<ExpenseRecord>> watchRange(DateRange r) => _watch(
    where: _db.expenses.date.isBetweenValues(ymd(r.start), ymd(r.end)),
    order: [
      OrderingTerm.asc(_db.expenses.date),
      OrderingTerm.asc(_db.expenses.createdAt),
      _rowOrder,
    ],
  );

  /// One expense with its receipt count, or null when there is none.
  Future<ExpenseRecord?> byId(String id) async {
    final rows = await _query(where: _db.expenses.id.equals(id)).get();
    return rows.isEmpty ? null : _rows(rows).single;
  }

  /// Unpaid, non-voided expenses by due date; those without one come last.
  Stream<List<ExpenseRecord>> watchPending() => _watch(
    where:
        _db.expenses.voided.equals(false) &
        _db.expenses.paymentStatus.equals(PaymentStatus.pending.name),
    order: [
      OrderingTerm.asc(_db.expenses.dueDate.isNull()),
      OrderingTerm.asc(_db.expenses.dueDate),
      OrderingTerm.asc(_db.expenses.date),
      OrderingTerm.asc(_db.expenses.createdAt),
      _rowOrder,
    ],
  );

  JoinedSelectStatement<HasResultSet, dynamic> _query({
    Expression<bool>? where,
    List<OrderingTerm> order = const [],
  }) {
    final query = _db.select(_db.expenses).join([
      leftOuterJoin(
        _db.receipts,
        _db.receipts.expenseId.equalsExp(_db.expenses.id),
      ),
    ]);
    if (where != null) query.where(where);
    query
      ..addColumns([_receiptCount])
      ..groupBy([_db.expenses.id])
      ..orderBy(order);
    return query;
  }

  Stream<List<ExpenseRecord>> _watch({
    required Expression<bool> where,
    required List<OrderingTerm> order,
  }) => _query(where: where, order: order).watch().map(_rows);

  List<ExpenseRecord> _rows(List<TypedResult> rows) => [
    for (final r in rows)
      _record(r.readTable(_db.expenses), r.read(_receiptCount)!),
  ];

  static ExpenseRecord _record(ExpenseData e, int receiptCount) =>
      ExpenseRecord(
        id: e.id,
        date: parseYmd(e.date),
        supplierId: e.supplierId,
        categoryId: e.categoryId,
        invoiceNumber: e.invoiceNumber,
        base: Money(e.baseCents),
        vatPct: e.vatPct,
        vat: Money(e.vatCents),
        total: Money(e.totalCents),
        paymentMethodId: e.paymentMethodId,
        paidInCashDayId: e.paidInCashDayId,
        paymentStatus: e.paymentStatus,
        dueDate: e.dueDate == null ? null : parseYmd(e.dueDate!),
        origin: e.origin,
        fixedCostId: e.fixedCostId,
        fixedStatus: e.fixedStatus,
        voided: e.voided,
        voidReason: e.voidReason,
        receiptCount: receiptCount,
      );

  /// Non-voided totals per supplier id (no supplier: key `''`).
  Future<Map<String, Money>> totalsBySupplier(DateRange r) =>
      _totals(r, (e) => e.supplierId ?? '');

  /// Non-voided totals per category id.
  Future<Map<String, Money>> totalsByCategory(DateRange r) =>
      _totals(r, (e) => e.categoryId);

  Future<Map<String, Money>> _totals(
    DateRange r,
    String Function(ExpenseData) key,
  ) async {
    final rows =
        await (_db.select(_db.expenses)..where(
              (e) =>
                  e.date.isBetweenValues(ymd(r.start), ymd(r.end)) &
                  e.voided.equals(false),
            ))
            .get();
    final totals = <String, Money>{};
    for (final e in rows) {
      final k = key(e);
      totals[k] = (totals[k] ?? Money.zero) + Money(e.totalCents);
    }
    return totals;
  }

  /// Every expense in the shape the alert rules need.
  Future<List<ExpenseSnapshot>> snapshots() async {
    final rows = await _query().get();
    return [
      for (final r in rows)
        () {
          final e = r.readTable(_db.expenses);
          return ExpenseSnapshot(
            id: e.id,
            voided: e.voided,
            receiptCount: r.read(_receiptCount)!,
            paymentStatus: e.paymentStatus,
            dueDate: e.dueDate == null ? null : parseYmd(e.dueDate!),
            planned:
                e.origin == ExpenseOrigin.fixed &&
                e.fixedStatus != FixedStatus.confirmed,
          );
        }(),
    ];
  }

  Future<List<ReceiptData>> receipts(String expenseId) =>
      (_db.select(_db.receipts)
            ..where((x) => x.expenseId.equals(expenseId))
            ..orderBy([
              (x) => OrderingTerm.asc(x.createdAt),
              (_) => OrderingTerm.asc(
                const CustomExpression<int>('justificante.rowid'),
              ),
            ]))
          .get();

  // ------------------------------------------------------------ mutations

  Future<ExpenseData> _row(String id) async {
    final row = await (_db.select(
      _db.expenses,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
    if (row == null) throw ArgumentError.value(id, 'id', 'unknown expense');
    return row;
  }

  /// Throws [PeriodLockedException] when [date]'s month or the cash day
  /// [cashDayId] is closed.
  Future<void> _ensureOpen(DateTime date, String? cashDayId) async {
    await _guard.ensureMonthOpen(date);
    if (cashDayId == null) return;
    final day = await (_db.select(
      _db.days,
    )..where((d) => d.id.equals(cashDayId))).getSingleOrNull();
    if (day == null) {
      throw ArgumentError.value(cashDayId, 'paidInCashDayId', 'unknown day');
    }
    await _guard.ensureDayOpen(parseYmd(day.date));
  }

  static void _checkAmounts(ExpenseInput i) {
    if (!_vatRates.contains(i.vatPct)) {
      throw ArgumentError.value(i.vatPct, 'vatPct', 'must be 0, 4, 10 or 21');
    }
    if (i.base.cents < 0 || i.vat.cents < 0) {
      throw ArgumentError('base and vat must not be negative');
    }
    if (i.base + i.vat != i.total) {
      throw ArgumentError.value(i.total, 'total', 'must equal base + vat');
    }
    if (i.total.cents <= 0) {
      throw ArgumentError.value(i.total, 'total', 'must be greater than zero');
    }
  }

  static void _require(bool exists, String name, String value) {
    if (!exists) throw ArgumentError.value(value, name, 'unknown $name');
  }

  /// Amounts plus references (category, payment method, supplier, cash day).
  Future<void> _validate(ExpenseInput i) async {
    _checkAmounts(i);
    _require(
      await (_db.select(
            _db.expenseCategories,
          )..where((t) => t.id.equals(i.categoryId))).getSingleOrNull() !=
          null,
      'categoryId',
      i.categoryId,
    );
    _require(
      await (_db.select(
            _db.paymentMethods,
          )..where((t) => t.id.equals(i.paymentMethodId))).getSingleOrNull() !=
          null,
      'paymentMethodId',
      i.paymentMethodId,
    );
    final supplier = i.supplierId;
    if (supplier != null) {
      _require(
        await (_db.select(
              _db.suppliers,
            )..where((t) => t.id.equals(supplier))).getSingleOrNull() !=
            null,
        'supplierId',
        supplier,
      );
    }
    final day = i.paidInCashDayId;
    if (day != null) {
      _require(
        await (_db.select(
              _db.days,
            )..where((t) => t.id.equals(day))).getSingleOrNull() !=
            null,
        'paidInCashDayId',
        day,
      );
    }
  }

  static Map<String, Object?> _inputValues(ExpenseInput i) => {
    'date': ymd(i.date),
    'supplierId': i.supplierId,
    'categoryId': i.categoryId,
    'invoiceNumber': i.invoiceNumber,
    'baseCents': i.base.cents,
    'vatPct': i.vatPct,
    'vatCents': i.vat.cents,
    'totalCents': i.total.cents,
    'paymentMethodId': i.paymentMethodId,
    'paidInCashDayId': i.paidInCashDayId,
    'paymentStatus': i.paymentStatus,
    'dueDate': i.dueDate == null ? null : ymd(i.dueDate!),
  };

  static Map<String, Object?> _rowValues(ExpenseData e) => {
    'date': e.date,
    'supplierId': e.supplierId,
    'categoryId': e.categoryId,
    'invoiceNumber': e.invoiceNumber,
    'baseCents': e.baseCents,
    'vatPct': e.vatPct,
    'vatCents': e.vatCents,
    'totalCents': e.totalCents,
    'paymentMethodId': e.paymentMethodId,
    'paidInCashDayId': e.paidInCashDayId,
    'paymentStatus': e.paymentStatus,
    'dueDate': e.dueDate,
  };

  /// A manual expense (origin `manual`, no fixed cost).
  Future<String> create(ExpenseInput input) =>
      _db.transaction(() => _insert(input, origin: ExpenseOrigin.manual));

  /// A planned expense generated from a fixed cost (origin `fixed`).
  Future<String> createFromFixed(
    ExpenseInput input, {
    required String fixedCostId,
  }) => _db.transaction(
    () => _insert(
      input,
      origin: ExpenseOrigin.fixed,
      fixedCostId: fixedCostId,
      fixedStatus: FixedStatus.planned,
    ),
  );

  /// Confirms a planned fixed expense with the amount actually charged: the
  /// base and VAT are recomputed from [actualTotal] at the row's VAT rate.
  Future<void> confirmFixed(String expenseId, Money actualTotal) =>
      _db.transaction(() async {
        final row = await _row(expenseId);
        if (row.origin != ExpenseOrigin.fixed) {
          throw StateError('Expense $expenseId is not a fixed expense');
        }
        if (row.voided) throw StateError('Expense $expenseId is voided');
        if (actualTotal.cents <= 0) {
          throw ArgumentError.value(
            actualTotal,
            'actualTotal',
            'must be greater than zero',
          );
        }
        await _ensureOpen(parseYmd(row.date), row.paidInCashDayId);
        final split = VatCalc.fromTotal(actualTotal, row.vatPct);
        await (_db.update(
          _db.expenses,
        )..where((e) => e.id.equals(expenseId))).write(
          ExpensesCompanion(
            baseCents: Value(split.base.cents),
            vatCents: Value(split.vat.cents),
            totalCents: Value(actualTotal.cents),
            fixedStatus: const Value(FixedStatus.confirmed),
            updatedAt: Value(nowIso()),
          ),
        );
        await _audit.updated(
          _entity,
          expenseId,
          {
            'baseCents': row.baseCents,
            'vatCents': row.vatCents,
            'totalCents': row.totalCents,
            'fixedStatus': row.fixedStatus,
          },
          {
            'baseCents': split.base.cents,
            'vatCents': split.vat.cents,
            'totalCents': actualTotal.cents,
            'fixedStatus': FixedStatus.confirmed,
          },
        );
      });

  /// Validates, checks the locks, inserts and audits one expense. Must run
  /// inside a transaction; shared by every creation path.
  Future<String> _insert(
    ExpenseInput input, {
    required ExpenseOrigin origin,
    String? fixedCostId,
    FixedStatus? fixedStatus,
  }) async {
    await _validate(input);
    await _ensureOpen(input.date, input.paidInCashDayId);
    final id = newId();
    final now = nowIso();
    await _db
        .into(_db.expenses)
        .insert(
          ExpensesCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            date: ymd(input.date),
            supplierId: Value(input.supplierId),
            categoryId: input.categoryId,
            invoiceNumber: Value(input.invoiceNumber),
            baseCents: input.base.cents,
            vatPct: Value(input.vatPct),
            vatCents: Value(input.vat.cents),
            totalCents: input.total.cents,
            paymentMethodId: Value(input.paymentMethodId),
            paidInCashDayId: Value(input.paidInCashDayId),
            paymentStatus: input.paymentStatus,
            dueDate: Value(input.dueDate == null ? null : ymd(input.dueDate!)),
            origin: origin,
            fixedCostId: Value(fixedCostId),
            fixedStatus: Value(fixedStatus),
          ),
        );
    await _audit.inserted(_entity, id, {
      ..._inputValues(input),
      'origin': origin,
      'fixedCostId': fixedCostId,
      'fixedStatus': fixedStatus,
    });
    return id;
  }

  Future<void> update(String id, ExpenseInput input) =>
      _db.transaction(() async {
        final row = await _row(id);
        await _ensureOpen(parseYmd(row.date), row.paidInCashDayId);
        if (row.voided) throw StateError('Expense $id is voided');
        await _validate(input);
        await _ensureOpen(input.date, input.paidInCashDayId);
        await (_db.update(_db.expenses)..where((e) => e.id.equals(id))).write(
          ExpensesCompanion(
            date: Value(ymd(input.date)),
            supplierId: Value(input.supplierId),
            categoryId: Value(input.categoryId),
            invoiceNumber: Value(input.invoiceNumber),
            baseCents: Value(input.base.cents),
            vatPct: Value(input.vatPct),
            vatCents: Value(input.vat.cents),
            totalCents: Value(input.total.cents),
            paymentMethodId: Value(input.paymentMethodId),
            paidInCashDayId: Value(input.paidInCashDayId),
            paymentStatus: Value(input.paymentStatus),
            dueDate: Value(input.dueDate == null ? null : ymd(input.dueDate!)),
            updatedAt: Value(nowIso()),
          ),
        );
        await _audit.updated(_entity, id, _rowValues(row), _inputValues(input));
      });

  Future<void> voidRecord(String id, String reason) async {
    final why = reason.trim();
    if (why.isEmpty) {
      throw ArgumentError.value(reason, 'reason', 'must not be blank');
    }
    return _db.transaction(() async {
      final row = await _row(id);
      await _ensureOpen(parseYmd(row.date), row.paidInCashDayId);
      if (row.voided) throw StateError('Expense $id is already voided');
      await (_db.update(_db.expenses)..where((e) => e.id.equals(id))).write(
        ExpensesCompanion(
          voided: const Value(true),
          voidReason: Value(why),
          updatedAt: Value(nowIso()),
        ),
      );
      await _audit.event(
        _entity,
        id,
        'voided',
        oldValue: false,
        newValue: true,
        reason: why,
      );
    });
  }

  Future<void> markPaid(String id, bool paid) => _db.transaction(() async {
    final row = await _row(id);
    await _ensureOpen(parseYmd(row.date), row.paidInCashDayId);
    if (row.voided) throw StateError('Expense $id is voided');
    final status = paid ? PaymentStatus.paid : PaymentStatus.pending;
    await (_db.update(_db.expenses)..where((e) => e.id.equals(id))).write(
      ExpensesCompanion(
        paymentStatus: Value(status),
        updatedAt: Value(nowIso()),
      ),
    );
    await _audit.updated(
      _entity,
      id,
      {'paymentStatus': row.paymentStatus},
      {'paymentStatus': status},
    );
  });

  /// Stores [source] in private storage and links it to the expense. The file
  /// is removed again if the database write fails.
  Future<void> attachReceipt(
    String expenseId,
    File source,
    ReceiptKind kind,
  ) async {
    final relative = await _store.save(source, kind);
    try {
      await _db.transaction(() async {
        final row = await _row(expenseId);
        await _ensureOpen(parseYmd(row.date), row.paidInCashDayId);
        if (row.voided) throw StateError('Expense $expenseId is voided');
        final size = await _store.fileFor(relative).length();
        final id = newId();
        final now = nowIso();
        await _db
            .into(_db.receipts)
            .insert(
              ReceiptsCompanion.insert(
                id: id,
                createdAt: now,
                updatedAt: now,
                expenseId: expenseId,
                relativePath: relative,
                kind: kind,
                sizeBytes: size,
              ),
            );
        await _audit.inserted(_receiptEntity, id, {
          'expenseId': expenseId,
          'relativePath': relative,
          'kind': kind,
          'sizeBytes': size,
        });
      });
    } catch (_) {
      final file = _store.fileFor(relative);
      if (await file.exists()) await file.delete();
      rethrow;
    }
  }
}
