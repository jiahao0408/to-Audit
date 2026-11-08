import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/domain/cash_calc.dart';
import 'package:to_audit/domain/money.dart';

void main() {
  test('expected cash and 1 cent shortfall needs comment', () {
    final exp = expectedCash(const CashInputs(
        openingFloat: Money(20000),
        cashSales: Money(85040),
        cashTips: Money(1200),
        cashExpenses: Money(4530),
        withdrawals: Money(50000)));
    expect(exp, const Money(51710));
    final diff = cashDiscrepancy(counted: const Money(51709), expected: exp);
    expect(diff, const Money(-1));
    expect(
        requiresComment(
            cashDiff: diff, cardDiff: Money.zero, threshold: Money.zero),
        isTrue);
    expect(
        requiresComment(
            cashDiff: Money.zero, cardDiff: Money.zero, threshold: Money.zero),
        isFalse);
    expect(
        requiresComment(
            cashDiff: const Money(50),
            cardDiff: Money.zero,
            threshold: const Money(100)),
        isFalse);
  });

  test('card discrepancy includes card tips', () {
    expect(
        cardDiscrepancy(
            terminalTotal: const Money(152000),
            cardSales: const Money(150000),
            cardTips: const Money(2000)),
        Money.zero);
    expect(
        cardDiscrepancy(
            terminalTotal: const Money(151000),
            cardSales: const Money(150000),
            cardTips: const Money(2000)),
        const Money(-1000));
  });

  test('denomination count', () {
    expect(countDenominations({5000: 3, 2000: 2, 200: 1, 1: 7}),
        const Money(19207));
    expect(() => countDenominations({300: 1}), throwsArgumentError);
    expect(() => countDenominations({100: -1}), throwsArgumentError);
  });
}
