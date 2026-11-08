import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../db/app_database.dart';

/// Records one change-log row per changed field.
///
/// It does NOT open its own transaction: callers must wrap the data write and
/// the audit call in a single `db.transaction` so both commit or roll back
/// together.
class AuditWriter {
  AuditWriter(this._db, {this.author = 'owner', DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final String author;
  final DateTime Function() _clock;

  /// Logs a creation: one row with field `*` and the JSON of [values].
  Future<void> inserted(
    String entity,
    String id,
    Map<String, Object?> values, {
    String? reason,
  }) => _write(entity, id, '*', null, jsonEncode(values), reason);

  /// Logs one row per key whose value differs between [before] and [after].
  Future<void> updated(
    String entity,
    String id,
    Map<String, Object?> before,
    Map<String, Object?> after, {
    String? reason,
  }) async {
    for (final key in {...before.keys, ...after.keys}) {
      final o = _text(before[key]);
      final n = _text(after[key]);
      if (o == n) continue;
      await _write(entity, id, key, o, n, reason);
    }
  }

  /// Logs a single named event/field change.
  Future<void> event(
    String entity,
    String id,
    String field, {
    Object? oldValue,
    Object? newValue,
    String? reason,
  }) => _write(entity, id, field, _text(oldValue), _text(newValue), reason);

  Future<void> _write(
    String entity,
    String id,
    String field,
    String? oldV,
    String? newV,
    String? reason,
  ) {
    return _db
        .into(_db.changeLog)
        .insert(
          ChangeLogCompanion.insert(
            id: newId(),
            at: _clock().toUtc().toIso8601String(),
            entity: entity,
            recordId: id,
            field: field,
            oldValue: Value(oldV),
            newValue: Value(newV),
            reason: Value(reason),
            author: author,
          ),
        );
  }

  static String? _text(Object? v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is num || v is bool) return v.toString();
    if (v is Enum) return v.name;
    if (v is DateTime) return v.toUtc().toIso8601String();
    if (v is Map || v is List) return jsonEncode(v);
    return v.toString();
  }
}
