import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import '../security/db_key_manager.dart';
import 'backup_service.dart';
import 'db_snapshotter.dart';
import 'restore_recovery.dart';
import 'toaudit_format.dart';

/// Schema version of the app database (see `AppDatabase.schemaVersion`).
const currentSchemaVersion = 1;

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
    currentSchemaVersion: currentSchemaVersion,
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

  try {
    if (await paths.marker.exists() ||
        await paths.dbBak.exists() ||
        await paths.receiptsBak.exists()) {
      throw StateError(
        'An earlier restore was not finished: restart the app to recover '
        'it before restoring again',
      );
    }
    final key = await keys.getOrCreateKey();
    await dbFile.parent.create(recursive: true);
    await deleteDbFiles(paths.dbStaged);
    await deleteDirIfExists(paths.receiptsStaged);
    await paths.receipts.create(recursive: true);

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

    try {
      await paths.marker.writeAsString('restore', flush: true);
      if (await dbFile.exists()) await moveDbFiles(dbFile, paths.dbBak);
      await paths.receipts.rename(paths.receiptsBak.path);
      await moveDbFiles(paths.dbStaged, dbFile);
      await paths.receiptsStaged.rename(paths.receipts.path);

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
        // A database that had no `.bak` (none existed) must not stay.
        if (!await paths.dbBak.exists()) await deleteDbFiles(dbFile);
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
  } finally {
    await step(() => deleteDirIfExists(source));
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
