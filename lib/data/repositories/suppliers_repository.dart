// Named constructor parameters cannot be private, hence the initializer list.
// ignore_for_file: prefer_initializing_formals

import 'package:drift/drift.dart';

import '../audit/audit_writer.dart';
import '../db/app_database.dart';

class SupplierInput {
  const SupplierInput({
    required this.name,
    this.nif,
    this.phone,
    this.defaultCategoryId,
  });

  final String name;
  final String? nif;
  final String? phone;
  final String? defaultCategoryId;
}

class SupplierRecord {
  const SupplierRecord({
    required this.id,
    required this.name,
    this.nif,
    this.phone,
    this.defaultCategoryId,
  });

  final String id;
  final String name;
  final String? nif;
  final String? phone;
  final String? defaultCategoryId;
}

class SuppliersRepository {
  SuppliersRepository(this._db, {required AuditWriter audit}) : _audit = audit;

  final AppDatabase _db;
  final AuditWriter _audit;

  static const _entity = 'proveedor';

  static SupplierRecord _record(SupplierData s) => SupplierRecord(
    id: s.id,
    name: s.name,
    nif: s.taxId,
    phone: s.phone,
    defaultCategoryId: s.categoryId,
  );

  Stream<List<SupplierRecord>> watchAll() =>
      (_db.select(_db.suppliers)..orderBy([(s) => OrderingTerm.asc(s.name)]))
          .watch()
          .map((rows) => [for (final s in rows) _record(s)]);

  /// Case-insensitive substring match on name or NIF, ordered by name.
  Future<List<SupplierRecord>> search(String query) async {
    final q = query.trim().toLowerCase();
    final rows = await (_db.select(
      _db.suppliers,
    )..orderBy([(s) => OrderingTerm.asc(s.name)])).get();
    return [
      for (final s in rows)
        if (s.name.toLowerCase().contains(q) ||
            (s.taxId ?? '').toLowerCase().contains(q))
          _record(s),
    ];
  }

  static String? _clean(String? v) {
    final t = v?.trim();
    return t == null || t.isEmpty ? null : t;
  }

  static Map<String, Object?> _values(SupplierInput i) => {
    'name': i.name.trim(),
    'taxId': _clean(i.nif),
    'phone': _clean(i.phone),
    'categoryId': i.defaultCategoryId,
  };

  Future<void> _check(SupplierInput i) async {
    if (i.name.trim().isEmpty) {
      throw ArgumentError.value(i.name, 'name', 'must not be blank');
    }
    final cat = i.defaultCategoryId;
    if (cat != null) {
      final row = await (_db.select(
        _db.expenseCategories,
      )..where((c) => c.id.equals(cat))).getSingleOrNull();
      if (row == null) {
        throw ArgumentError.value(cat, 'defaultCategoryId', 'unknown category');
      }
    }
  }

  Future<String> create(SupplierInput input) async {
    if (input.name.trim().isEmpty) {
      throw ArgumentError.value(input.name, 'name', 'must not be blank');
    }
    return _db.transaction(() async {
      await _check(input);
      final id = newId();
      final now = nowIso();
      final v = _values(input);
      await _db
          .into(_db.suppliers)
          .insert(
            SuppliersCompanion.insert(
              id: id,
              createdAt: now,
              updatedAt: now,
              name: v['name']! as String,
              taxId: Value(v['taxId'] as String?),
              phone: Value(v['phone'] as String?),
              categoryId: Value(v['categoryId'] as String?),
            ),
          );
      await _audit.inserted(_entity, id, v);
      return id;
    });
  }

  Future<void> update(String id, SupplierInput input) async {
    if (input.name.trim().isEmpty) {
      throw ArgumentError.value(input.name, 'name', 'must not be blank');
    }
    return _db.transaction(() async {
      final row = await (_db.select(
        _db.suppliers,
      )..where((s) => s.id.equals(id))).getSingleOrNull();
      if (row == null) throw ArgumentError.value(id, 'id', 'unknown supplier');
      await _check(input);
      final before = {
        'name': row.name,
        'taxId': row.taxId,
        'phone': row.phone,
        'categoryId': row.categoryId,
      };
      final after = _values(input);
      await (_db.update(_db.suppliers)..where((s) => s.id.equals(id))).write(
        SuppliersCompanion(
          name: Value(after['name']! as String),
          taxId: Value(after['taxId'] as String?),
          phone: Value(after['phone'] as String?),
          categoryId: Value(after['categoryId'] as String?),
          updatedAt: Value(nowIso()),
        ),
      );
      await _audit.updated(_entity, id, before, after);
    });
  }
}
