// Named constructor parameters cannot be private, hence the initializer list.
// ignore_for_file: prefer_initializing_formals

import 'package:drift/drift.dart';

import '../../domain/dates.dart';
import '../../domain/money.dart';
import '../audit/audit_writer.dart';
import '../audit/period_guard.dart';
import '../db/app_database.dart';

/// Cash taken out of the till (bank deposit, owner, cash payment, change).
class WithdrawalRecord {
  const WithdrawalRecord({
    required this.id,
    required this.dayId,
    required this.typeId,
    required this.date,
    required this.amount,
    this.note,
    this.voided = false,
    this.voidReason,
  });

  final String id;
  final String dayId;
  final String typeId;

  /// The date of the day the withdrawal belongs to.
  final DateTime date;
  final Money amount;
  final String? note;
  final bool voided;
  final String? voidReason;
}

/// Withdrawals from the till; they feed the day's expected cash.
class WithdrawalsRepository {
  WithdrawalsRepository(
    this._db, {
    required AuditWriter audit,
    required PeriodGuard guard,
  }) : _audit = audit,
       _guard = guard;

  final AppDatabase _db;
  final AuditWriter _audit;
  final PeriodGuard _guard;

  static const _entity = 'retirada';

  // ---------------------------------------------------------------- reads

  /// Withdrawals of one day, oldest first, voided ones included.
  Stream<List<WithdrawalRecord>> watchDay(String dayId) => _watch(
    where: _db.withdrawals.dayId.equals(dayId),
    order: [OrderingTerm.asc(_db.withdrawals.createdAt), _rowOrder],
  );

  /// Withdrawals of the days in [r], by day date then creation, voided ones
  /// included (the UI shows them struck through).
  Stream<List<WithdrawalRecord>> watchRange(DateRange r) => _watch(
    where: _db.days.date.isBetweenValues(ymd(r.start), ymd(r.end)),
    order: [
      OrderingTerm.asc(_db.days.date),
      OrderingTerm.asc(_db.withdrawals.createdAt),
      _rowOrder,
    ],
  );

  /// Insertion order breaks ties between rows created in the same millisecond.
  static final OrderingTerm _rowOrder = OrderingTerm.asc(
    const CustomExpression<int>('retirada.rowid'),
  );

  Stream<List<WithdrawalRecord>> _watch({
    required Expression<bool> where,
    required List<OrderingTerm> order,
  }) {
    final query = _db.select(_db.withdrawals).join([
      innerJoin(_db.days, _db.days.id.equalsExp(_db.withdrawals.dayId)),
    ])..where(where);
    query.orderBy(order);
    return query.watch().map(
      (rows) => [
        for (final r in rows)
          _record(r.readTable(_db.withdrawals), r.readTable(_db.days)),
      ],
    );
  }

  static WithdrawalRecord _record(WithdrawalData w, DayData day) =>
      WithdrawalRecord(
        id: w.id,
        dayId: w.dayId,
        typeId: w.withdrawalTypeId,
        date: parseYmd(day.date),
        amount: Money(w.amountCents),
        note: w.note,
        voided: w.voided,
        voidReason: w.voidReason,
      );

  /// Non-voided totals per type id, over the days whose date is in [r].
  Future<Map<String, Money>> totalsByType(DateRange r) async {
    final rows =
        await (_db.select(_db.withdrawals).join([
              innerJoin(_db.days, _db.days.id.equalsExp(_db.withdrawals.dayId)),
            ])..where(
              _db.days.date.isBetweenValues(ymd(r.start), ymd(r.end)) &
                  _db.withdrawals.voided.equals(false),
            ))
            .get();
    final totals = <String, Money>{};
    for (final row in rows) {
      final w = row.readTable(_db.withdrawals);
      totals[w.withdrawalTypeId] =
          (totals[w.withdrawalTypeId] ?? Money.zero) + Money(w.amountCents);
    }
    return totals;
  }

  // ------------------------------------------------------------ mutations

  Future<DayData> _day(String dayId) async {
    final day = await (_db.select(
      _db.days,
    )..where((d) => d.id.equals(dayId))).getSingleOrNull();
    if (day == null) {
      throw ArgumentError.value(dayId, 'dayId', 'unknown day');
    }
    return day;
  }

  Future<WithdrawalData> _row(String id) async {
    final row = await (_db.select(
      _db.withdrawals,
    )..where((w) => w.id.equals(id))).getSingleOrNull();
    if (row == null) throw ArgumentError.value(id, 'id', 'unknown withdrawal');
    return row;
  }

  Future<void> _checkType(String typeId, {required bool mustBeActive}) async {
    final type = await (_db.select(
      _db.withdrawalTypes,
    )..where((t) => t.id.equals(typeId))).getSingleOrNull();
    if (type == null) {
      throw ArgumentError.value(typeId, 'typeId', 'unknown withdrawal type');
    }
    if (mustBeActive && !type.active) {
      throw ArgumentError.value(
        typeId,
        'typeId',
        'withdrawal type is inactive',
      );
    }
  }

  static void _checkAmount(Money amount) {
    if (amount.cents <= 0) {
      throw ArgumentError.value(amount, 'amount', 'must be greater than zero');
    }
  }

  Future<String> add({
    required String dayId,
    required Money amount,
    required String typeId,
    String? note,
  }) async {
    _checkAmount(amount);
    return _db.transaction(() async {
      final day = await _day(dayId);
      await _guard.ensureDayOpen(parseYmd(day.date));
      await _checkType(typeId, mustBeActive: true);
      final id = newId();
      final now = nowIso();
      await _db
          .into(_db.withdrawals)
          .insert(
            WithdrawalsCompanion.insert(
              id: id,
              createdAt: now,
              updatedAt: now,
              dayId: dayId,
              amountCents: amount.cents,
              withdrawalTypeId: typeId,
              note: Value(note),
            ),
          );
      await _audit.inserted(_entity, id, {
        'dayId': dayId,
        'amountCents': amount.cents,
        'withdrawalTypeId': typeId,
        'note': note,
      });
      return id;
    });
  }

  /// Changes the given fields; a null argument leaves the field as it is.
  Future<void> update(
    String id, {
    Money? amount,
    String? typeId,
    String? note,
  }) async {
    if (amount != null) _checkAmount(amount);
    return _db.transaction(() async {
      final row = await _row(id);
      final day = await _day(row.dayId);
      await _guard.ensureDayOpen(parseYmd(day.date));
      if (row.voided) throw StateError('Withdrawal $id is voided');
      if (typeId != null) {
        await _checkType(typeId, mustBeActive: typeId != row.withdrawalTypeId);
      }
      final before = {
        'amountCents': row.amountCents,
        'withdrawalTypeId': row.withdrawalTypeId,
        'note': row.note,
      };
      final after = {
        'amountCents': amount?.cents ?? row.amountCents,
        'withdrawalTypeId': typeId ?? row.withdrawalTypeId,
        'note': note ?? row.note,
      };
      await (_db.update(_db.withdrawals)..where((w) => w.id.equals(id))).write(
        WithdrawalsCompanion(
          amountCents: Value(after['amountCents']! as int),
          withdrawalTypeId: Value(after['withdrawalTypeId']! as String),
          note: Value(after['note'] as String?),
          updatedAt: Value(nowIso()),
        ),
      );
      await _audit.updated(_entity, id, before, after);
    });
  }

  Future<void> voidRecord(String id, String reason) async {
    final why = reason.trim();
    if (why.isEmpty) {
      throw ArgumentError.value(reason, 'reason', 'must not be blank');
    }
    return _db.transaction(() async {
      final row = await _row(id);
      final day = await _day(row.dayId);
      await _guard.ensureDayOpen(parseYmd(day.date));
      if (row.voided) throw StateError('Withdrawal $id is already voided');
      await (_db.update(_db.withdrawals)..where((w) => w.id.equals(id))).write(
        WithdrawalsCompanion(
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
}
