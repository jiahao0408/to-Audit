import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/domain/dates.dart';
import 'package:to_audit/domain/enums.dart';
import 'package:to_audit/domain/money.dart';

import 'scenario.dart';

void main() {
  late ReportScenario s;

  setUp(() async => s = await ReportScenario.create());
  tearDown(() => s.dispose());

  test(
    'November report counts only closed days and classifies costs',
    () async {
      final r = await s.reports.build(rangeMonth('2026-11'));
      expect(r.pnl.sales, const Money(270000));
      expect(r.pnl.purchases, const Money(30000));
      expect(r.pnl.fixedCosts, const Money(100000));
      expect(r.pnl.pendingFixed, const Money(20000));
      expect(r.pnl.otherExpenses, const Money(5000));
      expect(r.pnl.personnel, const Money(90000));
      expect(r.pnl.profit, const Money(45000));
      expect(r.pnl.averageTicket, const Money(3000));
      // VAT of purchases + confirmed fixed + other, not of the planned one.
      expect(
        r.pnl.vatPaid,
        VatCalc.fromTotal(const Money(30000), 21).vat +
            VatCalc.fromTotal(const Money(100000), 21).vat +
            VatCalc.fromTotal(const Money(5000), 21).vat,
      );

      expect(r.days.map((d) => ymd(d.date)), [
        '2026-11-03',
        '2026-11-05',
        '2026-11-07',
      ]);
      expect(r.days[2].status, DayStatus.open);
      expect(r.days[2].sales, Money.zero);
      expect(r.days[0].sales, const Money(150000));
      expect(r.days[0].covers, 50);
      expect(r.days[0].cashDiff, const Money(-200));
      expect(r.days[1].sales, const Money(120000));
      expect(r.salesByPaymentMethod.values.single, const Money(270000));
      expect(r.withdrawalsTotal, const Money(1000));
      expect(r.withdrawalsByType.values.single, const Money(1000));
      expect(r.cashDiscrepancyTotal, const Money(-200));
      expect(r.cardDiscrepancyTotal, Money.zero);
      expect(r.expenses, hasLength(4));
      expect(r.payroll.single.payment!.gross, const Money(70000));
    },
  );

  test('daily expenses are summed per date', () async {
    final r = await s.reports.build(rangeMonth('2026-11'));
    expect(r.days[0].expenses, const Money(30000));
    expect(r.days[1].expenses, const Money(5000));
    expect(r.days[2].expenses, Money.zero);
  });

  test('DayRow.expenses excludes planned fixed costs', () async {
    // Open Nov 1 (rent, confirmed) and Nov 2 (light, planned) so they have rows.
    await s.days.openDay(ReportScenario.d(1));
    await s.days.openDay(ReportScenario.d(2));
    final r = await s.reports.build(rangeMonth('2026-11'));
    Money on(int day) =>
        r.days.firstWhere((d) => d.date == ReportScenario.d(day)).expenses;
    expect(on(1), const Money(100000));
    expect(on(2), Money.zero);
    expect(r.pnl.pendingFixed, const Money(20000));
    // Every expense falls on a day with a row now except Nov 6-less ones.
    final sum = r.days.fold(Money.zero, (a, d) => a + d.expenses);
    expect(sum, r.pnl.purchases + r.pnl.fixedCosts + r.pnl.otherExpenses);
  });

  test('home summary for the current month', () async {
    final h = await s.reports.home(ReportScenario.d(8));
    expect(h.monthSales, const Money(270000));
    expect(h.lastClosedDay, ReportScenario.d(5));
    // Nov 6 has no row at all, so it is the first pending day after Nov 5.
    expect(h.nextPending, ReportScenario.d(6));
    final expected = await s.reports.build(
      rangeCustom(ReportScenario.d(1), ReportScenario.d(5)),
    );
    expect(h.profitToDate, expected.pnl.profit);
  });

  test('home summary without closed days', () async {
    final h = await s.reports.home(DateTime.utc(2027, 3, 10));
    expect(h.monthSales, Money.zero);
    expect(h.profitToDate, Money.zero);
    expect(h.lastClosedDay, isNull);
  });
}
