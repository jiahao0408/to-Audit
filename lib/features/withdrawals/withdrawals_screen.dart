import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/providers.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/withdrawals_repository.dart';
import '../../domain/dates.dart';
import '../../domain/money.dart';
import '../../l10n/app_localizations.dart';
import '../common/catalog_label.dart';
import '../common/catalog_providers.dart';

enum _Period { week, month }

/// Withdrawals screen: period selector + list + totals by type.
class WithdrawalsScreen extends ConsumerStatefulWidget {
  const WithdrawalsScreen({super.key});

  @override
  ConsumerState<WithdrawalsScreen> createState() => _WithdrawalsScreenState();
}

class _WithdrawalsScreenState extends ConsumerState<WithdrawalsScreen> {
  _Period _period = _Period.month;

  DateRange _range() {
    final now = ref.read(clockProvider)();
    return switch (_period) {
      _Period.week => rangeThisWeek(now),
      _Period.month => rangeThisMonth(now),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final range = _range();
    final withdrawals = ref.watch(
      _withdrawalsRangeProvider(range),
    );
    final totals = ref.watch(_totalsByTypeProvider(range));
    final types = ref.watch(withdrawalTypesProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text(l.screenWithdrawals)),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PeriodSelector(
                  period: _period,
                  onChanged: (p) => setState(() => _period = p),
                  locale: locale,
                  range: range,
                ),
                const Divider(height: 1),
                Expanded(
                  child: withdrawals.when(
                    data: (list) => _WithdrawalsBody(
                      list: list,
                      types: types,
                      locale: locale,
                      totals: totals.value,
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) =>
                        Center(child: Text(l.withdrawalsErrLoad)),
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

// ----------------------------------------------------------- providers

final _withdrawalsRangeProvider =
    StreamProvider.autoDispose.family<List<WithdrawalRecord>, DateRange>(
      (ref, range) =>
          ref.watch(withdrawalsRepositoryProvider).watchRange(range),
    );

final _totalsByTypeProvider =
    FutureProvider.autoDispose.family<Map<String, Money>, DateRange>(
      (ref, range) =>
          ref.read(withdrawalsRepositoryProvider).totalsByType(range),
    );

// ----------------------------------------------------------- widgets

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.period,
    required this.onChanged,
    required this.locale,
    required this.range,
  });

  final _Period period;
  final ValueChanged<_Period> onChanged;
  final String locale;
  final DateRange range;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final dateLabel = range.start == range.end
        ? DateFormat.yMMMMd(locale).format(range.start)
        : '${DateFormat.yMd(locale).format(range.start)} – '
            '${DateFormat.yMd(locale).format(range.end)}';
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<_Period>(
            segments: [
              ButtonSegment(
                value: _Period.week,
                label: Text(l.withdrawalsPeriodWeek),
              ),
              ButtonSegment(
                value: _Period.month,
                label: Text(l.withdrawalsPeriodMonth),
              ),
            ],
            selected: {period},
            showSelectedIcon: false,
            onSelectionChanged: (v) => onChanged(v.first),
          ),
          const SizedBox(height: 4),
          Text(
            dateLabel,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WithdrawalsBody extends StatelessWidget {
  const _WithdrawalsBody({
    required this.list,
    required this.types,
    required this.locale,
    required this.totals,
  });

  final List<WithdrawalRecord> list;
  final List<CatalogItem> types;
  final String locale;
  final Map<String, Money>? totals;

  String _typeName(AppLocalizations l, String typeId) {
    final t = types.where((t) => t.id == typeId).firstOrNull;
    return t == null ? typeId : catalogLabel(l, t);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (list.isEmpty) {
      return Center(child: Text(l.withdrawalsEmpty));
    }
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        for (final w in list)
          ListTile(
            key: ValueKey('withdrawal-${w.id}'),
            title: Text(
              w.amount.format(locale),
              style: w.voided
                  ? const TextStyle(decoration: TextDecoration.lineThrough)
                  : null,
            ),
            subtitle: Text(
              [
                _typeName(l, w.typeId),
                DateFormat.yMMMd(locale).format(w.date),
                if ((w.note ?? '').isNotEmpty) w.note!,
                if (w.voided) l.dayVoided,
              ].join(' · '),
            ),
          ),
        const Divider(),
        if (totals != null && totals!.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l.withdrawalsTotalsTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          for (final entry in totals!.entries)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_typeName(l, entry.key)),
                  ),
                  Text(
                    entry.value.format(locale),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l.export_totalWithdrawals,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Text(
                  Money.sum(totals!.values).format(locale),
                  key: const ValueKey('withdrawals-total'),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
