import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/providers.dart';
import 'package:to_audit/data/security/key_store.dart';
import 'package:to_audit/domain/dates.dart';
import 'package:to_audit/domain/enums.dart';
import 'package:to_audit/features/calendar/calendar_screen.dart';
import 'package:to_audit/l10n/app_localizations.dart';

import '../../support/app_harness.dart';

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
  late List<String> visited;

  setUp(() {
    db = AppDatabase.memory();
    visited = [];
  });
  tearDown(() => db.close());

  Future<ProviderContainer> pumpCalendar(WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const CalendarScreen()),
        GoRoute(
          path: '/day/:ymd',
          builder: (context, state) {
            visited.add(state.uri.toString());
            return const Scaffold(body: Text('day page'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: appOverrides(
          db: db,
          keyStore: MemoryKeyStore(),
          biometrics: FakeBiometricAuth(),
          clock: () => DateTime(2026, 11, 9, 10),
          documents: Directory.systemTemp,
        ),
        child: MaterialApp.router(
          locale: const Locale('es'),
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

  Finder cell(String ymd) => find.byKey(ValueKey('day-$ymd'));

  IconData iconOf(WidgetTester tester, String ymd) => tester
      .widget<Icon>(
        find.descendant(of: cell(ymd), matching: find.byType(Icon)).first,
      )
      .icon!;

  testWidgets('shows the current month and the state of each day', (
    tester,
  ) async {
    await pumpCalendar(tester);
    expect(find.text('noviembre de 2026'), findsOneWidget);
    // Past day without a record, today without a record, a future day.
    expect(iconOf(tester, '2026-11-02'), Icons.edit_calendar_outlined);
    expect(iconOf(tester, '2026-11-09'), Icons.edit_calendar_outlined);
    expect(iconOf(tester, '2026-11-20'), Icons.schedule);
    await disposeApp(tester);
  });

  testWidgets('previous and next move between months', (tester) async {
    await pumpCalendar(tester);
    await tester.tap(find.byTooltip('Mes anterior'));
    await settle(tester);
    expect(find.text('octubre de 2026'), findsOneWidget);
    expect(cell('2026-10-31'), findsOneWidget);
    await tester.tap(find.byTooltip('Mes siguiente'));
    await tester.tap(find.byTooltip('Mes siguiente'));
    await settle(tester);
    expect(find.text('diciembre de 2026'), findsOneWidget);
    await disposeApp(tester);
  });

  testWidgets('tapping a day opens it', (tester) async {
    await pumpCalendar(tester);
    await tester.tap(cell('2026-11-05'));
    await settle(tester);
    expect(visited, ['/day/2026-11-05']);
    await disposeApp(tester);
  });

  testWidgets('tapping a future day does not navigate', (tester) async {
    await pumpCalendar(tester);
    await tester.tap(cell('2026-11-20'));
    await settle(tester);
    expect(visited, isEmpty);
    await disposeApp(tester);
  });

  testWidgets('long press on an unregistered day marks it no activity', (
    tester,
  ) async {
    await pumpCalendar(tester);
    await tester.longPress(cell('2026-11-03'));
    await settle(tester);
    expect(find.text('Marcar sin actividad'), findsOneWidget);

    await tester.tap(find.text('Marcar sin actividad'));
    await settle(tester);

    expect(find.text('Día marcado sin actividad'), findsOneWidget);
    expect(iconOf(tester, '2026-11-03'), Icons.do_not_disturb_on_outlined);
    final row = await tester.runAsync(
      () => (db.select(
        db.days,
      )..where((d) => d.date.equals('2026-11-03'))).getSingle(),
    );
    expect(row!.status, DayStatus.noActivity);
    await disposeApp(tester);
  });

  testWidgets('long press offers nothing on future or registered days', (
    tester,
  ) async {
    await pumpCalendar(tester);
    await tester.longPress(cell('2026-11-20'));
    await settle(tester);
    expect(find.text('Marcar sin actividad'), findsNothing);

    await tester.runAsync(
      () =>
          ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
              .read(daysRepositoryProvider)
              .markNoActivity(dateOnly(DateTime(2026, 11, 4))),
    );
    await settle(tester);
    await tester.longPress(cell('2026-11-04'));
    await settle(tester);
    expect(find.text('Marcar sin actividad'), findsNothing);
    await disposeApp(tester);
  });
}
