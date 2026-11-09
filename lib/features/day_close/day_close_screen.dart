import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/audit/period_guard.dart';
import '../../data/providers.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/days_repository.dart';
import '../../data/repositories/expenses_repository.dart';
import '../../data/repositories/withdrawals_repository.dart';
import '../../domain/dates.dart';
import '../../domain/enums.dart';
import '../../domain/money.dart';
import '../../l10n/app_localizations.dart';
import '../common/auth_gate.dart';
import '../common/catalog_label.dart';
import '../common/catalog_providers.dart';
import '../common/confirm_reason_dialog.dart';
import '../common/money_field.dart';
import 'day_close_controller.dart';
import 'denomination_counter.dart';
import 'quick_cash_expense_sheet.dart';
import 'quick_withdrawal_sheet.dart';

/// Withdrawals of a day (voided ones included), kept up to date.
final dayWithdrawalsProvider = StreamProvider.autoDispose
    .family<List<WithdrawalRecord>, String>(
      (ref, dayId) => ref.watch(withdrawalsRepositoryProvider).watchDay(dayId),
    );

/// Expenses paid from the till of a day, identified by (day id, day date).
final dayCashExpensesProvider = StreamProvider.autoDispose
    .family<List<ExpenseRecord>, (String, DateTime)>((ref, key) {
      final (dayId, date) = key;
      return ref
          .watch(expensesRepositoryProvider)
          .watchRange(DateRange(date, date))
          .map(
            (all) => [
              for (final e in all)
                if (e.paidInCashDayId == dayId) e,
            ],
          );
    });

String _errorText(AppLocalizations l, DayCloseError error) => switch (error) {
  DayCloseError.commentRequired => l.dayErrCommentRequired,
  DayCloseError.countedMissing => l.dayErrCountedMissing,
  DayCloseError.terminalMissing => l.dayErrTerminalMissing,
  DayCloseError.periodLocked => l.dayErrLocked,
  DayCloseError.notOpen => l.dayErrNotOpen,
  DayCloseError.saveFailed => l.dayErrSave,
};

/// Registration and close of one day (spec 6.2). A closed day is shown read
/// only with a "Reabrir" button.
class DayCloseScreen extends ConsumerStatefulWidget {
  const DayCloseScreen({super.key, required this.ymd});

  final String ymd;

  @override
  ConsumerState<DayCloseScreen> createState() => _DayCloseScreenState();
}

class _DayCloseScreenState extends ConsumerState<DayCloseScreen>
    with WidgetsBindingObserver {
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    try {
      _date = parseYmd(widget.ymd);
    } on FormatException {
      _date = null;
    }
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final date = _date;
    if (date == null || state == AppLifecycleState.resumed) return;
    // Going to the background: write what is pending.
    ref.read(dayCloseControllerProvider(date).notifier).flush();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final date = _date;
    if (date == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l.screenDay)),
        body: Center(child: Text(l.dayInvalidDate)),
      );
    }
    final locale = Localizations.localeOf(context).languageCode;
    final async = ref.watch(dayCloseControllerProvider(date));
    return Scaffold(
      appBar: AppBar(title: Text(DateFormat.yMMMMEEEEd(locale).format(date))),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: async.when(
              data: (s) => _DayBody(
                key: ValueKey('${s.dayId}/${s.status.name}'),
                state: s,
                locale: locale,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    e is PeriodLockedException
                        ? l.dayErrLocked
                        : l.dayLoadError,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayBody extends ConsumerStatefulWidget {
  const _DayBody({super.key, required this.state, required this.locale});

  final DayCloseState state;
  final String locale;

  @override
  ConsumerState<_DayBody> createState() => _DayBodyState();
}

class _DayBodyState extends ConsumerState<_DayBody> {
  final _formKey = GlobalKey<FormState>();
  bool _closing = false;

  DayCloseState get s => widget.state;
  String get locale => widget.locale;

  DayCloseController get _controller =>
      ref.read(dayCloseControllerProvider(s.date).notifier);

  Future<void> _close() async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    if (!(_formKey.currentState?.validate() ?? true)) {
      messenger.showSnackBar(SnackBar(content: Text(l.dayFormInvalid)));
      return;
    }
    setState(() => _closing = true);
    final next = await _controller.close();
    if (!mounted) return;
    setState(() => _closing = false);
    final closed =
        ref.read(dayCloseControllerProvider(s.date)).value?.status ==
        DayStatus.closed;
    if (!closed) return;
    if (next != null) {
      router.go('/day/${ymd(next)}');
    } else {
      messenger.showSnackBar(SnackBar(content: Text(l.dayClosedNoPending)));
      router.go('/');
    }
  }

  Future<void> _reopen() async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await requireAuth(context, ref, reason: l.dayReopenAuthReason);
    if (!ok || !mounted) return;
    final reason = await askReason(context, title: l.dayReopenReasonTitle);
    if (reason == null || !mounted) return;
    await _controller.reopen(reason);
    if (!mounted) return;
    final state = ref.read(dayCloseControllerProvider(s.date)).value;
    if (state?.isOpen ?? false) {
      messenger.showSnackBar(SnackBar(content: Text(l.dayReopened)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = s.isOpen ? _editable(context) : _readOnly(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  // ------------------------------------------------------------ open day

  List<Widget> _editable(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final methods = _visibleMethods();
    final c = _controller;
    return [
      _Section(l.daySectionSales),
      for (final m in methods) ...[
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            catalogLabel(l, m),
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Row(
          children: [
            for (final shift in Shift.values) ...[
              if (shift == Shift.dinner) const SizedBox(width: 12),
              Expanded(
                child: MoneyField(
                  key: ValueKey('sale-${m.id}-${shift.name}'),
                  label: shift == Shift.lunch
                      ? l.dayShiftLunch
                      : l.dayShiftDinner,
                  required: false,
                  initialValue: s.sales[(m.id, shift)],
                  onChanged: (v) => c.setSale(m.id, shift, v),
                ),
              ),
            ],
          ],
        ),
      ],
      const SizedBox(height: 12),
      Row(
        children: [
          for (final shift in Shift.values) ...[
            if (shift == Shift.dinner) const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                key: ValueKey('covers-${shift.name}'),
                initialValue: (s.covers[shift] ?? 0) > 0
                    ? '${s.covers[shift]}'
                    : null,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
                decoration: InputDecoration(
                  labelText: shift == Shift.lunch
                      ? l.dayCoversLunch
                      : l.dayCoversDinner,
                ),
                onChanged: (v) => c.setCovers(shift, int.tryParse(v) ?? 0),
              ),
            ),
          ],
        ],
      ),
      const SizedBox(height: 8),
      _InfoRow(
        label: l.dayTotalSales,
        value: s.summary.totalSales.format(locale),
      ),
      _Section(l.daySectionTips),
      Row(
        children: [
          Expanded(
            child: MoneyField(
              key: const ValueKey('tips-cash'),
              label: l.dayTipsCash,
              required: false,
              initialValue: s.cashTips.isZero ? null : s.cashTips,
              onChanged: (v) => c.setTips(cash: v ?? Money.zero),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: MoneyField(
              key: const ValueKey('tips-card'),
              label: l.dayTipsCard,
              required: false,
              initialValue: s.cardTips.isZero ? null : s.cardTips,
              onChanged: (v) => c.setTips(card: v ?? Money.zero),
            ),
          ),
        ],
      ),
      _Section(l.daySectionCashOut),
      _CashOut(state: s, locale: locale, readOnly: false),
      _Section(l.daySectionCount),
      MoneyField(
        key: const ValueKey('opening-float'),
        label: l.dayOpeningFloat,
        initialValue: s.openingFloat,
        onChanged: (v) {
          if (v != null) c.setOpeningFloat(v);
        },
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 12),
        child: Text(
          l.dayOpeningFloatHint,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
      SegmentedButton<bool>(
        key: const ValueKey('count-mode'),
        segments: [
          ButtonSegment(value: false, label: Text(l.dayCountTotal)),
          ButtonSegment(value: true, label: Text(l.dayCountDenominations)),
        ],
        selected: {s.byDenominations},
        showSelectedIcon: false,
        onSelectionChanged: (v) => c.setCountMode(byDenominations: v.first),
      ),
      const SizedBox(height: 12),
      if (s.byDenominations)
        DenominationCounter(
          initialCounts: s.denominations,
          locale: locale,
          onChanged: c.setDenominations,
        )
      else
        MoneyField(
          key: const ValueKey('counted-total'),
          label: l.dayCountedCash,
          initialValue: s.countedCash,
          onChanged: c.setCountedTotal,
        ),
      const SizedBox(height: 12),
      MoneyField(
        key: const ValueKey('terminal-total'),
        label: l.dayTerminalTotal,
        initialValue: s.terminalTotal,
        onChanged: c.setTerminalTotal,
      ),
      _Section(l.daySectionResult),
      _ResultCard(summary: s.summary, locale: locale),
      const SizedBox(height: 16),
      TextFormField(
        key: const ValueKey('day-comment'),
        initialValue: s.comment.isEmpty ? null : s.comment,
        minLines: 2,
        maxLines: 4,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: s.summary.commentRequired
              ? l.dayCommentRequired
              : l.dayComment,
        ),
        onChanged: c.setComment,
      ),
      if (s.error != null) _ErrorText(_errorText(l, s.error!)),
      const SizedBox(height: 16),
      FilledButton(
        key: const ValueKey('close-day-button'),
        onPressed: s.commentMissing || _closing ? null : _close,
        child: Text(l.dayCloseButton),
      ),
      const SizedBox(height: 24),
    ];
  }

  /// Active payment methods, plus inactive ones that hold an amount.
  List<CatalogItem> _visibleMethods() {
    final all = ref.watch(paymentMethodsProvider).value ?? const [];
    bool hasAmount(String id) =>
        s.sales.entries.any((e) => e.key.$1 == id && !e.value.isZero);
    return [
      for (final m in all)
        if (m.active || hasAmount(m.id)) m,
    ];
  }

  // ----------------------------------------------------------- read only

  List<Widget> _readOnly(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final closed = s.status == DayStatus.closed;
    final methods = _visibleMethods();
    return [
      Card(
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: ListTile(
          leading: Icon(
            closed ? Icons.lock_outline : Icons.do_not_disturb_on_outlined,
          ),
          title: Text(closed ? l.dayClosedBanner : l.dayNoActivityBanner),
        ),
      ),
      if (s.error != null) _ErrorText(_errorText(l, s.error!)),
      if (closed) ...[
        _Section(l.daySectionSales),
        for (final m in methods)
          if (Shift.values.any((x) => s.sales[(m.id, x)] != null))
            _InfoRow(
              label: catalogLabel(l, m),
              value:
                  '${l.dayShiftLunch} ${(s.sales[(m.id, Shift.lunch)] ?? Money.zero).format(locale)} · '
                  '${l.dayShiftDinner} ${(s.sales[(m.id, Shift.dinner)] ?? Money.zero).format(locale)}',
            ),
        _InfoRow(
          label: l.dayCoversLunch,
          value: '${s.covers[Shift.lunch] ?? 0}',
        ),
        _InfoRow(
          label: l.dayCoversDinner,
          value: '${s.covers[Shift.dinner] ?? 0}',
        ),
        _InfoRow(
          label: l.dayTotalSales,
          value: s.summary.totalSales.format(locale),
        ),
        _Section(l.daySectionTips),
        _InfoRow(label: l.dayTipsCash, value: s.cashTips.format(locale)),
        _InfoRow(label: l.dayTipsCard, value: s.cardTips.format(locale)),
        _Section(l.daySectionCashOut),
        _CashOut(state: s, locale: locale, readOnly: true),
        _Section(l.daySectionCount),
        _InfoRow(
          label: l.dayOpeningFloat,
          value: s.openingFloat.format(locale),
        ),
        if (s.countedCash != null)
          _InfoRow(
            label: l.dayCountedCash,
            value: s.countedCash!.format(locale),
          ),
        if (s.terminalTotal != null)
          _InfoRow(
            label: l.dayTerminalTotal,
            value: s.terminalTotal!.format(locale),
          ),
        _Section(l.daySectionResult),
        _ResultCard(summary: s.summary, locale: locale),
        if (s.comment.isNotEmpty) ...[
          const SizedBox(height: 16),
          _InfoRow(label: l.dayComment, value: s.comment),
        ],
      ],
      const SizedBox(height: 16),
      OutlinedButton.icon(
        key: const ValueKey('reopen-day-button'),
        onPressed: _reopen,
        icon: const Icon(Icons.lock_open_outlined),
        label: Text(l.dayReopen),
      ),
      const SizedBox(height: 24),
    ];
  }
}

// ------------------------------------------------------------ small widgets

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 4),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        Flexible(child: Text(value, textAlign: TextAlign.end)),
      ],
    ),
  );
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Row(
      children: [
        Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            key: const ValueKey('day-error'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ],
    ),
  );
}

/// Expected cash and both discrepancies, each with its "Sobra" / "Falta".
class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.summary, required this.locale});

  final DaySummary summary;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _InfoRow(
              label: l.dayExpected,
              value: summary.expected.format(locale),
            ),
            _DiffRow(
              key: const ValueKey('cash-diff'),
              label: l.dayCashDiff,
              diff: summary.cashDiff,
              locale: locale,
            ),
            _DiffRow(
              key: const ValueKey('card-diff'),
              label: l.dayCardDiff,
              diff: summary.cardDiff,
              locale: locale,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiffRow extends StatelessWidget {
  const _DiffRow({
    super.key,
    required this.label,
    required this.diff,
    required this.locale,
  });

  final String label;
  final Money? diff;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final d = diff;
    final scheme = Theme.of(context).colorScheme;
    final (IconData icon, String word, Color color) = d == null
        ? (Icons.hourglass_empty, '', scheme.onSurfaceVariant)
        : d.isZero
        ? (Icons.check_circle_outline, l.dayStateBalanced, scheme.primary)
        : d.isNegative
        ? (Icons.arrow_downward, l.dayShort, scheme.error)
        : (Icons.arrow_upward, l.dayOver, scheme.tertiary);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (d == null)
            Text(l.dayDiffPending)
          else ...[
            Text(
              d.cents > 0 ? '+${d.format(locale)}' : d.format(locale),
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(word, style: TextStyle(color: color)),
          ],
        ],
      ),
    );
  }
}

/// Withdrawals and cash expenses of the day, with the "+" buttons.
class _CashOut extends ConsumerWidget {
  const _CashOut({
    required this.state,
    required this.locale,
    required this.readOnly,
  });

  final DayCloseState state;
  final String locale;
  final bool readOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final controller = ref.read(
      dayCloseControllerProvider(state.date).notifier,
    );
    final withdrawals =
        ref.watch(dayWithdrawalsProvider(state.dayId)).value ?? const [];
    final expenses =
        ref.watch(dayCashExpensesProvider((state.dayId, state.date))).value ??
        const [];
    final types = ref.watch(withdrawalTypesProvider).value ?? const [];
    final categories = ref.watch(expenseCategoriesProvider).value ?? const [];

    String typeName(String id) {
      final t = types.where((t) => t.id == id).firstOrNull;
      return t == null ? '' : catalogLabel(l, t);
    }

    String categoryName(String id) {
      final c = categories.where((c) => c.id == id).firstOrNull;
      return c == null ? '' : catalogLabel(l, c);
    }

    Future<void> voidWith(Future<void> Function(String reason) action) async {
      final messenger = ScaffoldMessenger.of(context);
      final reason = await askReason(context, title: l.dayVoidReasonTitle);
      if (reason == null) return;
      try {
        await action(reason);
      } on PeriodLockedException {
        messenger.showSnackBar(SnackBar(content: Text(l.dayErrLocked)));
      } catch (_) {
        messenger.showSnackBar(SnackBar(content: Text(l.dayErrSave)));
      }
    }

    Widget header(String title, String addTooltip, Key key, VoidCallback add) =>
        Row(
          children: [
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.labelLarge),
            ),
            if (!readOnly)
              IconButton.filledTonal(
                key: key,
                tooltip: addTooltip,
                icon: const Icon(Icons.add),
                onPressed: add,
              ),
          ],
        );

    Widget tile({
      required String title,
      required String subtitle,
      required bool voided,
      required VoidCallback onVoid,
    }) => ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: voided
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text(voided ? '$subtitle · ${l.dayVoided}' : subtitle),
      trailing: readOnly || voided
          ? null
          : IconButton(
              tooltip: l.dayVoid,
              icon: const Icon(Icons.block),
              onPressed: onVoid,
            ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header(
          l.dayWithdrawals,
          l.dayAddWithdrawal,
          const ValueKey('add-withdrawal'),
          () => showQuickWithdrawalSheet(context, state.date),
        ),
        if (withdrawals.isEmpty)
          Text(l.dayNoneYet, style: Theme.of(context).textTheme.bodySmall),
        for (final w in withdrawals)
          tile(
            title: w.amount.format(locale),
            subtitle: [
              typeName(w.typeId),
              if ((w.note ?? '').isNotEmpty) w.note!,
            ].join(' · '),
            voided: w.voided,
            onVoid: () =>
                voidWith((reason) => controller.voidWithdrawal(w.id, reason)),
          ),
        const SizedBox(height: 8),
        header(
          l.dayCashExpenses,
          l.dayAddCashExpense,
          const ValueKey('add-cash-expense'),
          () => showQuickCashExpenseSheet(context, state.date),
        ),
        if (expenses.isEmpty)
          Text(l.dayNoneYet, style: Theme.of(context).textTheme.bodySmall),
        for (final e in expenses)
          tile(
            title: e.total.format(locale),
            subtitle: categoryName(e.categoryId),
            voided: e.voided,
            onVoid: () =>
                voidWith((reason) => controller.voidCashExpense(e.id, reason)),
          ),
      ],
    );
  }
}
