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
  final keyStore = SecureKeyStore();
  Directory? documents;
  try {
    final docs = documents = await getApplicationDocumentsDirectory();
    // Work files of an export or restore that was cut short. A failing
    // cleanup must not look like a broken database.
    try {
      await BackupService.cleanTemp(defaultTempRoot());
    } catch (e) {
      debugPrint('Temp cleanup failed: ${e.runtimeType}');
    }
    final db = await openAndProbe(
      file: File(p.join(docs.path, databaseFileName)),
      keys: DbKeyManager(keyStore),
      filesRoot: docs,
    );
    runApp(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith(() => DatabaseNotifier(db)),
          documentsDirProvider.overrideWithValue(docs),
          keyStoreProvider.overrideWithValue(keyStore),
        ],
        child: const ToAuditApp(),
      ),
    );
  } on DatabaseKeyMissingException {
    runApp(
      StartupErrorApp(
        keyMissing: true,
        documents: documents,
        keyStore: keyStore,
      ),
    );
  } catch (e) {
    // Type only: the message of a storage error may carry paths.
    debugPrint('Startup failed: ${e.runtimeType}');
    runApp(
      StartupErrorApp(
        keyMissing: false,
        documents: documents,
        keyStore: keyStore,
      ),
    );
  }
}
