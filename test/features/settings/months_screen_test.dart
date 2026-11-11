import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/providers.dart';
import 'package:to_audit/data/security/key_store.dart';
import 'package:to_audit/domain/enums.dart';
import 'package:to_audit/features/settings/months_screen.dart';
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

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.memory());
  tearDown(() => db.close());

  /// 31 Oct and every day of 1-9 Nov finished, so both months can close.
  Future<void> seed() async {
    for (final date in [
      '2026-10-31',
      for (var day = 1; day <= 9; day++) '2026-11-0$day',
    ]) {
      await db
          .into(db.days)
          .insert(
            DaysCompanion.insert(
              id: 'day-$date',
              createdAt: nowIso(),
              updatedAt: nowIso(),
              date: date,
              status: DayStatus.noActivity,
              openingFloatCents: 0,
            ),
          );
    }
  }

  Future<void> end(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  }

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.runAsync(seed);
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
          home: MonthsScreen(),
        ),
      ),
    );
    await settle(tester);
  }

  Future<List<PeriodData>> periods(WidgetTester tester) async =>
      (await tester.runAsync(() => db.select(db.periods).get()))!;

  testWidgets('cancelling the confirmation leaves the month open', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text('Cerrar mes').first);
    await settle(tester);
    expect(find.text('¿Cerrar este mes?'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await settle(tester);
    expect(find.text('¿Cerrar este mes?'), findsNothing);
    expect(await periods(tester), isEmpty);
    expect(find.text('Cerrar mes'), findsNWidgets(2));
    await end(tester);
  });

  testWidgets('confirming closes the month; the current month is warned', (
    tester,
  ) async {
    await pump(tester);
    // First tile is November, the current month.
    await tester.tap(find.text('Cerrar mes').first);
    await settle(tester);
    expect(find.textContaining('mes en curso'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Cerrar mes'),
      ),
    );
    await settle(tester);
    final rows = await periods(tester);
    expect(rows.map((p) => (p.month, p.status)), [
      ('2026-11', PeriodStatus.closed),
    ]);
    await end(tester);
  });

  testWidgets('a past month gets the plain warning without the current-month '
      'text', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Cerrar mes').last);
    await settle(tester);
    expect(find.text('¿Cerrar este mes?'), findsOneWidget);
    expect(find.textContaining('mes en curso'), findsNothing);
    await tester.tap(find.text('Cancelar'));
    await settle(tester);
    await end(tester);
  });
}
