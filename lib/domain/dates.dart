/// Pure-Dart calendar helpers. Calendar dates are `DateTime.utc` at midnight.
library;

/// Returns [d]'s calendar day as UTC midnight.
DateTime dateOnly(DateTime d) => DateTime.utc(d.year, d.month, d.day);

/// `YYYY-MM-DD` (zero-padded).
String ymd(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

/// `YYYY-MM` (zero-padded).
String monthKey(DateTime d) {
  final y = d.year.toString().padLeft(4, '0');
  final m = d.month.toString().padLeft(2, '0');
  return '$y-$m';
}

final RegExp _ymdPattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
final RegExp _monthPattern = RegExp(r'^(\d{4})-(\d{2})$');

/// Parses `YYYY-MM-DD` into UTC midnight. Throws [FormatException] if [s] is
/// malformed or is not a real calendar date.
DateTime parseYmd(String s) {
  final match = _ymdPattern.firstMatch(s);
  if (match == null) {
    throw FormatException('Invalid date (expected YYYY-MM-DD)', s);
  }
  final y = int.parse(match.group(1)!);
  final m = int.parse(match.group(2)!);
  final d = int.parse(match.group(3)!);
  if (m < 1 || m > 12 || d < 1 || d > daysInMonth(y, m)) {
    throw FormatException('Invalid calendar date', s);
  }
  return DateTime.utc(y, m, d);
}

/// Number of days in the given month, leap years included.
int daysInMonth(int year, int month) {
  // Day 0 of the following month is the last day of [month].
  return DateTime.utc(year, month + 1, 0).day;
}

/// An inclusive range of calendar days: both [start] and [end] are included.
class DateRange {
  DateRange(DateTime start, DateTime end)
      : start = dateOnly(start),
        end = dateOnly(end) {
    if (this.end.isBefore(this.start)) {
      throw ArgumentError.value(end, 'end', 'must not be before start');
    }
  }

  final DateTime start;
  final DateTime end;

  /// Number of days in the range, both ends included.
  int get days => end.difference(start).inDays + 1;

  bool contains(DateTime d) {
    final day = dateOnly(d);
    return !day.isBefore(start) && !day.isAfter(end);
  }

  /// Every day from [start] to [end], inclusive.
  Iterable<DateTime> get dates sync* {
    for (var i = 0; i < days; i++) {
      yield DateTime.utc(start.year, start.month, start.day + i);
    }
  }

  @override
  bool operator ==(Object other) =>
      other is DateRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DateRange(${ymd(start)}..${ymd(end)})';
}

/// The single day [now] falls on.
DateRange rangeToday(DateTime now) {
  final day = dateOnly(now);
  return DateRange(day, day);
}

/// The week containing [now], from Monday to Sunday.
DateRange rangeThisWeek(DateTime now) {
  final day = dateOnly(now);
  // DateTime.monday == 1 ... DateTime.sunday == 7.
  final monday = DateTime.utc(day.year, day.month, day.day - (day.weekday - 1));
  final sunday = DateTime.utc(monday.year, monday.month, monday.day + 6);
  return DateRange(monday, sunday);
}

/// The whole calendar month containing [now].
DateRange rangeThisMonth(DateTime now) {
  final day = dateOnly(now);
  return _monthRange(day.year, day.month);
}

/// The calendar month identified by [monthKey] (`YYYY-MM`).
DateRange rangeMonth(String monthKey) {
  final match = _monthPattern.firstMatch(monthKey);
  if (match == null) {
    throw FormatException('Invalid month key (expected YYYY-MM)', monthKey);
  }
  final y = int.parse(match.group(1)!);
  final m = int.parse(match.group(2)!);
  if (m < 1 || m > 12) {
    throw FormatException('Invalid month key', monthKey);
  }
  return _monthRange(y, m);
}

/// An arbitrary inclusive range. Throws [ArgumentError] if [to] is before [from].
DateRange rangeCustom(DateTime from, DateTime to) => DateRange(from, to);

DateRange _monthRange(int year, int month) {
  return DateRange(
    DateTime.utc(year, month, 1),
    DateTime.utc(year, month, daysInMonth(year, month)),
  );
}
