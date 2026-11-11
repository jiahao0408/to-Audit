import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/providers.dart';
import 'package:to_audit/data/repositories/fixed_costs_repository.dart';
import 'package:to_audit/data/security/key_store.dart';
import 'package:to_audit/domain/enums.dart';
import 'package:to_audit/domain/money.dart';
import 'package:to_audit/features/fixed_costs/fixed_costs_screen.dart';
import 'package:to_audit/l10n/app_localizations.dart';

import '../../support/app_harness.dart';

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('lists every unconfirmed bill, old ones too, and confirms with '
      'the real amount', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = AppDatabase.memory();
    addTearDown(db.close);
    late ProviderContainer container;
    await tester.runAsync(() async {
      final category = (await db.select(db.expenseCategories).get())
          .firstWhere((c) => c.code == 'rent')
          .id;
      // Container only to build the repositories on the same database.
      container = ProviderContainer(
        overrides: appOverrides(
          db: db,
          keyStore: MemoryKeyStore(),
          biometrics: FakeBiometricAuth(),
          clock: () => DateTime(2026, 11, 9, 10),
          documents: Directory.systemTemp,
        ),
      );
      final repo = container.read(fixedCostsRepositoryProvider);
      await repo.create(
        FixedCostInput(
          concept: 'Alquiler local',
          categoryId: category,
          plannedAmount: const Money(80000),
          vatPct: 21,
          periodicity: Periodicity.monthly,
          chargeDay: 5,
          startMonth: '2026-09',
        ),
      );
      // September, October and November, all still planned.
      await repo.generateDue(DateTime(2026, 11, 9));
    });
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FixedCostsScreen(),
        ),
      ),
    );
    await settle(tester);

    final cards = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey &&
          '${(w.key as ValueKey).value}'.startsWith('pending-fixed-'),
    );
    expect(cards, findsNWidgets(3));
    // The concept is the title of each card; the oldest is from September.
    expect(
      find.text('Alquiler local'),
      findsNWidgets(4),
    ); // 3 cards + the definition
    expect(find.textContaining('septiembre'), findsOneWidget);

    await tester.tap(find.text('Confirmar importe real').first);
    await settle(tester);
    expect(find.text('Importe real (€)'), findsOneWidget);
    await tester.tap(find.text('Guardar'));
    await settle(tester);
    expect(find.text('Importe confirmado'), findsOneWidget);
    expect(cards, findsNWidgets(2));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });
}
