import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../common/catalog_label.dart';
import '../common/catalog_providers.dart';
import 'supplier_form.dart';

/// Suppliers list: tap to edit, "+" to add.
class SuppliersScreen extends ConsumerWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final suppliers = ref.watch(suppliersProvider).value ?? const [];
    final categories = ref.watch(expenseCategoriesProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text(l.screenSuppliers)),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('add-supplier'),
        tooltip: l.suppNewTitle,
        onPressed: () => showSupplierForm(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: suppliers.isEmpty
            ? Center(child: Text(l.suppNone))
            : ListView(
                padding: const EdgeInsets.only(bottom: 88),
                children: [
                  for (final s in suppliers)
                    ListTile(
                      key: ValueKey('supplier-${s.id}'),
                      minTileHeight: 56,
                      title: Text(s.name),
                      subtitle: Text(
                        [
                          if (s.defaultCategoryId != null)
                            for (final c in categories)
                              if (c.id == s.defaultCategoryId)
                                catalogLabel(l, c),
                          if ((s.nif ?? '').isNotEmpty) s.nif!,
                          if ((s.phone ?? '').isNotEmpty) s.phone!,
                        ].join(' · '),
                      ),
                      onTap: () => showSupplierForm(context, existing: s),
                    ),
                ],
              ),
      ),
    );
  }
}
