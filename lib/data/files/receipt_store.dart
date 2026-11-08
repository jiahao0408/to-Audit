import 'dart:io';
import 'dart:ui' as ui;

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

/// The `minWidth`/`minHeight` to give flutter_image_compress so the LONG side
/// of a [width]x[height] image ends up at most [maxLongSide] px. The plugin
/// scales by `max(1, min(width / minWidth, height / minHeight))`, i.e. it
/// bounds the short side, so the target short side is derived from the ratio.
/// An image already within the limit gets its own short side (scale 1).
int compressMinSide({
  required int width,
  required int height,
  required int maxLongSide,
}) {
  final long = width > height ? width : height;
  final short = width > height ? height : width;
  if (long <= maxLongSide) return short < 1 ? 1 : short;
  final target = (maxLongSide * short / long).round();
  return target < 1 ? 1 : target;
}

/// Reads the pixel size from the image header without decoding it.
Future<(int, int)> _imageSize(File source) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(
    await source.readAsBytes(),
  );
  try {
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    try {
      return (descriptor.width, descriptor.height);
    } finally {
      descriptor.dispose();
    }
  } finally {
    buffer.dispose();
  }
}

Future<List<int>> _defaultCompressor(
  File source, {
  int maxSide = 1600,
  int quality = 75,
}) async {
  final (width, height) = await _imageSize(source);
  final side = compressMinSide(
    width: width,
    height: height,
    maxLongSide: maxSide,
  );
  final bytes = await FlutterImageCompress.compressWithFile(
    source.absolute.path,
    minWidth: side,
    minHeight: side,
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
    try {
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
    } catch (_) {
      if (await target.exists()) await target.delete();
      rethrow;
    }
    return relative;
  }

  /// Resolves a relative path returned by [save] under the root.
  File fileFor(String relativePath) =>
      File(p.joinAll([_root.path, ...relativePath.split('/')]));
}
