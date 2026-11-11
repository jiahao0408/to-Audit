import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:to_audit/data/backup/backup_service.dart';
import 'package:to_audit/data/backup/db_snapshotter.dart';
import 'package:to_audit/data/backup/offline_restore.dart';
import 'package:to_audit/data/backup/restore_recovery.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/db/open_database.dart';
import 'package:to_audit/data/security/db_key_manager.dart';
import 'package:to_audit/data/security/key_store.dart';

import '../../support/sqlcipher.dart';
import 'backup_service_test.dart' show Phone, keyA, keyB;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  setUpAll(quietSqlCipherLog);

  late Phone source;
  late Directory target;
  late File backup;

  setUp(() async {
    source = await Phone.create('rb_src', hexKey: keyA);
    await source.seed();
    backup = await source.service().export(
      'secret-pass',
      now: DateTime(2026, 11, 8, 10),
    );
    target = await Directory.systemTemp.createTemp('rb_dst');
  });

  tearDown(() async {
    await source.dispose();
    await target.delete(recursive: true);
  });

  File db() => File('${target.path}/to_audit.db');
  Directory receipts() => Directory('${target.path}/files/receipts');
  File marker() => File('${db().path}.restore-in-progress');

  /// An existing, working database and one receipt (key B).
  Future<(DbKeyManager, List<int>)> original() async {
    final store = MemoryKeyStore();
    await store.write(DbKeyManager.storageKey, keyB);
    final old = await openEncryptedDatabase(file: db(), hexKey: keyB);
    await old.customSelect('SELECT COUNT(*) c FROM dia_caja').get();
    await old.close();
    await receipts().create(recursive: true);
    await File('${receipts().path}/old.jpg').writeAsBytes([1, 2, 3]);
    return (DbKeyManager(store), db().readAsBytesSync());
  }

  void expectOriginal(List<int> bytes) {
    expect(db().readAsBytesSync(), bytes);
    expect(File('${receipts().path}/old.jpg').readAsBytesSync(), [1, 2, 3]);
    expect(File('${db().path}.bak').existsSync(), isFalse);
    expect(File('${db().path}.restoring').existsSync(), isFalse);
    expect(marker().existsSync(), isFalse);
    expect(Directory('${receipts().path}.bak').existsSync(), isFalse);
    expect(Directory('${receipts().path}.restoring').existsSync(), isFalse);
  }

  Future<void> runWith(
    DbKeyManager keys, {
    Future<void> Function(File, File, String)? importPlain,
    int dayDelta = 0,
  }) async {
    final preview = await BackupService.inspectFile(
      backup,
      'secret-pass',
      tempRoot: Directory('${target.path}/tmp'),
      currentSchemaVersion: AppDatabase.currentSchemaVersion,
    );
    await applyPreviewWithoutOpenDb(
      preview: BackupPreview(
        decryptedDir: preview.decryptedDir,
        createdAt: preview.createdAt,
        schemaVersion: preview.schemaVersion,
        days: preview.days + dayDelta,
        expenses: preview.expenses,
      ),
      dbFile: db(),
      filesRoot: Directory('${target.path}/files'),
      keys: keys,
      importPlain: importPlain ?? importPlainToSqlCipher,
    );
  }

  test('a failing marker write never touches the original', () async {
    final (keys, bytes) = await original();
    Directory(marker().path).createSync();
    await expectLater(runWith(keys), throwsA(anything));
    Directory(marker().path).deleteSync();
    expectOriginal(bytes);
  });

  test('a failure while staging leaves the original untouched', () async {
    final (keys, bytes) = await original();
    await expectLater(
      runWith(
        keys,
        importPlain: (src, dest, key) async {
          File('${dest.path}-journal').writeAsStringSync('partial');
          throw const FileSystemException('disk full');
        },
      ),
      throwsA(isA<FileSystemException>()),
    );
    expectOriginal(bytes);
  });

  test('a failure during the swap puts the original back', () async {
    final (keys, bytes) = await original();
    await expectLater(
      runWith(
        keys,
        importPlain: (src, dest, key) async {
          await importPlainToSqlCipher(src, dest, key);
          // A non-empty folder where receipts.bak must go: the rename fails
          // after the database was already moved aside.
          final decoy = Directory('${receipts().path}.bak')..createSync();
          File('${decoy.path}/x').writeAsStringSync('x');
        },
      ),
      throwsA(isA<FileSystemException>()),
    );
    expect(db().readAsBytesSync(), bytes);
    expect(File('${db().path}.bak').existsSync(), isFalse);
    expect(marker().existsSync(), isFalse);
  });

  test('a count mismatch rolls back to the original', () async {
    final (keys, bytes) = await original();
    await expectLater(
      runWith(keys, dayDelta: 1),
      throwsA(isA<BackupVerifyException>()),
    );
    expectOriginal(bytes);
  });

  test('with no original, a failed verify leaves nothing behind', () async {
    final keys = DbKeyManager(MemoryKeyStore());
    await expectLater(
      runWith(keys, dayDelta: 1),
      throwsA(isA<BackupVerifyException>()),
    );
    expect(db().existsSync(), isFalse);
    expect(receipts().existsSync(), isFalse);
    expect(marker().existsSync(), isFalse);
  });

  test('a kill before verify with no original: recovery removes the '
      'unverified data', () async {
    // State after a kill: restored data in place, marker says no original.
    final keys = DbKeyManager(MemoryKeyStore());
    await restoreWithoutOpenDb(
      backup: backup,
      password: 'secret-pass',
      dbFile: db(),
      filesRoot: Directory('${target.path}/files'),
      tempRoot: Directory('${target.path}/tmp'),
      keys: keys,
    );
    marker().writeAsStringSync('no-db,no-receipts');
    await recoverInterruptedRestore(
      dbFile: db(),
      filesRoot: Directory('${target.path}/files'),
      hexKey: (await keys.existingKey())!,
    );
    expect(db().existsSync(), isFalse);
    expect(receipts().existsSync(), isFalse);
    expect(marker().existsSync(), isFalse);
  });

  test('lost key with leftovers: they move to .orphan and the restore '
      'goes ahead', () async {
    db().writeAsStringSync('damaged');
    File('${db().path}.bak').writeAsStringSync('old bak');
    marker().writeAsStringSync('restore');
    Directory('${receipts().path}.bak').createSync(recursive: true);
    final keys = DbKeyManager(MemoryKeyStore());
    await runWith(keys);
    expect(File('${db().path}.orphan').readAsStringSync(), 'old bak');
    expect(Directory('${receipts().path}.orphan').existsSync(), isTrue);
    expect(marker().existsSync(), isFalse);
    final conn = sqlite3.open(db().path);
    conn.execute("PRAGMA key = \"x'${await keys.existingKey()}'\"");
    expect(conn.select('SELECT COUNT(*) c FROM dia_caja').first['c'], 2);
    conn.close();
  });

  test('with a key and leftovers it asks to restart the app', () async {
    final (keys, _) = await original();
    marker().writeAsStringSync('restore');
    await expectLater(
      runWith(keys),
      throwsA(isA<RestoreNeedsRestartException>()),
    );
  });
}
