import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/audit/period_guard.dart';
import '../../domain/money.dart';
import '../../l10n/app_localizations.dart';
import '../common/catalog_label.dart';
import '../common/catalog_providers.dart';
import '../common/money_field.dart';
import 'day_close_controller.dart';

/// Bottom sheet that records a cash withdrawal on the day [date].
Future<void> showQuickWithdrawalSheet(BuildContext context, DateTime date) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => QuickWithdrawalSheet(date: date),
  );
}

class QuickWithdrawalSheet extends ConsumerStatefulWidget {
  const QuickWithdrawalSheet({super.key, required this.date});

  final DateTime date;

  @override
  ConsumerState<QuickWithdrawalSheet> createState() => _SheetState();
}

class _SheetState extends ConsumerState<QuickWithdrawalSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  String? _typeId;
  bool _busy = false;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (Money.parse(_amount.text).cents <= 0) {
      messenger.showSnackBar(SnackBar(content: Text(l.amountMustBePositive)));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(dayCloseControllerProvider(widget.date).notifier)
          .addWithdrawal(
            amount: Money.parse(_amount.text),
            typeId: _typeId!,
            note: _note.text,
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
    final types = [
      for (final t in ref.watch(withdrawalTypesProvider).value ?? const [])
        if (t.active) t,
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
                l.sheetWithdrawalTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              MoneyField(
                key: const ValueKey('withdrawal-amount'),
                label: l.fieldAmount,
                controller: _amount,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const ValueKey('withdrawal-type'),
                initialValue: _typeId,
                decoration: InputDecoration(labelText: l.fieldType),
                items: [
                  for (final t in types)
                    DropdownMenuItem(
                      value: t.id,
                      child: Text(catalogLabel(l, t)),
                    ),
                ],
                validator: (v) => v == null ? l.fieldRequired : null,
                onChanged: (v) => setState(() => _typeId = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('withdrawal-note'),
                controller: _note,
                decoration: InputDecoration(labelText: l.fieldNote),
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: const ValueKey('withdrawal-save'),
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
