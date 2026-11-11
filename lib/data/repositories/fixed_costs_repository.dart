// Named constructor parameters cannot be private, hence the initializer list.
// ignore_for_file: prefer_initializing_formals

import 'package:drift/drift.dart';

import '../../domain/dates.dart';
import '../../domain/enums.dart';
import '../../domain/money.dart';
import '../audit/audit_writer.dart';
import '../audit/period_guard.dart';
import '../db/app_database.dart';
import 'expenses_repository.dart';

/// The user-editable fields of a recurring bill.
class FixedCostInput {
  const FixedCostInput({
    required this.concept,
    required this.categoryId,
    required this.plannedAmount,
    required this.vatPct,
    required this.periodicity,
    required this.chargeDay,
    required this.startMonth,
  });

  final String concept;
  final String categoryId;

  /// The expected total (VAT included) of each charge.
  final Money plannedAmount;
  final int vatPct;
  final Periodicity periodicity;

  /// Day of the month the bill is charged, 1-31 (clamped to the month end).
  final int chargeDay;

  /// First month of the bill, `YYYY-MM`.
  final String startMonth;
}

class FixedCostRecord {
  const FixedCostRecord({
    required this.id,
    required this.concept,
    required this.categoryId,
    required this.plannedAmount,
    required this.vatPct,
    required this.periodicity,
    required this.chargeDay,
    required this.startMonth,
    required this.active,
  });

  final String id;
  final String concept;
  final String categoryId;
  final Money plannedAmount;
  final int vatPct;
  final Periodicity periodicity;
  final int chargeDay;
  final String startMonth;
  final bool active;
}

/// Recurring bills, generated as planned expenses and confirmed later with the
/// amount actually charged.
class FixedCostsRepository {
  FixedCostsRepository(
    this._db, {
    required AuditWriter audit,
    required PeriodGuard guard,
    required ExpensesRepository expenses,
  }) : _audit = audit,
       _expenses = expenses;

  final AppDatabase _db;
  final AuditWriter _audit;
  final ExpensesRepository _expenses;

  static const _entity = 'gasto_fijo';
  static const _vatRates = {0, 4, 10, 21};
  static final RegExp _monthPattern = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$');

  Stream<List<FixedCostRecord>> watchAll() =>
      (_db.select(_db.fixedCosts)..orderBy([
            (t) => OrderingTerm.asc(t.concept),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
          .watch()
          .map((rows) => [for (final r in rows) _record(r)]);

  static FixedCostRecord _record(FixedCostData r) => FixedCostRecord(
    id: r.id,
    concept: r.concept,
    categoryId: r.categoryId,
    plannedAmount: Money(r.plannedAmountCents),
    vatPct: r.vatPct,
    periodicity: r.periodicity,
    chargeDay: r.chargeDay,
    startMonth: r.startMonth,
    active: r.active,
  );

  Future<void> _validate(FixedCostInput i) async {
    if (i.concept.trim().isEmpty) {
      throw ArgumentError.value(i.concept, 'concept', 'must not be blank');
    }
    if (i.chargeDay < 1 || i.chargeDay > 31) {
      throw ArgumentError.value(i.chargeDay, 'chargeDay', 'must be 1-31');
    }
    if (i.plannedAmount.cents <= 0) {
      throw ArgumentError.value(
        i.plannedAmount,
        'plannedAmount',
        'must be greater than zero',
      );
    }
    if (!_vatRates.contains(i.vatPct)) {
      throw ArgumentError.value(i.vatPct, 'vatPct', 'must be 0, 4, 10 or 21');
    }
    if (!_monthPattern.hasMatch(i.startMonth)) {
      throw ArgumentError.value(i.startMonth, 'startMonth', 'expected YYYY-MM');
    }
    final cat = await (_db.select(
      _db.expenseCategories,
    )..where((t) => t.id.equals(i.categoryId))).getSingleOrNull();
    if (cat == null) {
      throw ArgumentError.value(i.categoryId, 'categoryId', 'unknown category');
    }
  }

  static Map<String, Object?> _inputValues(FixedCostInput i) => {
    'concept': i.concept.trim(),
    'categoryId': i.categoryId,
    'plannedAmountCents': i.plannedAmount.cents,
    'vatPct': i.vatPct,
    'periodicity': i.periodicity,
    'chargeDay': i.chargeDay,
    'startMonth': i.startMonth,
  };

  static Map<String, Object?> _rowValues(FixedCostData r) => {
    'concept': r.concept,
    'categoryId': r.categoryId,
    'plannedAmountCents': r.plannedAmountCents,
    'vatPct': r.vatPct,
    'periodicity': r.periodicity,
    'chargeDay': r.chargeDay,
    'startMonth': r.startMonth,
  };

  Future<String> create(FixedCostInput input) => _db.transaction(() async {
    await _validate(input);
    final id = newId();
    final now = nowIso();
    await _db
        .into(_db.fixedCosts)
        .insert(
          FixedCostsCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            concept: input.concept.trim(),
            categoryId: input.categoryId,
            plannedAmountCents: input.plannedAmount.cents,
            vatPct: Value(input.vatPct),
            periodicity: input.periodicity,
            chargeDay: input.chargeDay,
            startMonth: input.startMonth,
          ),
        );
    await _audit.inserted(_entity, id, {
      ..._inputValues(input),
      'active': true,
    });
    return id;
  });

  Future<FixedCostData> _row(String id) async {
    final row = await (_db.select(
      _db.fixedCosts,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) throw ArgumentError.value(id, 'id', 'unknown fixed cost');
    return row;
  }

  Future<void> update(String id, FixedCostInput input) =>
      _db.transaction(() async {
        final row = await _row(id);
        await _validate(input);
        await (_db.update(_db.fixedCosts)..where((t) => t.id.equals(id))).write(
          FixedCostsCompanion(
            concept: Value(input.concept.trim()),
            categoryId: Value(input.categoryId),
            plannedAmountCents: Value(input.plannedAmount.cents),
            vatPct: Value(input.vatPct),
            periodicity: Value(input.periodicity),
            chargeDay: Value(input.chargeDay),
            startMonth: Value(input.startMonth),
            updatedAt: Value(nowIso()),
          ),
        );
        await _audit.updated(_entity, id, _rowValues(row), _inputValues(input));
      });

  Future<void> setActive(String id, bool active) => _db.transaction(() async {
    final row = await _row(id);
    await (_db.update(_db.fixedCosts)..where((t) => t.id.equals(id))).write(
      FixedCostsCompanion(active: Value(active), updatedAt: Value(nowIso())),
    );
    await _audit.updated(
      _entity,
      id,
      {'active': row.active},
      {'active': active},
    );
  });

  static int _monthIndex(String key) =>
      int.parse(key.substring(0, 4)) * 12 + int.parse(key.substring(5, 7)) - 1;

  /// Creates the planned expenses that are due up to [today]'s month and
  /// returns how many were created. A (fixed cost, month) that already has an
  /// expense, voided or not, is never generated again; closed months are
  /// skipped.
  Future<int> generateDue(DateTime today) => _db.transaction(() async {
    final costs = await (_db.select(
      _db.fixedCosts,
    )..where((t) => t.active.equals(true))).get();
    if (costs.isEmpty) return 0;
    final card = await (_db.select(
      _db.paymentMethods,
    )..where((p) => p.code.equals('card'))).getSingleOrNull();
    if (card == null) throw StateError('Payment method "card" is missing');
    final periods = await (_db.select(
      _db.periods,
    )..where((p) => p.status.equals(PeriodStatus.closed.name))).get();
    final closed = {for (final p in periods) p.month};
    final last = _monthIndex(monthKey(today));
    var created = 0;
    for (final fc in costs) {
      final first = _monthIndex(fc.startMonth);
      final split = VatCalc.fromTotal(Money(fc.plannedAmountCents), fc.vatPct);
      for (var idx = first; idx <= last; idx++) {
        if ((idx - first) % fc.periodicity.months != 0) continue;
        final year = idx ~/ 12;
        final month = idx % 12 + 1;
        if (closed.contains(monthKey(DateTime.utc(year, month)))) continue;
        final lastDay = daysInMonth(year, month);
        final date = DateTime.utc(
          year,
          month,
          fc.chargeDay < lastDay ? fc.chargeDay : lastDay,
        );
        // Per (fixed cost, month): editing the charge day, start month or
        // periodicity must not plan a second expense for a month that
        // already has one (voided or not).
        final prefix = monthKey(date);
        final exists =
            await (_db.select(_db.expenses)
                  ..where(
                    (e) =>
                        e.fixedCostId.equals(fc.id) & e.date.like('$prefix-%'),
                  )
                  ..limit(1))
                .getSingleOrNull();
        if (exists != null) continue;
        await _expenses.createFromFixed(
          ExpenseInput(
            date: date,
            categoryId: fc.categoryId,
            base: split.base,
            vatPct: fc.vatPct,
            vat: split.vat,
            total: Money(fc.plannedAmountCents),
            paymentMethodId: card.id,
            paymentStatus: PaymentStatus.pending,
            dueDate: date,
          ),
          fixedCostId: fc.id,
        );
        created++;
      }
    }
    return created;
  });

  /// Confirms a generated expense with the amount actually charged.
  Future<void> confirm(String expenseId, Money actualTotal) =>
      _expenses.confirmFixed(expenseId, actualTotal);
}
