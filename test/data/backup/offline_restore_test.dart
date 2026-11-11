import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:to_audit/data/backup/offline_restore.dart';
import 'package:to_audit/data/backup/toaudit_format.dart'
    show BackupDecryptException;
import 'package:to_audit/data/db/open_database.dart';
import 'package:to_audit/data/security/db_key_manager.dart';
import 'package:to_audit/data/security/key_store.dart';

import '../../support/sqlcipher.dart';
import 'backup_service_test.dart' show Phone, keyA;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  setUpAll(quietSqlCipherLog);

  late Phone source;
  late Directory target;
  late File backup;

  setUp(() async {
    source = await Phone.create('off_src', hexKey: keyA);
    await source.seed();
    final svc = source.service();
    backup = await svc.export('secret-pass', now: DateTime(2026, 11, 8, 10));
    target = await Directory.systemTemp.createTemp('off_dst');
  });

  tearDown(() async {
    await source.dispose();
    await target.delete(recursive: true);
  });

  Future<void> run(DbKeyManager keys, {String password = 'secret-pass'}) =>
      restoreWithoutOpenDb(
        backup: backup,
        password: password,
        dbFile: File('${target.path}/to_audit.db'),
        filesRoot: Directory('${target.path}/files'),
        tempRoot: Directory('${target.path}/tmp'),
        keys: keys,
      );

  test(
    'restores into an empty folder with a new key and opens normally',
    () async {
      final keys = DbKeyManager(MemoryKeyStore());
      await run(keys);
      final db = await openAppDatabase(
        file: File('${target.path}/to_audit.db'),
        keys: keys,
        filesRoot: Directory('${target.path}/files'),
      );
      final days = await db
          .customSelect('SELECT COUNT(*) c FROM dia_caja')
          .getSingle();
      expect(days.read<int>('c'), 2);
      await db.close();
      expect(File('${target.path}/files/receipts/r1.jpg').existsSync(), isTrue);
      expect(
        File('${target.path}/to_audit.db.restore-in-progress').existsSync(),
        isFalse,
      );
      expect(File('${target.path}/to_audit.db.bak').existsSync(), isFalse);
    },
  );

  test('replaces an unreadable database file', () async {
    await File('${target.path}/to_audit.db').writeAsString('not a database');
    final keys = DbKeyManager(MemoryKeyStore());
    await run(keys);
    final conn = sqlite3.open('${target.path}/to_audit.db');
    conn.execute("PRAGMA key = \"x'${await keys.existingKey()}'\"");
    expect(conn.select('SELECT COUNT(*) c FROM gasto').first['c'], 3);
    conn.close();
  });

  test('wrong password throws and leaves nothing behind', () async {
    final keys = DbKeyManager(MemoryKeyStore());
    await expectLater(
      run(keys, password: 'nope-nope-1'),
      throwsA(isA<BackupDecryptException>()),
    );
    expect(File('${target.path}/to_audit.db').existsSync(), isFalse);
    expect(Directory('${target.path}/tmp').listSync(), isEmpty);
  });
}
