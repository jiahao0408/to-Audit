import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import '../db/app_database.dart';
import '../security/db_key_manager.dart';
import 'backup_service.dart';
import 'db_snapshotter.dart';
import 'restore_recovery.dart';
import 'toaudit_format.dart';

/// Restores a `.toaudit` copy when the app has NO open database (start-up
/// error screen: lost key, damaged file).
///
/// Decrypts and verifies [backup] ([BackupDecryptException],
/// [BackupTooNewException]), creates a database key if the key store has none,
/// builds the encrypted database and receipts next to the current ones and
/// swaps them in with the same marker / `.bak` protocol as
/// [BackupService.restore]. The restored database is opened once to check it
/// holds the announced days and expenses ([BackupVerifyException] otherwise,
/// after putting everything back). Nothing is opened afterwards: the caller
/// tells the user to close and reopen the app.
Future<void> restoreWithoutOpenDb({
  required File backup,
  required String password,
  required File dbFile,
  required Directory filesRoot,
  required Directory tempRoot,
  required DbKeyManager keys,
  KeyDeriver deriveKey = isolateKeyDeriver,
  Future<void> Function(File src, File dest, String hexKey) importPlain =
      importPlainToSqlCipher,
}) async {
  final preview = await BackupService.inspectFile(
    backup,
    password,
    tempRoot: tempRoot,
    currentSchemaVersion: AppDatabase.currentSchemaVersion,
    deriveKey: deriveKey,
  );
  await applyPreviewWithoutOpenDb(
    preview: preview,
    dbFile: dbFile,
    filesRoot: filesRoot,
    keys: keys,
    importPlain: importPlain,
  );
}

/// Second half of [restoreWithoutOpenDb], for a screen that shows the
/// [BackupPreview] (from [BackupService.inspectFile]) for confirmation first.
/// Deletes [BackupPreview.decryptedDir] when done, whatever the outcome.
Future<void> applyPreviewWithoutOpenDb({
  required BackupPreview preview,
  required File dbFile,
  required Directory filesRoot,
  required DbKeyManager keys,
  Future<void> Function(File src, File dest, String hexKey) importPlain =
      importPlainToSqlCipher,
}) async {
  final source = preview.decryptedDir;
  final paths = RestorePaths(dbFile: dbFile, filesRoot: filesRoot);

  Future<void> step(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {}
  }

  // True when this call created the key: a rollback then deletes it again, so
  // the next start sees "key missing" instead of a key for nothing.
  var createdKey = false;
  try {
    final leftovers =
        await paths.marker.exists() ||
        await paths.dbBak.exists() ||
        await paths.receiptsBak.exists();
    if (leftovers) {
      if (await keys.existingKey() != null) {
        throw RestoreNeedsRestartException();
      }
      // No key: what a half-done restore left cannot be opened (its key is
      // gone) and start-up recovery will never run, so it is moved aside
      // instead of blocking the restore for good.
      await _orphan(paths);
    }
    createdKey = await keys.existingKey() == null;
    final key = await keys.getOrCreateKey();
    await dbFile.parent.create(recursive: true);
    await deleteDbFiles(paths.dbStaged);
    await deleteDirIfExists(paths.receiptsStaged);

    try {
      await importPlain(
        File(p.join(source.path, 'db.sqlite')),
        paths.dbStaged,
        key,
      );
      final src = Directory(p.join(source.path, 'receipts'));
      await paths.receiptsStaged.create(recursive: true);
      if (await src.exists()) {
        await for (final e in src.list(recursive: true, followLinks: false)) {
          if (e is! File) continue;
          final target = File(
            p.joinAll([
              paths.receiptsStaged.path,
              ...p.split(p.relative(e.path, from: src.path)),
            ]),
          );
          await target.parent.create(recursive: true);
          await e.copy(target.path);
        }
      }
    } catch (_) {
      await step(() => deleteDbFiles(paths.dbStaged));
      await step(() => deleteDirIfExists(paths.receiptsStaged));
      rethrow;
    }

    // What exists now is never deleted unless the new data was already put in
    // its place (`*Placed`) and there was nothing before it.
    final hadDb = await dbFile.exists();
    final hadReceipts = await paths.receipts.exists();
    var dbPlaced = false;
    var receiptsPlaced = false;
    try {
      await paths.marker.writeAsString(
        [if (!hadDb) markerNoDb, if (!hadReceipts) markerNoReceipts].join(',') +
            (hadDb && hadReceipts ? 'restore' : ''),
        flush: true,
      );
      if (hadDb) await moveDbFiles(dbFile, paths.dbBak);
      if (hadReceipts) await paths.receipts.rename(paths.receiptsBak.path);
      await moveDbFiles(paths.dbStaged, dbFile);
      dbPlaced = true;
      await paths.receiptsStaged.rename(paths.receipts.path);
      receiptsPlaced = true;

      final (days, expenses) = _counts(dbFile, key);
      if (days != preview.days || expenses != preview.expenses) {
        throw BackupVerifyException(
          'Restored $days days and $expenses expenses, '
          'expected ${preview.days} and ${preview.expenses}',
        );
      }
      await paths.marker.delete();
    } catch (_) {
      var putBack = true;
      try {
        if (dbPlaced && !hadDb) await deleteDbFiles(dbFile);
        if (receiptsPlaced && !hadReceipts) {
          await deleteDirIfExists(paths.receipts);
        }
        await putBackupsBack(paths);
      } catch (_) {
        putBack = false;
      }
      await step(() => deleteDbFiles(paths.dbStaged));
      await step(() => deleteDirIfExists(paths.receiptsStaged));
      if (putBack) {
        await step(() async {
          if (await paths.marker.exists()) await paths.marker.delete();
        });
      }
      rethrow;
    }
    await step(() => deleteDbFiles(paths.dbBak));
    await step(() => deleteDirIfExists(paths.receiptsBak));
  } catch (_) {
    if (createdKey) await step(keys.deleteKey);
    rethrow;
  } finally {
    await step(() => deleteDirIfExists(source));
  }
}

/// Moves the leftovers of an unfinished restore to `*.orphan`.
Future<void> _orphan(RestorePaths paths) async {
  if (await paths.marker.exists()) await paths.marker.delete();
  if (await paths.dbBak.exists()) {
    final orphan = File('${paths.dbFile.path}.orphan');
    await deleteDbFiles(orphan);
    await moveDbFiles(paths.dbBak, orphan);
  }
  if (await paths.receiptsBak.exists()) {
    final orphan = Directory('${paths.receipts.path}.orphan');
    await deleteDirIfExists(orphan);
    await paths.receiptsBak.rename(orphan.path);
  }
}

(int, int) _counts(File db, String hexKey) {
  final conn = sqlite3.open(db.path, mode: OpenMode.readOnly);
  try {
    conn.execute("PRAGMA key = \"x'$hexKey'\"");
    int count(String t) =>
        conn.select('SELECT COUNT(*) AS c FROM $t').first['c'] as int;
    return (count('dia_caja'), count('gasto'));
  } finally {
    conn.close();
  }
}
