// Named constructor parameters cannot be private, hence the initializer list.
// ignore_for_file: prefer_initializing_formals

import 'package:drift/drift.dart';

import '../../domain/dates.dart';
import '../../domain/enums.dart';
import '../audit/audit_writer.dart';
import '../db/app_database.dart';

/// Thrown when a month cannot be closed because some of its days are still
/// unregistered or open.
class MonthNotReadyException implements Exception {
  const MonthNotReadyException(this.pendingDates);

  final List<DateTime> pendingDates;

  @override
  String toString() =>
      'MonthNotReadyException(${pendingDates.map(ymd).join(', ')})';
}

/// Month close and reopen. A closed month locks its days, expenses, payroll
/// and withdrawals through `PeriodGuard`.
class PeriodsRepository {
  PeriodsRepository(this._db, {required AuditWriter audit}) : _audit = audit;

  final AppDatabase _db;
  final AuditWriter _audit;

  static const _entity = 'periodo';

  Future<PeriodData?> _row(String monthKey) => (_db.select(
    _db.periods,
  )..where((p) => p.month.equals(monthKey))).getSingleOrNull();

  Future<bool> isClosed(String monthKey) async =>
      (await _row(monthKey))?.status == PeriodStatus.closed;

  /// The keys (`YYYY-MM`) of every closed month.
  Stream<Set<String>> watchClosed() =>
      (_db.select(_db.periods)
            ..where((p) => p.status.equals(PeriodStatus.closed.name)))
          .watch()
          .map((rows) => {for (final p in rows) p.month});

  /// Closes [monthKey]. Every day from the first recorded day (or the month
  /// start, if later) to the month end or [today] (if earlier) must be closed
  /// or marked as no activity; otherwise [MonthNotReadyException] lists the
  /// pending dates.
  Future<void> closeMonth(String monthKey, {required DateTime today}) =>
      _db.transaction(() async {
        final range = rangeMonth(monthKey);
        final now = dateOnly(today);
        if (range.start.isAfter(now)) {
          throw ArgumentError.value(
            monthKey,
            'monthKey',
            'the month has not started yet',
          );
        }
        final row = await _row(monthKey);
        if (row?.status == PeriodStatus.closed) {
          throw StateError('$monthKey is already closed');
        }
        final pending = await _pendingDates(range, now);
        if (pending.isNotEmpty) throw MonthNotReadyException(pending);

        final closedAt = nowIso();
        var id = row?.id;
        if (row == null) {
          id = newId();
          await _db
              .into(_db.periods)
              .insert(
                PeriodsCompanion.insert(
                  id: id,
                  createdAt: closedAt,
                  updatedAt: closedAt,
                  month: monthKey,
                  status: PeriodStatus.closed,
                  closedAt: Value(closedAt),
                ),
              );
        } else {
          await (_db.update(
            _db.periods,
          )..where((p) => p.id.equals(row.id))).write(
            PeriodsCompanion(
              status: const Value(PeriodStatus.closed),
              closedAt: Value(closedAt),
              updatedAt: Value(closedAt),
            ),
          );
        }
        await _audit.event(
          _entity,
          id!,
          'status',
          oldValue: PeriodStatus.open,
          newValue: PeriodStatus.closed,
        );
      });

  Future<List<DateTime>> _pendingDates(DateRange month, DateTime today) async {
    final first =
        await (_db.select(_db.days)
              ..orderBy([(d) => OrderingTerm.asc(d.date)])
              ..limit(1))
            .getSingleOrNull();
    if (first == null) return const [];
    final firstDay = parseYmd(first.date);
    final from = firstDay.isAfter(month.start) ? firstDay : month.start;
    final to = today.isBefore(month.end) ? today : month.end;
    if (to.isBefore(from)) return const [];
    final rows = await (_db.select(
      _db.days,
    )..where((d) => d.date.isBetweenValues(ymd(from), ymd(to)))).get();
    final done = {
      for (final d in rows)
        if (d.status != DayStatus.open) d.date,
    };
    return [
      for (final date in DateRange(from, to).dates)
        if (!done.contains(ymd(date))) date,
    ];
  }

  /// Reopens a closed month; [reason] is required and logged.
  Future<void> reopenMonth(String monthKey, String reason) async {
    final why = reason.trim();
    if (why.isEmpty) {
      throw ArgumentError.value(reason, 'reason', 'must not be blank');
    }
    return _db.transaction(() async {
      final row = await _row(monthKey);
      if (row == null || row.status != PeriodStatus.closed) {
        throw StateError('$monthKey is not closed');
      }
      await (_db.update(_db.periods)..where((p) => p.id.equals(row.id))).write(
        PeriodsCompanion(
          status: const Value(PeriodStatus.open),
          closedAt: const Value(null),
          updatedAt: Value(nowIso()),
        ),
      );
      await _audit.event(
        _entity,
        row.id,
        'status',
        oldValue: PeriodStatus.closed,
        newValue: PeriodStatus.open,
        reason: why,
      );
    });
  }
}
