import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/db/open_database.dart';
import 'package:to_audit/data/providers.dart';
import 'package:to_audit/data/security/db_key_manager.dart';
import 'package:to_audit/data/security/key_store.dart';
import 'package:to_audit/domain/enums.dart';
import 'package:to_audit/features/backup/backup_screen.dart';
import 'package:to_audit/features/common/platform_services.dart';
import 'package:to_audit/features/home/home_screen.dart';
import 'package:to_audit/l10n/app_localizations.dart';

import '../../data/backup/backup_service_test.dart'
    show Phone, keyA, keyB, repack;
import '../../support/app_harness.dart';
import '../../support/sqlcipher.dart';

class _FakeSharer implements FileSharer {
  bool result = true;
  final List<String> shared = [];
  final List<Uint8List> headers = [];

  @override
  Future<bool> shareFile(File file, {String? mimeType}) async {
    expect(file.existsSync(), isTrue, reason: 'the copy exists while sharing');
    shared.add(file.uri.pathSegments.last);
    headers.add(file.readAsBytesSync().sublist(0, 8));
    return result;
  }

  @override
  Future<void> savePdf(Uint8List bytes, String filename) async {}
}

class _FakePicker implements BackupFilePicker {
  File? next;

  @override
  Future<File?> pick() async => next;
}

/// Real time for file IO, PBKDF2 isolates and SQLCipher, until [done].
Future<void> waitFor(WidgetTester tester, bool Function() done) async {
  for (var i = 0; i < 300; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(milliseconds: 50));
    if (done()) return;
  }
  final texts = find
      .byType(Text)
      .evaluate()
      .map((e) => (e.widget as Text).data);
  fail('timed out; screen shows: $texts');
}

bool _busy() => find.byType(CircularProgressIndicator).evaluate().isNotEmpty;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  setUpAll(quietSqlCipherLog);

  late Directory documents;
  late Directory tempRoot;
  late AppDatabase db;
  late MemoryKeyStore keyStore;
  late _FakeSharer sharer;
  late _FakePicker picker;
  late ProviderContainer container;

  final clock = DateTime(2026, 11, 9, 10);

  setUp(() async {
    documents = await Directory.systemTemp.createTemp('bk_docs');
    tempRoot = await Directory.systemTemp.createTemp('bk_tmp');
    keyStore = MemoryKeyStore();
    await keyStore.write(DbKeyManager.storageKey, keyA);
    db = await openEncryptedDatabase(
      file: File('${documents.path}/to_audit.db'),
      hexKey: keyA,
    );
    // The file is created on the first query.
    await db.customSelect('SELECT 1').get();
    sharer = _FakeSharer();
    picker = _FakePicker();
  });

  tearDown(() async {
    try {
      await container.read(databaseProvider).close();
    } catch (_) {}
    // The background isolate of a closed database may release its file late.
    for (final dir in [documents, tempRoot]) {
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {}
    }
  });

  Future<void> pump(
    WidgetTester tester, {
    bool standalone = false,
    bool withDb = true,
  }) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/backup',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
        GoRoute(
          path: '/backup',
          builder: (_, _) => BackupScreen(standalone: standalone),
        ),
      ],
    );
    addTearDown(router.dispose);
    final overrides = [
      ...appOverrides(
        db: db,
        keyStore: keyStore,
        biometrics: FakeBiometricAuth(),
        clock: () => clock,
        documents: documents,
      ),
      tempRootProvider.overrideWithValue(tempRoot),
      backupIterationsProvider.overrideWithValue(1000),
      fileSharerProvider.overrideWithValue(sharer),
      backupFilePickerProvider.overrideWithValue(picker),
    ];
    container = ProviderContainer(overrides: overrides);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// A backup from another "phone" with one closed day of 1.234,56 € sales
  /// (key B, so restoring also changes the key the data is stored with).
  Future<File> sourceBackup(WidgetTester tester, {String name = 'src'}) async {
    late File file;
    await tester.runAsync(() async {
      final source = await Phone.create(name, hexKey: keyB);
      await source.seed();
      final now = DateTime.now().toUtc().toIso8601String();
      final cash = (await source.db.select(source.db.paymentMethods).get())
          .firstWhere((m) => m.code == 'cash')
          .id;
      await source.db
          .into(source.db.days)
          .insert(
            DaysCompanion.insert(
              id: 'dclosed',
              createdAt: now,
              updatedAt: now,
              date: '2026-11-05',
              status: DayStatus.closed,
              openingFloatCents: 0,
            ),
          );
      await source.db
          .into(source.db.sales)
          .insert(
            SalesCompanion.insert(
              id: 's1',
              createdAt: now,
              updatedAt: now,
              dayId: 'dclosed',
              shift: Shift.lunch,
              paymentMethodId: cash,
              amountCents: 123456,
            ),
          );
      file = await source.service().export(
        'secret-pass',
        now: DateTime.utc(2026, 11, 8, 9),
      );
      final copy = File('${documents.path}/$name.toaudit');
      await file.copy(copy.path);
      file = copy;
      await source.dispose();
    });
    return file;
  }

  Future<void> chooseFileAndPassword(
    WidgetTester tester,
    File file,
    String password,
  ) async {
    picker.next = file;
    await tester.tap(find.text('Elegir archivo .toaudit'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.enterText(
      find.byKey(const ValueKey('backup-restore-pass')),
      password,
    );
    await tester.tap(find.text('Continuar'));
    await tester.pump();
  }

  List<String> restoreDirs() => tempRoot
      .listSync()
      .map((e) => e.uri.pathSegments.where((s) => s.isNotEmpty).last)
      .where((n) => n.startsWith('restore_'))
      .toList();

  testWidgets('password under 8 characters and mismatch show messages', (
    tester,
  ) async {
    await pump(tester);
    await tester.enterText(find.byKey(const ValueKey('backup-pass')), 'short');
    await tester.pump();
    expect(find.text('Mínimo 8 caracteres'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('backup-pass')),
      'long-enough',
    );
    await tester.enterText(
      find.byKey(const ValueKey('backup-pass-confirm')),
      'different1',
    );
    await tester.pump();
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Crear y exportar'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.onPressed, isNull);
    expect(sharer.shared, isEmpty);
    // The warning about the password is always visible.
    expect(
      find.textContaining('sin ella no se puede restaurar'),
      findsOneWidget,
    );
  });

  testWidgets('create: real export is shared and the temp copy is deleted', (
    tester,
  ) async {
    await pump(tester);
    await tester.enterText(
      find.byKey(const ValueKey('backup-pass')),
      'long-enough',
    );
    await tester.enterText(
      find.byKey(const ValueKey('backup-pass-confirm')),
      'long-enough',
    );
    await tester.pump();
    await tester.tap(find.text('Crear y exportar'));
    await tester.pump();
    await waitFor(tester, () => sharer.shared.isNotEmpty && !_busy());

    expect(sharer.shared, ['to-audit-2026-11-09.toaudit']);
    expect(ascii.decode(sharer.headers.single), 'TOAUDIT1');
    expect(find.text('Copia creada'), findsOneWidget);
    // Nothing is left behind once the share sheet returned.
    expect(
      tempRoot.listSync().where((e) => e.path.endsWith('.toaudit')),
      isEmpty,
    );
    // The password fields were cleared.
    expect(find.text('long-enough'), findsNothing);
    // Shared: the backup reminder is reset.
    final last = await tester.runAsync(
      () => container.read(settingsRepositoryProvider).lastBackupAt(),
    );
    expect(last, isNotNull);
  });

  testWidgets('a dismissed share sheet is not a backup', (tester) async {
    sharer.result = false;
    await pump(tester);
    await tester.enterText(
      find.byKey(const ValueKey('backup-pass')),
      'long-enough',
    );
    await tester.enterText(
      find.byKey(const ValueKey('backup-pass-confirm')),
      'long-enough',
    );
    await tester.pump();
    await tester.tap(find.text('Crear y exportar'));
    await tester.pump();
    await waitFor(tester, () => sharer.shared.isNotEmpty && !_busy());

    expect(find.text('Copia creada'), findsNothing);
    final last = await tester.runAsync(
      () => container.read(settingsRepositoryProvider).lastBackupAt(),
    );
    expect(last, isNull);
    expect(
      tempRoot.listSync().where((e) => e.path.endsWith('.toaudit')),
      isEmpty,
    );
  });

  testWidgets('a file that is not .toaudit is refused', (tester) async {
    await pump(tester);
    final other = File('${documents.path}/x.zip')..writeAsStringSync('x');
    picker.next = other;
    await tester.tap(find.text('Elegir archivo .toaudit'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.text('El archivo debe tener la extensión .toaudit'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('backup-restore-pass')), findsNothing);
  });

  testWidgets('wrong password shows the decrypt message', (tester) async {
    await pump(tester);
    final backup = await sourceBackup(tester);
    await chooseFileAndPassword(tester, backup, 'wrong-password');
    await waitFor(tester, () => !_busy());
    expect(find.text('Contraseña incorrecta o archivo dañado'), findsOneWidget);
    expect(find.text('Restaurar ahora'), findsNothing);
    expect(restoreDirs(), isEmpty);
  });

  testWidgets('a backup from a newer app shows the too-new message', (
    tester,
  ) async {
    await pump(tester);
    final backup = await sourceBackup(tester);
    late File newer;
    await tester.runAsync(() async {
      newer = await repack(backup, File('${documents.path}/newer.toaudit'), (
        entries,
      ) {
        final manifest = jsonDecode(
          utf8.decode(entries['manifest.json']!),
        ) as Map<String, dynamic>;
        manifest['schemaVersion'] = 99;
        entries['manifest.json'] = utf8.encode(jsonEncode(manifest));
      });
    });
    await chooseFileAndPassword(tester, newer, 'secret-pass');
    await waitFor(tester, () => !_busy());
    expect(
      find.text('Esta copia fue creada con una versión más reciente de la app'),
      findsOneWidget,
    );
    expect(restoreDirs(), isEmpty);
  });

  testWidgets('summary is shown and cancelling deletes the decrypted folder', (
    tester,
  ) async {
    await pump(tester);
    final backup = await sourceBackup(tester);
    await chooseFileAndPassword(tester, backup, 'secret-pass');
    await waitFor(
      tester,
      () => find.text('Restaurar ahora').evaluate().isNotEmpty,
    );

    expect(find.text('Vista previa de la copia'), findsOneWidget);
    // 3 days (2 open + 1 closed) and 3 expenses.
    expect(find.text('3'), findsNWidgets(2));
    expect(restoreDirs(), hasLength(1));

    await tester.tap(find.text('Cancelar y limpiar'));
    await waitFor(tester, () => restoreDirs().isEmpty);
    expect(find.text('Elegir archivo .toaudit'), findsOneWidget);
  });

  testWidgets('restore replaces the data and the home screen shows it', (
    tester,
  ) async {
    await pump(tester);
    final backup = await sourceBackup(tester);
    await chooseFileAndPassword(tester, backup, 'secret-pass');
    await waitFor(
      tester,
      () => find.text('Restaurar ahora').evaluate().isNotEmpty,
    );

    await tester.tap(find.text('Restaurar ahora'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const ValueKey('backup-restore-confirm')));
    await tester.pump();
    await waitFor(
      tester,
      () => find
          .byWidgetPredicate(
            (w) => w is Text && (w.data ?? '').contains('1.234,56'),
          )
          .evaluate()
          .isNotEmpty,
    );
    expect(find.byType(HomeScreen), findsOneWidget);

    expect(restoreDirs(), isEmpty);
    // The provider holds the reopened database, not the closed one.
    expect(identical(container.read(databaseProvider), db), isFalse);
  });

  testWidgets('a marker left by an earlier restore asks to restart the app', (
    tester,
  ) async {
    await pump(tester);
    final backup = await sourceBackup(tester);
    File('${documents.path}/to_audit.db.restore-in-progress')
        .writeAsStringSync('restore');
    await chooseFileAndPassword(tester, backup, 'secret-pass');
    await waitFor(
      tester,
      () => find.text('Restaurar ahora').evaluate().isNotEmpty,
    );
    await tester.tap(find.text('Restaurar ahora'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const ValueKey('backup-restore-confirm')));
    await tester.pump();
    await waitFor(
      tester,
      () => find
          .text('Reinicia la app para terminar de recuperar los datos')
          .evaluate()
          .isNotEmpty,
    );
    expect(restoreDirs(), isEmpty);
  });

  testWidgets('standalone (no database): restores and asks to reopen', (
    tester,
  ) async {
    // The start-up error case: a damaged file and no key.
    await tester.runAsync(db.close);
    File('${documents.path}/to_audit.db').writeAsStringSync('damaged');
    keyStore = MemoryKeyStore();
    await pump(tester, standalone: true);
    expect(find.text('Nueva copia'), findsNothing);
    final backup = await sourceBackup(tester);
    await chooseFileAndPassword(tester, backup, 'secret-pass');
    await waitFor(
      tester,
      () => find.text('Restaurar ahora').evaluate().isNotEmpty,
    );
    await tester.tap(find.text('Restaurar ahora'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const ValueKey('backup-restore-confirm')));
    await tester.pump();
    await waitFor(
      tester,
      () => find.text('Copia restaurada').evaluate().isNotEmpty,
    );
    expect(find.textContaining('Cierra y vuelve a abrir'), findsOneWidget);

    // The restored database opens with the key that was created.
    final reopened = await tester.runAsync(
      () async => openAppDatabase(
        file: File('${documents.path}/to_audit.db'),
        keys: DbKeyManager(keyStore),
        filesRoot: documents,
      ),
    );
    final count = await tester.runAsync(
      () =>
          reopened!.customSelect('SELECT COUNT(*) c FROM dia_caja').getSingle(),
    );
    expect(count!.read<int>('c'), 3);
    await tester.runAsync(reopened!.close);
  });
}
