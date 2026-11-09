import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show ByteData;
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/export/csv_zip_export.dart';
import 'package:to_audit/data/export/export_keys.dart';
import 'package:to_audit/data/export/gestor_zip_export.dart';
import 'package:to_audit/data/export/pdf_report.dart';
import 'package:to_audit/data/export/xlsx_export.dart';
import 'package:to_audit/data/reports/report_service.dart';
import 'package:to_audit/data/repositories/settings_repository.dart';
import 'package:to_audit/domain/dates.dart';
import 'package:to_audit/domain/enums.dart';

import '../reports/scenario.dart';

void main() {
  late ReportScenario s;
  late ReportData data;

  const es = ExportLabels('es', _key);
  const zh = ExportLabels('zh', _key);

  setUp(() async {
    s = await ReportScenario.create();
    data = await s.reports.build(rangeMonth('2026-11'));
  });
  tearDown(() => s.dispose());

  group('receiptFileName', () {
    test('keeps Unicode letters and cleans separators', () {
      expect(
        receiptFileName(
          date: DateTime.utc(2026, 11, 3),
          supplier: '蔬菜店 / Hnos. García',
          invoice: 'F 12/3',
          index: 1,
          ext: 'jpg',
        ),
        '2026-11-03_蔬菜店-Hnos.-García_F-12-3_1.jpg',
      );
    });

    test('falls back when supplier or invoice are missing or blank', () {
      expect(
        receiptFileName(
          date: DateTime.utc(2026, 11, 3),
          invoice: ' / ',
          index: 2,
          ext: 'pdf',
        ),
        '2026-11-03_sin-proveedor_sin-numero_2.pdf',
      );
    });
  });

  group('CSV zip', () {
    List<ArchiveFile> files(List<int> zip) =>
        ZipDecoder().decodeBytes(zip).files;

    test('one UTF-8 BOM file per sheet with es separators', () {
      final zip = files(buildCsvZip(data, es, names: _names(s)));
      expect(zip.map((f) => f.name), [
        'sheetSummary.csv',
        'sheetDays.csv',
        'sheetSales.csv',
        'sheetExpenses.csv',
        'sheetPayroll.csv',
        'sheetWithdrawals.csv',
      ]);
      final summary = zip.first.content as List<int>;
      expect(summary.take(3), [0xEF, 0xBB, 0xBF]);
      final text = utf8.decode(summary.skip(3).toList());
      expect(text, contains('totalSales;2700,00'));
      expect(text, contains('profit;450,00'));
    });

    test('zh uses comma and decimal point; names survive as UTF-8', () {
      final zip = files(buildCsvZip(data, zh, names: _names(s)));
      final summary = utf8.decode(
        (zip[0].content as List<int>).skip(3).toList(),
      );
      expect(summary, contains('profit,450.00'));
      final expenses = zip.firstWhere((f) => f.name == 'sheetExpenses.csv');
      final bytes = expenses.content as List<int>;
      expect(bytes.take(3), [0xEF, 0xBB, 0xBF]);
      expect(utf8.decode(bytes.skip(3).toList()), contains('蔬菜店'));
    });
  });

  test('XLSX has six sheets and numeric money', () {
    final bytes = buildXlsx(data, es, names: _names(s));
    final book = Excel.decodeBytes(bytes);
    expect(book.tables.keys, [
      'sheetSummary',
      'sheetDays',
      'sheetSales',
      'sheetExpenses',
      'sheetPayroll',
      'sheetWithdrawals',
    ]);
    final summary = book.tables['sheetSummary']!;
    final profitRow = summary.rows.firstWhere(
      (r) => r.first?.value.toString() == 'profit',
    );
    // The cell is numeric (Excel stores 450.00 as the integer 450).
    final value = profitRow[1]!.value;
    expect(switch (value) {
      IntCellValue(:final value) => value.toDouble(),
      DoubleCellValue(:final value) => value,
      _ => null,
    }, 450.0);
    expect(book.tables['sheetDays']!.rows, hasLength(1 + 3));
  });

  test('PDF is generated with the real CJK font', () async {
    final font = ByteData.sublistView(
      await File('assets/fonts/NotoSansSC-Regular.ttf').readAsBytes(),
    );
    final pdf = await buildPdfReport(
      data: data,
      restaurant: const RestaurantInfo(
        name: '餐厅 La Huerta',
        nif: 'B12345678',
        address: 'Calle Mayor 1',
      ),
      locale: 'es',
      generatedAt: DateTime(2026, 11, 8, 9, 5),
      labels: es,
      cjkFont: font,
    );
    expect(pdf, isNotEmpty);
    expect(utf8.decode(pdf.take(4).toList()), '%PDF');
  });

  test('accountant ZIP holds gastos.csv and one file per receipt', () async {
    final photo = File('${s.tmp.path}/in.jpg')..writeAsBytesSync([1, 2, 3]);
    final pdf = File('${s.tmp.path}/in.pdf')..writeAsBytesSync([4, 5]);
    await s.expenses.attachReceipt(s.meatExpenseId, photo, ReceiptKind.photo);
    await s.expenses.attachReceipt(s.meatExpenseId, pdf, ReceiptKind.pdf);
    final expenses = data.expenses;
    final receipts = {
      for (final e in expenses) e.id: await s.expenses.receipts(e.id),
    };
    final out = Directory('${s.tmp.path}/out');
    final file = await buildGestorZip(
      expenses: expenses,
      receipts: receipts,
      store: s.store,
      out: out,
      labels: es,
      supplierName: (id) => id == s.supplierId ? '蔬菜店 / Hnos. García' : '',
      generatedAt: DateTime(2026, 11, 8),
    );
    expect(file.path.endsWith('gestor-2026-11-08.zip'), isTrue);
    final names = ZipDecoder()
        .decodeBytes(await file.readAsBytes())
        .files
        .map((f) => f.name)
        .toList();
    expect(names, contains('gastos.csv'));
    expect(names.where((n) => n.startsWith('justificantes/')).toList(), [
      'justificantes/2026-11-03_蔬菜店-Hnos.-García_sin-numero_1.jpg',
      'justificantes/2026-11-03_蔬菜店-Hnos.-García_sin-numero_2.pdf',
    ]);
  });
}

String _key(String key) => key;

ExportNames _names(ReportScenario s) => ExportNames(
  supplier: (id) => id == s.supplierId ? '蔬菜店 / Hnos. García' : '',
);
