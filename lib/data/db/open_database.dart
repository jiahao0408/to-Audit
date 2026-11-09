import 'dart:io';

import 'package:drift/native.dart';

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
/// first run. Throws [DatabaseKeyMissingException] when [file] exists but no
/// key is stored.
Future<AppDatabase> openAppDatabase({
  required File file,
  required DbKeyManager keys,
}) async {
  if (await file.exists() && await keys.existingKey() == null) {
    throw DatabaseKeyMissingException(file.path);
  }
  return openEncryptedDatabase(file: file, hexKey: await keys.getOrCreateKey());
}
