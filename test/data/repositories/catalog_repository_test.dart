import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/audit/audit_writer.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/repositories/catalog_repository.dart';
import 'package:to_audit/domain/enums.dart';

void main() {
  late AppDatabase db;
  late CatalogRepository repo;

  setUp(() {
    db = AppDatabase.memory();
    repo = CatalogRepository(db, AuditWriter(db));
  });
  tearDown(() => db.close());

  Future<List<CatalogItem>> payments({bool all = false}) =>
      repo.watch(CatalogKind.paymentMethod, includeInactive: all).first;

  test('add puts a payment method at the end and audits it', () async {
    final before = await payments();
    final id = await repo.add(
      CatalogKind.paymentMethod,
      '  Cheque ',
      paymentKind: PaymentKind.other,
    );
    final after = await payments();
    expect(after, hasLength(before.length + 1));
    expect(after.last.id, id);
    expect(after.last.name, 'Cheque');
    expect(after.last.order, before.last.order + 1);
    expect(after.last.paymentKind, PaymentKind.other);
    expect(after.last.categoryKind, isNull);
    final log = await db.select(db.changeLog).get();
    expect(log.single.entity, 'forma_pago');
    expect(log.single.recordId, id);
    expect(log.single.field, '*');
  });

  test('add validates name and kinds', () async {
    expect(
      () => repo.add(
        CatalogKind.paymentMethod,
        '  ',
        paymentKind: PaymentKind.cash,
      ),
      throwsArgumentError,
    );
    expect(() => repo.add(CatalogKind.paymentMethod, 'X'), throwsArgumentError);
    expect(
      () => repo.add(CatalogKind.expenseCategory, 'X'),
      throwsArgumentError,
    );
    expect(() => repo.add(CatalogKind.withdrawalType, ''), throwsArgumentError);
    expect(await db.select(db.changeLog).get(), isEmpty);
  });

  test('expense category and withdrawal type add', () async {
    final c = await repo.add(
      CatalogKind.expenseCategory,
      'Postres',
      categoryKind: CategoryKind.purchase,
    );
    final w = await repo.add(CatalogKind.withdrawalType, 'Propina');
    final cat = await repo.byId(CatalogKind.expenseCategory, c);
    expect(cat.categoryKind, CategoryKind.purchase);
    expect((await repo.byId(CatalogKind.withdrawalType, w)).name, 'Propina');
    final log = await db.select(db.changeLog).get();
    expect(log.map((r) => r.entity).toSet(), {
      'categoria_gasto',
      'tipo_retirada',
    });
  });

  test('setActive(false) hides from watch but byId still returns it', () async {
    final id = await repo.add(
      CatalogKind.paymentMethod,
      'Cheque',
      paymentKind: PaymentKind.other,
    );
    await repo.setActive(CatalogKind.paymentMethod, id, false);
    expect((await payments()).map((e) => e.id), isNot(contains(id)));
    expect((await payments(all: true)).map((e) => e.id), contains(id));
    final item = await repo.byId(CatalogKind.paymentMethod, id);
    expect(item.active, isFalse);
    final log = await db.select(db.changeLog).get();
    final row = log.firstWhere((r) => r.field == 'active');
    expect(row.oldValue, 'true');
    expect(row.newValue, 'false');
  });

  test('rename audits the name change', () async {
    final id = await repo.add(CatalogKind.withdrawalType, 'Uno');
    await repo.rename(CatalogKind.withdrawalType, id, ' Dos ');
    expect((await repo.byId(CatalogKind.withdrawalType, id)).name, 'Dos');
    final log = await db.select(db.changeLog).get();
    final row = log.firstWhere((r) => r.field == 'name');
    expect(row.oldValue, 'Uno');
    expect(row.newValue, 'Dos');
    expect(
      () => repo.rename(CatalogKind.withdrawalType, id, ' '),
      throwsArgumentError,
    );
  });

  test('reorder rewrites sortOrder', () async {
    final ids = (await payments(all: true)).map((e) => e.id).toList();
    final reversed = ids.reversed.toList();
    await repo.reorder(CatalogKind.paymentMethod, reversed);
    final after = await payments(all: true);
    expect(after.map((e) => e.id), reversed);
    expect(after.map((e) => e.order), List.generate(ids.length, (i) => i));
  });

  test('reorder requires exactly the ids of that catalog', () async {
    final ids = (await payments(all: true)).map((e) => e.id).toList();
    expect(
      () => repo.reorder(CatalogKind.paymentMethod, ids.sublist(1)),
      throwsArgumentError,
    );
    expect(
      () => repo.reorder(CatalogKind.paymentMethod, [...ids, 'zzz']),
      throwsArgumentError,
    );
    expect(
      () =>
          repo.reorder(CatalogKind.paymentMethod, [...ids.sublist(1), ids[1]]),
      throwsArgumentError,
    );
  });

  test('byId on unknown id throws StateError', () {
    expect(
      () => repo.byId(CatalogKind.paymentMethod, 'nope'),
      throwsStateError,
    );
  });
}
