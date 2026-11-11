import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';

/// Parses the route parameter into a [CatalogKind].
CatalogKind? parseCatalogKind(String kind) {
  return switch (kind) {
    'payment_method' => CatalogKind.paymentMethod,
    'expense_category' => CatalogKind.expenseCategory,
    'withdrawal_type' => CatalogKind.withdrawalType,
    _ => null,
  };
}

/// Catalog screen: list items, add new, rename, activate/deactivate, reorder.
class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key, required this.kind});

  final String kind;

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  CatalogKind? get _catalogKind => parseCatalogKind(widget.kind);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final kind = _catalogKind;
    if (kind == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.screenCatalogs)),
        body: Center(child: Text(l.catalogEmpty)),
      );
    }

    final itemsAsync = ref.watch(_catalogItemsProvider(kind));

    final title = switch (kind) {
      CatalogKind.paymentMethod => l.settingsCatalogPayments,
      CatalogKind.expenseCategory => l.settingsCatalogCategories,
      CatalogKind.withdrawalType => l.settingsCatalogWithdrawals,
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addItem(context, kind),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: itemsAsync.when(
          data: (items) => items.isEmpty
              ? Center(child: Text(l.catalogEmpty))
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: items.length,
                  onReorderItem: (oldI, newI) =>
                      _reorder(kind, items, oldI, newI),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _CatalogItemTile(
                      key: ValueKey(item.id),
                      item: item,
                      kind: kind,
                    );
                  },
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.catalogErrSave),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => ref.invalidate(_catalogItemsProvider(kind)),
                  child: Text(l.actionRetry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addItem(BuildContext context, CatalogKind kind) async {
    final l = AppLocalizations.of(context)!;
    final ctl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.catalogNew),
        content: TextField(
          controller: ctl,
          autofocus: true,
          decoration: InputDecoration(labelText: l.catalogFieldName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.actionSave),
          ),
        ],
      ),
    );
    if (result != true || !context.mounted) return;
    final name = ctl.text.trim();
    if (name.isEmpty) {
      ctl.dispose();
      return;
    }
    try {
      await ref
          .read(catalogRepositoryProvider)
          .add(
            kind,
            name,
            paymentKind: kind == CatalogKind.paymentMethod
                ? PaymentKind.cash
                : null,
            categoryKind: kind == CatalogKind.expenseCategory
                ? CategoryKind.other
                : null,
          );
      ref.invalidate(_catalogItemsProvider(kind));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.catalogErrSave)));
      }
    }
    ctl.dispose();
  }

  Future<void> _reorder(
    CatalogKind kind,
    List<CatalogItem> items,
    int oldI,
    int newI,
  ) async {
    final reordered = [...items];
    if (newI > oldI) newI -= 1;
    final item = reordered.removeAt(oldI);
    reordered.insert(newI, item);
    final ids = reordered.map((i) => i.id).toList();
    try {
      await ref.read(catalogRepositoryProvider).reorder(kind, ids);
      ref.invalidate(_catalogItemsProvider(kind));
    } catch (_) {
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.catalogErrSave)));
      }
    }
  }
}

final _catalogItemsProvider =
    StreamProvider.family<List<CatalogItem>, CatalogKind>(
      (ref, kind) => ref
          .watch(catalogRepositoryProvider)
          .watch(kind, includeInactive: true),
    );

class _CatalogItemTile extends ConsumerWidget {
  const _CatalogItemTile({super.key, required this.item, required this.kind});

  final CatalogItem item;
  final CatalogKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(item.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: item.active,
              onChanged: (v) => _toggle(context, ref, v),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _rename(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref, bool active) async {
    final l = AppLocalizations.of(context)!;
    try {
      await ref
          .read(catalogRepositoryProvider)
          .setActive(kind, item.id, active);
      ref.invalidate(_catalogItemsProvider(kind));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.catalogErrSave)));
      }
    }
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final ctl = TextEditingController(text: item.name);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.catalogFieldName),
        content: TextField(
          controller: ctl,
          autofocus: true,
          decoration: InputDecoration(labelText: l.catalogFieldName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.actionSave),
          ),
        ],
      ),
    );
    if (result != true || !context.mounted) return;
    final name = ctl.text.trim();
    if (name.isEmpty) {
      ctl.dispose();
      return;
    }
    try {
      await ref.read(catalogRepositoryProvider).rename(kind, item.id, name);
      ref.invalidate(_catalogItemsProvider(kind));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.catalogErrSave)));
      }
    }
    ctl.dispose();
  }
}
