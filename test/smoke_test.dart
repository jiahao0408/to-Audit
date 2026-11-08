import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('in-memory drift database runs select 1', () async {
    final db = NativeDatabase.memory();
    final executor = DatabaseConnection(db);
    await executor.ensureOpen(_NoopUser());
    final rows = await executor.runSelect('select 1 as v', const []);
    expect(rows.first['v'], 1);
    await executor.close();
  });
}

class _NoopUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}
