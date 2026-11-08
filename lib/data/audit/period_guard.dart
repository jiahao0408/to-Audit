import '../../domain/dates.dart';
import '../../domain/enums.dart';
import '../db/app_database.dart';

/// Thrown when a write targets a closed day or a closed month.
class PeriodLockedException implements Exception {
  const PeriodLockedException({required this.kind, required this.key});

  /// `'day'` or `'month'`.
  final String kind;

  /// `YYYY-MM-DD` for a day, `YYYY-MM` for a month.
  final String key;

  @override
  String toString() => 'PeriodLockedException($kind $key is closed)';
}

/// Rejects writes that fall in closed days or closed months.
class PeriodGuard {
  PeriodGuard(this._db);

  final AppDatabase _db;

  Future<void> ensureMonthOpen(DateTime date) async {
    final key = monthKey(date);
    final row = await (_db.select(
      _db.periods,
    )..where((p) => p.month.equals(key))).getSingleOrNull();
    if (row != null && row.status == PeriodStatus.closed) {
      throw PeriodLockedException(kind: 'month', key: key);
    }
  }

  Future<void> ensureDayOpen(DateTime date) async {
    await ensureMonthOpen(date);
    final key = ymd(date);
    final row = await (_db.select(
      _db.days,
    )..where((d) => d.date.equals(key))).getSingleOrNull();
    if (row != null &&
        (row.status == DayStatus.closed ||
            row.status == DayStatus.noActivity)) {
      throw PeriodLockedException(kind: 'day', key: key);
    }
  }
}
