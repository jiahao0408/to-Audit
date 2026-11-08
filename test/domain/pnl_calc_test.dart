import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/domain/dates.dart';
import 'package:to_audit/domain/money.dart';
import 'package:to_audit/domain/pnl_calc.dart';

void main() {
  group('proratedPersonnel', () {
    test('full month returns the whole monthly cost', () {
      final result = proratedPersonnel([
        PayrollMonth('2026-11', Money(300000)),
      ], rangeMonth('2026-11'));
      expect(result, Money(300000));
    });

    test('half of a month is prorated by days', () {
      final result = proratedPersonnel([
        PayrollMonth('2026-11', Money(300000)),
      ], DateRange(DateTime.utc(2026, 11, 1), DateTime.utc(2026, 11, 15)));
      expect(result, Money(150000));
    });

    test('range spanning two months prorates each month and sums', () {
      final result = proratedPersonnel([
        PayrollMonth('2026-10', Money(310000)),
        PayrollMonth('2026-11', Money(300000)),
      ], DateRange(DateTime.utc(2026, 10, 25), DateTime.utc(2026, 11, 5)));
      // Oct 25..31 = 7 of 31 days: 70000. Nov 1..5 = 5 of 30 days: 50000.
      expect(result, Money(120000));
    });

    test('months with no overlap contribute zero', () {
      final result = proratedPersonnel([
        PayrollMonth('2026-09', Money(999999)),
        PayrollMonth('2026-11', Money(300000)),
      ], rangeMonth('2026-11'));
      expect(result, Money(300000));
    });

    test('empty payroll list gives zero', () {
      expect(proratedPersonnel([], rangeMonth('2026-11')), Money.zero);
    });
  });

  group('computePnl', () {
    PnlInputs inputs({
      DateRange? range,
      int sales = 3000000,
      int purchases = 900000,
      int fixedCosts = 300000,
      int otherExpenses = 50000,
      int pendingFixed = 0,
      int vatPaid = 0,
      int covers = 0,
      List<PayrollMonth>? payroll,
    }) {
      return PnlInputs(
        range: range ?? rangeMonth('2026-11'),
        sales: Money(sales),
        purchases: Money(purchases),
        fixedCosts: Money(fixedCosts),
        otherExpenses: Money(otherExpenses),
        pendingFixed: Money(pendingFixed),
        vatPaid: Money(vatPaid),
        covers: covers,
        payroll: payroll ?? [PayrollMonth('2026-11', Money(900000))],
      );
    }

    test('profit = sales - purchases - fixed - other - personnel', () {
      final result = computePnl(inputs());
      expect(result.personnel, Money(900000));
      expect(result.profit, Money(850000));
    });

    test('passes sales, costs and informational amounts through', () {
      final result = computePnl(inputs(pendingFixed: 12345, vatPaid: 67890));
      expect(result.sales, Money(3000000));
      expect(result.purchases, Money(900000));
      expect(result.fixedCosts, Money(300000));
      expect(result.otherExpenses, Money(50000));
      expect(result.pendingFixed, Money(12345));
      expect(result.vatPaid, Money(67890));
    });

    test('pendingFixed and vatPaid do not reduce profit', () {
      final base = computePnl(inputs());
      final withInfo = computePnl(inputs(pendingFixed: 500, vatPaid: 700));
      expect(withInfo.profit, base.profit);
    });

    test('personnel is prorated from payroll and range', () {
      final result = computePnl(
        inputs(
          range: DateRange(
            DateTime.utc(2026, 11, 1),
            DateTime.utc(2026, 11, 15),
          ),
          payroll: [PayrollMonth('2026-11', Money(900000))],
        ),
      );
      expect(result.personnel, Money(450000));
      expect(result.profit, Money(3000000 - 900000 - 300000 - 50000 - 450000));
    });

    test('average ticket is sales / covers', () {
      final result = computePnl(inputs(covers: 1000));
      expect(result.averageTicket, Money(3000));
    });

    test('average ticket is null when covers is 0', () {
      final result = computePnl(inputs(covers: 0));
      expect(result.averageTicket, isNull);
    });

    test('personnelPct is personnel / sales', () {
      final result = computePnl(inputs());
      expect(result.personnelPct, closeTo(0.3, 1e-12));
    });

    test('personnelPct is null when sales is 0', () {
      final result = computePnl(inputs(sales: 0));
      expect(result.personnelPct, isNull);
    });
  });
}
