import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/providers.dart';
import '../../data/repositories/days_repository.dart';
import '../../domain/dates.dart';
import '../../l10n/app_localizations.dart';
import 'month_grid.dart';

/// The day records of [range], kept up to date.
final daysInRangeProvider = StreamProvider.family<List<DayRecord>, DateRange>(
  (ref, range) => ref.watch(daysRepositoryProvider).watchRange(range),
);

/// A month at a time (the current one by default). Tap a day to open it;
/// long-press an unregistered day up to today to mark it "no activity".
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
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

  DateRange get _range => DateRange(
    DateTime.utc(_year, _month, 1),
    DateTime.utc(_year, _month, daysInMonth(_year, _month)),
  );

  Future<void> _markNoActivity(DateTime date) async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(daysRepositoryProvider).markNoActivity(date);
      messenger.showSnackBar(SnackBar(content: Text(l.markNoActivityDone)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.markNoActivityError)));
    }
  }

  Future<void> _onLongPress(
    DateTime date,
    Map<DateTime, DayCellState> states,
  ) async {
    if (states[date] != DayCellState.unregistered) return;
    final l = AppLocalizations.of(context)!;
    final mark = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: ListTile(
          minTileHeight: 56,
          leading: const Icon(Icons.do_not_disturb_on_outlined),
          title: Text(l.markNoActivity),
          onTap: () => Navigator.of(context).pop(true),
        ),
      ),
    );
    if (mark == true && mounted) await _markNoActivity(date);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final today = dateOnly(ref.watch(clockProvider)());
    final records = ref.watch(daysInRangeProvider(_range));
    final title = DateFormat.yMMMM(locale).format(DateTime.utc(_year, _month));

    return Scaffold(
      appBar: AppBar(title: Text(l.screenCalendar)),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(12),
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
                        key: const ValueKey('calendar-month'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: l.calendarNextMonth,
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () => _shift(1),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                records.when(
                  data: (list) {
                    final byDate = {for (final r in list) dateOnly(r.date): r};
                    final states = {
                      for (final date in _range.dates)
                        date: cellState(byDate[date], date, today),
                    };
                    return MonthGrid(
                      year: _year,
                      month: _month,
                      states: states,
                      today: today,
                      onTap: (date) {
                        if (states[date] == DayCellState.future) return;
                        context.push('/day/${ymd(date)}');
                      },
                      onLongPress: (date) => _onLongPress(date, states),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(l.homeLoadError, textAlign: TextAlign.center),
                  ),
                ),
                const SizedBox(height: 16),
                const _Legend(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        for (final state in DayCellState.values)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: dayStateColors(scheme, state).$1,
                  borderRadius: BorderRadius.circular(6),
                  border: state == DayCellState.future
                      ? Border.all(color: scheme.outlineVariant)
                      : null,
                ),
                child: Icon(
                  dayStateIcon(state),
                  size: 16,
                  color: dayStateColors(scheme, state).$2,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                dayStateLabel(l, state),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
      ],
    );
  }
}
