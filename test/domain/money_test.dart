import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/domain/money.dart';

void main() {
  test('parse accepts comma or dot, up to 2 decimals, trims', () {
    expect(Money.parse('12,5'), const Money(1250));
    expect(Money.parse('12.50'), const Money(1250));
    expect(Money.parse(' 7 '), const Money(700));
    expect(Money.parse('0,05'), const Money(5));
  });

  test('parse rejects thousands, negatives, 3 decimals, empty', () {
    for (final s in ['1.234,56', '-3', '12,345', '', 'abc', '1,2,3']) {
      expect(() => Money.parse(s), throwsFormatException, reason: s);
    }
  });

  test('format es and zh', () {
    // intl may emit a no-break space before the symbol; normalise it.
    String n(String s) => s.replaceAll(' ', ' ').replaceAll(' ', ' ');
    expect(n(const Money(123456).format('es')), '1.234,56 €');
    expect(n(const Money(-1).format('es')), '-0,01 €');
    expect(n(const Money(123456).format('zh')), '€1,234.56');
  });

  test('multiplyRatio rounds half away from zero', () {
    expect(const Money(5).multiplyRatio(1, 2), const Money(3));
    expect(const Money(-5).multiplyRatio(1, 2), const Money(-3));
    expect(const Money(300000).multiplyRatio(15, 30), const Money(150000));
  });

  test('VAT from base and from total', () {
    expect(VatCalc.fromBase(const Money(1000), 10), (
      vat: const Money(100),
      total: const Money(1100),
    ));
    expect(VatCalc.fromBase(const Money(5), 10), (
      vat: const Money(1),
      total: const Money(6),
    ));
    expect(VatCalc.fromTotal(const Money(1210), 21), (
      base: const Money(1000),
      vat: const Money(210),
    ));
    expect(VatCalc.fromTotal(const Money(100), 21), (
      base: const Money(83),
      vat: const Money(17),
    ));
    expect(() => VatCalc.fromBase(const Money(100), 7), throwsArgumentError);
  });
}
