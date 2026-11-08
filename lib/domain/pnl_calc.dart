/// Pure-Dart profit and loss (cuenta de resultados) calculations.
library;

import 'dates.dart';
import 'money.dart';

/// Employer cost for one payroll month (gross pay plus employer social
/// security). [month] is `YYYY-MM`.
class PayrollMonth {
  const PayrollMonth(this.month, this.cost);

  final String month;
  final Money cost;
}

/// Personnel cost for [range], prorated by day from each payroll month.
///
/// Each month contributes `cost * (days of range in that month) / days in
/// that month`, rounded per month; months with no overlap contribute zero.
Money proratedPersonnel(List<PayrollMonth> months, DateRange range) {
  var total = Money.zero;
  for (final m in months) {
    final year = int.parse(m.month.substring(0, 4));
    final month = int.parse(m.month.substring(5, 7));
    final monthStart = DateTime.utc(year, month, 1);
    final monthEnd = DateTime.utc(year, month, daysInMonth(year, month));
    final overlapStart = range.start.isAfter(monthStart)
        ? range.start
        : monthStart;
    final overlapEnd = range.end.isBefore(monthEnd) ? range.end : monthEnd;
    if (overlapEnd.isBefore(overlapStart)) {
      continue;
    }
    final days = overlapEnd.difference(overlapStart).inDays + 1;
    total += m.cost.multiplyRatio(days, daysInMonth(year, month));
  }
  return total;
}

/// Inputs for a P&L computation over [range].
class PnlInputs {
  const PnlInputs({
    required this.range,
    required this.sales,
    required this.purchases,
    required this.fixedCosts,
    required this.otherExpenses,
    required this.pendingFixed,
    required this.vatPaid,
    required this.covers,
    required this.payroll,
  });

  final DateRange range;
  final Money sales;
  final Money purchases;
  final Money fixedCosts;
  final Money otherExpenses;
  final Money pendingFixed;
  final Money vatPaid;
  final int covers;
  final List<PayrollMonth> payroll;
}

/// Result of [computePnl]. [averageTicket] is null when there are no covers;
/// [personnelPct] is null when there are no sales.
class PnlResult {
  const PnlResult({
    required this.sales,
    required this.purchases,
    required this.fixedCosts,
    required this.otherExpenses,
    required this.personnel,
    required this.profit,
    required this.pendingFixed,
    required this.vatPaid,
    required this.averageTicket,
    required this.personnelPct,
  });

  final Money sales;
  final Money purchases;
  final Money fixedCosts;
  final Money otherExpenses;
  final Money personnel;
  final Money profit;
  final Money pendingFixed;
  final Money vatPaid;
  final Money? averageTicket;
  final double? personnelPct;
}

/// Computes the P&L for [i]. Personnel is prorated from the payroll months
/// over the range. `pendingFixed` and `vatPaid` are informational and do not
/// affect profit.
PnlResult computePnl(PnlInputs i) {
  final personnel = proratedPersonnel(i.payroll, i.range);
  final profit =
      i.sales - i.purchases - i.fixedCosts - i.otherExpenses - personnel;
  return PnlResult(
    sales: i.sales,
    purchases: i.purchases,
    fixedCosts: i.fixedCosts,
    otherExpenses: i.otherExpenses,
    personnel: personnel,
    profit: profit,
    pendingFixed: i.pendingFixed,
    vatPaid: i.vatPaid,
    averageTicket: i.covers == 0 ? null : i.sales.multiplyRatio(1, i.covers),
    personnelPct: i.sales.isZero ? null : personnel.cents / i.sales.cents,
  );
}
