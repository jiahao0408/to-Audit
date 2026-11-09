import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'data/backup/backup_service.dart';
import 'data/db/open_database.dart';
import 'data/providers.dart';
import 'data/security/db_key_manager.dart';
import 'data/security/key_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final documents = await getApplicationDocumentsDirectory();
  final keyStore = SecureKeyStore();
  try {
    // Work files of an export or restore that was cut short. A failing
    // cleanup must not look like a broken database.
    try {
      await BackupService.cleanTemp(defaultTempRoot());
    } catch (e) {
      debugPrint('Temp cleanup failed: ${e.runtimeType}');
    }
    final db = await openAppDatabase(
      file: File(p.join(documents.path, databaseFileName)),
      keys: DbKeyManager(keyStore),
      filesRoot: documents,
    );
    runApp(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith(() => DatabaseNotifier(db)),
          documentsDirProvider.overrideWithValue(documents),
          keyStoreProvider.overrideWithValue(keyStore),
        ],
        child: const ToAuditApp(),
      ),
    );
  } on DatabaseKeyMissingException {
    runApp(const StartupErrorApp(keyMissing: true));
  } catch (e) {
    // Type only: the message of a storage error may carry paths.
    debugPrint('Startup failed: ${e.runtimeType}');
    runApp(const StartupErrorApp(keyMissing: false));
  }
}
