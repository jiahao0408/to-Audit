import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../../domain/dates.dart';
import '../db/app_database.dart';
import '../repositories/settings_repository.dart';
import 'db_snapshotter.dart';
import 'toaudit_format.dart';

/// A decrypted and verified backup, ready for [BackupService.restore].
class BackupPreview {
  const BackupPreview({
    required this.decryptedDir,
    required this.createdAt,
    required this.schemaVersion,
    required this.days,
    required this.expenses,
  });

  /// Holds `db.sqlite` and `receipts/` in plain form. [BackupService.restore]
  /// deletes it; delete it yourself when the restore is not done.
  final Directory decryptedDir;
  final DateTime createdAt;
  final int schemaVersion, days, expenses;
}

/// The backup comes from a newer app version (higher schema version).
class BackupTooNewException implements Exception {
  const BackupTooNewException();

  @override
  String toString() => 'BackupTooNewException';
}

/// Exports and restores `.toaudit` backups: a ZIP with `db.sqlite`,
/// `receipts/...` and `manifest.json`, encrypted with [ToauditFormat].
///
/// After [restore] the database has been reopened through `reopenDb`, so the
/// `db` given here is closed: build a new service for further work.
class BackupService {
  BackupService({
    required this._db,
    required this._snapshotter,
    required this._filesRoot,
    required this._tempRoot,
    required this._settings,
    required this._closeDb,
    required this._reopenDb,
    required this._dbFile,
    required this._hexKey,
    this._iterations = 600000,
  });

  final AppDatabase _db;
  final DbSnapshotter _snapshotter;
  final Directory _filesRoot;
  final Directory _tempRoot;
  final SettingsRepository _settings;
  final Future<void> Function() _closeDb;
  final Future<void> Function() _reopenDb;
  final File _dbFile;
  final Future<String> Function() _hexKey;
  final int _iterations;

  static const minPasswordLength = 8;
  static const _dbEntry = 'db.sqlite';
  static const _manifestEntry = 'manifest.json';
  static const _receiptsDir = 'receipts';
  static final _sha256Hex = RegExp(r'^[0-9a-f]{64}$');

  /// Writes `to-audit-YYYY-MM-DD.toaudit` (date of [now]) in the temp root,
  /// encrypted with [password] (at least 8 characters, else
  /// [ArgumentError]), and records [now] as the last backup.
  Future<File> export(String password, {required DateTime now}) async {
    if (password.length < minPasswordLength) {
      throw ArgumentError('The password must have at least 8 characters');
    }
    await _tempRoot.create(recursive: true);
    final out = File(p.join(_tempRoot.path, 'to-audit-${ymd(now)}.toaudit'));
    final work = await _tempRoot.createTemp('export_');
    var writing = false;
    try {
      final dbCopy = File(p.join(work.path, _dbEntry));
      await _snapshotter.exportPlain(dbCopy);
      final receipts = await _receiptFiles();
      final hashes = <String, String>{_dbEntry: await _sha256(dbCopy)};
      for (final e in receipts.entries) {
        hashes[e.key] = await _sha256(e.value);
      }
      final manifest = utf8.encode(
        jsonEncode({
          'schemaVersion': _db.schemaVersion,
          'createdAt': now.toUtc().toIso8601String(),
          'days': await _count('dia_caja'),
          'expenses': await _count('gasto'),
          'files': hashes,
        }),
      );

      final zip = File(p.join(work.path, 'backup.zip'));
      final encoder = ZipFileEncoder()..create(zip.path);
      try {
        await encoder.addFile(dbCopy, _dbEntry);
        for (final e in receipts.entries) {
          // Photos and PDFs are already compressed.
          await encoder.addFile(e.value, e.key, ArchiveFile.STORE);
        }
        encoder.addArchiveFile(
          ArchiveFile(_manifestEntry, manifest.length, manifest),
        );
      } finally {
        await encoder.close();
      }

      writing = true;
      final sink = out.openWrite();
      try {
        await ToauditFormat.encrypt(
          zip.openRead(),
          sink,
          password,
          iterations: _iterations,
        );
      } finally {
        await sink.close();
      }
    } catch (_) {
      if (writing && await out.exists()) await out.delete();
      rethrow;
    } finally {
      await work.delete(recursive: true);
    }
    await _settings.setLastBackupAt(now);
    return out;
  }

  /// Decrypts [backup] into a temp folder and verifies every SHA-256 of the
  /// manifest ([BackupDecryptException] otherwise). A backup with a higher
  /// schema version than this app is [BackupTooNewException].
  Future<BackupPreview> inspect(File backup, String password) async {
    await _tempRoot.create(recursive: true);
    final dir = await _tempRoot.createTemp('restore_');
    final zip = File('${dir.path}.zip');
    try {
      final sink = zip.openWrite();
      try {
        // Not addStream: after a stream error, close() would throw instead.
        await for (final chunk in ToauditFormat.decrypt(backup, password)) {
          sink.add(chunk);
        }
      } finally {
        await sink.close();
      }
      await _extract(zip, dir);
      await zip.delete();
      return await _verify(dir);
    } catch (_) {
      await dir.delete(recursive: true);
      rethrow;
    } finally {
      if (await zip.exists()) await zip.delete();
    }
  }

  /// Replaces the database and receipts with those of [preview]. On any
  /// failure the previous files are put back, the database is reopened and
  /// the error is rethrown.
  Future<void> restore(BackupPreview preview) async {
    final source = preview.decryptedDir;
    final dbBak = File('${_dbFile.path}.bak');
    final receipts = Directory(p.join(_filesRoot.path, _receiptsDir));
    final receiptsBak = Directory('${receipts.path}.bak');
    try {
      // Left by an interrupted restore: may hold the only good copy.
      if (await dbBak.exists() || await receiptsBak.exists()) {
        throw StateError('A previous restore left .bak files behind');
      }
      final key = await _hexKey();

      var dbMoved = false, dbReplaced = false;
      var receiptsMoved = false, receiptsReplaced = false;
      try {
        await _closeDb();
        if (await _dbFile.exists()) {
          await _dbFile.rename(dbBak.path);
          dbMoved = true;
        }
        if (await receipts.exists()) {
          await receipts.rename(receiptsBak.path);
          receiptsMoved = true;
        }
        dbReplaced = true;
        await _snapshotter.importPlain(
          File(p.join(source.path, _dbEntry)),
          _dbFile,
          key,
        );
        receiptsReplaced = true;
        await _copyDir(Directory(p.join(source.path, _receiptsDir)), receipts);
        await _reopenDb();
      } catch (e, st) {
        // Best effort, step by step: a failing step must not stop the rest.
        Future<void> step(Future<void> Function() action) async {
          try {
            await action();
          } catch (_) {}
        }

        if (dbReplaced) {
          await step(() async {
            if (await _dbFile.exists()) await _dbFile.delete();
          });
        }
        if (dbMoved) await step(() => dbBak.rename(_dbFile.path));
        if (receiptsReplaced) {
          await step(() async {
            if (await receipts.exists()) await receipts.delete(recursive: true);
          });
        }
        if (receiptsMoved) await step(() => receiptsBak.rename(receipts.path));
        await step(_reopenDb);
        Error.throwWithStackTrace(e, st);
      }

      if (dbMoved) await dbBak.delete();
      if (receiptsMoved) await receiptsBak.delete(recursive: true);
    } finally {
      if (await source.exists()) await source.delete(recursive: true);
    }
  }

  Future<int> _count(String table) async {
    final row = await _db
        .customSelect('SELECT COUNT(*) AS c FROM $table')
        .getSingle();
    return row.read<int>('c');
  }

  /// Files under `<filesRoot>/receipts`, keyed by their `/`-separated path
  /// relative to the files root.
  Future<Map<String, File>> _receiptFiles() async {
    final dir = Directory(p.join(_filesRoot.path, _receiptsDir));
    final files = <String, File>{};
    if (!await dir.exists()) return files;
    await for (final e in dir.list(recursive: true, followLinks: false)) {
      if (e is File) files[_relative(e, _filesRoot)] = e;
    }
    return Map.fromEntries(
      files.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  static String _relative(FileSystemEntity e, Directory root) =>
      p.split(p.relative(e.path, from: root.path)).join('/');

  static Future<String> _sha256(File file) async =>
      (await sha256.bind(file.openRead()).first).toString();

  /// `db.sqlite`, `manifest.json` or a plain path under `receipts/`.
  static bool _allowedEntry(String name) {
    if (name == _dbEntry || name == _manifestEntry) return true;
    final parts = name.split('/');
    return parts.length > 1 &&
        parts.first == _receiptsDir &&
        parts.every(
          (s) => s.isNotEmpty && s != '.' && s != '..' && !s.contains(r'\'),
        ) &&
        !name.contains(':');
  }

  static Future<void> _extract(File zip, Directory dir) async {
    final input = InputFileStream(zip.path);
    try {
      final Archive archive;
      try {
        archive = ZipDecoder().decodeBuffer(input);
      } on FormatException {
        throw const BackupDecryptException('The backup is damaged');
      }
      for (final f in archive.files) {
        if (!f.isFile) continue;
        if (!_allowedEntry(f.name)) {
          throw const BackupDecryptException('Unexpected file in the backup');
        }
        final target = File(p.joinAll([dir.path, ...f.name.split('/')]));
        await target.parent.create(recursive: true);
        final output = OutputFileStream(target.path);
        try {
          f.writeContent(output);
        } finally {
          await output.close();
        }
      }
    } finally {
      await input.close();
    }
  }

  /// Reads the manifest of the extracted backup in [dir] and checks that the
  /// files on disk are exactly the listed ones, with matching hashes.
  Future<BackupPreview> _verify(Directory dir) async {
    const damaged = BackupDecryptException('The backup is damaged');
    final manifestFile = File(p.join(dir.path, _manifestEntry));
    if (!await manifestFile.exists()) throw damaged;
    final Object? json;
    try {
      json = jsonDecode(await manifestFile.readAsString());
    } on FormatException {
      throw damaged;
    }
    if (json is! Map<String, dynamic>) throw damaged;
    final schemaVersion = json['schemaVersion'];
    final createdAt = json['createdAt'];
    final days = json['days'];
    final expenses = json['expenses'];
    final files = json['files'];
    if (schemaVersion is! int ||
        createdAt is! String ||
        days is! int ||
        expenses is! int ||
        files is! Map<String, dynamic>) {
      throw damaged;
    }
    if (schemaVersion > _db.schemaVersion) throw const BackupTooNewException();
    final created = DateTime.tryParse(createdAt);
    if (created == null || !files.containsKey(_dbEntry)) throw damaged;

    final onDisk = <String>{};
    await for (final e in dir.list(recursive: true, followLinks: false)) {
      if (e is File) onDisk.add(_relative(e, dir));
    }
    onDisk.remove(_manifestEntry);
    if (onDisk.length != files.length || !onDisk.containsAll(files.keys)) {
      throw damaged;
    }
    for (final MapEntry(:key, :value) in files.entries) {
      if (value is! String || !_sha256Hex.hasMatch(value)) throw damaged;
      final file = File(p.joinAll([dir.path, ...key.split('/')]));
      if (await _sha256(file) != value) throw damaged;
    }

    return BackupPreview(
      decryptedDir: dir,
      createdAt: created,
      schemaVersion: schemaVersion,
      days: days,
      expenses: expenses,
    );
  }

  static Future<void> _copyDir(Directory src, Directory dest) async {
    await dest.create(recursive: true);
    if (!await src.exists()) return;
    await for (final e in src.list(recursive: true, followLinks: false)) {
      if (e is! File) continue;
      final target = File(
        p.joinAll([dest.path, ...p.split(p.relative(e.path, from: src.path))]),
      );
      await target.parent.create(recursive: true);
      await e.copy(target.path);
    }
  }
}
