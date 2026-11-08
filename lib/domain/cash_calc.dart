/// Pure-Dart cash reconciliation calculations for the daily close.
library;

import 'money.dart';

/// Euro banknote and coin values, in cents, largest first.
const List<int> euroDenominations = [
  50000, 20000, 10000, 5000, 2000, 1000, 500, 200, 100, 50, 20, 10, 5, 2, 1,
];

/// Total value of a count of banknotes and coins.
///
/// [countByDenomination] maps a denomination in cents (see
/// [euroDenominations]) to the number of pieces counted. Throws
/// [ArgumentError] for an unknown denomination or a negative count.
Money countDenominations(Map<int, int> countByDenomination) {
  var total = Money.zero;
  countByDenomination.forEach((denomination, count) {
    if (!euroDenominations.contains(denomination)) {
      throw ArgumentError.value(
        denomination,
        'denomination',
        'must be one of euroDenominations',
      );
    }
    if (count < 0) {
      throw ArgumentError.value(count, 'count', 'must not be negative');
    }
    total = total + Money(denomination * count);
  });
  return total;
}

/// Cash movements for one day used to compute the expected cash in the till.
class CashInputs {
  const CashInputs({
    required this.openingFloat,
    required this.cashSales,
    required this.cashTips,
    required this.cashExpenses,
    required this.withdrawals,
  });

  final Money openingFloat;
  final Money cashSales;
  final Money cashTips;
  final Money cashExpenses;
  final Money withdrawals;
}

/// Expected cash = opening float + cash sales + cash tips - cash expenses
/// - withdrawals.
Money expectedCash(CashInputs i) =>
    i.openingFloat + i.cashSales + i.cashTips - i.cashExpenses - i.withdrawals;

/// Cash discrepancy = counted - expected. Negative means a shortfall.
Money cashDiscrepancy({required Money counted, required Money expected}) =>
    counted - expected;

/// Card discrepancy = terminal total - (card sales + card tips).
Money cardDiscrepancy({
  required Money terminalTotal,
  required Money cardSales,
  required Money cardTips,
}) =>
    terminalTotal - (cardSales + cardTips);

/// Whether either discrepancy exceeds [threshold] in absolute value.
bool requiresComment({
  required Money cashDiff,
  required Money cardDiff,
  required Money threshold,
}) =>
    cashDiff.abs().compareTo(threshold) > 0 ||
    cardDiff.abs().compareTo(threshold) > 0;
