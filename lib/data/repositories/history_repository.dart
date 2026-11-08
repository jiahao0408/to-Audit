import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// Read-only access to the change log.
class HistoryRepository {
  HistoryRepository(this._db);

  final AppDatabase _db;

  /// Changes of one record, oldest first.
  Stream<List<ChangeLogData>> watchFor(String entity, String id) =>
      (_db.select(_db.changeLog)
            ..where((c) => c.entity.equals(entity) & c.recordId.equals(id))
            ..orderBy([(c) => OrderingTerm.asc(c.at)]))
          .watch();

  /// Latest changes across all records, newest first.
  Stream<List<ChangeLogData>> watchAll({int limit = 200}) =>
      (_db.select(_db.changeLog)
            ..orderBy([(c) => OrderingTerm.desc(c.at)])
            ..limit(limit))
          .watch();
}
