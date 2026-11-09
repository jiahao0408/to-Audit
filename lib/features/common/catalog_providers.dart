import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/suppliers_repository.dart';

/// Payment methods, inactive ones included (history may reference them).
final paymentMethodsProvider = StreamProvider<List<CatalogItem>>(
  (ref) => ref
      .watch(catalogRepositoryProvider)
      .watch(CatalogKind.paymentMethod, includeInactive: true),
);

/// Expense categories, inactive ones included.
final expenseCategoriesProvider = StreamProvider<List<CatalogItem>>(
  (ref) => ref
      .watch(catalogRepositoryProvider)
      .watch(CatalogKind.expenseCategory, includeInactive: true),
);

/// Withdrawal types, inactive ones included.
final withdrawalTypesProvider = StreamProvider<List<CatalogItem>>(
  (ref) => ref
      .watch(catalogRepositoryProvider)
      .watch(CatalogKind.withdrawalType, includeInactive: true),
);

final suppliersProvider = StreamProvider<List<SupplierRecord>>(
  (ref) => ref.watch(suppliersRepositoryProvider).watchAll(),
);
