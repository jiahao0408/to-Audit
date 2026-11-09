// Named constructor parameters cannot be private, hence the initializer list.
// ignore_for_file: prefer_initializing_formals

import 'package:drift/drift.dart';

import '../../domain/dates.dart';
import '../../domain/enums.dart';
import '../../domain/money.dart';
import '../../domain/pnl_calc.dart';
import '../db/app_database.dart';
import '../repositories/catalog_repository.dart';
import '../repositories/days_repository.dart';
import '../repositories/expenses_repository.dart';
import '../repositories/payroll_repository.dart';
import '../repositories/withdrawals_repository.dart';

/// One line of the daily table of a report.
class DayRow {
  const DayRow({
    required this.date,
    required this.status,
    required this.sales,
    required this.covers,
    required this.expenses,
    required this.cashDiff,
    required this.cardDiff,
  });

  final DateTime date;
  final DayStatus status;
  final Money sales;
  final int covers;
  final Money expenses;
  final Money cashDiff;
  final Money cardDiff;
}

/// Everything a period report (screen, PDF, Excel, CSV) needs.
class ReportData {
  const ReportData({
    required this.range,
    required this.pnl,
    required this.days,
    required this.salesByPaymentMethod,
    required this.withdrawalsTotal,
    required this.withdrawalsByType,
    required this.cashDiscrepancyTotal,
    required this.cardDiscrepancyTotal,
    required this.expenses,
    required this.payroll,
  });

  final DateRange range;
  final PnlResult pnl;
  final List<DayRow> days;

  /// Sales of closed days keyed by payment method id.
  final Map<String, Money> salesByPaymentMethod;
  final Money withdrawalsTotal;

  /// Non-voided withdrawals keyed by withdrawal type id.
  final Map<String, Money> withdrawalsByType;
  final Money cashDiscrepancyTotal;
  final Money cardDiscrepancyTotal;

  /// Non-voided expenses dated in the range.
  final List<ExpenseRecord> expenses;
  final List<PayrollRow> payroll;
}

/// Figures for the home screen.
class HomeSummary {
  const HomeSummary({
    required this.monthSales,
    required this.profitToDate,
    required this.lastClosedDay,
    required this.nextPending,
  });

  final Money monthSales;
  final Money profitToDate;
  final DateTime? lastClosedDay;
  final DateTime? nextPending;
}

/// Builds period reports and the home summary. Read-only.
class ReportService {
  ReportService({
    required AppDatabase db,
    required DaysRepository days,
    required ExpensesRepository expenses,
    required PayrollRepository payroll,
    required WithdrawalsRepository withdrawals,
    required CatalogRepository catalog,
  }) : _db = db,
       _days = days,
       _expenses = expenses,
       _payroll = payroll,
       _withdrawals = withdrawals,
       _catalog = catalog;

  final AppDatabase _db;
  final DaysRepository _days;
  final ExpensesRepository _expenses;
  final PayrollRepository _payroll;
  final WithdrawalsRepository _withdrawals;
  final CatalogRepository _catalog;

  Future<ReportData> build(DateRange range) async {
    final dayRows =
        await (_db.select(_db.days)
              ..where(
                (d) => d.date.isBetweenValues(ymd(range.start), ymd(range.end)),
              )
              ..orderBy([(d) => OrderingTerm.asc(d.date)]))
            .get();
    final dayIds = dayRows.map((d) => d.id).toList();
    final sales = dayIds.isEmpty
        ? <SaleData>[]
        : await (_db.select(
            _db.sales,
          )..where((s) => s.dayId.isIn(dayIds))).get();
    final covers = dayIds.isEmpty
        ? <CoverData>[]
        : await (_db.select(
            _db.covers,
          )..where((c) => c.dayId.isIn(dayIds))).get();
    final closedIds = {
      for (final d in dayRows)
        if (d.status == DayStatus.closed) d.id,
    };

    final expenses = [
      for (final e in await _expenses.watchRange(range).first)
        if (!e.voided) e,
    ];
    final kinds = <String, CategoryKind>{};
    for (final e in expenses) {
      if (e.origin == ExpenseOrigin.manual &&
          !kinds.containsKey(e.categoryId)) {
        final item = await _catalog.byId(
          CatalogKind.expenseCategory,
          e.categoryId,
        );
        kinds[e.categoryId] = item.categoryKind ?? CategoryKind.other;
      }
    }

    var purchases = Money.zero;
    var fixed = Money.zero;
    var pendingFixed = Money.zero;
    var other = Money.zero;
    var vatPaid = Money.zero;
    final expensesByDate = <String, Money>{};
    for (final e in expenses) {
      final planned =
          e.origin == ExpenseOrigin.fixed &&
          e.fixedStatus != FixedStatus.confirmed;
      if (!planned) {
        // Same classification as the summary: planned fixed costs don't count.
        expensesByDate[ymd(e.date)] =
            (expensesByDate[ymd(e.date)] ?? Money.zero) + e.total;
      }
      if (e.origin == ExpenseOrigin.fixed) {
        if (e.fixedStatus == FixedStatus.confirmed) {
          fixed += e.total;
          vatPaid += e.vat;
        } else {
          pendingFixed += e.total;
        }
      } else if (kinds[e.categoryId] == CategoryKind.purchase) {
        purchases += e.total;
        vatPaid += e.vat;
      } else {
        other += e.total;
        vatPaid += e.vat;
      }
    }

    final byMethod = <String, Money>{};
    var totalSales = Money.zero;
    final salesByDay = <String, Money>{};
    for (final s in sales) {
      if (!closedIds.contains(s.dayId)) continue;
      final m = Money(s.amountCents);
      byMethod[s.paymentMethodId] =
          (byMethod[s.paymentMethodId] ?? Money.zero) + m;
      salesByDay[s.dayId] = (salesByDay[s.dayId] ?? Money.zero) + m;
      totalSales += m;
    }
    var totalCovers = 0;
    final coversByDay = <String, int>{};
    for (final c in covers) {
      if (!closedIds.contains(c.dayId)) continue;
      coversByDay[c.dayId] = (coversByDay[c.dayId] ?? 0) + c.count;
      totalCovers += c.count;
    }

    var cashDisc = Money.zero;
    var cardDisc = Money.zero;
    final rows = <DayRow>[];
    for (final d in dayRows) {
      final cash = Money(d.cashDiffCents ?? 0);
      final card = Money(d.cardDiffCents ?? 0);
      if (d.status == DayStatus.closed) {
        cashDisc += cash;
        cardDisc += card;
      }
      rows.add(
        DayRow(
          date: parseYmd(d.date),
          status: d.status,
          sales: salesByDay[d.id] ?? Money.zero,
          covers: coversByDay[d.id] ?? 0,
          expenses: expensesByDate[d.date] ?? Money.zero,
          cashDiff: cash,
          cardDiff: card,
        ),
      );
    }

    final withdrawalsByType = await _withdrawals.totalsByType(range);
    final payroll = <PayrollRow>[];
    var year = range.start.year;
    var month = range.start.month;
    while (year * 12 + month <= range.end.year * 12 + range.end.month) {
      payroll.addAll(await _payroll.month(monthKey(DateTime.utc(year, month))));
      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
    }

    final pnl = computePnl(
      PnlInputs(
        range: range,
        sales: totalSales,
        purchases: purchases,
        fixedCosts: fixed,
        otherExpenses: other,
        pendingFixed: pendingFixed,
        vatPaid: vatPaid,
        covers: totalCovers,
        payroll: await _payroll.costs(range),
      ),
    );
    return ReportData(
      range: range,
      pnl: pnl,
      days: rows,
      salesByPaymentMethod: byMethod,
      withdrawalsTotal: Money.sum(withdrawalsByType.values),
      withdrawalsByType: withdrawalsByType,
      cashDiscrepancyTotal: cashDisc,
      cardDiscrepancyTotal: cardDisc,
      expenses: expenses,
      payroll: payroll,
    );
  }

  Future<HomeSummary> home(DateTime today) async {
    final day = dateOnly(today);
    final month = rangeThisMonth(day);
    final closed =
        await (_db.select(_db.days)
              ..where(
                (d) =>
                    d.status.equals(DayStatus.closed.name) &
                    d.date.isBetweenValues(ymd(month.start), ymd(month.end)),
              )
              ..orderBy([(d) => OrderingTerm.asc(d.date)]))
            .get();
    final monthSales = (await build(month)).pnl.sales;
    DateTime? lastClosed;
    var profit = Money.zero;
    if (closed.isNotEmpty) {
      lastClosed = parseYmd(closed.last.date);
      profit = (await build(DateRange(month.start, lastClosed))).pnl.profit;
    }

    final latest =
        await (_db.select(_db.days)
              ..where((d) => d.status.equals(DayStatus.open.name).not())
              ..orderBy([(d) => OrderingTerm.desc(d.date)])
              ..limit(1))
            .getSingleOrNull();
    final after = latest == null
        ? month.start.subtract(const Duration(days: 1))
        : parseYmd(latest.date);
    return HomeSummary(
      monthSales: monthSales,
      profitToDate: profit,
      lastClosedDay: lastClosed,
      nextPending: await _days.nextPendingDate(after: after, today: day),
    );
  }
}
