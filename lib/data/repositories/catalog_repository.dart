import 'package:drift/drift.dart';

import '../../domain/enums.dart';
import '../audit/audit_writer.dart';
import '../db/app_database.dart';

enum CatalogKind { paymentMethod, expenseCategory, withdrawalType }

/// One entry of a configurable catalog.
class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.code,
    required this.name,
    required this.active,
    required this.order,
    this.paymentKind,
    this.categoryKind,
  });

  final String id;
  final String? code;
  final String name;
  final bool active;
  final int order;
  final PaymentKind? paymentKind;
  final CategoryKind? categoryKind;
}

/// Payment methods, expense categories and withdrawal types.
///
/// Items are never deleted: they are deactivated, so history that references
/// them stays readable. Every change is audited with the table's sql name.
class CatalogRepository {
  CatalogRepository(this._db, this._audit);

  final AppDatabase _db;
  final AuditWriter _audit;

  static String _entity(CatalogKind kind) => switch (kind) {
    CatalogKind.paymentMethod => 'forma_pago',
    CatalogKind.expenseCategory => 'categoria_gasto',
    CatalogKind.withdrawalType => 'tipo_retirada',
  };

  static String _cleanName(String name) {
    final n = name.trim();
    if (n.isEmpty) throw ArgumentError.value(name, 'name', 'must not be blank');
    return n;
  }

  Stream<List<CatalogItem>> watch(
    CatalogKind kind, {
    bool includeInactive = false,
  }) {
    switch (kind) {
      case CatalogKind.paymentMethod:
        final q = _db.select(_db.paymentMethods);
        if (!includeInactive) q.where((t) => t.active.equals(true));
        q.orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
        return q.watch().map((rows) => rows.map(_fromPayment).toList());
      case CatalogKind.expenseCategory:
        final q = _db.select(_db.expenseCategories);
        if (!includeInactive) q.where((t) => t.active.equals(true));
        q.orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
        return q.watch().map((rows) => rows.map(_fromCategory).toList());
      case CatalogKind.withdrawalType:
        final q = _db.select(_db.withdrawalTypes);
        if (!includeInactive) q.where((t) => t.active.equals(true));
        q.orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
        return q.watch().map((rows) => rows.map(_fromWithdrawal).toList());
    }
  }

  /// Returns the item even when it is inactive.
  Future<CatalogItem> byId(CatalogKind kind, String id) async {
    final item = (await _all(kind)).where((i) => i.id == id).firstOrNull;
    if (item == null) {
      throw StateError('No ${_entity(kind)} with id $id');
    }
    return item;
  }

  Future<String> add(
    CatalogKind kind,
    String name, {
    PaymentKind? paymentKind,
    CategoryKind? categoryKind,
  }) {
    final clean = _cleanName(name);
    if (kind == CatalogKind.paymentMethod && paymentKind == null) {
      throw ArgumentError.notNull('paymentKind');
    }
    if (kind == CatalogKind.expenseCategory && categoryKind == null) {
      throw ArgumentError.notNull('categoryKind');
    }
    return _db.transaction(() async {
      final id = newId();
      final now = nowIso();
      final items = await _all(kind);
      final order = items.isEmpty
          ? 0
          : items.map((i) => i.order).reduce((a, b) => a > b ? a : b) + 1;
      switch (kind) {
        case CatalogKind.paymentMethod:
          await _db
              .into(_db.paymentMethods)
              .insert(
                PaymentMethodsCompanion.insert(
                  id: id,
                  createdAt: now,
                  updatedAt: now,
                  name: clean,
                  kind: paymentKind!,
                  sortOrder: order,
                ),
              );
        case CatalogKind.expenseCategory:
          await _db
              .into(_db.expenseCategories)
              .insert(
                ExpenseCategoriesCompanion.insert(
                  id: id,
                  createdAt: now,
                  updatedAt: now,
                  name: clean,
                  kind: categoryKind!,
                  sortOrder: order,
                ),
              );
        case CatalogKind.withdrawalType:
          await _db
              .into(_db.withdrawalTypes)
              .insert(
                WithdrawalTypesCompanion.insert(
                  id: id,
                  createdAt: now,
                  updatedAt: now,
                  name: clean,
                  sortOrder: order,
                ),
              );
      }
      await _audit.inserted(_entity(kind), id, {
        'name': clean,
        'kind': paymentKind ?? categoryKind,
        'sortOrder': order,
        'active': true,
      });
      return id;
    });
  }

  Future<void> rename(CatalogKind kind, String id, String name) {
    final clean = _cleanName(name);
    return _db.transaction(() async {
      final old = await byId(kind, id);
      if (old.name == clean) return;
      await _update(kind, id, name: clean);
      await _audit.updated(
        _entity(kind),
        id,
        {'name': old.name},
        {'name': clean},
      );
    });
  }

  Future<void> setActive(CatalogKind kind, String id, bool active) {
    return _db.transaction(() async {
      final old = await byId(kind, id);
      if (old.active == active) return;
      await _update(kind, id, active: active);
      await _audit.updated(
        _entity(kind),
        id,
        {'active': old.active},
        {'active': active},
      );
    });
  }

  /// [idsInOrder] must be exactly the ids of this catalog (active or not).
  Future<void> reorder(CatalogKind kind, List<String> idsInOrder) {
    return _db.transaction(() async {
      final current = await _all(kind);
      final expected = current.map((i) => i.id).toSet();
      if (idsInOrder.length != expected.length ||
          idsInOrder.toSet().length != idsInOrder.length ||
          !idsInOrder.toSet().containsAll(expected)) {
        throw ArgumentError.value(
          idsInOrder,
          'idsInOrder',
          'must contain exactly the ids of ${_entity(kind)}',
        );
      }
      final before = {for (final i in current) i.id: i.order};
      for (final (index, id) in idsInOrder.indexed) {
        if (before[id] == index) continue;
        await _update(kind, id, sortOrder: index);
        await _audit.updated(
          _entity(kind),
          id,
          {'sortOrder': before[id]},
          {'sortOrder': index},
        );
      }
    });
  }

  Future<List<CatalogItem>> _all(CatalogKind kind) async {
    switch (kind) {
      case CatalogKind.paymentMethod:
        final rows = await (_db.select(
          _db.paymentMethods,
        )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
        return rows.map(_fromPayment).toList();
      case CatalogKind.expenseCategory:
        final rows = await (_db.select(
          _db.expenseCategories,
        )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
        return rows.map(_fromCategory).toList();
      case CatalogKind.withdrawalType:
        final rows = await (_db.select(
          _db.withdrawalTypes,
        )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
        return rows.map(_fromWithdrawal).toList();
    }
  }

  Future<void> _update(
    CatalogKind kind,
    String id, {
    String? name,
    bool? active,
    int? sortOrder,
  }) async {
    final now = nowIso();
    switch (kind) {
      case CatalogKind.paymentMethod:
        await (_db.update(
          _db.paymentMethods,
        )..where((t) => t.id.equals(id))).write(
          PaymentMethodsCompanion(
            name: Value.absentIfNull(name),
            active: Value.absentIfNull(active),
            sortOrder: Value.absentIfNull(sortOrder),
            updatedAt: Value(now),
          ),
        );
      case CatalogKind.expenseCategory:
        await (_db.update(
          _db.expenseCategories,
        )..where((t) => t.id.equals(id))).write(
          ExpenseCategoriesCompanion(
            name: Value.absentIfNull(name),
            active: Value.absentIfNull(active),
            sortOrder: Value.absentIfNull(sortOrder),
            updatedAt: Value(now),
          ),
        );
      case CatalogKind.withdrawalType:
        await (_db.update(
          _db.withdrawalTypes,
        )..where((t) => t.id.equals(id))).write(
          WithdrawalTypesCompanion(
            name: Value.absentIfNull(name),
            active: Value.absentIfNull(active),
            sortOrder: Value.absentIfNull(sortOrder),
            updatedAt: Value(now),
          ),
        );
    }
  }

  static CatalogItem _fromPayment(PaymentMethodData r) => CatalogItem(
    id: r.id,
    code: r.code,
    name: r.name,
    active: r.active,
    order: r.sortOrder,
    paymentKind: r.kind,
  );

  static CatalogItem _fromCategory(ExpenseCategoryData r) => CatalogItem(
    id: r.id,
    code: r.code,
    name: r.name,
    active: r.active,
    order: r.sortOrder,
    categoryKind: r.kind,
  );

  static CatalogItem _fromWithdrawal(WithdrawalTypeData r) => CatalogItem(
    id: r.id,
    code: r.code,
    name: r.name,
    active: r.active,
    order: r.sortOrder,
  );
}
