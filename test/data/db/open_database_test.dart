import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/db/open_database.dart';
import 'package:to_audit/data/security/db_key_manager.dart';
import 'package:to_audit/data/security/key_store.dart';
import 'package:to_audit/domain/enums.dart';

import '../../support/sqlcipher.dart';

const keyA = '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';
const keyB = 'ffeeddccbbaa99887766554433221100ffeeddccbbaa99887766554433221100';

void main() {
  late Directory dir;
  late File file;

  setUpAll(quietSqlCipherLog);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('to_audit_db_');
    file = File('${dir.path}/to_audit.db');
  });
  tearDown(() => dir.delete(recursive: true));

  Future<void> insertDay(AppDatabase db) => db
      .into(db.days)
      .insert(
        DaysCompanion.insert(
          id: 'day-1',
          createdAt: nowIso(),
          updatedAt: nowIso(),
          date: '2026-11-09',
          status: DayStatus.open,
          openingFloatCents: 0,
        ),
      );

  test('the bundled SQLite is SQLCipher', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final row = await db.customSelect('PRAGMA cipher_version').getSingle();
    expect(row.data.values.single, isA<String>());
    expect(row.data.values.single as String, isNotEmpty);
    await db.close();
  });

  test('key A opens, key B throws, the file is not plain SQLite', () async {
    final created = await openEncryptedDatabase(file: file, hexKey: keyA);
    await insertDay(created);
    await created.close();

    final wrong = await openEncryptedDatabase(file: file, hexKey: keyB);
    await expectLater(wrong.select(wrong.days).get(), throwsA(anything));
    await wrong.close().catchError((_) {});

    final right = await openEncryptedDatabase(file: file, hexKey: keyA);
    final days = await right.select(right.days).get();
    expect(days.map((d) => d.date), ['2026-11-09']);
    await right.close();

    final header = (await file.openRead(0, 16).first).take(16).toList();
    expect(header, isNot(ascii.encode('SQLite format 3\u0000')));
  });

  test('openEncryptedDatabase rejects a key that is not 64 hex chars', () {
    expect(
      () => openEncryptedDatabase(file: file, hexKey: 'abc'),
      throwsArgumentError,
    );
    expect(
      () => openEncryptedDatabase(file: file, hexKey: "${keyA.substring(1)}'"),
      throwsArgumentError,
    );
  });

  test('openAppDatabase creates a key on first run and reuses it', () async {
    final store = MemoryKeyStore();
    final first = await openAppDatabase(
      file: file,
      keys: DbKeyManager(store),
      filesRoot: dir,
    );
    await insertDay(first);
    await first.close();
    expect(store.values['db_key'], isNotNull);

    final again = await openAppDatabase(
      file: file,
      keys: DbKeyManager(store),
      filesRoot: dir,
    );
    expect(await again.select(again.days).get(), hasLength(1));
    await again.close();
  });

  test('openAppDatabase never creates a new DB over one without key', () async {
    final created = await openEncryptedDatabase(file: file, hexKey: keyA);
    await insertDay(created);
    await created.close();
    final before = await file.readAsBytes();

    final store = MemoryKeyStore();
    await expectLater(
      openAppDatabase(file: file, keys: DbKeyManager(store), filesRoot: dir),
      throwsA(isA<DatabaseKeyMissingException>()),
    );
    expect(store.values, isEmpty);
    expect(await file.readAsBytes(), before);
  });

  test('openAppDatabase recovers a restore killed after db → .bak', () async {
    final store = MemoryKeyStore();
    final keys = DbKeyManager(store);
    final created = await openAppDatabase(
      file: file,
      keys: keys,
      filesRoot: dir,
    );
    await insertDay(created);
    await created.close();
    // Killed between "rename db to .bak" and "rename .restoring into place".
    await file.rename('${file.path}.bak');
    await File('${file.path}.restoring').writeAsString('staged');
    await File('${file.path}.restore-in-progress').writeAsString('restore');

    final reopened = await openAppDatabase(
      file: file,
      keys: keys,
      filesRoot: dir,
    );
    expect(await reopened.select(reopened.days).get(), hasLength(1));
    await reopened.close();
    expect(await File('${file.path}.bak').exists(), isFalse);
    expect(await File('${file.path}.restore-in-progress').exists(), isFalse);
    expect(await File('${file.path}.restoring').exists(), isFalse);
  });
}
