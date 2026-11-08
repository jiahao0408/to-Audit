import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/audit/audit_writer.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/repositories/history_repository.dart';
import 'package:to_audit/domain/enums.dart';

void main() {
  late AppDatabase db;
  late AuditWriter audit;

  setUp(() {
    db = AppDatabase.memory();
    audit = AuditWriter(db, clock: () => DateTime.utc(2026, 1, 2, 3, 4, 5));
  });
  tearDown(() => db.close());

  test('updated writes one row for the changed field only', () async {
    await db.transaction(
      () => audit.updated(
        'x',
        'id1',
        {'a': 1, 'b': 2},
        {'a': 1, 'b': 3},
        reason: 'fix',
      ),
    );
    final rows = await db.select(db.changeLog).get();
    expect(rows, hasLength(1));
    expect(rows.single.field, 'b');
    expect(rows.single.oldValue, '2');
    expect(rows.single.newValue, '3');
    expect(rows.single.reason, 'fix');
    expect(rows.single.author, 'owner');
    expect(rows.single.prevHash, isNull);
    expect(rows.single.at, '2026-01-02T03:04:05.000Z');
  });

  test('updated with equal values writes nothing', () async {
    await db.transaction(() => audit.updated('x', 'id1', {'a': 1}, {'a': 1}));
    expect(await db.select(db.changeLog).get(), isEmpty);
  });

  test('inserted writes a * row with JSON; event converts enums', () async {
    await audit.inserted('x', 'id1', {'a': 1, 'n': null});
    await audit.event(
      'x',
      'id1',
      'status',
      oldValue: DayStatus.open,
      newValue: DayStatus.closed,
    );
    final rows = await db.select(db.changeLog).get();
    final ins = rows.firstWhere((r) => r.field == '*');
    expect(ins.oldValue, isNull);
    expect(ins.newValue, '{"a":1,"n":null}');
    final ev = rows.firstWhere((r) => r.field == 'status');
    expect(ev.oldValue, 'open');
    expect(ev.newValue, 'closed');
  });

  test('rollback leaves no rows', () async {
    await expectLater(
      db.transaction(() async {
        await audit.updated('x', 'id1', {'a': 1}, {'a': 2});
        throw StateError('boom');
      }),
      throwsStateError,
    );
    expect(await db.select(db.changeLog).get(), isEmpty);
  });

  test('HistoryRepository orders and filters', () async {
    var t = 0;
    final w = AuditWriter(db, clock: () => DateTime.utc(2026, 1, 1, 0, 0, t++));
    await w.event('x', 'a', 'f', newValue: 1);
    await w.event('x', 'a', 'g', newValue: 2);
    await w.event('y', 'b', 'f', newValue: 3);
    final repo = HistoryRepository(db);
    final forA = await repo.watchFor('x', 'a').first;
    expect(forA.map((r) => r.field), ['f', 'g']);
    final all = await repo.watchAll(limit: 2).first;
    expect(all.map((r) => r.newValue), ['3', '2']);
  });
}
