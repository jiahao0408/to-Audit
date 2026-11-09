import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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

/// Unpaid, non-voided expenses by due date.
final pendingExpensesProvider = StreamProvider.autoDispose<List<ExpenseRecord>>(
  (ref) => ref.watch(expensesRepositoryProvider).watchPending(),
);

/// The expenses dated in [range], voided ones included.
final monthExpensesProvider = StreamProvider.autoDispose
    .family<List<ExpenseRecord>, DateRange>(
      (ref, range) => ref.watch(expensesRepositoryProvider).watchRange(range),
    );

/// Expenses (RF-GAS): pending invoices, and everything in a month with the
/// totals by supplier and category.
class ExpensesListScreen extends ConsumerWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.screenExpenses),
          actions: [
            IconButton(
              key: const ValueKey('open-suppliers'),
              tooltip: l.screenSuppliers,
              icon: const Icon(Icons.storefront_outlined),
              onPressed: () => context.push('/suppliers'),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l.expTabPending),
              Tab(text: l.expTabAll),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          key: const ValueKey('add-expense'),
          tooltip: l.screenExpenseNew,
          onPressed: () => context.push('/expenses/new'),
          child: const Icon(Icons.add),
        ),
        body: const SafeArea(
          child: TabBarView(children: [_PendingTab(), _AllTab()]),
        ),
      ),
    );
  }
}

/// Names for the ids an expense refers to.
class _Names {
  _Names(this.l, List<SupplierRecord> suppliers, List<CatalogItem> categories)
    : _suppliers = {for (final s in suppliers) s.id: s.name},
      _categories = {for (final c in categories) c.id: catalogLabel(l, c)};

  final AppLocalizations l;
  final Map<String, String> _suppliers;
  final Map<String, String> _categories;

  String supplier(String? id) =>
      id == null ? l.noSupplier : _suppliers[id] ?? '';

  String category(String id) => _categories[id] ?? '';

  /// What identifies the expense in a list: its supplier, else its category.
  String title(ExpenseRecord e) =>
      e.supplierId == null ? category(e.categoryId) : supplier(e.supplierId);
}

_Names _namesOf(BuildContext context, WidgetRef ref) => _Names(
  AppLocalizations.of(context)!,
  ref.watch(suppliersProvider).value ?? const [],
  ref.watch(expenseCategoriesProvider).value ?? const [],
);

class _PendingTab extends ConsumerWidget {
  const _PendingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final names = _namesOf(context, ref);
    final locale = Localizations.localeOf(context).languageCode;
    final expenses = ref.watch(pendingExpensesProvider).value ?? const [];
    if (expenses.isEmpty) return Center(child: Text(l.expEmpty));
    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        for (final e in expenses)
          _ExpenseTile(expense: e, names: names, locale: locale),
      ],
    );
  }
}

class _AllTab extends ConsumerStatefulWidget {
  const _AllTab();

  @override
  ConsumerState<_AllTab> createState() => _AllTabState();
}

class _AllTabState extends ConsumerState<_AllTab> {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final today = dateOnly(ref.read(clockProvider)());
    _year = today.year;
    _month = today.month;
  }

  void _shift(int months) {
    final target = DateTime.utc(_year, _month + months);
    setState(() {
      _year = target.year;
      _month = target.month;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final names = _namesOf(context, ref);
    final locale = Localizations.localeOf(context).languageCode;
    final range = DateRange(
      DateTime.utc(_year, _month, 1),
      DateTime.utc(_year, _month, daysInMonth(_year, _month)),
    );
    final expenses = ref.watch(monthExpensesProvider(range)).value ?? const [];
    final title = DateFormat.yMMMM(locale).format(DateTime.utc(_year, _month));

    return ListView(
      padding: const EdgeInsets.only(bottom: 88),
      children: [
        Row(
          children: [
            IconButton(
              tooltip: l.calendarPrevMonth,
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _shift(-1),
            ),
            Expanded(
              child: Text(
                title,
                key: const ValueKey('expenses-month'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: l.calendarNextMonth,
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _shift(1),
            ),
          ],
        ),
        if (expenses.isNotEmpty) _Totals(expenses: expenses, names: names),
        if (expenses.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(child: Text(l.expEmpty)),
          ),
        for (final e in expenses)
          _ExpenseTile(expense: e, names: names, locale: locale),
      ],
    );
  }
}

/// Totals by supplier and by category of the month (RF-GAS-07), voided
/// expenses left out.
class _Totals extends StatelessWidget {
  const _Totals({required this.expenses, required this.names});

  final List<ExpenseRecord> expenses;
  final _Names names;

  @override
  Widget build(BuildContext context) {
    final l = names.l;
    final locale = Localizations.localeOf(context).languageCode;
    final bySupplier = <String, Money>{};
    final byCategory = <String, Money>{};
    for (final e in expenses.where((e) => !e.voided)) {
      final supplier = names.supplier(e.supplierId);
      bySupplier[supplier] = (bySupplier[supplier] ?? Money.zero) + e.total;
      final category = names.category(e.categoryId);
      byCategory[category] = (byCategory[category] ?? Money.zero) + e.total;
    }
    List<Widget> rows(Map<String, Money> totals) {
      final sorted = totals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return [
        for (final e in sorted)
          ListTile(
            dense: true,
            title: Text(e.key),
            trailing: Text(e.value.format(locale)),
          ),
      ];
    }

    return ExpansionTile(
      key: const ValueKey('expense-totals'),
      title: Text(l.expTotalsTitle),
      children: [
        ListTile(
          dense: true,
          title: Text(
            l.expTotalsBySupplier,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        ...rows(bySupplier),
        ListTile(
          dense: true,
          title: Text(
            l.expTotalsByCategory,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        ...rows(byCategory),
      ],
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.expense,
    required this.names,
    required this.locale,
  });

  final ExpenseRecord expense;
  final _Names names;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = names.l;
    final e = expense;
    final strike = e.voided
        ? const TextStyle(decoration: TextDecoration.lineThrough)
        : null;
    final details = [
      DateFormat.yMd(locale).format(e.date),
      if ((e.invoiceNumber ?? '').isNotEmpty) e.invoiceNumber!,
      if (e.dueDate != null &&
          !e.voided &&
          e.paymentStatus == PaymentStatus.pending)
        l.expDueOn(DateFormat.yMd(locale).format(e.dueDate!)),
    ].join(' · ');
    return ListTile(
      key: ValueKey('expense-${e.id}'),
      minTileHeight: 64,
      title: Text(names.title(e), style: strike),
      subtitle: Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(details, style: strike),
          if (e.voided)
            Chip(
              avatar: const Icon(Icons.block, size: 16),
              label: Text(l.expVoidedChip),
              visualDensity: VisualDensity.compact,
            )
          else if (e.incomplete)
            Chip(
              avatar: const Icon(Icons.warning_amber_rounded, size: 16),
              label: Text(l.expIncomplete),
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
      trailing: Text(
        e.total.format(locale),
        style: Theme.of(context).textTheme.titleSmall?.merge(strike),
      ),
      onTap: () => context.push('/expenses/${e.id}'),
    );
  }
}
