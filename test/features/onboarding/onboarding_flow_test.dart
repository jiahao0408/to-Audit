import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/app.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/providers.dart';
import 'package:to_audit/data/security/key_store.dart';
import 'package:to_audit/domain/money.dart';
import 'package:to_audit/features/lock/app_lock_controller.dart';

import '../../support/app_harness.dart';

/// Lets the database streams, the router redirect and animations finish.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Unmounts the app and lets drift's stream clean-up timers run, so the test
/// ends without pending timers.
Future<void> disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(milliseconds: 50));
}

void main() {
  late AppDatabase db;
  late MemoryKeyStore keyStore;
  late FakeBiometricAuth biometrics;

  setUp(() {
    db = AppDatabase.memory();
    keyStore = MemoryKeyStore();
    biometrics = FakeBiometricAuth();
  });
  tearDown(() => db.close());

  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: appOverrides(
          db: db,
          keyStore: keyStore,
          biometrics: biometrics,
          clock: () => DateTime(2026, 11, 9, 10),
          documents: Directory.systemTemp,
        ),
        child: const ToAuditApp(),
      ),
    );
    await settle(tester);
    return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  }

  Future<void> next(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('onboarding-next')));
    await settle(tester);
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('onboarding-next')));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    await settle(tester);
  }

  testWidgets('a fresh install lands on the onboarding, in Spanish', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Elige el idioma'), findsOneWidget);
    expect(find.text('Paso 1 de 4'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('choosing Chinese switches the texts at once', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('language-zh')));
    await settle(tester);
    expect(find.text('选择语言'), findsOneWidget);
    expect(find.text('Elige el idioma'), findsNothing);
    await disposeApp(tester);
  });

  testWidgets('the whole first run ends on the home screen with data saved', (
    tester,
  ) async {
    final container = await pumpApp(tester);

    await next(tester); // language -> restaurant

    // The name is required.
    await next(tester);
    expect(find.text('Obligatorio'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('restaurant-name')),
      'Casa Chen',
    );
    await tester.enterText(
      find.byKey(const ValueKey('restaurant-nif')),
      'B12345678',
    );
    await next(tester); // -> PIN
    expect(find.textContaining('reinstalar la app'), findsOneWidget);

    // A short PIN and a mismatch are refused.
    await tester.enterText(find.byKey(const ValueKey('pin-create')), '123');
    await next(tester);
    expect(
      find.text('El PIN debe tener exactamente 6 dígitos'),
      findsOneWidget,
    );
    await tester.enterText(find.byKey(const ValueKey('pin-create')), '123456');
    await tester.enterText(find.byKey(const ValueKey('pin-repeat')), '123457');
    await next(tester);
    expect(find.text('Los PIN no coinciden'), findsOneWidget);
    await tester.enterText(find.byKey(const ValueKey('pin-repeat')), '123456');
    await next(tester); // -> float (no biometrics on this phone)

    expect(find.text('Fondo de caja inicial'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('initial-float')),
      '150,5',
    );
    await finish(tester);

    expect(find.text('Inicio'), findsWidgets);
    expect(container.read(appLockProvider), isFalse);
    final settings = container.read(settingsRepositoryProvider);
    await tester.runAsync(() async {
      expect(await settings.onboardingDone(), isTrue);
      expect((await settings.restaurant())?.name, 'Casa Chen');
      expect((await settings.restaurant())?.nif, 'B12345678');
      expect(await settings.initialFloat(), const Money(15050));
      expect(await settings.biometricsEnabled(), isFalse);
      expect(await container.read(pinManagerProvider).hasPin(), isTrue);
    });
    await disposeApp(tester);
  });

  testWidgets('with biometrics the extra step turns the flag on', (
    tester,
  ) async {
    biometrics.available = true;
    final container = await pumpApp(tester);
    expect(find.text('Paso 1 de 5'), findsOneWidget);

    await next(tester);
    await tester.enterText(find.byKey(const ValueKey('restaurant-name')), 'X');
    await next(tester);
    await tester.enterText(find.byKey(const ValueKey('pin-create')), '123456');
    await tester.enterText(find.byKey(const ValueKey('pin-repeat')), '123456');
    await next(tester);

    expect(find.text('Huella o rostro'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('biometrics-switch')));
    await settle(tester);
    expect(biometrics.reasons, ['Desbloquea to Audit']);
    await next(tester);
    await tester.enterText(find.byKey(const ValueKey('initial-float')), '0');
    await finish(tester);

    await tester.runAsync(() async {
      expect(
        await container.read(settingsRepositoryProvider).biometricsEnabled(),
        isTrue,
      );
    });
    await disposeApp(tester);
  });
}
