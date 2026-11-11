import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

/// A restore cannot start because an earlier one left its marker or `.bak`
/// files: the app must be restarted so start-up recovery can decide.
class RestoreNeedsRestartException extends StateError {
  RestoreNeedsRestartException()
    : super(
        'An earlier restore was not finished: restart the app to recover '
        'it before restoring again',
      );
}

/// Files a restore works with, next to the database and the receipts.
///
/// A restore stages the new data in `.restoring`, writes the [marker], moves
/// the current data to `.bak`, moves `.restoring` into place and deletes the
/// marker once the new database is verified (see `BackupService.restore`).
class RestorePaths {
  RestorePaths({required this.dbFile, required Directory filesRoot})
    : receipts = Directory(p.join(filesRoot.path, 'receipts'));

  final File dbFile;
  final Directory receipts;

  File get dbBak => File('${dbFile.path}.bak');
  File get dbStaged => File('${dbFile.path}.restoring');

  /// Exists from just before the database is closed until the restored one
  /// is verified, or until a rollback has put every `.bak` back.
  File get marker => File('${dbFile.path}.restore-in-progress');
  Directory get receiptsBak => Directory('${receipts.path}.bak');
  Directory get receiptsStaged => Directory('${receipts.path}.restoring');
}

/// Marker payload words: there was no database / receipts folder before the
/// restore.
const markerNoDb = 'no-db';
const markerNoReceipts = 'no-receipts';

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

/// Puts every `.bak` of [paths] back in place, replacing the live database
/// (with its journals) and receipts. Each part is attempted even when the
/// other fails; the first error is rethrown at the end. Nothing happens to a
/// live file that has no `.bak`.
Future<void> putBackupsBack(RestorePaths paths) async {
  Object? error;
  StackTrace? trace;
  Future<void> attempt(Future<void> Function() action) async {
    try {
      await action();
    } catch (e, st) {
      error ??= e;
      trace ??= st;
    }
  }

  await attempt(() async {
    if (!await paths.dbBak.exists()) return;
    await deleteDbFiles(paths.dbFile);
    await moveDbFiles(paths.dbBak, paths.dbFile);
  });
  await attempt(() async {
    if (!await paths.receiptsBak.exists()) return;
    await deleteDirIfExists(paths.receipts);
    await paths.receiptsBak.rename(paths.receipts.path);
  });
  if (error case final e?) Error.throwWithStackTrace(e, trace!);
}

/// Whether [db] opens with [hexKey] and holds the app tables.
bool _opens(File db, String hexKey) {
  final Database conn;
  try {
    conn = sqlite3.open(db.path, mode: OpenMode.readWrite);
  } on SqliteException {
    return false;
  }
  try {
    conn.execute("PRAGMA key = \"x'$hexKey'\"");
    conn.select('SELECT count(*) FROM dia_caja');
    conn.select('SELECT count(*) FROM gasto');
    return true;
  } on SqliteException {
    return false;
  } finally {
    conn.close();
  }
}

/// Undoes or completes a restore that was interrupted (app killed, or a
/// rollback that could not finish). Call it only at app start, before the
/// database is opened, and never from inside a restore.
///
/// - Marker present: the restore was not verified, so every `.bak` goes back
///   in place (live files and journals are replaced), then the marker is
///   deleted. If that fails the marker stays and the error is rethrown.
/// - Marker absent: `.bak` files come from a verified restore whose cleanup
///   failed and are deleted, except that a `.bak` is moved back when the live
///   counterpart is missing (or, for the database, does not open with
///   [hexKey] or lacks the app tables).
///
/// `.restoring` leftovers are deleted in both cases.
Future<void> recoverInterruptedRestore({
  required File dbFile,
  required Directory filesRoot,
  required String hexKey,
}) async {
  if (!RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(hexKey)) {
    throw ArgumentError('hexKey must be 64 hex characters');
  }
  final paths = RestorePaths(dbFile: dbFile, filesRoot: filesRoot);

  if (await paths.marker.exists()) {
    // The payload says what did not exist before the restore, so the
    // unverified restored data is removed instead of being left in place.
    final payload = await paths.marker.readAsString();
    if (payload.contains(markerNoDb) && !await paths.dbBak.exists()) {
      await deleteDbFiles(dbFile);
    }
    if (payload.contains(markerNoReceipts) &&
        !await paths.receiptsBak.exists()) {
      await deleteDirIfExists(paths.receipts);
    }
    await putBackupsBack(paths);
    await paths.marker.delete();
  } else {
    if (await paths.dbBak.exists()) {
      if (await dbFile.exists() && _opens(dbFile, hexKey)) {
        await deleteDbFiles(paths.dbBak);
      } else {
        await deleteDbFiles(dbFile);
        await moveDbFiles(paths.dbBak, dbFile);
      }
    }
    if (await paths.receiptsBak.exists()) {
      if (await paths.receipts.exists()) {
        await paths.receiptsBak.delete(recursive: true);
      } else {
        await paths.receiptsBak.rename(paths.receipts.path);
      }
    }
  }
  await deleteDbFiles(paths.dbStaged);
  await deleteDirIfExists(paths.receiptsStaged);
}
