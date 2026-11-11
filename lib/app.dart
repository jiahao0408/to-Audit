import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/providers.dart';
import 'data/security/key_store.dart';
import 'features/backup/backup_screen.dart';
import 'features/lock/app_lock_gate.dart';
import 'l10n/app_localizations.dart';
import 'router.dart';

const _seed = Colors.teal;
const _minButton = Size(48, 48);

/// Material 3 theme in [brightness]: seed colors, 48x48 minimum buttons and
/// the bundled font (it has the Chinese glyphs).
ThemeData buildTheme(Brightness brightness) {
  final shape = WidgetStatePropertyAll(
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
  const size = WidgetStatePropertyAll(_minButton);
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: _seed,
    brightness: brightness,
    fontFamily: 'NotoSansSC',
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(minimumSize: size, shape: shape),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(minimumSize: size, shape: shape),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(minimumSize: size, shape: shape),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(minimumSize: size, shape: shape),
    ),
    materialTapTargetSize: MaterialTapTargetSize.padded,
  );
}

const _delegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

class ToAuditApp extends ConsumerWidget {
  const ToAuditApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(localeProvider).value ?? 'es';
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: _delegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: Locale(code),
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) => AppLockGate(child: child!),
    );
  }
}

/// Shown instead of the app when the database cannot be opened. It offers to
/// restore a backup; it never creates a new database.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({
    super.key,
    required this.keyMissing,
    this.documents,
    this.keyStore,
  });

  /// Where the database lives and the key store, for the restore.
  final Directory? documents;
  final KeyStore? keyStore;

  /// The database exists but its key is gone (spec section 10).
  final bool keyMissing;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: _delegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: Builder(
        builder: (context) {
          final l = AppLocalizations.of(context)!;
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        keyMissing ? l.keyMissingTitle : l.startupErrorTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        keyMissing ? l.keyMissingBody : l.startupErrorBody,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: documents == null
                            ? null
                            : () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ProviderScope(
                                    overrides: [
                                      documentsDirProvider.overrideWithValue(
                                        documents!,
                                      ),
                                      keyStoreProvider.overrideWithValue(
                                        keyStore ?? SecureKeyStore(),
                                      ),
                                    ],
                                    child: const BackupScreen(standalone: true),
                                  ),
                                ),
                              ),
                        child: Text(l.restoreBackupButton),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
