import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/audit/period_guard.dart';
import '../../data/providers.dart';
import '../../data/repositories/fixed_costs_repository.dart';
import '../../domain/enums.dart';
import '../../domain/money.dart';
import '../../l10n/app_localizations.dart';
import '../common/catalog_label.dart';
import '../common/catalog_providers.dart';
import '../common/money_field.dart';

/// Opens the fixed cost form as a bottom sheet. Returns the saved id, or null
/// if the user cancelled.
Future<String?> showFixedCostForm(BuildContext context, {String? id}) async {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _FixedCostSheet(id: id),
  );
}

class _FixedCostSheet extends ConsumerStatefulWidget {
  const _FixedCostSheet({this.id});

  final String? id;

  @override
  ConsumerState<_FixedCostSheet> createState() => _FixedCostSheetState();
}

class _FixedCostSheetState extends ConsumerState<_FixedCostSheet> {
  final _formKey = GlobalKey<FormState>();
  final _concept = TextEditingController();
  final _planned = TextEditingController();
  final _chargeDay = TextEditingController();
  final _startMonth = TextEditingController();

  bool _loading = true;
  bool _busy = false;
  String? _categoryId;
  int _vatPct = 21;
  Periodicity _periodicity = Periodicity.monthly;

  bool get _isNew => widget.id == null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _concept.dispose();
    _planned.dispose();
    _chargeDay.dispose();
    _startMonth.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = widget.id;
    if (id == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final repo = ref.read(fixedCostsRepositoryProvider);
      final all = await repo.watchAll().first;
      final record = all.where((r) => r.id == id).firstOrNull;
      if (!mounted) return;
      if (record == null) {
        setState(() => _loading = false);
        return;
      }
      setState(() {
        _concept.text = record.concept;
        _categoryId = record.categoryId;
        _planned.text = MoneyField.text(record.plannedAmount);
        _vatPct = record.vatPct;
        _periodicity = record.periodicity;
        _chargeDay.text = '${record.chargeDay}';
        _startMonth.text = record.startMonth;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_categoryId == null) {
      messenger.showSnackBar(SnackBar(content: Text(l.fieldRequired)));
      return;
    }
    final planned = _tryMoney(_planned.text);
    if (planned == null || planned.cents <= 0) {
      messenger.showSnackBar(SnackBar(content: Text(l.amountMustBePositive)));
      return;
    }
    final chargeDay = int.tryParse(_chargeDay.text);
    if (chargeDay == null || chargeDay < 1 || chargeDay > 31) {
      messenger.showSnackBar(SnackBar(content: Text(l.fieldRequired)));
      return;
    }
    final month = _startMonth.text.trim();
    if (!RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(month)) {
      messenger.showSnackBar(SnackBar(content: Text(l.fieldRequired)));
      return;
    }
    final input = FixedCostInput(
      concept: _concept.text,
      categoryId: _categoryId!,
      plannedAmount: planned,
      vatPct: _vatPct,
      periodicity: _periodicity,
      chargeDay: chargeDay,
      startMonth: month,
    );
    setState(() => _busy = true);
    try {
      final repo = ref.read(fixedCostsRepositoryProvider);
      final id = widget.id;
      if (_isNew) {
        final newId = await repo.create(input);
        if (mounted) Navigator.of(context).pop(newId);
      } else {
        await repo.update(id!, input);
        if (mounted) Navigator.of(context).pop(id);
      }
    } on PeriodLockedException {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l.dayErrLocked)));
        setState(() => _busy = false);
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l.fixedCostErrSave)));
        setState(() => _busy = false);
      }
    }
  }

  Money? _tryMoney(String text) {
    try {
      return Money.parse(text);
    } on FormatException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final title = _isNew ? l.fixedCostNewTitle : l.fixedCostEditTitle;
    final categories = [
      for (final c in ref.watch(expenseCategoriesProvider).value ?? const [])
        if (c.active || c.id == _categoryId) c,
    ];
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          key: const ValueKey('fixed-cost-concept'),
                          controller: _concept,
                          decoration: InputDecoration(
                            labelText: l.fixedCostFieldConcept,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          validator: (v) =>
                              (v ?? '').trim().isEmpty ? l.fieldRequired : null,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          key: const ValueKey('fixed-cost-category'),
                          initialValue: _categoryId,
                          decoration: InputDecoration(
                            labelText: l.fieldCategory,
                          ),
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
                        MoneyField(
                          key: const ValueKey('fixed-cost-planned'),
                          controller: _planned,
                          label: l.fixedCostFieldPlanned,
                          onChanged: (_) {},
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l.fieldVat,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        SegmentedButton<int>(
                          key: const ValueKey('fixed-cost-vat'),
                          segments: [
                            for (final pct in const [0, 4, 10, 21])
                              ButtonSegment(value: pct, label: Text('$pct %')),
                          ],
                          selected: {_vatPct},
                          showSelectedIcon: false,
                          onSelectionChanged: (v) =>
                              setState(() => _vatPct = v.first),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l.fixedCostFieldPeriodicity,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 4),
                        SegmentedButton<Periodicity>(
                          key: const ValueKey('fixed-cost-periodicity'),
                          segments: [
                            ButtonSegment(
                              value: Periodicity.monthly,
                              label: Text(l.periodicityMonthly),
                            ),
                            ButtonSegment(
                              value: Periodicity.bimonthly,
                              label: Text(l.periodicityBimonthly),
                            ),
                            ButtonSegment(
                              value: Periodicity.quarterly,
                              label: Text(l.periodicityQuarterly),
                            ),
                            ButtonSegment(
                              value: Periodicity.annual,
                              label: Text(l.periodicityAnnual),
                            ),
                          ],
                          selected: {_periodicity},
                          showSelectedIcon: false,
                          onSelectionChanged: (v) =>
                              setState(() => _periodicity = v.first),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const ValueKey('fixed-cost-charge-day'),
                          controller: _chargeDay,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          decoration: InputDecoration(
                            labelText: l.fixedCostFieldChargeDay,
                          ),
                          validator: (v) {
                            final d = int.tryParse(v ?? '');
                            if (d == null || d < 1 || d > 31) {
                              return l.fieldRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const ValueKey('fixed-cost-start-month'),
                          controller: _startMonth,
                          decoration: InputDecoration(
                            labelText: l.fixedCostFieldStartMonth,
                            hintText: '2026-01',
                          ),
                          validator: (v) {
                            if (!RegExp(r'^\d{4}-(0[1-9]|1[0-2])$')
                                .hasMatch((v ?? '').trim())) {
                              return l.fieldRequired;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          key: const ValueKey('fixed-cost-save'),
                          onPressed: _busy ? null : _save,
                          child: Text(l.actionSave),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
