import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:to_audit/data/audit/audit_writer.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/providers.dart';
import 'package:to_audit/data/repositories/settings_repository.dart';
import 'package:to_audit/data/reports/alerts_service.dart';
import 'package:to_audit/data/reports/report_service.dart';
import 'package:to_audit/data/security/key_store.dart';
import 'package:to_audit/domain/alerts_calc.dart';
import 'package:to_audit/domain/enums.dart';
import 'package:to_audit/domain/money.dart';
import 'package:to_audit/features/home/home_screen.dart';
import 'package:to_audit/l10n/app_localizations.dart';

import '../../support/app_harness.dart';

class FakeReportService extends Fake implements ReportService {
  FakeReportService(this.summary);

  HomeSummary summary;
  final List<DateTime> asked = [];

  @override
  Future<HomeSummary> home(DateTime today) async {
    asked.add(today);
    return summary;
  }
}

class FakeAlertsService extends Fake implements AlertsService {
  FakeAlertsService(this.alerts);

  List<Alert> alerts;

  @override
  Future<List<Alert>> current([DateTime? today]) async => alerts;
}

/// A Text whose content equals [text], ignoring non-breaking spaces.
Finder money(String text) => find.byWidgetPredicate(
  (w) => w is Text && (w.data ?? '').replaceAll(' ', ' ') == text,
);

/// Lets futures and drift streams finish under the fake clock of the test.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  late AppDatabase db;
  late FakeReportService report;
  late FakeAlertsService alerts;
  late DateTime now;
  late List<String> visited;

  setUp(() {
    db = AppDatabase.memory();
    now = DateTime(2026, 11, 9, 10);
    visited = [];
    report = FakeReportService(
      HomeSummary(
        monthSales: const Money(270000),
        profitToDate: const Money(54321),
        lastClosedDay: DateTime.utc(2026, 11, 6),
        nextPending: DateTime.utc(2026, 11, 7),
      ),
    );
    alerts = FakeAlertsService([
      const Alert(type: AlertType.backupOld),
      Alert(type: AlertType.dayUnregistered, date: DateTime.utc(2026, 11, 7)),
    ]);
  });
  tearDown(() => db.close());

  Future<ProviderContainer> pumpHome(
    WidgetTester tester, {
    String locale = 'es',
  }) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
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
            clock: () => now,
            documents: Directory.systemTemp,
          ),
          reportServiceProvider.overrideWithValue(report),
          alertsServiceProvider.overrideWithValue(alerts),
          localeProvider.overrideWith((ref) => Stream.value(locale)),
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
    return ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));
  }

  Future<void> disposeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('shows the month sales and the profit to date', (tester) async {
    await pumpHome(tester);
    expect(find.text('Ventas del mes'), findsOneWidget);
    expect(money('2.700,00 €'), findsOneWidget);
    expect(find.text('Beneficio acumulado'), findsOneWidget);
    expect(money('543,21 €'), findsOneWidget);
    expect(find.textContaining('Hasta el último día cerrado'), findsOneWidget);
    expect(report.asked.single, DateTime.utc(2026, 11, 9));
    await disposeApp(tester);
  });

  testWidgets('the register button goes to the next pending day', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.tap(find.text('Registrar siguiente día pendiente'));
    await settle(tester);
    expect(visited, ['/day/2026-11-07']);
    await disposeApp(tester);
  });

  testWidgets('no pending day hides the register button', (tester) async {
    report.summary = HomeSummary(
      monthSales: Money.zero,
      profitToDate: Money.zero,
      lastClosedDay: null,
      nextPending: null,
    );
    await pumpHome(tester);
    expect(find.text('Registrar siguiente día pendiente'), findsNothing);
    expect(find.text('Todos los días están al día'), findsOneWidget);
    expect(find.text('Aún no hay días cerrados'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('the alerts counter shows the count and opens the alerts', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(find.text('2 alertas'), findsOneWidget);
    await tester.tap(find.text('2 alertas'));
    await settle(tester);
    expect(visited, ['/alerts']);
    await disposeApp(tester);
  });

  testWidgets('no alerts reads "Sin alertas"', (tester) async {
    alerts.alerts = [];
    await pumpHome(tester);
    expect(find.text('Sin alertas'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('shortcuts go to calendar, expenses, reports and settings', (
    tester,
  ) async {
    await pumpHome(tester);
    for (final (label, path) in [
      ('Calendario', '/calendar'),
      ('Gastos', '/expenses'),
      ('Informes', '/reports'),
      ('Ajustes', '/settings'),
    ]) {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await settle(tester);
      expect(visited.last, path);
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await settle(tester);
    }
    await disposeApp(tester);
  });

  testWidgets('Chinese shows yuan-style money and Chinese labels', (
    tester,
  ) async {
    await pumpHome(tester, locale: 'zh');
    expect(find.text('本月销售额'), findsOneWidget);
    expect(money('€2,700.00'), findsOneWidget);
    expect(find.text('2 条提醒'), findsOneWidget);
    await disposeApp(tester);
  });

  group('backup reminder', () {
    testWidgets('a banner appears when the copy is due and opens /backup', (
      tester,
    ) async {
      final container = await pumpHome(tester);
      // Never backed up: due.
      expect(
        find.text('Aún no has hecho ninguna copia de seguridad'),
        findsOneWidget,
      );
      await tester.tap(find.text('Hacer copia'));
      await settle(tester);
      expect(visited, ['/backup']);
      expect(container, isNotNull);
      await disposeApp(tester);
    });

    testWidgets('a recent copy hides the banner', (tester) async {
      final container = await pumpHome(tester);
      await tester.runAsync(
        () => container
            .read(settingsRepositoryProvider)
            .setLastBackupAt(DateTime(2026, 11, 8, 9).toUtc()),
      );
      container.invalidate(backupStatusProvider);
      await settle(tester);
      expect(find.text('Hacer copia'), findsNothing);
      await disposeApp(tester);
    });

    testWidgets('an old copy says how many days ago', (tester) async {
      final container = await pumpHome(tester);
      await tester.runAsync(
        () => container
            .read(settingsRepositoryProvider)
            .setLastBackupAt(DateTime(2026, 10, 30, 9).toUtc()),
      );
      container.invalidate(backupStatusProvider);
      await settle(tester);
      expect(
        find.text('Tu última copia de seguridad fue hace 10 días'),
        findsOneWidget,
      );
      await disposeApp(tester);
    });
  });

  group('backup warning on open', () {
    testWidgets('no day registered yet: no dialog', (tester) async {
      await pumpHome(tester);
      expect(find.byType(AlertDialog), findsNothing);
      await disposeApp(tester);
    });

    testWidgets('with a day and no recent copy: one dialog, once', (
      tester,
    ) async {
      await db
          .into(db.days)
          .insert(
            DaysCompanion.insert(
              id: 'd1',
              createdAt: nowIso(),
              updatedAt: nowIso(),
              date: '2026-11-01',
              status: DayStatus.open,
              openingFloatCents: 0,
            ),
          );
      final container = await pumpHome(tester);
      expect(find.text('Copia de seguridad pendiente'), findsOneWidget);

      await tester.tap(find.text('Más tarde'));
      await settle(tester);
      expect(find.byType(AlertDialog), findsNothing);

      // Back on the home screen later in the same run: not asked again.
      container.invalidate(homeSummaryProvider);
      await settle(tester);
      expect(find.byType(AlertDialog), findsNothing);
      await disposeApp(tester);
    });

    testWidgets('the dialog button opens /backup', (tester) async {
      await db
          .into(db.days)
          .insert(
            DaysCompanion.insert(
              id: 'd1',
              createdAt: nowIso(),
              updatedAt: nowIso(),
              date: '2026-11-01',
              status: DayStatus.open,
              openingFloatCents: 0,
            ),
          );
      await pumpHome(tester);
      await tester.tap(find.text('Hacer copia ahora'));
      await settle(tester);
      expect(visited, ['/backup']);
      await disposeApp(tester);
    });

    testWidgets('a copy from last week: banner maybe, but no dialog', (
      tester,
    ) async {
      await db
          .into(db.days)
          .insert(
            DaysCompanion.insert(
              id: 'd1',
              createdAt: nowIso(),
              updatedAt: nowIso(),
              date: '2026-11-01',
              status: DayStatus.open,
              openingFloatCents: 0,
            ),
          );
      await SettingsRepository(
        db,
        AuditWriter(db),
      ).setLastBackupAt(DateTime(2026, 11, 2, 9).toUtc());
      await pumpHome(tester);
      expect(find.byType(AlertDialog), findsNothing);
      await disposeApp(tester);
    });
  });
}
