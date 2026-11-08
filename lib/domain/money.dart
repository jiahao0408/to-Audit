import 'package:intl/intl.dart';

/// A monetary amount stored as integer cents. Never use double for money.
class Money implements Comparable<Money> {
  const Money(this.cents);

  static const Money zero = Money(0);

  final int cents;

  Money operator +(Money other) => Money(cents + other.cents);

  Money operator -(Money other) => Money(cents - other.cents);

  Money operator -() => Money(-cents);

  Money abs() => cents < 0 ? Money(-cents) : this;

  bool get isZero => cents == 0;

  bool get isNegative => cents < 0;

  /// Returns `this * numerator / denominator`, rounding half away from zero.
  Money multiplyRatio(int numerator, int denominator) {
    if (denominator == 0) {
      throw ArgumentError.value(denominator, 'denominator', 'must not be 0');
    }
    var n = cents * numerator;
    var d = denominator;
    if (d < 0) {
      n = -n;
      d = -d;
    }
    final absN = n.abs();
    var q = absN ~/ d;
    final r = absN % d;
    if (2 * r >= d) {
      q++;
    }
    return Money(n < 0 ? -q : q);
  }

  static Money sum(Iterable<Money> values) =>
      values.fold(zero, (acc, m) => acc + m);

  /// Parses a user-entered amount such as `12,5`, `12.50` or ` 7 `.
  ///
  /// A single `,` or `.` is the decimal separator (at most 2 decimals).
  /// Thousands separators, negatives, and empty or non-numeric input are
  /// rejected with a [FormatException].
  static Money parse(String input) {
    final s = input.trim();
    final match = _amountPattern.firstMatch(s);
    if (match == null) {
      throw FormatException('Invalid amount', input);
    }
    final whole = match.group(1)!;
    final fraction = (match.group(3) ?? '').padRight(2, '0');
    return Money(int.parse(whole) * 100 + int.parse(fraction));
  }

  static final RegExp _amountPattern = RegExp(r'^(\d+)([.,](\d{1,2}))?$');

  /// Formats the amount with a euro symbol. [locale] is `'es'` or `'zh'`.
  String format(String locale) {
    final String intlLocale;
    switch (locale) {
      case 'es':
        intlLocale = 'es_ES';
      case 'zh':
        intlLocale = 'zh_CN';
      default:
        throw ArgumentError.value(locale, 'locale', 'expected "es" or "zh"');
    }
    return NumberFormat.currency(
      locale: intlLocale,
      symbol: '€',
      decimalDigits: 2,
    ).format(cents / 100);
  }

  @override
  int compareTo(Money other) => cents.compareTo(other.cents);

  @override
  bool operator ==(Object other) => other is Money && other.cents == cents;

  @override
  int get hashCode => cents.hashCode;

  @override
  String toString() => 'Money($cents)';
}

/// Spanish VAT (IVA) helpers. Rates are whole percentages.
class VatCalc {
  const VatCalc._();

  static const Set<int> _rates = {0, 4, 10, 21};

  static void _checkRate(int vatPct) {
    if (!_rates.contains(vatPct)) {
      throw ArgumentError.value(
        vatPct,
        'vatPct',
        'must be one of 0, 4, 10, 21',
      );
    }
  }

  /// Computes VAT and total from a base (net) amount.
  static ({Money vat, Money total}) fromBase(Money base, int vatPct) {
    _checkRate(vatPct);
    final vat = base.multiplyRatio(vatPct, 100);
    return (vat: vat, total: base + vat);
  }

  /// Splits a gross total into base (net) amount and VAT.
  static ({Money base, Money vat}) fromTotal(Money total, int vatPct) {
    _checkRate(vatPct);
    final base = total.multiplyRatio(100, 100 + vatPct);
    return (base: base, vat: total - base);
  }
}
