import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/audit/period_guard.dart';
import '../../domain/money.dart';
import '../../l10n/app_localizations.dart';
import '../common/catalog_label.dart';
import '../common/catalog_providers.dart';
import '../common/money_field.dart';
import 'day_close_controller.dart';

/// Bottom sheet that records a purchase paid in cash from the till of the day
/// [date].
Future<void> showQuickCashExpenseSheet(BuildContext context, DateTime date) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => QuickCashExpenseSheet(date: date),
  );
}

class QuickCashExpenseSheet extends ConsumerStatefulWidget {
  const QuickCashExpenseSheet({super.key, required this.date});

  final DateTime date;

  @override
  ConsumerState<QuickCashExpenseSheet> createState() => _SheetState();
}

class _SheetState extends ConsumerState<QuickCashExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _invoice = TextEditingController();
  String? _categoryId;
  String? _supplierId;
  int _vatPct = 10;
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _invoice.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final total = Money.parse(_amount.text);
    if (total.cents <= 0) {
      messenger.showSnackBar(SnackBar(content: Text(l.amountMustBePositive)));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(dayCloseControllerProvider(widget.date).notifier)
          .addCashExpense(
            total: total,
            categoryId: _categoryId!,
            vatPct: _vatPct,
            supplierId: _supplierId,
            invoiceNumber: _invoice.text,
          );
      navigator.pop();
    } on PeriodLockedException {
      messenger.showSnackBar(SnackBar(content: Text(l.dayErrLocked)));
      if (mounted) setState(() => _busy = false);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.dayErrSave)));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final categories = [
      for (final c in ref.watch(expenseCategoriesProvider).value ?? const [])
        if (c.active) c,
    ];
    final suppliers = ref.watch(suppliersProvider).value ?? const [];
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
                l.sheetCashExpenseTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              MoneyField(
                key: const ValueKey('expense-amount'),
                label: l.fieldTotalAmount,
                controller: _amount,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const ValueKey('expense-category'),
                initialValue: _categoryId,
                decoration: InputDecoration(labelText: l.fieldCategory),
                items: [
                  for (final c in categories)
                    DropdownMenuItem(
                      value: c.id,
                      child: Text(catalogLabel(l, c)),
                    ),
                ],
                validator: (v) => v == null ? l.fieldRequired : null,
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                key: const ValueKey('expense-supplier'),
                initialValue: _supplierId,
                decoration: InputDecoration(labelText: l.fieldSupplierOptional),
                items: [
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l.noSupplier),
                  ),
                  for (final s in suppliers)
                    DropdownMenuItem<String?>(value: s.id, child: Text(s.name)),
                ],
                onChanged: (v) => setState(() => _supplierId = v),
              ),
              const SizedBox(height: 12),
              Text(l.fieldVat, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 4),
              SegmentedButton<int>(
                key: const ValueKey('expense-vat'),
                segments: [
                  for (final pct in const [0, 4, 10, 21])
                    ButtonSegment(value: pct, label: Text('$pct %')),
                ],
                selected: {_vatPct},
                showSelectedIcon: false,
                onSelectionChanged: (v) => setState(() => _vatPct = v.first),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('expense-invoice'),
                controller: _invoice,
                decoration: InputDecoration(labelText: l.fieldInvoiceOptional),
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: const ValueKey('expense-save'),
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
