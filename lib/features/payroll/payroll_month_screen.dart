import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/audit/period_guard.dart';
import '../../data/providers.dart';
import '../../data/repositories/payroll_repository.dart';
import '../../domain/dates.dart';
import '../../domain/money.dart';
import '../../domain/pnl_calc.dart';
import '../../l10n/app_localizations.dart';
import '../common/catalog_label.dart';
import '../common/catalog_providers.dart';
import '../common/confirm_reason_dialog.dart';
import '../common/money_field.dart';
import 'employee_form.dart';

/// Payroll rows for a given month key (`YYYY-MM`).
final _payrollMonthProvider = FutureProvider.autoDispose
    .family<List<PayrollRow>, String>(
      (ref, month) => ref.watch(payrollRepositoryProvider).month(month),
    );

/// P&L of a month from the report service: personnel cost and sales.
final _monthPnlProvider = FutureProvider.autoDispose.family<PnlResult, String>((
  ref,
  month,
) async {
  final report = await ref
      .watch(reportServiceProvider)
      .build(rangeMonth(month));
  return report.pnl;
});

/// The payroll month screen. [month] is `YYYY-MM`.
class PayrollMonthScreen extends ConsumerStatefulWidget {
  const PayrollMonthScreen({super.key, required this.month});

  final String month;

  @override
  ConsumerState<PayrollMonthScreen> createState() => _PayrollMonthScreenState();
}

class _PayrollMonthScreenState extends ConsumerState<PayrollMonthScreen> {
  late String _month;

  @override
  void initState() {
    super.initState();
    _month = widget.month;
  }

  void _prevMonth() => setState(() {
    final r = rangeMonth(_month);
    final prev = DateTime.utc(r.start.year, r.start.month - 1, 1);
    _month = monthKey(prev);
  });

  void _nextMonth() => setState(() {
    final r = rangeMonth(_month);
    final next = DateTime.utc(r.start.year, r.start.month + 1, 1);
    _month = monthKey(next);
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final rows = ref.watch(_payrollMonthProvider(_month));
    final pnl = ref.watch(_monthPnlProvider(_month));
    return Scaffold(
      appBar: AppBar(
        title: Text(l.screenPayroll),
        actions: [
          IconButton(
            key: const ValueKey('payroll-add-employee'),
            tooltip: l.payrollEmployeeNewTitle,
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () async {
              await showEmployeeForm(context);
              ref.invalidate(_payrollMonthProvider(_month));
              ref.invalidate(_monthPnlProvider(_month));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MonthSelector(
                  month: _month,
                  locale: locale,
                  onPrev: _prevMonth,
                  onNext: _nextMonth,
                ),
                const Divider(height: 1),
                Expanded(
                  child: rows.when(
                    data: (list) => _PayrollBody(
                      rows: list,
                      month: _month,
                      locale: locale,
                      pnl: pnl.value,
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Text(
                        e is PeriodLockedException
                            ? l.dayErrLocked
                            : l.payrollErrSave,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------- month selector

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.month,
    required this.locale,
    required this.onPrev,
    required this.onNext,
  });

  final String month;
  final String locale;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final date = rangeMonth(month).start;
    final label = DateFormat.yMMMM(locale).format(date);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            key: const ValueKey('payroll-prev-month'),
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrev,
          ),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          IconButton(
            key: const ValueKey('payroll-next-month'),
            icon: const Icon(Icons.chevron_right),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------- payroll body

class _PayrollBody extends ConsumerWidget {
  const _PayrollBody({
    required this.rows,
    required this.month,
    required this.locale,
    required this.pnl,
  });

  final List<PayrollRow> rows;
  final String month;
  final String locale;
  final PnlResult? pnl;

  void _refresh(WidgetRef ref) {
    ref.invalidate(_payrollMonthProvider(month));
    ref.invalidate(_monthPnlProvider(month));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    if (rows.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.payrollNoEmployees,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    // Total gross + employer SS
    var totalCost = Money.zero;
    for (final r in rows) {
      final p = r.payment;
      if (p != null && !p.voided) {
        totalCost += p.gross + p.employerSs;
      }
    }
    // Personnel cost over sales of the month, both from the report service.
    final sales = pnl?.sales;
    final pct = (pnl != null && sales != null && !sales.isZero)
        ? pnl!.personnel.cents / sales.cents * 100
        : null;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              for (final row in rows)
                _EmployeeRow(
                  row: row,
                  month: month,
                  locale: locale,
                  onSave: () => _refresh(ref),
                  onVoid: () => _refresh(ref),
                ),
            ],
          ),
        ),
        _TotalsBar(totalCost: totalCost, pct: pct, locale: locale),
      ],
    );
  }
}

// ----------------------------------------------------------- employee row

class _EmployeeRow extends ConsumerWidget {
  const _EmployeeRow({
    required this.row,
    required this.month,
    required this.locale,
    required this.onSave,
    required this.onVoid,
  });

  final PayrollRow row;
  final String month;
  final String locale;
  final VoidCallback onSave;
  final VoidCallback onVoid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final e = row.employee;
    final p = row.payment;
    final methods = ref.watch(paymentMethodsProvider).value ?? const [];
    String? methodName;
    if (p?.paymentMethodId != null) {
      final m = methods.where((m) => m.id == p!.paymentMethodId).firstOrNull;
      if (m != null) methodName = catalogLabel(l, m);
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.name,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      if (e.role.isNotEmpty)
                        Text(
                          e.role,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  key: ValueKey('payroll-edit-employee-${e.id}'),
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: l.payrollEmployeeEditTitle,
                  onPressed: () async {
                    await showEmployeeForm(context, id: e.id);
                    onSave();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (p != null && !p.voided) ...[
              _InfoRow(l.export_colGross, p.gross.format(locale)),
              _InfoRow(l.export_colNet, p.net.format(locale)),
              _InfoRow(l.export_colEmployerSs, p.employerSs.format(locale)),
              if (methodName != null) _InfoRow(l.expFieldPayment, methodName),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    key: ValueKey('payroll-void-${e.id}'),
                    icon: const Icon(Icons.block, size: 18),
                    label: Text(l.payrollPaymentVoid),
                    onPressed: () => _void(context, ref, p.id),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    key: ValueKey('payroll-save-${e.id}'),
                    onPressed: () =>
                        _showPaymentForm(context, ref, existingPayment: p),
                    child: Text(l.payrollPaymentSave),
                  ),
                ],
              ),
            ] else ...[
              Text(
                l.payrollNoPayment,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  key: ValueKey('payroll-add-${e.id}'),
                  onPressed: () => _showPaymentForm(context, ref),
                  child: Text(l.payrollPaymentSave),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _void(
    BuildContext context,
    WidgetRef ref,
    String paymentId,
  ) async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final reason = await askReason(context, title: l.payrollVoidReasonTitle);
    if (reason == null || !context.mounted) return;
    try {
      await ref.read(payrollRepositoryProvider).voidPayment(paymentId, reason);
      onVoid();
    } on PeriodLockedException {
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l.dayErrLocked)));
      }
    } catch (_) {
      if (context.mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l.payrollErrSave)));
      }
    }
  }

  Future<void> _showPaymentForm(
    BuildContext context,
    WidgetRef ref, {
    PayrollPaymentRecord? existingPayment,
  }) async {
    final saved = await showPayrollPaymentForm(
      context,
      employeeId: row.employee.id,
      employeeName: row.employee.name,
      month: month,
      existing: existingPayment,
    );
    if (saved == true) onSave();
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(fontVariations: const [FontVariation('wght', 600)]),
        ),
      ],
    ),
  );
}

// ----------------------------------------------------------- totals bar

class _TotalsBar extends StatelessWidget {
  const _TotalsBar({
    required this.totalCost,
    required this.pct,
    required this.locale,
  });

  final Money totalCost;
  final double? pct;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.payrollTotalCost,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  totalCost.format(locale),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.payrollPercentOfSales,
                style: Theme.of(context).textTheme.labelSmall,
              ),
              Text(
                pct == null
                    ? '—'
                    : '${NumberFormat('0.0', locale).format(pct!)} %',
                key: const ValueKey('payroll-pct'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ----------------------------------------------------------- payment form

/// Shows the payment entry form as a bottom sheet. Returns `true` when saved.
Future<bool?> showPayrollPaymentForm(
  BuildContext context, {
  required String employeeId,
  required String employeeName,
  required String month,
  PayrollPaymentRecord? existing,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _PaymentSheet(
      employeeId: employeeId,
      employeeName: employeeName,
      month: month,
      existing: existing,
    ),
  );
}

class _PaymentSheet extends ConsumerStatefulWidget {
  const _PaymentSheet({
    required this.employeeId,
    required this.employeeName,
    required this.month,
    this.existing,
  });

  final String employeeId;
  final String employeeName;
  final String month;
  final PayrollPaymentRecord? existing;

  @override
  ConsumerState<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<_PaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _gross = TextEditingController();
  final _net = TextEditingController();
  final _ss = TextEditingController();
  bool _busy = false;
  String? _methodId;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    if (p != null) {
      _gross.text = MoneyField.text(p.gross);
      _net.text = MoneyField.text(p.net);
      _ss.text = MoneyField.text(p.employerSs);
      _methodId = p.paymentMethodId;
    }
  }

  @override
  void dispose() {
    _gross.dispose();
    _net.dispose();
    _ss.dispose();
    super.dispose();
  }

  Money? _tryMoney(TextEditingController c) {
    try {
      return Money.parse(c.text);
    } on FormatException {
      return null;
    }
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final gross = _tryMoney(_gross);
    final net = _tryMoney(_net);
    final ss = _tryMoney(_ss);
    if (gross == null || net == null || ss == null) {
      messenger.showSnackBar(SnackBar(content: Text(l.amountInvalid)));
      return;
    }
    if (_methodId == null) {
      messenger.showSnackBar(SnackBar(content: Text(l.fieldRequired)));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(payrollRepositoryProvider)
          .savePayment(
            employeeId: widget.employeeId,
            month: widget.month,
            gross: gross,
            net: net,
            employerSs: ss,
            paymentMethodId: _methodId!,
          );
      if (mounted) Navigator.of(context).pop(true);
    } on PeriodLockedException {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l.dayErrLocked)));
        setState(() => _busy = false);
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l.payrollErrSave)));
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final methods = [
      for (final m in ref.watch(paymentMethodsProvider).value ?? const [])
        if (m.active || m.id == _methodId) m,
    ];
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.employeeName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(widget.month, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 16),
              MoneyField(
                key: const ValueKey('payroll-field-gross'),
                controller: _gross,
                label: l.payrollFieldGross,
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              MoneyField(
                key: const ValueKey('payroll-field-net'),
                controller: _net,
                label: l.payrollFieldNet,
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              MoneyField(
                key: const ValueKey('payroll-field-ss'),
                controller: _ss,
                label: l.payrollFieldEmployerSs,
                onChanged: (_) {},
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: const ValueKey('payroll-field-method'),
                initialValue: _methodId,
                decoration: InputDecoration(labelText: l.expFieldPayment),
                items: [
                  for (final m in methods)
                    DropdownMenuItem(
                      value: m.id,
                      child: Text(catalogLabel(l, m)),
                    ),
                ],
                validator: (v) => v == null ? l.fieldRequired : null,
                onChanged: (v) => setState(() => _methodId = v),
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const ValueKey('payroll-save-payment'),
                onPressed: _busy ? null : _save,
                child: Text(l.actionSave),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
