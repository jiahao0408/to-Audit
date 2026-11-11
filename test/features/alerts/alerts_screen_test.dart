import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/providers.dart';
import 'package:to_audit/data/reports/alerts_service.dart';
import 'package:to_audit/data/security/key_store.dart';
import 'package:to_audit/domain/alerts_calc.dart';
import 'package:to_audit/features/alerts/alerts_screen.dart';
import 'package:to_audit/l10n/app_localizations.dart';

import '../../support/app_harness.dart';

class _FakeAlertsService extends Fake implements AlertsService {
  _FakeAlertsService(this.alerts);

  final List<Alert> alerts;

  @override
  Future<List<Alert>> current([DateTime? today]) async => alerts;
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  Future<({List<String> visited})> pumpAlerts(
    WidgetTester tester,
    List<Alert> alerts, {
    String locale = 'es',
  }) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    final visited = <String>[];
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const AlertsScreen()),
        GoRoute(
          path: '/:rest(.*)',
          builder: (context, state) {
            visited.add(state.uri.toString());
            return Scaffold(body: Text('page ${state.uri}'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);
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
          alertsServiceProvider.overrideWithValue(_FakeAlertsService(alerts)),
          localeProvider.overrideWith((_) => Stream.value(locale)),
        ],
        child: MaterialApp.router(
          locale: Locale(locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await settle(tester);
    return (visited: visited);
  }

  testWidgets('shows empty state when there are no alerts', (tester) async {
    await pumpAlerts(tester, []);
    expect(find.text('No hay alertas pendientes'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('dayOpen alert shows description and navigates to /day/…', (
    tester,
  ) async {
    final date = DateTime.utc(2026, 11, 7);
    final (:visited) = await pumpAlerts(tester, [
      Alert(type: AlertType.dayOpen, date: date),
    ]);

    // The description is visible.
    expect(find.textContaining('2026'), findsAtLeastNWidgets(1));
    // The "Ver día" button is visible and navigates.
    expect(find.text('Ver día'), findsOneWidget);
    await tester.tap(find.text('Ver día'));
    await settle(tester);
    expect(visited, ['/day/2026-11-07']);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('backupOld alert shows go-backup button', (tester) async {
    final (:visited) = await pumpAlerts(tester, [
      const Alert(type: AlertType.backupOld),
    ]);
    expect(find.text('Hacer copia'), findsOneWidget);
    await tester.tap(find.text('Hacer copia'));
    await settle(tester);
    expect(visited, ['/backup']);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('multiple alert types are grouped and all visible', (
    tester,
  ) async {
    final date = DateTime.utc(2026, 11, 7);
    await pumpAlerts(tester, [
      Alert(type: AlertType.dayOpen, date: date),
      const Alert(type: AlertType.backupOld),
      const Alert(type: AlertType.missingReceipt, recordId: 'exp-1'),
    ]);
    // All three navigation buttons (or labels) should be present.
    expect(find.text('Ver día'), findsOneWidget);
    expect(find.text('Hacer copia'), findsOneWidget);
    expect(find.text('Ver gasto'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('missingReceipt navigates to /expenses/:id', (tester) async {
    final (:visited) = await pumpAlerts(tester, [
      const Alert(type: AlertType.missingReceipt, recordId: 'abc-123'),
    ]);
    await tester.tap(find.text('Ver gasto'));
    await settle(tester);
    expect(visited, ['/expenses/abc-123']);
    await tester.pumpWidget(const SizedBox());
  });
}
