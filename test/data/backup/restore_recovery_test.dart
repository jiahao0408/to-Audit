import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' show sqlite3;
import 'package:to_audit/data/backup/restore_recovery.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/db/open_database.dart';
import 'package:to_audit/domain/enums.dart';

import '../../support/sqlcipher.dart';

const key = '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';

void main() {
  late Directory dir;
  late File db;
  late Directory receipts;

  setUpAll(quietSqlCipherLog);
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('recovery_');
    db = File('${dir.path}/to_audit.db');
    receipts = Directory('${dir.path}/receipts');
  });
  tearDown(() => dir.delete(recursive: true));

  File at(String suffix) => File('${db.path}$suffix');
  Directory receiptsAt(String suffix) => Directory('${receipts.path}$suffix');

  /// An encrypted database at [file] holding one day dated [date].
  Future<void> makeDb(File file, String date) async {
    final d = await openEncryptedDatabase(file: file, hexKey: key);
    await d
        .into(d.days)
        .insert(
          DaysCompanion.insert(
            id: date,
            createdAt: nowIso(),
            updatedAt: nowIso(),
            date: date,
            status: DayStatus.open,
            openingFloatCents: 0,
          ),
        );
    await d.close();
  }

  /// A keyed database that opens but has none of the app tables.
  void makeEmptySchemaDb(File file) {
    final raw = sqlite3.open(file.path);
    raw.execute("PRAGMA key = \"x'$key'\"");
    raw.execute('CREATE TABLE other (x)');
    raw.close();
  }

  Future<List<String>> datesIn(File file) async {
    final d = await openEncryptedDatabase(file: file, hexKey: key);
    try {
      return [for (final day in await d.select(d.days).get()) day.date];
    } finally {
      await d.close();
    }
  }

  Future<void> makeReceipts(Directory d, String content) async {
    await d.create(recursive: true);
    await File('${d.path}/r.jpg').writeAsString(content);
  }

  Future<String> receiptIn(Directory d) =>
      File('${d.path}/r.jpg').readAsString();

  Future<void> recover() =>
      recoverInterruptedRestore(dbFile: db, filesRoot: dir, hexKey: key);

  Future<List<String>> leftovers() async => [
    for (final e in await dir.list().toList())
      if (RegExp(r'\.(bak|restoring|restore-in-progress)|-journal')
          .hasMatch(e.path))
        e.path,
  ];

  Future<void> mark() => at('.restore-in-progress').writeAsString('restore');

  test('killed after renaming the db to .bak: old data comes back', () async {
    await mark();
    await makeDb(at('.bak'), '2026-11-01');
    await makeReceipts(receiptsAt('.bak'), 'old');
    await makeDb(at('.restoring'), '2026-12-01');
    await makeReceipts(receiptsAt('.restoring'), 'new');

    await recover();
    expect(await datesIn(db), ['2026-11-01']);
    expect(await receiptIn(receipts), 'old');
    expect(await leftovers(), isEmpty);
  });

  test('killed between the db and the receipts swap: rolled back', () async {
    await mark();
    await makeDb(db, '2026-12-01'); // new one already in place
    await makeDb(at('.bak'), '2026-11-01');
    await makeReceipts(receiptsAt('.bak'), 'old');
    await makeReceipts(receiptsAt('.restoring'), 'new');

    await recover();
    expect(await datesIn(db), ['2026-11-01']);
    expect(await receiptIn(receipts), 'old');
    expect(await leftovers(), isEmpty);
  });

  test('killed while staging: live data kept, staging removed', () async {
    await makeDb(db, '2026-11-01');
    await makeReceipts(receipts, 'old');
    await at('.restoring').writeAsString('partial');
    await at('.restoring-journal').writeAsString('partial journal');
    await makeReceipts(receiptsAt('.restoring'), 'new');

    await recover();
    expect(await datesIn(db), ['2026-11-01']);
    expect(await receiptIn(receipts), 'old');
    expect(await leftovers(), isEmpty);
  });

  test('restore had finished but .bak was not deleted: .bak removed', () async {
    await makeDb(db, '2026-12-01');
    await makeReceipts(receipts, 'new');
    await makeDb(at('.bak'), '2026-11-01');
    await makeReceipts(receiptsAt('.bak'), 'old');

    await recover();
    expect(await datesIn(db), ['2026-12-01']);
    expect(await receiptIn(receipts), 'new');
    expect(await leftovers(), isEmpty);
  });

  test('a live db that does not open with the key: .bak comes back', () async {
    await db.writeAsString('not a database at all, just garbage bytes');
    await at('-journal').writeAsString('garbage journal');
    await makeDb(at('.bak'), '2026-11-01');

    await recover();
    expect(await datesIn(db), ['2026-11-01']);
    // The journal of the dropped file must not pair with the restored one.
    expect(await leftovers(), isEmpty);
  });

  test('nothing to recover leaves everything as it is', () async {
    await makeDb(db, '2026-11-01');
    await makeReceipts(receipts, 'old');
    final before = await db.readAsBytes();

    await recover();
    expect(await db.readAsBytes(), before);
    expect(await receiptIn(receipts), 'old');
    expect(await leftovers(), isEmpty);
  });

  test('killed in a rollback after receipts were deleted: put back', () async {
    await mark();
    await makeDb(db, '2026-11-01'); // the db was already moved back
    await makeReceipts(receiptsAt('.bak'), 'old');

    await recover();
    expect(await datesIn(db), ['2026-11-01']);
    expect(await receiptIn(receipts), 'old');
    expect(await leftovers(), isEmpty);
  });

  test(
    'without marker, receipts.bak with no live receipts goes back',
    () async {
      await makeDb(db, '2026-11-01');
      await makeReceipts(receiptsAt('.bak'), 'old');

      await recover();
      expect(await receiptIn(receipts), 'old');
      expect(await leftovers(), isEmpty);
    },
  );

  test('marker with an empty-schema live db: rolled back', () async {
    await mark();
    makeEmptySchemaDb(db);
    await makeDb(at('.bak'), '2026-11-01');
    await makeReceipts(receipts, 'new');
    await makeReceipts(receiptsAt('.bak'), 'old');

    await recover();
    expect(await datesIn(db), ['2026-11-01']);
    expect(await receiptIn(receipts), 'old');
    expect(await leftovers(), isEmpty);
  });

  test(
    'without marker, an empty-schema live db does not count as opening',
    () async {
      makeEmptySchemaDb(db);
      await makeDb(at('.bak'), '2026-11-01');

      await recover();
      expect(await datesIn(db), ['2026-11-01']);
      expect(await leftovers(), isEmpty);
    },
  );

  test('a marker with nothing moved yet is just removed', () async {
    await mark();
    await makeDb(db, '2026-11-01');
    await makeReceipts(receipts, 'old');
    await makeReceipts(receiptsAt('.restoring'), 'new');

    await recover();
    expect(await datesIn(db), ['2026-11-01']);
    expect(await receiptIn(receipts), 'old');
    expect(await leftovers(), isEmpty);
  });
}
