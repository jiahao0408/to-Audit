import 'package:excel/excel.dart';

import '../../domain/money.dart';
import '../reports/report_service.dart';
import 'export_keys.dart';
import 'export_tables.dart';

/// Builds the period report workbook: one sheet per [ExportTable]. Money is a
/// numeric cell (cents / 100) so the accountant can sum it.
List<int> buildXlsx(
  ReportData data,
  ExportLabels labels, {
  ExportNames names = const ExportNames(),
}) {
  final excel = Excel.createExcel();
  final defaultSheet = excel.getDefaultSheet();
  final tables = buildReportTables(data, labels, names: names);
  final moneyStyle = CellStyle(numberFormat: NumFormat.standard_2);
  for (final table in tables) {
    final name = _sheetName(table.name);
    final rows = [table.header, ...table.rows];
    for (var r = 0; r < rows.length; r++) {
      for (var c = 0; c < rows[r].length; c++) {
        final cell = rows[r][c];
        excel.updateCell(
          name,
          CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r),
          _cell(cell),
          cellStyle: cell is Money ? moneyStyle : null,
        );
      }
    }
  }
  if (defaultSheet != null &&
      !tables.any((t) => _sheetName(t.name) == defaultSheet)) {
    excel.delete(defaultSheet);
  }
  return excel.encode()!;
}

CellValue? _cell(Object? value) => switch (value) {
  null => null,
  Money m => DoubleCellValue(m.cents / 100),
  int i => IntCellValue(i),
  _ => TextCellValue(value.toString()),
};

/// Excel limits sheet names to 31 characters without `[]:*?/\`.
String _sheetName(String name) {
  final clean = name.replaceAll(RegExp(r'[\[\]:*?/\\]'), '-').trim();
  final cut = clean.length > 31 ? clean.substring(0, 31) : clean;
  return cut.isEmpty ? '-' : cut;
}
