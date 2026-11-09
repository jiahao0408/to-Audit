import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/providers.dart';
import 'package:to_audit/data/security/key_store.dart';
import 'package:to_audit/features/common/auth_gate.dart';
import 'package:to_audit/features/lock/app_lock_controller.dart';
import 'package:to_audit/features/lock/app_lock_gate.dart';
import 'package:to_audit/data/security/pin_manager.dart';
import 'package:to_audit/features/lock/lock_screen.dart' show hasPinProvider;
import 'package:to_audit/features/lock/pin_entry.dart';
import 'package:to_audit/l10n/app_localizations.dart';

import '../../support/app_harness.dart';

void main() {
  late AppDatabase db;
  late MemoryKeyStore keyStore;
  late FakeBiometricAuth biometrics;
  late DateTime now;
  late Directory documents;

  setUp(() {
    db = AppDatabase.memory();
    keyStore = MemoryKeyStore();
    biometrics = FakeBiometricAuth();
    now = DateTime(2026, 11, 9, 10);
    documents = Directory.systemTemp;
  });
  tearDown(() => db.close());

  Widget app({Widget? body}) => ProviderScope(
    overrides: appOverrides(
      db: db,
      keyStore: keyStore,
      biometrics: biometrics,
      clock: () => now,
      documents: documents,
    ),
    child: MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => AppLockGate(child: child!),
      home: Scaffold(body: body ?? const Center(child: Text('secreto'))),
    ),
  );

  ProviderContainer containerOf(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

  Future<void> setPin(WidgetTester tester, [String pin = '123456']) => tester
      .runAsync(() => containerOf(tester).read(pinManagerProvider).setPin(pin));

  Future<void> typePin(WidgetTester tester, String pin) async {
    for (final d in pin.split('')) {
      await tester.tap(find.byKey(ValueKey('pin-key-$d')));
      await tester.pump();
    }
    // Hashing runs in real time.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pump();
  }

  testWidgets('with no PIN the app is not covered', (tester) async {
    await tester.pumpWidget(app());
    await tester.pump();
    await tester.pump();
    expect(find.text('secreto'), findsOneWidget);
    expect(find.byKey(const ValueKey('pin-key-1')), findsNothing);
  });

  testWidgets('with a PIN it starts locked and the right PIN unlocks', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await setPin(tester);
    containerOf(tester).invalidate(hasPinProvider);
    await tester.pump();
    await tester.pump();

    expect(find.text('Introduce tu PIN'), findsOneWidget);
    expect(find.text('secreto'), findsNothing);

    await typePin(tester, '123456');
    expect(find.text('secreto'), findsOneWidget);
    expect(find.text('Introduce tu PIN'), findsNothing);
  });

  testWidgets('a wrong PIN shows the attempts left and stays locked', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await setPin(tester);
    containerOf(tester).invalidate(hasPinProvider);
    await tester.pump();
    await tester.pump();

    await typePin(tester, '000000');
    expect(
      find.text('PIN incorrecto. Intentos antes del bloqueo: 4'),
      findsOneWidget,
    );
    expect(find.text('secreto'), findsNothing);
  });

  testWidgets('five wrong PINs lock the pad with a countdown', (tester) async {
    await tester.pumpWidget(app());
    await setPin(tester);
    containerOf(tester).invalidate(hasPinProvider);
    await tester.pump();
    await tester.pump();

    for (var i = 0; i < 5; i++) {
      await typePin(tester, '000000');
    }
    expect(find.textContaining('Demasiados intentos'), findsOneWidget);
    final key = tester.widget<TextButton>(
      find.byKey(const ValueKey('pin-key-1')),
    );
    expect(key.onPressed, isNull);
    // Leave no countdown timer running.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a verify that throws does not kill the pad', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PinEntry(
            verify: (pin) async {
              calls++;
              if (calls == 1) throw PlatformException(code: 'keystore');
              return const PinOk();
            },
            onSuccess: () {},
          ),
        ),
      ),
    );
    Future<void> type() async {
      for (final d in '123456'.split('')) {
        await tester.tap(find.byKey(ValueKey('pin-key-$d')));
        await tester.pump();
      }
      await tester.pump();
    }

    await type();
    expect(find.text('No se pudo comprobar el PIN'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await type();
    expect(calls, 2);
    expect(find.text('No se pudo comprobar el PIN'), findsNothing);
  });

  testWidgets('the app locks after 5 minutes in the background', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await setPin(tester);
    containerOf(tester).invalidate(hasPinProvider);
    await tester.pump();
    await tester.pump();
    containerOf(tester).read(appLockProvider.notifier).unlock();
    await tester.pump();
    expect(find.text('secreto'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = now.add(const Duration(minutes: 4, seconds: 59));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('secreto'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = now.add(const Duration(minutes: 5));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('Introduce tu PIN'), findsOneWidget);
    expect(find.text('secreto'), findsNothing);
  });

  testWidgets('the screen under the lock keeps its state', (tester) async {
    await tester.pumpWidget(
      app(
        body: const Center(child: TextField(key: ValueKey('draft'))),
      ),
    );
    await setPin(tester);
    containerOf(tester).invalidate(hasPinProvider);
    await tester.pump();
    await tester.pump();
    containerOf(tester).read(appLockProvider.notifier).unlock();
    await tester.pump();
    await tester.enterText(find.byKey(const ValueKey('draft')), 'media tarea');

    containerOf(tester).read(appLockProvider.notifier).lock();
    await tester.pump();
    expect(find.byKey(const ValueKey('draft')), findsNothing);
    containerOf(tester).read(appLockProvider.notifier).unlock();
    await tester.pump();
    expect(find.text('media tarea'), findsOneWidget);
  });

  testWidgets('the lock screen offers biometrics when enabled', (tester) async {
    biometrics
      ..available = true
      ..succeeds = false;
    await tester.pumpWidget(app());
    await setPin(tester);
    await tester.runAsync(
      () =>
          containerOf(tester)
              .read(settingsRepositoryProvider)
              .setBiometricsEnabled(true),
    );
    containerOf(tester).invalidate(hasPinProvider);
    await tester.pump();
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();

    // It asked once on its own and, being cancelled by the fake, stays locked
    // with the button there.
    expect(biometrics.reasons, hasLength(1));
    expect(find.text('secreto'), findsNothing);
    expect(find.byKey(const ValueKey('lock-biometric')), findsOneWidget);
    biometrics.succeeds = true;
    await tester.tap(find.byKey(const ValueKey('lock-biometric')));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    expect(find.text('secreto'), findsOneWidget);
    expect(biometrics.reasons, contains('Desbloquea to Audit'));
  });

  group('requireAuth', () {
    late WidgetRef captured;
    bool? outcome;

    Future<void> pumpAuthApp(WidgetTester tester) async {
      outcome = null;
      await tester.pumpWidget(
        ProviderScope(
          overrides: appOverrides(
            db: db,
            keyStore: keyStore,
            biometrics: biometrics,
            clock: () => now,
            documents: documents,
          ),
          child: MaterialApp(
            locale: const Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Consumer(
              builder: (context, ref, _) {
                captured = ref;
                return Scaffold(
                  body: TextButton(
                    onPressed: () async => outcome = await requireAuth(
                      context,
                      ref,
                      reason: 'Reabrir el mes',
                    ),
                    child: const Text('go'),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    Future<void> tapGo(WidgetTester tester) async {
      await tester.tap(find.text('go'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();
    }

    testWidgets('uses the biometrics when enabled and available', (
      tester,
    ) async {
      biometrics.available = true;
      await pumpAuthApp(tester);
      await tester.runAsync(
        () => captured
            .read(settingsRepositoryProvider)
            .setBiometricsEnabled(true),
      );
      await tapGo(tester);
      expect(outcome, isTrue);
      expect(biometrics.reasons, ['Reabrir el mes']);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('falls back to the PIN when the biometrics fail', (
      tester,
    ) async {
      biometrics
        ..available = true
        ..succeeds = false;
      await pumpAuthApp(tester);
      await tester.runAsync(() async {
        await captured
            .read(settingsRepositoryProvider)
            .setBiometricsEnabled(true);
        await captured.read(pinManagerProvider).setPin('123456');
      });
      await tapGo(tester);
      expect(biometrics.reasons, ['Reabrir el mes']);
      expect(find.text('Confirma con tu PIN'), findsOneWidget);

      await typePin(tester, '123456');
      expect(outcome, isTrue);
    });

    testWidgets('without biometrics asks for the PIN and rejects a wrong one', (
      tester,
    ) async {
      await pumpAuthApp(tester);
      await tester.runAsync(
        () => captured.read(pinManagerProvider).setPin('123456'),
      );
      await tapGo(tester);
      expect(biometrics.reasons, isEmpty);
      expect(find.text('Reabrir el mes'), findsOneWidget);

      await typePin(tester, '654321');
      expect(outcome, isNull);
      expect(find.text('Confirma con tu PIN'), findsOneWidget);

      await typePin(tester, '123456');
      expect(outcome, isTrue);
    });

    testWidgets('cancelling the PIN dialog returns false', (tester) async {
      await pumpAuthApp(tester);
      await tapGo(tester);
      await tester.tap(find.text('Cancelar'));
      await tester.pump();
      expect(outcome, isFalse);
    });
  });
}
