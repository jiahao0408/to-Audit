import 'package:sqlite3/sqlite3.dart';

/// Turns off SQLCipher's native log for the whole process, so tests that
/// open a database with a wrong key on purpose keep a clean output.
void quietSqlCipherLog() {
  final db = sqlite3.openInMemory();
  try {
    db.execute('PRAGMA cipher_log_level = NONE');
  } finally {
    db.close();
  }
}
