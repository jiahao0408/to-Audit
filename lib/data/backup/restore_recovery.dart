import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

/// Files a restore works with, next to the database and the receipts.
///
/// A restore stages the new data in `.restoring`, moves the current data to
/// `.bak`, then moves `.restoring` into place (see `BackupService.restore`).
class RestorePaths {
  RestorePaths({required this.dbFile, required Directory filesRoot})
    : receipts = Directory(p.join(filesRoot.path, 'receipts'));

  final File dbFile;
  final Directory receipts;

  File get dbBak => File('${dbFile.path}.bak');
  File get dbStaged => File('${dbFile.path}.restoring');
  Directory get receiptsBak => Directory('${receipts.path}.bak');
  Directory get receiptsStaged => Directory('${receipts.path}.restoring');
}

/// SQLite files that belong to a database file and must follow it.
const _siblings = ['-journal', '-wal', '-shm'];

/// Deletes [db] and its `-journal`, `-wal` and `-shm` files.
Future<void> deleteDbFiles(File db) async {
  for (final f in [db, for (final s in _siblings) File('${db.path}$s')]) {
    if (await f.exists()) await f.delete();
  }
}

/// Renames [from] to [to] together with its journal files. Stale journal
/// files of [to] are removed first so they cannot pair with the new file.
Future<void> moveDbFiles(File from, File to) async {
  for (final s in _siblings) {
    final stale = File('${to.path}$s');
    if (await stale.exists()) await stale.delete();
  }
  await from.rename(to.path);
  for (final s in _siblings) {
    final f = File('${from.path}$s');
    if (await f.exists()) await f.rename('${to.path}$s');
  }
}

Future<void> deleteDirIfExists(Directory dir) async {
  if (await dir.exists()) await dir.delete(recursive: true);
}

/// Whether [db] opens as a SQLCipher database with [hexKey].
bool _opens(File db, String hexKey) {
  final Database conn;
  try {
    conn = sqlite3.open(db.path, mode: OpenMode.readWrite);
  } on SqliteException {
    return false;
  }
  try {
    conn.execute("PRAGMA key = \"x'$hexKey'\"");
    conn.select('SELECT count(*) FROM sqlite_master');
    return true;
  } on SqliteException {
    return false;
  } finally {
    conn.close();
  }
}

/// Undoes or completes a restore that was interrupted (app killed). Call it
/// before opening the database.
///
/// When `.bak` files exist the restore was interrupted after the current
/// data was moved aside. They are put back when a `.restoring` leftover
/// exists or the live database is missing or does not open with [hexKey];
/// otherwise the restore had finished and the `.bak` files are deleted.
/// `.restoring` leftovers are always deleted.
Future<void> recoverInterruptedRestore({
  required File dbFile,
  required Directory filesRoot,
  required String hexKey,
}) async {
  if (!RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hexKey)) {
    throw ArgumentError('hexKey must be 64 hex characters');
  }
  final paths = RestorePaths(dbFile: dbFile, filesRoot: filesRoot);
  final staging =
      await paths.dbStaged.exists() || await paths.receiptsStaged.exists();
  final dbBak = await paths.dbBak.exists();
  final receiptsBak = await paths.receiptsBak.exists();

  if (dbBak || receiptsBak) {
    final rollBack =
        staging ||
        (dbBak && (!await dbFile.exists() || !_opens(dbFile, hexKey)));
    if (rollBack) {
      if (dbBak) {
        await deleteDbFiles(dbFile);
        await moveDbFiles(paths.dbBak, dbFile);
      }
      if (receiptsBak) {
        await deleteDirIfExists(paths.receipts);
        await paths.receiptsBak.rename(paths.receipts.path);
      }
    } else {
      await deleteDbFiles(paths.dbBak);
      await deleteDirIfExists(paths.receiptsBak);
    }
  }
  await deleteDbFiles(paths.dbStaged);
  await deleteDirIfExists(paths.receiptsStaged);
}
