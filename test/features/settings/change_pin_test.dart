import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/providers.dart';
import 'package:to_audit/data/security/key_store.dart';
import 'package:to_audit/features/settings/settings_screen.dart';
import 'package:to_audit/l10n/app_localizations.dart';

import '../../support/app_harness.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 30)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> typePin(WidgetTester tester, String pin) async {
  for (final d in pin.split('')) {
    await tester.tap(find.text(d).last);
    await tester.pump();
  }
  await settle(tester);
}

void main() {
  testWidgets('a mismatch while creating the new PIN says so', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...appOverrides(
            db: db,
            keyStore: MemoryKeyStore(),
            biometrics: FakeBiometricAuth(),
            clock: () => DateTime(2026, 11, 9, 10),
            documents: Directory.systemTemp,
          ),
          localeProvider.overrideWith((_) => Stream.value('es')),
        ],
        child: const MaterialApp(
          locale: Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );
    await settle(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsScreen)),
    );
    await tester.runAsync(
      () => container.read(pinManagerProvider).setPin('123456'),
    );

    await tester.tap(find.text('Cambiar PIN').last);
    await settle(tester);
    await typePin(tester, '123456'); // current PIN (requireAuth)
    await typePin(tester, '111111'); // new PIN
    await typePin(tester, '222222'); // confirmation differs

    expect(find.text('Los PIN no coinciden'), findsOneWidget);
    expect(find.textContaining('Intentos'), findsNothing);
    // Still the old PIN.
    final ok = await tester.runAsync(
      () => container.read(pinManagerProvider).verify('123456'),
    );
    expect(ok.toString(), contains('PinOk'));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });
}
