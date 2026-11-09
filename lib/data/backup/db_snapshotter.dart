import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

import '../db/app_database.dart';

/// Copies the app database to and from a plain (unencrypted) SQLite file.
abstract class DbSnapshotter {
  /// Writes a plain copy of the open database to [dest] (replaced if present).
  Future<void> exportPlain(File dest);

  /// Creates [destEncrypted] (which must not exist) from the plain database
  /// [src], encrypted with [hexKey].
  Future<void> importPlain(File src, File destEncrypted, String hexKey);
}

String _quote(String path) => "'${path.replaceAll("'", "''")}'";

final _hexKey = RegExp(r'^[0-9a-fA-F]{64}$');

/// Production snapshotter for the SQLCipher database, using
/// `sqlcipher_export` (which also copies `user_version`).
class SqlCipherSnapshotter implements DbSnapshotter {
  SqlCipherSnapshotter(this._db);

  final AppDatabase _db;

  @override
  Future<void> exportPlain(File dest) async {
    if (await dest.exists()) await dest.delete();
    await _db.customStatement(
      'ATTACH DATABASE ${_quote(dest.path)} AS plaintext KEY \'\'',
    );
    try {
      await _db.customSelect("SELECT sqlcipher_export('plaintext')").get();
    } finally {
      await _db.customStatement('DETACH DATABASE plaintext');
    }
  }

  @override
  Future<void> importPlain(File src, File destEncrypted, String hexKey) async {
    if (!_hexKey.hasMatch(hexKey)) {
      throw ArgumentError('hexKey must be 64 hex characters');
    }
    final db = sqlite3.open(src.path);
    try {
      db.execute(
        'ATTACH DATABASE ${_quote(destEncrypted.path)} AS encrypted '
        "KEY \"x'$hexKey'\"",
      );
      try {
        db.select("SELECT sqlcipher_export('encrypted')");
      } finally {
        db.execute('DETACH DATABASE encrypted');
      }
    } finally {
      db.close();
    }
  }
}

/// Snapshotter for a plain (unencrypted) database, used in tests:
/// `VACUUM INTO` to export, a file copy to import ([hexKey] is ignored).
class PlainSnapshotter implements DbSnapshotter {
  PlainSnapshotter(this._db);

  final AppDatabase _db;

  @override
  Future<void> exportPlain(File dest) async {
    if (await dest.exists()) await dest.delete();
    await _db.customStatement('VACUUM INTO ${_quote(dest.path)}');
  }

  @override
  Future<void> importPlain(File src, File destEncrypted, String hexKey) async {
    await src.copy(destEncrypted.path);
  }
}
