import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../domain/dates.dart';
import '../../domain/money.dart';
import '../reports/report_service.dart';
import '../repositories/settings_repository.dart';
import 'export_keys.dart';
import 'export_tables.dart';

/// Builds the printable period report. Every text uses the CJK font so Chinese
/// supplier and employee names render.
Future<Uint8List> buildPdfReport({
  required ReportData data,
  required RestaurantInfo restaurant,
  required String locale,
  required DateTime generatedAt,
  required ExportLabels labels,
  required ByteData cjkFont,
}) async {
  final font = pw.Font.ttf(cjkFont);
  final t = labels.t;
  String money(Money m) => m.format(locale);
  final pnl = data.pnl;
  final expensesTotal = pnl.purchases + pnl.fixedCosts + pnl.otherExpenses;
  final generated =
      '${ymd(generatedAt)} '
      '${generatedAt.hour.toString().padLeft(2, '0')}:'
      '${generatedAt.minute.toString().padLeft(2, '0')}';

  final doc = pw.Document(
    title: t(ExportKeys.reportTitle),
    theme: pw.ThemeData.withFont(
      base: font,
      bold: font,
      italic: font,
      boldItalic: font,
    ),
  );

  final totals = <List<String>>[
    [t(ExportKeys.totalSales), money(pnl.sales)],
    [t(ExportKeys.totalExpenses), money(expensesTotal)],
    [t(ExportKeys.totalPayroll), money(pnl.personnel)],
    [t(ExportKeys.totalWithdrawals), money(data.withdrawalsTotal)],
    [t(ExportKeys.totalCashDiscrepancy), money(data.cashDiscrepancyTotal)],
    [t(ExportKeys.totalCardDiscrepancy), money(data.cardDiscrepancyTotal)],
    [t(ExportKeys.profit), money(pnl.profit)],
  ];

  final dayHeader = [
    t(ExportKeys.colDate),
    t(ExportKeys.colStatus),
    t(ExportKeys.colSales),
    t(ExportKeys.colCovers),
    t(ExportKeys.colExpenses),
    t(ExportKeys.colCashDiff),
    t(ExportKeys.colCardDiff),
  ];
  final dayRows = [
    for (final d in data.days)
      [
        ymd(d.date),
        t(dayStatusKey(d.status)),
        money(d.sales),
        d.covers.toString(),
        money(d.expenses),
        money(d.cashDiff),
        money(d.cardDiff),
      ],
  ];

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        pw.Text(restaurant.name, style: pw.TextStyle(fontSize: 20, font: font)),
        pw.Text('${t(ExportKeys.restaurantNif)}: ${restaurant.nif}'),
        pw.SizedBox(height: 8),
        pw.Text(
          '${t(ExportKeys.period)}: '
          '${ymd(data.range.start)} - ${ymd(data.range.end)}',
        ),
        pw.Text('${t(ExportKeys.generatedOn)}: $generated'),
        pw.SizedBox(height: 16),
        pw.TableHelper.fromTextArray(
          data: totals,
          headerCount: 0,
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
          },
          cellStyle: pw.TextStyle(font: font, fontSize: 11),
        ),
        pw.SizedBox(height: 16),
        pw.Text(
          t(ExportKeys.dailyDetail),
          style: pw.TextStyle(fontSize: 14, font: font),
        ),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headers: dayHeader,
          data: dayRows,
          headerStyle: pw.TextStyle(font: font, fontSize: 9),
          cellStyle: pw.TextStyle(font: font, fontSize: 9),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          cellAlignments: {
            for (var i = 2; i < 7; i++) i: pw.Alignment.centerRight,
          },
        ),
      ],
    ),
  );
  return doc.save();
}
