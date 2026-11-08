import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart' show SqliteException;
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/domain/enums.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.memory());
  tearDown(() => db.close());

  Future<void> insertDay(String id, String date) {
    return db.into(db.days).insert(DaysCompanion.insert(
          id: id,
          createdAt: nowIso(),
          updatedAt: nowIso(),
          date: date,
          status: DayStatus.open,
          openingFloatCents: 0,
        ));
  }

  test('seeds default payment methods in order', () async {
    final rows = await (db.select(db.paymentMethods)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    expect(rows.map((r) => r.code).toList(), [
      'cash', 'card', 'bizum', 'vouchers', 'glovo', 'justeat', 'ubereats',
    ]);
    expect(rows.map((r) => r.kind).toList(), [
      PaymentKind.cash, PaymentKind.card, PaymentKind.other, PaymentKind.other,
      PaymentKind.other, PaymentKind.other, PaymentKind.other,
    ]);
    expect(rows.first.name, 'Efectivo');
  });

  test('seeds 12 categories and 4 withdrawal types', () async {
    final cats = await db.select(db.expenseCategories).get();
    expect(cats.length, 12);
    expect(cats.where((c) => c.kind == CategoryKind.purchase).length, 5);
    final types = await (db.select(db.withdrawalTypes)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .get();
    expect(types.map((t) => t.code).toList(),
        ['bank_deposit', 'owner', 'cash_payment', 'change']);
  });

  test('duplicate day date throws SqliteException', () async {
    await insertDay('a', '2026-11-01');
    expect(insertDay('b', '2026-11-01'), throwsA(isA<SqliteException>()));
  });

  test('foreign keys are enforced', () async {
    final pm = (await db.select(db.paymentMethods).get()).first;
    expect(
      db.into(db.sales).insert(SalesCompanion.insert(
            id: 's1',
            createdAt: nowIso(),
            updatedAt: nowIso(),
            dayId: 'missing',
            shift: Shift.lunch,
            paymentMethodId: pm.id,
            amountCents: 100,
          )),
      throwsA(isA<SqliteException>()),
    );
  });
}
