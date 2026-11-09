/// Label keys used by the exporters, and the helpers that resolve them.
///
/// Task 18 maps every key to an ARB string; tests pass a fake `t` that
/// returns the key itself.
library;

/// Resolves label keys to display text and carries the export locale
/// (`'es'` or `'zh'`).
class ExportLabels {
  const ExportLabels(this.locale, this.t);

  final String locale;
  final String Function(String key) t;
}

/// Resolves record ids to display names. Exporters never touch the database.
class ExportNames {
  const ExportNames({
    this.paymentMethod = _same,
    this.category = _same,
    this.supplier = _supplier,
    this.withdrawalType = _same,
  });

  final String Function(String id) paymentMethod;
  final String Function(String id) category;
  final String Function(String? id) supplier;
  final String Function(String id) withdrawalType;

  static String _same(String id) => id;
  static String _supplier(String? id) => id ?? '';
}

/// The label keys the exporters ask for.
abstract final class ExportKeys {
  // Sheets / CSV files.
  static const sheetSummary = 'sheetSummary';
  static const sheetDays = 'sheetDays';
  static const sheetSales = 'sheetSales';
  static const sheetExpenses = 'sheetExpenses';
  static const sheetPayroll = 'sheetPayroll';
  static const sheetWithdrawals = 'sheetWithdrawals';

  // Generic columns.
  static const colConcept = 'colConcept';
  static const colAmount = 'colAmount';
  static const colDate = 'colDate';
  static const colStatus = 'colStatus';
  static const colSales = 'colSales';
  static const colCovers = 'colCovers';
  static const colExpenses = 'colExpenses';
  static const colCashDiff = 'colCashDiff';
  static const colCardDiff = 'colCardDiff';
  static const colPaymentMethod = 'colPaymentMethod';
  static const colSupplier = 'colSupplier';
  static const colInvoice = 'colInvoice';
  static const colCategory = 'colCategory';
  static const colBase = 'colBase';
  static const colVatPct = 'colVatPct';
  static const colVat = 'colVat';
  static const colTotal = 'colTotal';
  static const colPayment = 'colPayment';
  static const colReceipts = 'colReceipts';
  static const colEmployee = 'colEmployee';
  static const colRole = 'colRole';
  static const colMonth = 'colMonth';
  static const colGross = 'colGross';
  static const colNet = 'colNet';
  static const colEmployerSs = 'colEmployerSs';
  static const colWithdrawalType = 'colWithdrawalType';

  // Summary lines and PDF headings.
  static const reportTitle = 'reportTitle';
  static const restaurantNif = 'restaurantNif';
  static const period = 'period';
  static const generatedOn = 'generatedOn';
  static const totalSales = 'totalSales';
  static const totalPurchases = 'totalPurchases';
  static const totalFixedCosts = 'totalFixedCosts';
  static const totalOtherExpenses = 'totalOtherExpenses';
  static const totalExpenses = 'totalExpenses';
  static const totalPayroll = 'totalPayroll';
  static const totalWithdrawals = 'totalWithdrawals';
  static const totalCashDiscrepancy = 'totalCashDiscrepancy';
  static const totalCardDiscrepancy = 'totalCardDiscrepancy';
  static const pendingFixed = 'pendingFixed';
  static const vatPaid = 'vatPaid';
  static const averageTicket = 'averageTicket';
  static const profit = 'profit';
  static const dailyDetail = 'dailyDetail';

  // Values.
  static const statusOpen = 'statusOpen';
  static const statusClosed = 'statusClosed';
  static const statusNoActivity = 'statusNoActivity';
  static const paymentPaid = 'paymentPaid';
  static const paymentPending = 'paymentPending';
}
