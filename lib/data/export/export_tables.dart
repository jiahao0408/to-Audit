import '../../domain/dates.dart';
import '../../domain/enums.dart';
import '../../domain/money.dart';
import '../reports/report_service.dart';
import '../repositories/expenses_repository.dart';
import 'export_keys.dart';

/// One sheet of an export: a header and rows whose cells are `String`, `int`,
/// [Money] or null. XLSX and CSV render the same tables.
class ExportTable {
  const ExportTable(this.name, this.header, this.rows);

  final String name;
  final List<String> header;
  final List<List<Object?>> rows;
}

String dayStatusKey(DayStatus s) => switch (s) {
  DayStatus.open => ExportKeys.statusOpen,
  DayStatus.closed => ExportKeys.statusClosed,
  DayStatus.noActivity => ExportKeys.statusNoActivity,
};

/// The six sheets of the period report, in order.
List<ExportTable> buildReportTables(
  ReportData data,
  ExportLabels labels, {
  ExportNames names = const ExportNames(),
}) {
  final t = labels.t;
  final pnl = data.pnl;
  final expensesTotal = pnl.purchases + pnl.fixedCosts + pnl.otherExpenses;

  final summary = ExportTable(
    t(ExportKeys.sheetSummary),
    [t(ExportKeys.colConcept), t(ExportKeys.colAmount)],
    [
      [
        t(ExportKeys.period),
        '${ymd(data.range.start)} - ${ymd(data.range.end)}',
      ],
      [t(ExportKeys.totalSales), pnl.sales],
      [t(ExportKeys.totalPurchases), pnl.purchases],
      [t(ExportKeys.totalFixedCosts), pnl.fixedCosts],
      [t(ExportKeys.totalOtherExpenses), pnl.otherExpenses],
      [t(ExportKeys.totalExpenses), expensesTotal],
      [t(ExportKeys.totalPayroll), pnl.personnel],
      [t(ExportKeys.totalWithdrawals), data.withdrawalsTotal],
      [t(ExportKeys.totalCashDiscrepancy), data.cashDiscrepancyTotal],
      [t(ExportKeys.totalCardDiscrepancy), data.cardDiscrepancyTotal],
      [t(ExportKeys.pendingFixed), pnl.pendingFixed],
      [t(ExportKeys.vatPaid), pnl.vatPaid],
      [t(ExportKeys.averageTicket), pnl.averageTicket],
      [t(ExportKeys.profit), pnl.profit],
    ],
  );

  final days = ExportTable(
    t(ExportKeys.sheetDays),
    [
      t(ExportKeys.colDate),
      t(ExportKeys.colStatus),
      t(ExportKeys.colSales),
      t(ExportKeys.colCovers),
      t(ExportKeys.colExpenses),
      t(ExportKeys.colCashDiff),
      t(ExportKeys.colCardDiff),
    ],
    [
      for (final d in data.days)
        [
          ymd(d.date),
          t(dayStatusKey(d.status)),
          d.sales,
          d.covers,
          d.expenses,
          d.cashDiff,
          d.cardDiff,
        ],
    ],
  );

  final sales = ExportTable(
    t(ExportKeys.sheetSales),
    [t(ExportKeys.colPaymentMethod), t(ExportKeys.colAmount)],
    [
      for (final e in data.salesByPaymentMethod.entries)
        [names.paymentMethod(e.key), e.value],
    ],
  );

  final expenses = expenseTable(
    t(ExportKeys.sheetExpenses),
    data.expenses,
    labels,
    names,
  );

  final payroll = ExportTable(
    t(ExportKeys.sheetPayroll),
    [
      t(ExportKeys.colEmployee),
      t(ExportKeys.colRole),
      t(ExportKeys.colMonth),
      t(ExportKeys.colGross),
      t(ExportKeys.colNet),
      t(ExportKeys.colEmployerSs),
    ],
    [
      for (final row in data.payroll)
        if (row.payment != null)
          [
            row.employee.name,
            row.employee.role,
            row.payment!.month,
            row.payment!.gross,
            row.payment!.net,
            row.payment!.employerSs,
          ],
    ],
  );

  final withdrawals = ExportTable(
    t(ExportKeys.sheetWithdrawals),
    [t(ExportKeys.colWithdrawalType), t(ExportKeys.colAmount)],
    [
      for (final e in data.withdrawalsByType.entries)
        [names.withdrawalType(e.key), e.value],
    ],
  );

  return [summary, days, sales, expenses, payroll, withdrawals];
}

/// The expenses table. [receiptNames] adds a last column with the file names
/// of each expense's receipts (used by the accountant ZIP).
ExportTable expenseTable(
  String name,
  List<ExpenseRecord> expenses,
  ExportLabels labels,
  ExportNames names, {
  Map<String, List<String>>? receiptNames,
}) {
  final t = labels.t;
  return ExportTable(
    name,
    [
      t(ExportKeys.colDate),
      t(ExportKeys.colSupplier),
      t(ExportKeys.colInvoice),
      t(ExportKeys.colCategory),
      t(ExportKeys.colBase),
      t(ExportKeys.colVatPct),
      t(ExportKeys.colVat),
      t(ExportKeys.colTotal),
      t(ExportKeys.colPayment),
      if (receiptNames != null) t(ExportKeys.colReceipts),
    ],
    [
      for (final e in expenses)
        [
          ymd(e.date),
          names.supplier(e.supplierId),
          e.invoiceNumber ?? '',
          names.category(e.categoryId),
          e.base,
          e.vatPct,
          e.vat,
          e.total,
          t(
            e.paymentStatus == PaymentStatus.paid
                ? ExportKeys.paymentPaid
                : ExportKeys.paymentPending,
          ),
          if (receiptNames != null)
            (receiptNames[e.id] ?? const []).join(' | '),
        ],
    ],
  );
}
