import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;

import '../../domain/enums.dart';
import '../db/app_database.dart' show newId;

/// Compresses the image at [source] to a JPEG whose longest side is at most
/// [maxSide], returning the encoded bytes.
typedef ImageCompressor = Future<List<int>> Function(
  File source, {
  int maxSide,
  int quality,
});

Future<List<int>> _defaultCompressor(
  File source, {
  int maxSide = 1600,
  int quality = 75,
}) async {
  final bytes = await FlutterImageCompress.compressWithFile(
    source.absolute.path,
    minWidth: maxSide,
    minHeight: maxSide,
    quality: quality,
    format: CompressFormat.jpeg,
  );
  if (bytes == null) {
    throw const FileSystemException('Image compression failed');
  }
  return bytes;
}

/// Keeps receipt files (compressed photos, copied PDFs) in private storage
/// under `<root>/receipts/`.
class ReceiptStore {
  ReceiptStore(this._root, {ImageCompressor? compressor})
    : _compressor = compressor ?? _defaultCompressor;

  final Directory _root;
  final ImageCompressor _compressor;

  static const _maxSide = 1600;
  static const _quality = 75;

  /// Stores [source] and returns its path relative to the root, with forward
  /// slashes (`receipts/<uuid>.jpg` or `receipts/<uuid>.pdf`).
  Future<String> save(File source, ReceiptKind kind) async {
    final ext = switch (kind) {
      ReceiptKind.photo => 'jpg',
      ReceiptKind.pdf => 'pdf',
    };
    final relative = 'receipts/${newId()}.$ext';
    final target = fileFor(relative);
    await target.parent.create(recursive: true);
    switch (kind) {
      case ReceiptKind.photo:
        final bytes = await _compressor(
          source,
          maxSide: _maxSide,
          quality: _quality,
        );
        await target.writeAsBytes(bytes, flush: true);
      case ReceiptKind.pdf:
        await source.copy(target.path);
    }
    return relative;
  }

  /// Resolves a relative path returned by [save] under the root.
  File fileFor(String relativePath) =>
      File(p.joinAll([_root.path, ...relativePath.split('/')]));
}
