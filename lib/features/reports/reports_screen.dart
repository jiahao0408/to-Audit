import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../data/export/csv_zip_export.dart';
import '../../data/export/export_keys.dart';
import '../../data/export/gestor_zip_export.dart';
import '../../data/export/pdf_report.dart';
import '../../data/export/xlsx_export.dart';
import '../../data/providers.dart';
import '../../data/reports/report_service.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/dates.dart';
import '../../l10n/app_localizations.dart';
import '../common/catalog_label.dart';
import '../common/export_labels.dart';
import '../common/period_picker.dart';
import '../common/platform_services.dart';

/// Builds the PDF of a report. The default loads the bundled CJK font and runs
/// [buildPdfReport]; tests replace it.
typedef PdfReportBuilder = Future<Uint8List> Function({
  required ReportData data,
  required RestaurantInfo restaurant,
  required String locale,
  required DateTime generatedAt,
  required ExportLabels labels,
});

final pdfReportBuilderProvider = Provider<PdfReportBuilder>(
  (ref) =>
      ({
        required data,
        required restaurant,
        required locale,
        required generatedAt,
        required labels,
      }) async => buildPdfReport(
        data: data,
        restaurant: restaurant,
        locale: locale,
        generatedAt: generatedAt,
        labels: labels,
        cjkFont: await rootBundle.load('assets/fonts/NotoSansSC-Regular.ttf'),
      ),
);

final _reportProvider = FutureProvider.autoDispose
    .family<ReportData, DateRange>(
      (ref, range) => ref.watch(reportServiceProvider).build(range),
    );

/// Reports screen: period selector, summary and export actions.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  PeriodSelection _period = const PeriodSelection(PeriodKind.month);
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).value ?? 'es';
    final now = ref.watch(clockProvider)();
    final range = _period.range(now);
    final reportAsync = ref.watch(_reportProvider(range));

    return Scaffold(
      appBar: AppBar(title: Text(l.screenReports)),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PeriodPicker(
                  selection: _period,
                  now: now,
                  withLastMonth: true,
                  onChanged: (v) => setState(() => _period = v),
                ),
                const SizedBox(height: 8),
                reportAsync.when(
                  data: (data) => _Summary(data: data, locale: locale),
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (_, _) => _ErrorBox(
                    message: l.reportErrLoad,
                    onRetry: () => ref.invalidate(_reportProvider(range)),
                  ),
                ),
                const SizedBox(height: 16),
                if (reportAsync.hasValue && !_exporting)
                  _ExportButtons(
                    onExport: (format) =>
                        _export(reportAsync.requireValue, locale, format),
                  ),
                if (_exporting)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<ExportNames> _names(AppLocalizations l) async {
    final catalog = ref.read(catalogRepositoryProvider);
    Future<Map<String, String>> labels(CatalogKind kind) async => {
      for (final i in await catalog.watch(kind, includeInactive: true).first)
        i.id: catalogLabel(l, i),
    };
    final methods = await labels(CatalogKind.paymentMethod);
    final categories = await labels(CatalogKind.expenseCategory);
    final types = await labels(CatalogKind.withdrawalType);
    final suppliers = {
      for (final s
          in await ref.read(suppliersRepositoryProvider).watchAll().first)
        s.id: s.name,
    };
    return ExportNames(
      paymentMethod: (id) => methods[id] ?? id,
      category: (id) => categories[id] ?? id,
      supplier: (id) => id == null ? '' : suppliers[id] ?? id,
      withdrawalType: (id) => types[id] ?? id,
    );
  }

  Future<File> _tempFile(String name) async {
    final dir = ref.read(tempRootProvider);
    await dir.create(recursive: true);
    return File(p.join(dir.path, name));
  }

  Future<void> _export(
    ReportData data,
    String locale,
    _ExportFormat format,
  ) async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final labels = exportLabels(l, locale);
    // Local time, never a UTC clock value, for the file name and the footer.
    final now = ref.read(clockProvider)();
    final sharer = ref.read(fileSharerProvider);
    final stamp = ymd(now);
    File? temp;
    Directory? tempDir;

    setState(() => _exporting = true);
    try {
      switch (format) {
        case _ExportFormat.pdf || _ExportFormat.savePdf:
          final restaurant =
              await ref.read(settingsRepositoryProvider).restaurant() ??
              const RestaurantInfo(name: '', nif: '', address: '');
          final bytes = await ref.read(pdfReportBuilderProvider)(
            data: data,
            restaurant: restaurant,
            locale: locale,
            generatedAt: now,
            labels: labels,
          );
          if (format == _ExportFormat.savePdf) {
            await sharer.savePdf(bytes, 'informe-$stamp.pdf');
          } else {
            temp = await _tempFile('informe-$stamp.pdf');
            await temp.writeAsBytes(bytes);
            await sharer.shareFile(temp, mimeType: 'application/pdf');
          }
        case _ExportFormat.xlsx:
          final bytes = buildXlsx(data, labels, names: await _names(l));
          temp = await _tempFile('informe-$stamp.xlsx');
          await temp.writeAsBytes(bytes);
          await sharer.shareFile(
            temp,
            mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          );
        case _ExportFormat.csv:
          final bytes = buildCsvZip(data, labels, names: await _names(l));
          temp = await _tempFile('informe-$stamp.zip');
          await temp.writeAsBytes(bytes);
          await sharer.shareFile(temp, mimeType: 'application/zip');
        case _ExportFormat.gestor:
          final names = await _names(l);
          final expenses = ref.read(expensesRepositoryProvider);
          final receipts = {
            for (final e in data.expenses) e.id: await expenses.receipts(e.id),
          };
          final root = ref.read(tempRootProvider);
          await root.create(recursive: true);
          tempDir = await root.createTemp('gestor_');
          final result = await buildGestorZip(
            expenses: data.expenses,
            receipts: receipts,
            store: ref.read(receiptStoreProvider),
            out: tempDir,
            labels: labels,
            supplierName: names.supplier,
            categoryName: names.category,
            generatedAt: now,
          );
          if (result.missingReceipts > 0) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(l.reportGestorMissing(result.missingReceipts)),
              ),
            );
          }
          await sharer.shareFile(result.zip, mimeType: 'application/zip');
      }
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.reportExportErr)));
    } finally {
      try {
        if (temp != null && await temp.exists()) await temp.delete();
        if (tempDir != null && await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      } catch (_) {}
      if (mounted) setState(() => _exporting = false);
    }
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.data, required this.locale});

  final ReportData data;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final pnl = data.pnl;
    final covers = data.days.fold<int>(0, (a, d) => a + d.covers);
    if (pnl.sales.isZero &&
        pnl.purchases.isZero &&
        pnl.fixedCosts.isZero &&
        pnl.otherExpenses.isZero &&
        pnl.personnel.isZero) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(l.reportNoData, textAlign: TextAlign.center),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Row(label: l.export_totalSales, value: pnl.sales.format(locale)),
            _Row(label: l.export_colCovers, value: '$covers'),
            _Row(
              label: l.export_averageTicket,
              value: pnl.averageTicket?.format(locale) ?? '—',
            ),
            _Row(
              label: l.export_totalPurchases,
              value: pnl.purchases.format(locale),
            ),
            _Row(
              label: l.export_totalFixedCosts,
              value: pnl.fixedCosts.format(locale),
            ),
            _Row(
              label: l.export_totalOtherExpenses,
              value: pnl.otherExpenses.format(locale),
            ),
            _Row(
              label: l.export_totalPayroll,
              value: pnl.personnelPct == null
                  ? pnl.personnel.format(locale)
                  : '${pnl.personnel.format(locale)} '
                        '(${NumberFormat('0.0', locale).format(pnl.personnelPct)} %)',
            ),
            const Divider(),
            _Row(
              label: l.export_profit,
              value: pnl.profit.format(locale),
              bold: true,
            ),
            const Divider(),
            _Row(
              label: l.export_totalWithdrawals,
              value: data.withdrawalsTotal.format(locale),
            ),
            _Row(
              label: l.export_totalCashDiscrepancy,
              value: data.cashDiscrepancyTotal.format(locale),
            ),
            _Row(
              label: l.export_totalCardDiscrepancy,
              value: data.cardDiscrepancyTotal.format(locale),
            ),
            if (!pnl.pendingFixed.isZero)
              _Row(
                label: l.export_pendingFixed,
                value: pnl.pendingFixed.format(locale),
                caption: true,
              ),
            if (!pnl.vatPaid.isZero)
              _Row(
                label: l.export_vatPaid,
                value: pnl.vatPaid.format(locale),
                caption: true,
              ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.bold = false,
    this.caption = false,
  });

  final String label;
  final String value;
  final bool bold;
  final bool caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = caption
        ? theme.textTheme.bodySmall
        : bold
        ? theme.textTheme.titleMedium
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

enum _ExportFormat { pdf, savePdf, xlsx, csv, gestor }

class _ExportButtons extends StatelessWidget {
  const _ExportButtons({required this.onExport});

  final void Function(_ExportFormat) onExport;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () => onExport(_ExportFormat.pdf),
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: Text(l.reportExportPdf),
        ),
        OutlinedButton.icon(
          onPressed: () => onExport(_ExportFormat.savePdf),
          icon: const Icon(Icons.save_alt_outlined),
          label: Text(l.reportSavePdf),
        ),
        OutlinedButton.icon(
          onPressed: () => onExport(_ExportFormat.xlsx),
          icon: const Icon(Icons.table_chart_outlined),
          label: Text(l.reportExportXlsx),
        ),
        OutlinedButton.icon(
          onPressed: () => onExport(_ExportFormat.csv),
          icon: const Icon(Icons.table_rows_outlined),
          label: Text(l.reportExportCsv),
        ),
        OutlinedButton.icon(
          onPressed: () => onExport(_ExportFormat.gestor),
          icon: const Icon(Icons.folder_zip_outlined),
          label: Text(l.reportExportGestor),
        ),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onRetry, child: Text(l.actionRetry)),
        ],
      ),
    );
  }
}
