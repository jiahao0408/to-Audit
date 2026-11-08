import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/domain/dates.dart';
import 'package:to_audit/domain/enums.dart';

void main() {
  group('ymd / parseYmd / monthKey', () {
    test('ymd zero-pads month and day', () {
      expect(ymd(DateTime.utc(2026, 3, 5)), '2026-03-05');
    });

    test('parseYmd round-trips and returns UTC midnight', () {
      final d = parseYmd('2026-03-29');
      expect(ymd(d), '2026-03-29');
      expect(d.isUtc, isTrue);
      expect(d, DateTime.utc(2026, 3, 29));
    });

    test('parseYmd rejects invalid input with FormatException', () {
      expect(() => parseYmd('2026-3-29'), throwsFormatException);
      expect(() => parseYmd('2026-02-30'), throwsFormatException);
      expect(() => parseYmd('hola'), throwsFormatException);
      expect(() => parseYmd(''), throwsFormatException);
    });

    test('monthKey returns YYYY-MM', () {
      expect(monthKey(DateTime.utc(2026, 11, 8)), '2026-11');
      expect(monthKey(DateTime.utc(2026, 1, 1)), '2026-01');
    });

    test('dateOnly drops the time part and keeps the calendar day', () {
      final d = dateOnly(DateTime.utc(2026, 11, 8, 23, 59, 59));
      expect(d, DateTime.utc(2026, 11, 8));
      expect(d.isUtc, isTrue);
    });
  });

  group('daysInMonth', () {
    test('handles leap and non-leap February', () {
      expect(daysInMonth(2028, 2), 29);
      expect(daysInMonth(2026, 2), 28);
      expect(daysInMonth(2000, 2), 29);
      expect(daysInMonth(1900, 2), 28);
    });

    test('handles 30 and 31 day months', () {
      expect(daysInMonth(2026, 4), 30);
      expect(daysInMonth(2026, 12), 31);
    });
  });

  group('DateRange', () {
    test('days is inclusive', () {
      final r = DateRange(
        DateTime.utc(2026, 10, 30),
        DateTime.utc(2026, 11, 2),
      );
      expect(r.days, 4);
    });

    test('single day range has days == 1', () {
      final d = DateTime.utc(2026, 11, 8);
      expect(DateRange(d, d).days, 1);
    });

    test('contains is inclusive on both ends', () {
      final r = DateRange(
        DateTime.utc(2026, 10, 30),
        DateTime.utc(2026, 11, 2),
      );
      expect(r.contains(DateTime.utc(2026, 10, 30)), isTrue);
      expect(r.contains(DateTime.utc(2026, 11, 2)), isTrue);
      expect(r.contains(DateTime.utc(2026, 10, 29)), isFalse);
      expect(r.contains(DateTime.utc(2026, 11, 3)), isFalse);
    });

    test('dates iterates every day inclusive across month boundary', () {
      final r = DateRange(
        DateTime.utc(2026, 10, 30),
        DateTime.utc(2026, 11, 2),
      );
      expect(r.dates.map(ymd).toList(), [
        '2026-10-30',
        '2026-10-31',
        '2026-11-01',
        '2026-11-02',
      ]);
    });

    test('value equality and hashCode', () {
      final a = DateRange(DateTime.utc(2026, 11, 1), DateTime.utc(2026, 11, 7));
      final b = DateRange(DateTime.utc(2026, 11, 1), DateTime.utc(2026, 11, 7));
      final c = DateRange(DateTime.utc(2026, 11, 1), DateTime.utc(2026, 11, 8));
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });

    test('constructor rejects end before start with ArgumentError', () {
      expect(
        () => DateRange(DateTime.utc(2026, 11, 2), DateTime.utc(2026, 10, 30)),
        throwsArgumentError,
      );
    });
  });

  group('rangeToday', () {
    test('normalizes now to a day range', () {
      final r = rangeToday(DateTime.utc(2026, 11, 8, 15, 30));
      expect(r.start, DateTime.utc(2026, 11, 8));
      expect(r.end, DateTime.utc(2026, 11, 8));
    });
  });

  group('rangeThisWeek (lunes a domingo)', () {
    test('domingo 2026-11-08 belongs to the week 11-02..11-08', () {
      expect(DateTime.utc(2026, 11, 8).weekday, DateTime.sunday);
      final r = rangeThisWeek(DateTime.utc(2026, 11, 8));
      expect(ymd(r.start), '2026-11-02');
      expect(ymd(r.end), '2026-11-08');
      expect(r.days, 7);
    });

    test('lunes 2026-11-09 starts the next week 11-09..11-15', () {
      final r = rangeThisWeek(DateTime.utc(2026, 11, 9));
      expect(ymd(r.start), '2026-11-09');
      expect(ymd(r.end), '2026-11-15');
    });

    test('normalizes time part of now', () {
      final r = rangeThisWeek(DateTime.utc(2026, 11, 9, 23, 59));
      expect(ymd(r.start), '2026-11-09');
    });
  });

  group('rangeThisMonth / rangeMonth', () {
    test('rangeThisMonth covers the whole month of now', () {
      final r = rangeThisMonth(DateTime.utc(2026, 2, 10));
      expect(r.days, 28);
      expect(ymd(r.start), '2026-02-01');
      expect(ymd(r.end), '2026-02-28');
    });

    test('rangeMonth parses the key and covers leap February', () {
      expect(rangeMonth('2028-02').days, 29);
      expect(ymd(rangeMonth('2028-02').end), '2028-02-29');
    });

    test('rangeMonth rejects malformed keys with FormatException', () {
      expect(() => rangeMonth('2028-2'), throwsFormatException);
      expect(() => rangeMonth('2028-13'), throwsFormatException);
      expect(() => rangeMonth('28-02'), throwsFormatException);
      expect(() => rangeMonth('2028/02'), throwsFormatException);
    });
  });

  group('rangeCustom', () {
    test('rejects inverted range with ArgumentError', () {
      expect(
        () =>
            rangeCustom(DateTime.utc(2026, 11, 2), DateTime.utc(2026, 10, 30)),
        throwsArgumentError,
      );
    });

    test('dates for 2026-10-30..2026-11-02 yields 4 dates', () {
      final r = rangeCustom(
        DateTime.utc(2026, 10, 30),
        DateTime.utc(2026, 11, 2),
      );
      expect(r.dates.length, 4);
    });
  });

  group('enums', () {
    test('Periodicity.months values', () {
      expect(Periodicity.monthly.months, 1);
      expect(Periodicity.bimonthly.months, 2);
      expect(Periodicity.quarterly.months, 3);
      expect(Periodicity.annual.months, 12);
    });

    test('enums persist by name', () {
      expect(Shift.lunch.name, 'lunch');
      expect(DayStatus.noActivity.name, 'noActivity');
      expect(ReceiptKind.pdf.name, 'pdf');
    });
  });
}
