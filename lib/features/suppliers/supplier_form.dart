import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../data/repositories/suppliers_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/catalog_label.dart';
import '../common/catalog_providers.dart';

/// Opens the supplier form in a bottom sheet. Creates a supplier, or edits
/// [existing]. Returns the id of the saved supplier, or null when cancelled.
Future<String?> showSupplierForm(
  BuildContext context, {
  SupplierRecord? existing,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => SupplierForm(existing: existing),
  );
}

class SupplierForm extends ConsumerStatefulWidget {
  const SupplierForm({super.key, this.existing});

  final SupplierRecord? existing;

  @override
  ConsumerState<SupplierForm> createState() => _SupplierFormState();
}

class _SupplierFormState extends ConsumerState<SupplierForm> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _nif = TextEditingController(text: widget.existing?.nif);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late String? _categoryId = widget.existing?.defaultCategoryId;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _nif.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final repo = ref.read(suppliersRepositoryProvider);
    final input = SupplierInput(
      name: _name.text,
      nif: _nif.text,
      phone: _phone.text,
      defaultCategoryId: _categoryId,
    );
    setState(() => _busy = true);
    try {
      final existing = widget.existing;
      final String id;
      if (existing == null) {
        id = await repo.create(input);
      } else {
        await repo.update(existing.id, input);
        id = existing.id;
      }
      navigator.pop(id);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.suppErrSave)));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final categories = [
      for (final c in ref.watch(expenseCategoriesProvider).value ?? const [])
        if (c.active || c.id == _categoryId) c,
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null ? l.suppNewTitle : l.suppEditTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('supplier-name'),
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: l.suppFieldName),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? l.fieldRequired : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('supplier-nif'),
                controller: _nif,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: l.suppFieldNif),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('supplier-phone'),
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: l.suppFieldPhone),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                key: const ValueKey('supplier-category'),
                initialValue: _categoryId,
                decoration: InputDecoration(labelText: l.suppFieldCategory),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('—'),
                  ),
                  for (final c in categories)
                    DropdownMenuItem<String?>(
                      value: c.id,
                      child: Text(catalogLabel(l, c)),
                    ),
                ],
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: const ValueKey('supplier-save'),
                onPressed: _busy ? null : _save,
                child: Text(l.actionSave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
