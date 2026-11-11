import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/providers.dart';
import 'package:to_audit/data/repositories/catalog_repository.dart';
import 'package:to_audit/data/security/key_store.dart';
import 'package:to_audit/domain/enums.dart';
import 'package:to_audit/features/settings/catalog_screen.dart';
import 'package:to_audit/l10n/app_localizations.dart';

import '../../support/app_harness.dart';

class _FakeCatalog extends Fake implements CatalogRepository {
  _FakeCatalog(this.items);

  final List<CatalogItem> items;
  final List<List<String>> reorders = [];
  final List<(String, PaymentKind?, CategoryKind?)> adds = [];

  @override
  Stream<List<CatalogItem>> watch(
    CatalogKind kind, {
    bool includeInactive = false,
  }) => Stream.value(items);

  @override
  Future<void> reorder(CatalogKind kind, List<String> idsInOrder) async =>
      reorders.add(idsInOrder);

  @override
  Future<String> add(
    CatalogKind kind,
    String name, {
    PaymentKind? paymentKind,
    CategoryKind? categoryKind,
  }) async {
    adds.add((name, paymentKind, categoryKind));
    return 'new';
  }
}

CatalogItem _item(String id, String name, {String? code, int order = 0}) =>
    CatalogItem(id: id, code: code, name: name, active: true, order: order);

void main() {
  Future<_FakeCatalog> pump(WidgetTester tester, String kind) async {
    final fake = _FakeCatalog([
      _item('a', 'Uno', order: 0),
      _item('b', 'Dos', order: 1),
      _item('c', 'Tres', code: 'rent', order: 2),
    ]);
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
          catalogRepositoryProvider.overrideWithValue(fake),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CatalogScreen(kind: kind),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    return fake;
  }

  testWidgets('moving an item down one place sends the new order', (
    tester,
  ) async {
    final fake = await pump(tester, 'expense_category');
    final list = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    // Flutter reports the index after the removal: Uno from 0 to 1.
    list.onReorderItem!(0, 1);
    await tester.pump();
    expect(fake.reorders.single, ['b', 'a', 'c']);
  });

  testWidgets('seeded codes use their translation', (tester) async {
    await pump(tester, 'expense_category');
    expect(find.text('Alquiler'), findsOneWidget);
    expect(find.text('Tres'), findsNothing);
  });

  testWidgets('a new payment method asks for its kind', (tester) async {
    final fake = await pump(tester, 'payment_method');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Sodexo');
    await tester.tap(find.text('Tarjeta'));
    await tester.pump();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(fake.adds.single, ('Sodexo', PaymentKind.card, null));
  });

  testWidgets('a new category asks for purchase or other', (tester) async {
    final fake = await pump(tester, 'expense_category');
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Vinos');
    await tester.tap(find.text('Otros'));
    await tester.pump();
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(fake.adds.single, ('Vinos', null, CategoryKind.other));
  });
}
