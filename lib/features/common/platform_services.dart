import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

/// Sharing and saving files through the system. Behind an interface so tests
/// never reach the platform channels.
abstract class FileSharer {
  /// Opens the system share menu for [file]. Returns when the menu is done.
  Future<void> shareFile(File file, {String? mimeType});

  /// Lets the user save or print a PDF (system dialog).
  Future<void> savePdf(Uint8List bytes, String filename);
}

class PlatformFileSharer implements FileSharer {
  @override
  Future<void> shareFile(File file, {String? mimeType}) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: mimeType)]),
    );
  }

  @override
  Future<void> savePdf(Uint8List bytes, String filename) =>
      Printing.sharePdf(bytes: bytes, filename: filename);
}

final fileSharerProvider = Provider<FileSharer>((ref) => PlatformFileSharer());

/// Asks the user for a file to restore. Null when cancelled.
abstract class BackupFilePicker {
  Future<File?> pick();
}

class PlatformBackupFilePicker implements BackupFilePicker {
  @override
  Future<File?> pick() async {
    final picked = await FilePicker.pickFile(type: FileType.any);
    final path = picked?.path;
    return path == null ? null : File(path);
  }
}

final backupFilePickerProvider = Provider<BackupFilePicker>(
  (ref) => PlatformBackupFilePicker(),
);
