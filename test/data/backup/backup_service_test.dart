import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/audit/audit_writer.dart';
import 'package:to_audit/data/backup/backup_service.dart';
import 'package:to_audit/data/backup/db_snapshotter.dart';
import 'package:to_audit/data/backup/restore_recovery.dart';
import 'package:to_audit/data/backup/toaudit_format.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/db/open_database.dart';
import 'package:to_audit/data/repositories/settings_repository.dart';
import 'package:to_audit/data/security/db_key_manager.dart';
import 'package:to_audit/data/security/key_store.dart';
import 'package:to_audit/domain/enums.dart';

import '../../support/sqlcipher.dart';

const _iterations = 1000;
const _password = 'secret-pass';
const keyA = '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';
const keyB = 'ffeeddccbbaa99887766554433221100ffeeddccbbaa99887766554433221100';

/// One "phone": a file database, its files root and a temp root.
class Phone {
  Phone._(this.dir, this.hexKey);

  final Directory dir;

  /// SQLCipher key, or null for a plain database.
  final String? hexKey;
  late AppDatabase db;

  File get dbFile => File('${dir.path}/to_audit.db');
  Directory get filesRoot => Directory('${dir.path}/files');
  Directory get receipts => Directory('${dir.path}/files/receipts');
  Directory get tempRoot => Directory('${dir.path}/tmp');

  static Future<Phone> create(String name, {String? hexKey}) async {
    final phone = Phone._(await Directory.systemTemp.createTemp(name), hexKey);
    await phone.tempRoot.create();
    await phone.filesRoot.create();
    await phone.reopen();
    return phone;
  }

  /// Opens the database and runs a query, so a broken file fails here.
  Future<AppDatabase> reopen() async {
    db = hexKey == null
        ? AppDatabase(NativeDatabase(dbFile))
        : await openEncryptedDatabase(file: dbFile, hexKey: hexKey!);
    await count('dia_caja');
    return db;
  }

  Future<int> count(String table) async {
    final row = await db
        .customSelect('SELECT COUNT(*) AS c FROM $table')
        .getSingle();
    return row.read<int>('c');
  }

  BackupService service({
    DbSnapshotter? snapshotter,
    Future<AppDatabase> Function()? reopenDb,
  }) => BackupService(
    db: db,
    snapshotter:
        snapshotter ??
        (hexKey == null ? PlainSnapshotter(db) : SqlCipherSnapshotter(db)),
    filesRoot: filesRoot,
    tempRoot: tempRoot,
    settings: SettingsRepository(db, AuditWriter(db)),
    closeDb: () => db.close(),
    reopenDb: reopenDb ?? reopen,
    dbFile: dbFile,
    hexKey: () async => hexKey ?? '',
    iterations: _iterations,
  );

  /// 2 days, 3 expenses (one voided) and 2 receipt files.
  Future<void> seed() async {
    final now = nowIso();
    final category = (await db.select(db.expenseCategories).get()).first.id;
    for (final (id, date) in [('d1', '2026-11-01'), ('d2', '2026-11-02')]) {
      await db
          .into(db.days)
          .insert(
            DaysCompanion.insert(
              id: id,
              createdAt: now,
              updatedAt: now,
              date: date,
              status: DayStatus.open,
              openingFloatCents: 10000,
            ),
          );
    }
    for (final (id, voided) in [('e1', false), ('e2', false), ('e3', true)]) {
      await db
          .into(db.expenses)
          .insert(
            ExpensesCompanion.insert(
              id: id,
              createdAt: now,
              updatedAt: now,
              date: '2026-11-01',
              categoryId: category,
              baseCents: 1000,
              totalCents: 1210,
              paymentStatus: PaymentStatus.paid,
              origin: ExpenseOrigin.manual,
              voided: Value(voided),
            ),
          );
    }
    await receipts.create(recursive: true);
    await File('${receipts.path}/r1.jpg').writeAsBytes(receiptBytes(1));
    await File('${receipts.path}/r2.pdf').writeAsBytes(receiptBytes(2));
  }

  Future<void> dispose() async {
    await db.close();
    await dir.delete(recursive: true);
  }
}

Uint8List receiptBytes(int seed) =>
    Uint8List.fromList(List.generate(70000, (i) => (i * seed + seed) % 256));

/// Snapshotter whose import first runs [whileStaging], then writes half a
/// file and its journal, and fails.
class FailingImport implements DbSnapshotter {
  FailingImport(this.inner, this.whileStaging);

  final DbSnapshotter inner;
  final Future<void> Function() whileStaging;

  @override
  Future<void> exportPlain(File dest) => inner.exportPlain(dest);

  @override
  Future<void> importPlain(File src, File destEncrypted, String hexKey) async {
    await whileStaging();
    await destEncrypted.writeAsString('partial');
    await File('${destEncrypted.path}-journal').writeAsString('partial');
    throw const FileSystemException('disk full');
  }
}

/// Snapshotter whose import also leaves a (non-hot, zeroed) journal next to
/// the imported file, which then follows it into place.
class JournalImport implements DbSnapshotter {
  JournalImport(this.inner);

  final DbSnapshotter inner;

  @override
  Future<void> exportPlain(File dest) => inner.exportPlain(dest);

  @override
  Future<void> importPlain(File src, File destEncrypted, String hexKey) async {
    await inner.importPlain(src, destEncrypted, hexKey);
    await File('${destEncrypted.path}-journal').writeAsBytes(Uint8List(512));
  }
}

/// Decrypts [backup], lets [edit] change the ZIP entries and encrypts it
/// again into [out].
Future<File> repack(
  File backup,
  File out,
  void Function(Map<String, List<int>> entries) edit,
) async {
  final zip = BytesBuilder(copy: false);
  await for (final chunk in ToauditFormat.decrypt(backup, _password)) {
    zip.add(chunk);
  }
  final entries = {
    for (final f in ZipDecoder().decodeBytes(zip.takeBytes()))
      if (f.isFile) f.name: (f.content as List<int>),
  };
  edit(entries);
  final archive = Archive();
  entries.forEach((name, bytes) {
    archive.addFile(ArchiveFile(name, bytes.length, bytes));
  });
  final sink = out.openWrite();
  await ToauditFormat.encrypt(
    Stream.value(ZipEncoder().encode(archive)!),
    sink,
    _password,
    iterations: _iterations,
  );
  await sink.close();
  return out;
}

void main() {
  // Two "phones" in one test: two databases on different files.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  setUpAll(quietSqlCipherLog);

  final now = DateTime.utc(2026, 11, 9, 18, 30);
  final phones = <Phone>[];

  Future<Phone> phone(String name, {String? hexKey}) async {
    final p = await Phone.create(name, hexKey: hexKey);
    phones.add(p);
    return p;
  }

  tearDown(() async {
    for (final p in phones) {
      await p.dispose();
    }
    phones.clear();
  });

  Future<List<String>> tempLeftovers(Phone p) async => [
    for (final e in await p.tempRoot.list().toList())
      if (!e.path.endsWith('.toaudit')) e.path,
  ];

  /// `.bak`, `.restoring` and journal files left next to the db or receipts.
  Future<List<String>> restoreLeftovers(Phone p) async => [
    for (final d in [p.dir, p.filesRoot])
      for (final e in await d.list().toList())
        if (RegExp(r'\.(bak|restoring|restore-in-progress)|-(journal|wal|shm)$')
            .hasMatch(e.path))
          e.path,
  ];

  test('export then restore into an empty database', () async {
    final source = await phone('backup_src');
    await source.seed();

    final backup = await source.service().export(_password, now: now);
    expect(backup.path, endsWith('to-audit-2026-11-09.toaudit'));
    expect(backup.parent.path, source.tempRoot.path);
    expect(
      await SettingsRepository(
        source.db,
        AuditWriter(source.db),
      ).lastBackupAt(),
      now,
    );
    expect(await tempLeftovers(source), isEmpty);

    final target = await phone('backup_dst');
    expect(await target.count('dia_caja'), 0);
    final service = target.service();
    final preview = await service.inspect(backup, _password);
    expect(preview.days, 2);
    expect(preview.expenses, 3);
    expect(preview.schemaVersion, 1);
    expect(preview.createdAt, now);

    await service.restore(preview);
    expect(await target.count('dia_caja'), 2);
    expect(await target.count('gasto'), 3);
    expect(
      await File('${target.receipts.path}/r1.jpg').readAsBytes(),
      receiptBytes(1),
    );
    expect(
      await File('${target.receipts.path}/r2.pdf').readAsBytes(),
      receiptBytes(2),
    );
    expect(await restoreLeftovers(target), isEmpty);
    expect(await preview.decryptedDir.exists(), isFalse);
    expect(await tempLeftovers(target), isEmpty);
  });

  test('the manifest lists every file with its sha256', () async {
    final source = await phone('backup_manifest');
    await source.seed();
    final backup = await source.service().export(_password, now: now);

    late Map<String, dynamic> manifest;
    await repack(backup, File('${source.dir.path}/copy.toaudit'), (entries) {
      expect(entries.keys, {
        'db.sqlite',
        'manifest.json',
        'receipts/r1.jpg',
        'receipts/r2.pdf',
      });
      manifest = jsonDecode(utf8.decode(entries['manifest.json']!));
    });
    expect(manifest['schemaVersion'], 1);
    expect(manifest['createdAt'], '2026-11-09T18:30:00.000Z');
    expect(manifest['days'], 2);
    expect(manifest['expenses'], 3);
    expect((manifest['files'] as Map).keys, {
      'db.sqlite',
      'receipts/r1.jpg',
      'receipts/r2.pdf',
    });
    expect(
      (manifest['files'] as Map).values,
      everyElement(matches(RegExp(r'^[0-9a-f]{64}$'))),
    );
  });

  test('a failing import puts the original data back', () async {
    final source = await phone('backup_src');
    await source.seed();
    final backup = await source.service().export(_password, now: now);

    final target = await phone('backup_dst');
    await target.seed();
    await target.db.customStatement("DELETE FROM gasto WHERE id = 'e3'");
    var stagedWhileOpen = false;
    final service = target.service(
      snapshotter: FailingImport(PlainSnapshotter(target.db), () async {
        // Staging runs while the current database is still open.
        expect(await target.count('dia_caja'), 2);
        stagedWhileOpen = true;
      }),
    );
    final preview = await service.inspect(backup, _password);

    await expectLater(
      service.restore(preview),
      throwsA(isA<FileSystemException>()),
    );
    expect(stagedWhileOpen, isTrue);
    // The original database opens again with its own data.
    expect(await target.count('dia_caja'), 2);
    expect(await target.count('gasto'), 2);
    expect(
      await File('${target.receipts.path}/r1.jpg').readAsBytes(),
      receiptBytes(1),
    );
    expect(await restoreLeftovers(target), isEmpty);
    expect(await tempLeftovers(target), isEmpty);
  });

  test('a count mismatch after reopening rolls back, journals too', () async {
    final source = await phone('backup_src');
    await source.seed();
    final backup = await source.service().export(_password, now: now);

    final target = await phone('backup_dst');
    await target.seed();
    await target.db.customStatement("DELETE FROM gasto WHERE id = 'e3'");
    final service = target.service(
      snapshotter: JournalImport(PlainSnapshotter(target.db)),
    );
    final real = await service.inspect(backup, _password);
    final wrong = BackupPreview(
      decryptedDir: real.decryptedDir,
      createdAt: real.createdAt,
      schemaVersion: real.schemaVersion,
      days: real.days + 1,
      expenses: real.expenses,
    );

    await expectLater(
      service.restore(wrong),
      throwsA(isA<BackupVerifyException>()),
    );
    expect(await target.count('dia_caja'), 2);
    expect(await target.count('gasto'), 2);
    expect(
      await File('${target.receipts.path}/r1.jpg').readAsBytes(),
      receiptBytes(1),
    );
    // The journal that came with the new file left with it.
    expect(await File('${target.dbFile.path}-journal').exists(), isFalse);
    expect(await restoreLeftovers(target), isEmpty);
    expect(await tempLeftovers(target), isEmpty);
  });

  test('a stale .bak or marker blocks a restore and is kept', () async {
    final source = await phone('backup_src');
    await source.seed();
    final backup = await source.service().export(_password, now: now);

    final target = await phone('backup_dst');
    await target.seed();
    final service = target.service();
    final paths = RestorePaths(
      dbFile: target.dbFile,
      filesRoot: target.filesRoot,
    );

    for (final leftover in <FileSystemEntity>[paths.dbBak, paths.marker]) {
      await File(leftover.path).writeAsString('only good copy');
      final preview = await service.inspect(backup, _password);
      await expectLater(service.restore(preview), throwsStateError);
      expect(await File(leftover.path).readAsString(), 'only good copy');
      expect(await target.count('dia_caja'), 2); // still open, untouched
      await File(leftover.path).delete();
    }

    await paths.receiptsBak.create();
    final preview = await service.inspect(backup, _password);
    await expectLater(service.restore(preview), throwsStateError);
    expect(await paths.receiptsBak.exists(), isTrue);
  });

  test('.restoring leftovers without a marker are cleared', () async {
    final source = await phone('backup_src');
    await source.seed();
    final backup = await source.service().export(_password, now: now);

    final target = await phone('backup_dst');
    await File('${target.dbFile.path}.restoring').writeAsString('partial');
    await File('${target.dbFile.path}.restoring-journal').writeAsString('x');
    await Directory('${target.receipts.path}.restoring')
        .create(recursive: true);
    final service = target.service();
    await service.restore(await service.inspect(backup, _password));
    expect(await target.count('dia_caja'), 2);
    expect(await restoreLeftovers(target), isEmpty);
  });

  test('a rollback that cannot put .bak back keeps the marker; the next '
      'start recovers the original', () async {
    final source = await phone('backup_src', hexKey: keyA);
    await source.seed();
    final backup = await source.service().export(_password, now: now);

    final target = await phone('backup_dst', hexKey: keyB);
    await target.seed();
    await target.db.customStatement("DELETE FROM gasto WHERE id = 'e3'");
    final paths = RestorePaths(
      dbFile: target.dbFile,
      filesRoot: target.filesRoot,
    );
    var reopens = 0;
    final service = target.service(
      reopenDb: () async {
        reopens++;
        // Injected fault: the live path turns into a folder, so neither
        // the reopen nor the rollback's move of .bak back can succeed.
        await deleteDbFiles(target.dbFile);
        await Directory(target.dbFile.path).create();
        throw const FileSystemException('injected');
      },
    );

    await expectLater(
      service.restore(await service.inspect(backup, _password)),
      throwsA(isA<FileSystemException>()),
    );
    expect(reopens, 1, reason: 'not reopened over a failed rollback');
    expect(await paths.marker.exists(), isTrue);
    expect(await paths.dbBak.exists(), isTrue);
    // The receipts part of the rollback still went through.
    expect(
      await File('${target.receipts.path}/r1.jpg').readAsBytes(),
      receiptBytes(1),
    );

    // Next start, the fault is gone.
    await Directory(target.dbFile.path).delete();
    final store = MemoryKeyStore()..values['db_key'] = keyB;
    target.db = await openAppDatabase(
      file: target.dbFile,
      keys: DbKeyManager(store),
      filesRoot: target.filesRoot,
    );
    expect(await target.count('dia_caja'), 2);
    expect(await target.count('gasto'), 2);
    expect(await restoreLeftovers(target), isEmpty);
  });

  test(
    'verify failure with openEncryptedDatabase keeps the original',
    () async {
      final source = await phone('backup_src', hexKey: keyA);
      await source.seed();
      final backup = await source.service().export(_password, now: now);

      final target = await phone('backup_dst', hexKey: keyB);
      await target.seed();
      await target.db.customStatement("DELETE FROM gasto WHERE id = 'e3'");
      final service = target.service(); // reopen = openEncryptedDatabase
      final real = await service.inspect(backup, _password);
      final wrong = BackupPreview(
        decryptedDir: real.decryptedDir,
        createdAt: real.createdAt,
        schemaVersion: real.schemaVersion,
        days: real.days,
        expenses: real.expenses + 5,
      );

      await expectLater(
        service.restore(wrong),
        throwsA(isA<BackupVerifyException>()),
      );
      expect(await target.count('dia_caja'), 2);
      expect(await target.count('gasto'), 2);
      expect(await restoreLeftovers(target), isEmpty);
      expect(await tempLeftovers(target), isEmpty);
    },
  );

  test('cleanTemp removes work folders and keeps .toaudit files', () async {
    final p = await phone('backup_clean');
    await Directory('${p.tempRoot.path}/export_123/x').create(recursive: true);
    await Directory('${p.tempRoot.path}/restore_456').create();
    await File('${p.tempRoot.path}/restore_456.zip').writeAsString('zip');
    await File('${p.tempRoot.path}/to-audit-2026-11-09.toaudit')
        .writeAsString('backup');

    await BackupService.cleanTemp(p.tempRoot);
    final names = await p.tempRoot
        .list()
        .map((e) => e.uri.pathSegments.last)
        .toList();
    expect(names, ['to-audit-2026-11-09.toaudit']);
    await BackupService.cleanTemp(Directory('${p.dir.path}/missing'));
  });

  test('schemaVersion 99 in the manifest is BackupTooNewException', () async {
    final source = await phone('backup_new');
    await source.seed();
    final backup = await source.service().export(_password, now: now);
    final newer = await repack(
      backup,
      File('${source.dir.path}/newer.toaudit'),
      (entries) {
        final manifest = jsonDecode(
          utf8.decode(entries['manifest.json']!),
        ) as Map<String, dynamic>;
        manifest['schemaVersion'] = 99;
        entries['manifest.json'] = utf8.encode(jsonEncode(manifest));
      },
    );

    await expectLater(
      source.service().inspect(newer, _password),
      throwsA(isA<BackupTooNewException>()),
    );
    expect(await tempLeftovers(source), isEmpty);
  });

  test(
    'a file whose sha256 does not match is BackupDecryptException',
    () async {
      final source = await phone('backup_sha');
      await source.seed();
      final backup = await source.service().export(_password, now: now);
      final tampered = await repack(
        backup,
        File('${source.dir.path}/tampered.toaudit'),
        (entries) => entries['receipts/r1.jpg'] = receiptBytes(3),
      );

      await expectLater(
        source.service().inspect(tampered, _password),
        throwsA(isA<BackupDecryptException>()),
      );
      expect(await tempLeftovers(source), isEmpty);
    },
  );

  test('unsafe or unlisted ZIP entries are BackupDecryptException', () async {
    final source = await phone('backup_slip');
    await source.seed();
    final backup = await source.service().export(_password, now: now);
    for (final name in ['../evil.txt', 'receipts/extra.jpg', 'other.txt']) {
      final bad = await repack(
        backup,
        File('${source.dir.path}/bad.toaudit'),
        (entries) => entries[name] = [1, 2, 3],
      );
      await expectLater(
        source.service().inspect(bad, _password),
        throwsA(isA<BackupDecryptException>()),
        reason: name,
      );
    }
    expect(
      await File('${source.tempRoot.parent.path}/evil.txt').exists(),
      isFalse,
    );
    expect(await tempLeftovers(source), isEmpty);
  });

  test('wrong password on inspect is BackupDecryptException', () async {
    final source = await phone('backup_pw');
    await source.seed();
    final backup = await source.service().export(_password, now: now);
    await expectLater(
      source.service().inspect(backup, 'other-password'),
      throwsA(isA<BackupDecryptException>()),
    );
    expect(await tempLeftovers(source), isEmpty);
  });

  test('a password shorter than 8 characters is ArgumentError', () async {
    final source = await phone('backup_short');
    await expectLater(
      source.service().export('1234567', now: now),
      throwsArgumentError,
    );
    expect(
      await SettingsRepository(
        source.db,
        AuditWriter(source.db),
      ).lastBackupAt(),
      isNull,
    );
  });

  test('SQLCipher: encrypted export restores into another key', () async {
    final source = await phone('backup_cipher_src', hexKey: keyA);
    await source.seed();
    final backup = await source.service().export(_password, now: now);

    final target = await phone('backup_cipher_dst', hexKey: keyB);
    final service = target.service();
    await service.restore(await service.inspect(backup, _password));

    expect(await target.count('dia_caja'), 2);
    expect(await target.count('gasto'), 3);
    // The restored file is encrypted with key B, not plain.
    final header = (await target.dbFile.openRead(0, 16).first).take(16);
    expect(header, isNot(ascii.encode('SQLite format 3\u0000')));
    await target.db.close();
    final wrong = await openEncryptedDatabase(
      file: target.dbFile,
      hexKey: keyA,
    );
    await expectLater(wrong.select(wrong.days).get(), throwsA(anything));
    await wrong.close().catchError((_) {});
    await target.reopen();
  });
}
