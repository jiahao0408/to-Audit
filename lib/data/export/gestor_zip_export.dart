import 'dart:io';

import 'package:archive/archive_io.dart';

import '../../domain/dates.dart';
import '../../domain/enums.dart';
import '../db/app_database.dart' show ReceiptData;
import '../files/receipt_store.dart';
import '../repositories/expenses_repository.dart';
import 'csv_zip_export.dart';
import 'export_keys.dart';
import 'export_tables.dart';

/// File name of a receipt inside the accountant ZIP:
/// `<date>_<supplier>_<invoice>_<index>.<ext>`.
///
/// Spaces and `\/:*?"<>|` become `-`, runs of `-` collapse, `-` at the ends is
/// trimmed and Unicode letters are kept.
String receiptFileName({
  required DateTime date,
  String? supplier,
  String? invoice,
  required int index,
  required String ext,
}) {
  final s1 = _slug(supplier) ?? 'sin-proveedor';
  final s2 = _slug(invoice) ?? 'sin-numero';
  return '${ymd(date)}_${s1}_${s2}_$index.$ext';
}

String? _slug(String? raw) {
  if (raw == null) return null;
  final clean = raw
      .replaceAll(RegExp(r'[\s\\/:*?"<>|]'), '-')
      .replaceAll(RegExp(r'-{2,}'), '-')
      .replaceAll(RegExp(r'^-+|-+$'), '');
  return clean.isEmpty ? null : clean;
}

/// Result of [buildGestorZip]: the ZIP and how many receipts were left out
/// because their file is missing on disk.
class GestorZipResult {
  const GestorZipResult({required this.zip, required this.missingReceipts});

  final File zip;
  final int missingReceipts;
}

/// Writes `<out>/gestor-<YYYY-MM-DD>.zip` (the date is [generatedAt]) with
/// `gastos.csv` and `justificantes/<receiptFileName>` for every receipt.
///
/// The ZIP is streamed to disk: receipts are stored (not recompressed) and
/// never held in memory together. A receipt whose file is missing is left out
/// of the ZIP and the CSV and counted in [GestorZipResult.missingReceipts].
Future<GestorZipResult> buildGestorZip({
  required List<ExpenseRecord> expenses,
  required Map<String, List<ReceiptData>> receipts,
  required ReceiptStore store,
  required Directory out,
  required ExportLabels labels,
  required String Function(String? supplierId) supplierName,
  required DateTime generatedAt,
  String Function(String categoryId)? categoryName,
}) async {
  await out.create(recursive: true);
  final target = File('${out.path}/gestor-${ymd(generatedAt)}.zip');
  final encoder = ZipFileEncoder()..create(target.path);
  final used = <String>{};
  final fileNames = <String, List<String>>{};
  var missing = 0;

  try {
    for (final e in expenses) {
      final supplier = e.supplierId == null ? null : supplierName(e.supplierId);
      var index = 1;
      for (final r in receipts[e.id] ?? const <ReceiptData>[]) {
        final file = store.fileFor(r.relativePath);
        if (!await file.exists()) {
          missing++;
          continue;
        }
        final ext = r.kind == ReceiptKind.pdf ? 'pdf' : 'jpg';
        String name;
        // Two expenses can share date, supplier and invoice: keep names unique.
        do {
          name = receiptFileName(
            date: e.date,
            supplier: supplier,
            invoice: e.invoiceNumber,
            index: index++,
            ext: ext,
          );
        } while (!used.add(name));
        await encoder.addFile(file, 'justificantes/$name', ArchiveFile.STORE);
        (fileNames[e.id] ??= []).add(name);
      }
    }

    final table = expenseTable(
      'gastos',
      expenses,
      labels,
      ExportNames(supplier: supplierName, category: categoryName ?? (id) => id),
      receiptNames: fileNames,
    );
    final csv = encodeCsv(table, labels.locale);
    encoder.addArchiveFile(ArchiveFile('gastos.csv', csv.length, csv));
  } finally {
    await encoder.close();
  }
  return GestorZipResult(zip: target, missingReceipts: missing);
}
