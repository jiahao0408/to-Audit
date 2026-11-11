import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/audit/period_guard.dart';
import '../../data/providers.dart';
import '../../data/repositories/expenses_repository.dart';
import '../../data/repositories/fixed_costs_repository.dart';
import '../../domain/dates.dart';
import '../../domain/enums.dart';
import '../../domain/money.dart';
import '../../l10n/app_localizations.dart';
import '../common/money_field.dart';
import 'fixed_cost_form.dart';

/// All fixed cost definitions, kept reactive.
final _fixedCostsProvider = StreamProvider.autoDispose<List<FixedCostRecord>>(
  (ref) => ref.watch(fixedCostsRepositoryProvider).watchAll(),
);

/// Every unconfirmed planned fixed expense, however old (a bill from two
/// months ago that was never confirmed must not disappear). Voided ones are
/// excluded.
final _pendingFixedExpensesProvider =
    StreamProvider.autoDispose<List<ExpenseRecord>>((ref) {
      final range = DateRange(DateTime.utc(2000), DateTime.utc(2100, 12, 31));
      return ref
          .watch(expensesRepositoryProvider)
          .watchRange(range)
          .map(
            (all) => [
              for (final e in all)
                if (e.origin == ExpenseOrigin.fixed &&
                    e.fixedStatus != FixedStatus.confirmed &&
                    !e.voided)
                  e,
            ],
          );
    });

/// Fixed costs: list of definitions and a "Por confirmar" section of planned
/// expenses waiting for the real amount.
class FixedCostsScreen extends ConsumerWidget {
  const FixedCostsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final defs = ref.watch(_fixedCostsProvider);
    final pending = ref.watch(_pendingFixedExpensesProvider);
    final concepts = {
      for (final fc in defs.value ?? const <FixedCostRecord>[])
        fc.id: fc.concept,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l.screenFixedCosts)),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('fixed-cost-add'),
        onPressed: () => showFixedCostForm(context),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SectionTitle(l.fixedCostSectionDefs),
                  defs.when(
                    data: (list) => list.isEmpty
                        ? _Empty(l.fixedCostNone)
                        : Column(
                            children: [
                              for (final fc in list)
                                _FixedCostCard(
                                  record: fc,
                                  locale: locale,
                                  onEdit: () =>
                                      showFixedCostForm(context, id: fc.id),
                                  onToggle: () =>
                                      _toggleActive(context, ref, fc),
                                ),
                            ],
                          ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => _Empty(l.fixedCostErrSave),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(l.fixedCostSectionPending),
                  pending.when(
                    data: (list) => list.isEmpty
                        ? _Empty(l.fixedCostNonePending)
                        : Column(
                            children: [
                              for (final e in list)
                                _PendingCard(
                                  expense: e,
                                  concept: concepts[e.fixedCostId],
                                  locale: locale,
                                  onConfirm: () =>
                                      _confirmExpense(context, ref, e),
                                ),
                            ],
                          ),
                    loading: () => const SizedBox.shrink(),
                    error: (e, st) => _Empty(l.fixedCostErrSave),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleActive(
    BuildContext context,
    WidgetRef ref,
    FixedCostRecord fc,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = AppLocalizations.of(context)!;
    try {
      await ref.read(fixedCostsRepositoryProvider).setActive(fc.id, !fc.active);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.fixedCostErrSave)));
    }
  }

  Future<void> _confirmExpense(
    BuildContext context,
    WidgetRef ref,
    ExpenseRecord expense,
  ) async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final actual = await showDialog<Money>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: l.fixedCostConfirmTitle,
        label: l.fixedCostFieldActual,
        initial: expense.total,
      ),
    );
    if (actual == null) return;
    try {
      await ref.read(fixedCostsRepositoryProvider).confirm(expense.id, actual);
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l.fixedCostConfirmed)));
      }
    } on PeriodLockedException {
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l.dayErrLocked)));
      }
    } catch (_) {
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l.fixedCostErrSave)));
      }
    }
  }
}

// ----------------------------------------------------------- small widgets

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(text, style: Theme.of(context).textTheme.bodySmall),
  );
}

class _FixedCostCard extends StatelessWidget {
  const _FixedCostCard({
    required this.record,
    required this.locale,
    required this.onEdit,
    required this.onToggle,
  });

  final FixedCostRecord record;
  final String locale;
  final VoidCallback onEdit;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final periodLabel = switch (record.periodicity) {
      Periodicity.monthly => l.periodicityMonthly,
      Periodicity.bimonthly => l.periodicityBimonthly,
      Periodicity.quarterly => l.periodicityQuarterly,
      Periodicity.annual => l.periodicityAnnual,
    };
    return Card(
      child: ListTile(
        key: ValueKey('fixed-cost-${record.id}'),
        title: Text(
          record.concept,
          style: record.active
              ? null
              : const TextStyle(decoration: TextDecoration.lineThrough),
        ),
        subtitle: Text(
          '${record.plannedAmount.format(locale)} · $periodLabel · '
          '${l.fixedCostFieldChargeDay.split(' ')[0]} ${record.chargeDay} '
          '· ${record.startMonth}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              key: ValueKey('fixed-cost-active-${record.id}'),
              value: record.active,
              onChanged: (_) => onToggle(),
            ),
            IconButton(
              key: ValueKey('fixed-cost-edit-${record.id}'),
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({
    required this.expense,
    required this.concept,
    required this.locale,
    required this.onConfirm,
  });

  final ExpenseRecord expense;
  final String? concept;
  final String locale;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Card(
      child: ListTile(
        key: ValueKey('pending-fixed-${expense.id}'),
        title: Text(concept ?? expense.total.format(locale)),
        subtitle: Text(
          '${expense.total.format(locale)} · '
          '${DateFormat.yMMMMd(locale).format(expense.date)}'
          '${expense.invoiceNumber != null ? ' · ${expense.invoiceNumber}' : ''}',
        ),
        trailing: FilledButton.tonal(
          key: ValueKey('confirm-fixed-${expense.id}'),
          onPressed: onConfirm,
          child: Text(l.fixedCostConfirmTitle),
        ),
      ),
    );
  }
}

class _ConfirmDialog extends StatefulWidget {
  const _ConfirmDialog({
    required this.title,
    required this.label,
    required this.initial,
  });

  final String title;
  final String label;
  final Money initial;

  @override
  State<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<_ConfirmDialog> {
  late final TextEditingController _controller;
  Money? _value;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: MoneyField.text(widget.initial));
    _value = widget.initial;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.title),
      content: MoneyField(
        controller: _controller,
        label: widget.label,
        onChanged: (v) => setState(() => _value = v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.actionCancel),
        ),
        FilledButton(
          onPressed: _value == null || _value!.cents <= 0
              ? null
              : () => Navigator.of(context).pop(_value),
          child: Text(l.actionSave),
        ),
      ],
    );
  }
}
