import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';

import '../../domain/money.dart';
import '../reports/report_service.dart';
import 'export_keys.dart';
import 'export_tables.dart';

/// One CSV per sheet of the period report, zipped. Each file is UTF-8 with a
/// BOM so Excel detects the encoding.
List<int> buildCsvZip(
  ReportData data,
  ExportLabels labels, {
  ExportNames names = const ExportNames(),
}) {
  final archive = Archive();
  final used = <String>{};
  for (final table in buildReportTables(data, labels, names: names)) {
    var file = '${_fileSafe(table.name)}.csv';
    for (var n = 2; !used.add(file); n++) {
      file = '${_fileSafe(table.name)}-$n.csv';
    }
    final bytes = encodeCsv(table, labels.locale);
    archive.addFile(ArchiveFile(file, bytes.length, bytes));
  }
  return ZipEncoder().encode(archive)!;
}

/// Encodes [table] as UTF-8 bytes with a BOM. `es` uses `;` and a decimal
/// comma; any other locale uses `,` and a decimal point.
List<int> encodeCsv(ExportTable table, String locale) {
  final es = locale == 'es';
  final codec = Csv(
    fieldDelimiter: es ? ';' : ',',
    lineDelimiter: '\r\n',
    autoDetect: false,
  );
  final rows = <List<String>>[
    [for (final h in table.header) _text(h)],
    for (final r in table.rows) [for (final c in r) _field(c, es)],
  ];
  return [0xEF, 0xBB, 0xBF, ...utf8.encode(codec.encode(rows))];
}

String _field(Object? value, bool es) => switch (value) {
  null => '',
  Money m => moneyText(m, es),
  _ => _text(value.toString()),
};

/// `1234.50` or `1234,50` (no thousands separator), with the sign in front.
String moneyText(Money m, bool es) {
  final abs = m.cents.abs();
  final text =
      '${m.isNegative ? '-' : ''}${abs ~/ 100}'
      '.${(abs % 100).toString().padLeft(2, '0')}';
  return es ? text.replaceFirst('.', ',') : text;
}

/// Text starting with a formula character is prefixed with `'` so a
/// spreadsheet never evaluates user-entered names.
String _text(String s) => s.isNotEmpty && '=+-@\t\r'.contains(s[0]) ? "'$s" : s;

String _fileSafe(String name) {
  final clean = name.replaceAll(RegExp(r'[\/:*?"<>|]'), '-').trim();
  return clean.isEmpty ? 'sheet' : clean;
}
