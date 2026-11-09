import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/audit/period_guard.dart';
import '../../data/db/app_database.dart' show ReceiptData;
import '../../data/providers.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/expenses_repository.dart';
import '../../data/repositories/suppliers_repository.dart';
import '../../domain/dates.dart';
import '../../domain/enums.dart';
import '../../domain/money.dart';
import '../../l10n/app_localizations.dart';
import '../common/catalog_label.dart';
import '../common/catalog_providers.dart';
import '../common/confirm_reason_dialog.dart';
import '../common/money_field.dart';
import '../suppliers/supplier_form.dart';
import 'receipt_picker.dart';

enum _Edited { base, total }

/// Creates an expense, or (with [id]) shows and edits one. An expense in a
/// closed period, or a voided one, opens read only with a lock.
class ExpenseFormScreen extends ConsumerStatefulWidget {
  const ExpenseFormScreen({super.key, this.id});

  final String? id;

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _invoice = TextEditingController();
  final _base = TextEditingController();
  final _total = TextEditingController();

  bool _loading = true;
  bool _notFound = false;
  ExpenseRecord? _existing;
  bool _locked = false;

  late DateTime _date;
  String? _supplierId;
  String? _categoryId;
  String? _paymentMethodId;
  int _vatPct = 21;
  _Edited _lastEdited = _Edited.base;
  bool _paid = true;
  DateTime? _dueDate;
  bool _busy = false;

  List<ReceiptData> _stored = [];
  final List<PickedReceipt> _pending = [];

  bool get _isNew => widget.id == null;
  bool get _readOnly => _locked || (_existing?.voided ?? false);

  @override
  void initState() {
    super.initState();
    _date = dateOnly(ref.read(clockProvider)());
    _load();
  }

  @override
  void dispose() {
    _invoice.dispose();
    _base.dispose();
    _total.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = widget.id;
    if (id == null) {
      setState(() => _loading = false);
      return;
    }
    final repo = ref.read(expensesRepositoryProvider);
    final record = await repo.byId(id);
    if (!mounted) return;
    if (record == null) {
      setState(() {
        _loading = false;
        _notFound = true;
      });
      return;
    }
    final guard = ref.read(periodGuardProvider);
    var locked = false;
    try {
      await guard.ensureMonthOpen(record.date);
      if (record.paidInCashDayId != null) {
        await guard.ensureDayOpen(record.date);
      }
    } on PeriodLockedException {
      locked = true;
    }
    final receipts = await repo.receipts(id);
    if (!mounted) return;
    setState(() {
      _existing = record;
      _locked = locked;
      _date = record.date;
      _supplierId = record.supplierId;
      _categoryId = record.categoryId;
      _paymentMethodId = record.paymentMethodId;
      _invoice.text = record.invoiceNumber ?? '';
      _vatPct = record.vatPct;
      _base.text = MoneyField.text(record.base);
      _total.text = MoneyField.text(record.total);
      _lastEdited = _Edited.total;
      _paid = record.paymentStatus == PaymentStatus.paid;
      _dueDate = record.dueDate;
      _stored = receipts;
      _loading = false;
    });
  }

  // ------------------------------------------------------------ amounts

  Money? _tryParse(String text) {
    try {
      return Money.parse(text);
    } on FormatException {
      return null;
    }
  }

  /// Base, VAT and total from whichever of base / total was edited last.
  ({Money base, Money vat, Money total})? _amounts() {
    if (_lastEdited == _Edited.base) {
      final base = _tryParse(_base.text);
      if (base == null) return null;
      final r = VatCalc.fromBase(base, _vatPct);
      return (base: base, vat: r.vat, total: r.total);
    }
    final total = _tryParse(_total.text);
    if (total == null) return null;
    final r = VatCalc.fromTotal(total, _vatPct);
    return (base: r.base, vat: r.vat, total: total);
  }

  /// Rewrites the field that was not edited, from the one that was.
  void _recalc() {
    final a = _amounts();
    if (a != null) {
      if (_lastEdited == _Edited.base) {
        _total.text = MoneyField.text(a.total);
      } else {
        _base.text = MoneyField.text(a.base);
      }
    }
    setState(() {});
  }

  void _onBase(Money? _) {
    _lastEdited = _Edited.base;
    _recalc();
  }

  void _onTotal(Money? _) {
    _lastEdited = _Edited.total;
    _recalc();
  }

  // ------------------------------------------------------------ actions

  Future<void> _pickDate({required bool due}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (due ? _dueDate : null) ?? _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      final day = DateTime.utc(picked.year, picked.month, picked.day);
      if (due) {
        _dueDate = day;
      } else {
        _date = day;
      }
    });
  }

  Future<void> _pickSupplier() async {
    final choice = await showModalBottomSheet<_SupplierChoice>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _SupplierPickerSheet(),
    );
    if (choice == null) return;
    setState(() {
      _supplierId = choice.supplier?.id;
      final category = choice.supplier?.defaultCategoryId;
      if (category != null) _categoryId = category;
    });
  }

  Future<void> _addReceipt(PickedReceipt picked) async {
    final id = widget.id;
    if (id == null) {
      setState(() => _pending.add(picked));
      return;
    }
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(expensesRepositoryProvider);
    try {
      await repo.attachReceipt(id, picked.file, picked.kind);
      final receipts = await repo.receipts(id);
      if (mounted) setState(() => _stored = receipts);
    } on PeriodLockedException {
      messenger.showSnackBar(SnackBar(content: Text(l.expErrLocked)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.expReceiptError)));
    }
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    if (!_formKey.currentState!.validate()) return;
    final a = _amounts();
    if (a == null || a.total.cents <= 0) {
      messenger.showSnackBar(SnackBar(content: Text(l.amountMustBePositive)));
      return;
    }
    final invoice = _invoice.text.trim();
    final input = ExpenseInput(
      date: _date,
      supplierId: _supplierId,
      categoryId: _categoryId!,
      invoiceNumber: invoice.isEmpty ? null : invoice,
      base: a.base,
      vatPct: _vatPct,
      vat: a.vat,
      total: a.total,
      paymentMethodId: _effectivePaymentMethod(
        ref.read(paymentMethodsProvider).value ?? const [],
      )!,
      paidInCashDayId: _existing?.paidInCashDayId,
      paymentStatus: _paid ? PaymentStatus.paid : PaymentStatus.pending,
      dueDate: _paid ? null : _dueDate,
    );
    final repo = ref.read(expensesRepositoryProvider);
    setState(() => _busy = true);
    try {
      final String id;
      if (_isNew) {
        id = await repo.create(input);
      } else {
        id = widget.id!;
        await repo.update(id, input);
      }
      var receiptFailed = false;
      for (final r in _pending) {
        try {
          await repo.attachReceipt(id, r.file, r.kind);
        } catch (_) {
          receiptFailed = true;
        }
      }
      if (receiptFailed) {
        messenger.showSnackBar(SnackBar(content: Text(l.expReceiptError)));
      }
      if (!mounted) return;
      if (router.canPop()) {
        router.pop();
      } else {
        router.go('/expenses');
      }
    } on PeriodLockedException {
      messenger.showSnackBar(SnackBar(content: Text(l.expErrLocked)));
      if (mounted) setState(() => _busy = false);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.expErrSave)));
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _void() async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final reason = await askReason(context, title: l.expVoidReasonTitle);
    if (reason == null || !mounted) return;
    try {
      await ref.read(expensesRepositoryProvider).voidRecord(widget.id!, reason);
      if (!mounted) return;
      if (router.canPop()) {
        router.pop();
      } else {
        router.go('/expenses');
      }
    } on PeriodLockedException {
      messenger.showSnackBar(SnackBar(content: Text(l.expErrLocked)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.expErrSave)));
    }
  }

  /// The chosen method, else "card" (the usual way an invoice is paid), else
  /// the first active one.
  String? _effectivePaymentMethod(List<CatalogItem> methods) {
    if (_paymentMethodId != null) return _paymentMethodId;
    final active = methods.where((m) => m.active).toList();
    if (active.isEmpty) return null;
    return (active.where((m) => m.code == 'card').firstOrNull ?? active.first)
        .id;
  }

  // -------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final title = _isNew ? l.screenExpenseNew : l.screenExpenseDetail;
    if (_loading || _notFound) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : Text(l.expNotFound),
        ),
      );
    }
    final locale = Localizations.localeOf(context).languageCode;
    final methods = ref.watch(paymentMethodsProvider).value ?? const [];
    final List<CatalogItem> categories = [
      for (final c in ref.watch(expenseCategoriesProvider).value ?? const [])
        if (c.active || c.id == _categoryId) c,
    ];
    final suppliers = ref.watch(suppliersProvider).value ?? const [];
    final supplier = suppliers.where((s) => s.id == _supplierId).firstOrNull;
    final effectiveMethod = _effectivePaymentMethod(methods);
    final amounts = _amounts();
    final voided = _existing?.voided ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (_locked)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.lock_outline, key: ValueKey('expense-lock')),
            ),
        ],
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
                  if (_locked)
                    _Banner(icon: Icons.lock_outline, text: l.expLockedBanner),
                  if (voided)
                    _Banner(
                      icon: Icons.block,
                      text: l.expVoidedBanner(_existing!.voidReason ?? ''),
                    ),
                  IgnorePointer(
                    ignoring: _readOnly,
                    child: ExcludeFocus(
                      excluding: _readOnly,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _fields(
                              l,
                              locale,
                              methods: methods,
                              categories: categories,
                              supplier: supplier,
                              effectiveMethod: effectiveMethod,
                              amounts: amounts,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _receiptsSection(l),
                  if (!_readOnly) ...[
                    const SizedBox(height: 24),
                    FilledButton(
                      key: const ValueKey('expense-save'),
                      onPressed: _busy ? null : _save,
                      child: Text(l.actionSave),
                    ),
                    if (!_isNew) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        key: const ValueKey('expense-void'),
                        onPressed: _busy ? null : _void,
                        icon: const Icon(Icons.block),
                        label: Text(l.expVoidButton),
                      ),
                    ],
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fields(
    AppLocalizations l,
    String locale, {
    required List<CatalogItem> methods,
    required List<CatalogItem> categories,
    required SupplierRecord? supplier,
    required String? effectiveMethod,
    required ({Money base, Money vat, Money total})? amounts,
  }) {
    final activeMethods = [
      for (final m in methods)
        if (m.active || m.id == effectiveMethod) m,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          key: const ValueKey('expense-date'),
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event_outlined),
          title: Text(l.expFieldDate),
          subtitle: Text(DateFormat.yMMMMd(locale).format(_date)),
          onTap: () => _pickDate(due: false),
        ),
        ListTile(
          key: const ValueKey('expense-supplier-pick'),
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.storefront_outlined),
          title: Text(l.expFieldSupplier),
          subtitle: Text(supplier?.name ?? l.expSupplierPick),
          trailing: const Icon(Icons.search),
          onTap: _pickSupplier,
        ),
        const SizedBox(height: 8),
        // Re-created when the supplier fills in a category: the field only
        // reads its initial value once.
        KeyedSubtree(
          key: ValueKey('category-${_categoryId ?? ''}'),
          child: DropdownButtonFormField<String>(
            key: const ValueKey('expense-category'),
            initialValue: _categoryId,
            decoration: InputDecoration(labelText: l.fieldCategory),
            items: [
              for (final c in categories)
                DropdownMenuItem(value: c.id, child: Text(catalogLabel(l, c))),
            ],
            validator: (v) => v == null ? l.fieldRequired : null,
            onChanged: (v) => setState(() => _categoryId = v),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: const ValueKey('expense-invoice'),
          controller: _invoice,
          decoration: InputDecoration(labelText: l.fieldInvoiceOptional),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MoneyField(
                key: const ValueKey('expense-base'),
                label: l.expFieldBase,
                controller: _base,
                onChanged: _onBase,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MoneyField(
                key: const ValueKey('expense-total'),
                label: l.expFieldTotal,
                controller: _total,
                onChanged: _onTotal,
              ),
            ),
          ],
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
          onSelectionChanged: (v) {
            _vatPct = v.first;
            _recalc();
          },
        ),
        const SizedBox(height: 8),
        if (amounts != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _SummaryRow(l.expSummaryBase, amounts.base.format(locale)),
                  _SummaryRow(
                    '${l.expSummaryVat} ($_vatPct %)',
                    amounts.vat.format(locale),
                  ),
                  _SummaryRow(
                    l.expSummaryTotal,
                    amounts.total.format(locale),
                    key: const ValueKey('expense-summary-total'),
                    bold: true,
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 12),
        KeyedSubtree(
          key: ValueKey('payment-${effectiveMethod ?? ''}'),
          child: DropdownButtonFormField<String>(
            key: const ValueKey('expense-payment'),
            initialValue: effectiveMethod,
            decoration: InputDecoration(labelText: l.expFieldPayment),
            items: [
              for (final m in activeMethods)
                DropdownMenuItem(value: m.id, child: Text(catalogLabel(l, m))),
            ],
            validator: (v) => v == null ? l.fieldRequired : null,
            onChanged: (v) => setState(() => _paymentMethodId = v),
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<bool>(
          key: const ValueKey('expense-status'),
          segments: [
            ButtonSegment(
              value: true,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(l.expStatusPaid),
            ),
            ButtonSegment(
              value: false,
              icon: const Icon(Icons.schedule),
              label: Text(l.expStatusPending),
            ),
          ],
          selected: {_paid},
          showSelectedIcon: false,
          onSelectionChanged: (v) => setState(() => _paid = v.first),
        ),
        if (!_paid)
          ListTile(
            key: const ValueKey('expense-due'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event_busy_outlined),
            title: Text(l.expFieldDue),
            subtitle: Text(
              _dueDate == null
                  ? l.expDueNone
                  : DateFormat.yMMMMd(locale).format(_dueDate!),
            ),
            trailing: _dueDate == null
                ? null
                : IconButton(
                    tooltip: l.expDueNone,
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _dueDate = null),
                  ),
            onTap: () => _pickDate(due: true),
          ),
      ],
    );
  }

  Widget _receiptsSection(AppLocalizations l) {
    final store = ref.read(receiptStoreProvider);
    final thumbs = <Widget>[
      for (final r in _stored)
        ReceiptThumb(file: store.fileFor(r.relativePath), kind: r.kind),
      for (final (i, p) in _pending.indexed)
        Stack(
          children: [
            ReceiptThumb(file: p.file, kind: p.kind),
            if (!_readOnly)
              Positioned(
                top: -8,
                right: -8,
                child: IconButton(
                  tooltip: l.actionCancel,
                  iconSize: 18,
                  icon: const Icon(Icons.cancel),
                  onPressed: () => setState(() => _pending.removeAt(i)),
                ),
              ),
          ],
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.expReceipts,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (thumbs.isEmpty)
          Text(l.expReceiptNone, style: Theme.of(context).textTheme.bodySmall)
        else
          Wrap(
            key: const ValueKey('expense-receipts'),
            spacing: 8,
            runSpacing: 8,
            children: thumbs,
          ),
        const SizedBox(height: 12),
        ReceiptButtons(enabled: !_readOnly, onPicked: _addReceipt),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.secondaryContainer,
    child: ListTile(leading: Icon(icon), title: Text(text)),
  );
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, {super.key, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold ? const TextStyle(fontWeight: FontWeight.bold) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

/// The supplier picked, or `null` supplier for "no supplier".
class _SupplierChoice {
  const _SupplierChoice(this.supplier);

  final SupplierRecord? supplier;
}

/// Search box over the suppliers, with "new supplier" and "no supplier".
class _SupplierPickerSheet extends ConsumerStatefulWidget {
  const _SupplierPickerSheet();

  @override
  ConsumerState<_SupplierPickerSheet> createState() => _PickerState();
}

class _PickerState extends ConsumerState<_SupplierPickerSheet> {
  String _query = '';

  Future<void> _create() async {
    final id = await showSupplierForm(context);
    if (id == null || !mounted) return;
    final all = await ref.read(suppliersRepositoryProvider).search('');
    if (!mounted) return;
    Navigator.of(context)
        .pop(_SupplierChoice(all.where((s) => s.id == id).firstOrNull));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final q = _query.trim().toLowerCase();
    final suppliers = [
      for (final s in ref.watch(suppliersProvider).value ?? const [])
        if (s.name.toLowerCase().contains(q) ||
            (s.nif ?? '').toLowerCase().contains(q))
          s,
    ];
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              key: const ValueKey('supplier-search'),
              autofocus: true,
              decoration: InputDecoration(
                labelText: l.expSupplierSearch,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  key: const ValueKey('supplier-new'),
                  leading: const Icon(Icons.add),
                  title: Text(l.expSupplierNew),
                  onTap: _create,
                ),
                ListTile(
                  key: const ValueKey('supplier-none'),
                  leading: const Icon(Icons.clear),
                  title: Text(l.expSupplierClear),
                  onTap: () =>
                      Navigator.of(context).pop(const _SupplierChoice(null)),
                ),
                for (final s in suppliers)
                  ListTile(
                    key: ValueKey('supplier-option-${s.id}'),
                    title: Text(s.name),
                    subtitle: (s.nif ?? '').isEmpty ? null : Text(s.nif!),
                    onTap: () => Navigator.of(context).pop(_SupplierChoice(s)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
