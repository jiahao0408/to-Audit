import 'dart:io';

import 'package:drift/native.dart';

import '../backup/restore_recovery.dart';
import '../security/db_key_manager.dart';
import 'app_database.dart';

/// The database file exists but the key store has no key for it. Thrown
/// instead of creating a new database over the existing one.
class DatabaseKeyMissingException implements Exception {
  const DatabaseKeyMissingException(this.path);

  final String path;

  @override
  String toString() => 'DatabaseKeyMissingException: no key for $path';
}

final _hexKey = RegExp(r'^[0-9a-fA-F]{64}$');

/// Opens (or creates) the SQLCipher database at [file] with the raw 32-byte
/// key [hexKey] (64 hex chars, else [ArgumentError]). A wrong key fails on
/// the first query.
Future<AppDatabase> openEncryptedDatabase({
  required File file,
  required String hexKey,
}) async {
  if (!_hexKey.hasMatch(hexKey)) {
    throw ArgumentError('hexKey must be 64 hex characters');
  }
  return AppDatabase(
    NativeDatabase.createInBackground(
      file,
      setup: (db) {
        db.execute("PRAGMA key = \"x'$hexKey'\"");
        db.select('select count(*) from sqlite_master');
      },
    ),
  );
}

/// Opens the app database with the key from [keys], creating the key on
/// first run. First undoes or completes an interrupted restore (see
/// [recoverInterruptedRestore]; receipts live under [filesRoot]), so a kill
/// in the middle of a restore never leads to a new empty database. Throws
/// [DatabaseKeyMissingException] when no key is stored but [file], its `.bak`
/// or its `.restore-in-progress` marker exists.
Future<AppDatabase> openAppDatabase({
  required File file,
  required DbKeyManager keys,
  required Directory filesRoot,
}) async {
  final existing = await keys.existingKey();
  if (existing != null) {
    await recoverInterruptedRestore(
      dbFile: file,
      filesRoot: filesRoot,
      hexKey: existing,
    );
  } else if (await file.exists() ||
      await File('${file.path}.bak').exists() ||
      await File('${file.path}.restore-in-progress').exists()) {
    // Any trace of a database (or of a restore that moved it aside) with no
    // key: never create a new database over it.
    throw DatabaseKeyMissingException(file.path);
  }
  return openEncryptedDatabase(file: file, hexKey: await keys.getOrCreateKey());
}

/// [openAppDatabase] plus a real query. The key is only applied on the first
/// query, so a wrong key or a damaged file would otherwise surface later,
/// inside the UI. On failure the database is closed and the error rethrown.
Future<AppDatabase> openAndProbe({
  required File file,
  required DbKeyManager keys,
  required Directory filesRoot,
}) async {
  final db = await openAppDatabase(
    file: file,
    keys: keys,
    filesRoot: filesRoot,
  );
  try {
    await db.customSelect('select count(*) from dia_caja').get();
    return db;
  } catch (_) {
    try {
      await db.close();
    } catch (_) {}
    rethrow;
  }
}
