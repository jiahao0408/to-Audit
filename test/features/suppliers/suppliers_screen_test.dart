import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/security/key_store.dart';
import 'package:to_audit/features/suppliers/suppliers_screen.dart';
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
  testWidgets('adds a supplier and edits it', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: appOverrides(
          db: db,
          keyStore: MemoryKeyStore(),
          biometrics: FakeBiometricAuth(),
          clock: () => DateTime(2026, 11, 9, 10),
          documents: Directory.systemTemp,
        ),
        child: const MaterialApp(
          locale: Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SuppliersScreen(),
        ),
      ),
    );
    await settle(tester);
    expect(find.text('Aún no hay proveedores'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('add-supplier')));
    await settle(tester);
    await tester.enterText(
      find.byKey(const ValueKey('supplier-name')),
      'Carnes Paco',
    );
    await tester.enterText(find.byKey(const ValueKey('supplier-nif')), 'B1234');
    await tester.tap(find.byKey(const ValueKey('supplier-save')));
    await settle(tester);
    expect(find.text('Carnes Paco'), findsOneWidget);
    expect(find.text('B1234'), findsOneWidget);

    await tester.tap(find.text('Carnes Paco'));
    await settle(tester);
    await tester.enterText(
      find.byKey(const ValueKey('supplier-name')),
      'Paco SL',
    );
    await tester.tap(find.byKey(const ValueKey('supplier-save')));
    await settle(tester);
    expect(find.text('Paco SL'), findsOneWidget);
    expect(find.text('Carnes Paco'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 50));
  });
}
