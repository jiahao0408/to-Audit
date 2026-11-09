import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/days_repository.dart';
import '../../domain/dates.dart';
import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';

/// What a calendar cell shows about its day.
enum DayCellState {
  unregistered,
  open,
  balanced,
  discrepancy,
  noActivity,
  future,
}

/// The state of the day [date] given its record [d] (null when there is
/// none) and today's date. A day after [today] with no record is `future`;
/// a closed day is `balanced` only when both stored differences are zero.
DayCellState cellState(DayRecord? d, DateTime date, DateTime today) {
  if (d == null) {
    return dateOnly(date).isAfter(dateOnly(today))
        ? DayCellState.future
        : DayCellState.unregistered;
  }
  return switch (d.status) {
    DayStatus.open => DayCellState.open,
    DayStatus.noActivity => DayCellState.noActivity,
    DayStatus.closed =>
      (d.cashDiff?.isZero ?? true) && (d.cardDiff?.isZero ?? true)
          ? DayCellState.balanced
          : DayCellState.discrepancy,
  };
}

/// Icon that tells the state apart without relying on color.
IconData dayStateIcon(DayCellState state) => switch (state) {
  DayCellState.unregistered => Icons.edit_calendar_outlined,
  DayCellState.open => Icons.timelapse,
  DayCellState.balanced => Icons.check_circle_outline,
  DayCellState.discrepancy => Icons.warning_amber_rounded,
  DayCellState.noActivity => Icons.do_not_disturb_on_outlined,
  DayCellState.future => Icons.schedule,
};

/// Text name of the state.
String dayStateLabel(AppLocalizations l, DayCellState state) => switch (state) {
  DayCellState.unregistered => l.dayStateUnregistered,
  DayCellState.open => l.dayStateOpen,
  DayCellState.balanced => l.dayStateBalanced,
  DayCellState.discrepancy => l.dayStateDiscrepancy,
  DayCellState.noActivity => l.dayStateNoActivity,
  DayCellState.future => l.dayStateFuture,
};

/// Fill and foreground colors of a state in the current theme.
(Color?, Color) dayStateColors(
  ColorScheme scheme,
  DayCellState state,
) => switch (state) {
  DayCellState.unregistered => (
    scheme.secondaryContainer,
    scheme.onSecondaryContainer,
  ),
  DayCellState.open => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
  DayCellState.balanced => (scheme.primaryContainer, scheme.onPrimaryContainer),
  DayCellState.discrepancy => (scheme.errorContainer, scheme.onErrorContainer),
  DayCellState.noActivity => (
    scheme.surfaceContainerHighest,
    scheme.onSurfaceVariant,
  ),
  DayCellState.future => (null, scheme.outline),
};

/// One month as a Monday-to-Sunday grid. Each day shows its number and an
/// icon for its state (color is not the only signal), and has a spoken label.
///
/// [states] is keyed by UTC-midnight dates; a day with no entry counts as
/// unregistered. [today], when given, gets an outline.
class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.year,
    required this.month,
    required this.states,
    required this.onTap,
    required this.onLongPress,
    this.today,
  });

  final int year;
  final int month;
  final Map<DateTime, DayCellState> states;
  final void Function(DateTime) onTap;
  final void Function(DateTime) onLongPress;
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final scheme = Theme.of(context).colorScheme;
    final weekday = DateFormat.E(locale);
    final dateFormat = DateFormat.MMMMEEEEd(locale);
    final leading = DateTime.utc(year, month, 1).weekday - DateTime.monday;
    final total = daysInMonth(year, month);
    final rows = ((leading + total) / 7).ceil();
    final todayDate = today == null ? null : dateOnly(today!);

    Widget header(int i) => Expanded(
      key: ValueKey('weekday-$i'),
      // 2 November 2026 is a Monday.
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            weekday.format(DateTime.utc(2026, 11, 2 + i)),
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ),
    );

    Widget cell(int index) {
      final dayNumber = index - leading + 1;
      if (dayNumber < 1 || dayNumber > total) {
        return Expanded(
          child: SizedBox(
            key: index < leading ? ValueKey('empty-$index') : null,
            height: 64,
          ),
        );
      }
      final date = DateTime.utc(year, month, dayNumber);
      final state = states[date] ?? DayCellState.unregistered;
      final (fill, onFill) = dayStateColors(scheme, state);
      final isToday = date == todayDate;
      final stateName = dayStateLabel(l, state);
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Semantics(
            button: true,
            label: l.dayCellLabel(dateFormat.format(date), stateName),
            excludeSemantics: true,
            onTap: () => onTap(date),
            onLongPress: () => onLongPress(date),
            child: Material(
              key: ValueKey('day-${ymd(date)}'),
              color: fill ?? Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: isToday
                    ? BorderSide(color: scheme.primary, width: 2)
                    : state == DayCellState.future
                    ? BorderSide(color: scheme.outlineVariant)
                    : BorderSide.none,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => onTap(date),
                onLongPress: () => onLongPress(date),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 60),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$dayNumber',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: onFill,
                                fontWeight: isToday ? FontWeight.bold : null,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Icon(dayStateIcon(state), size: 18, color: onFill),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [for (var i = 0; i < 7; i++) header(i)]),
        for (var r = 0; r < rows; r++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [for (var c = 0; c < 7; c++) cell(r * 7 + c)],
            ),
          ),
      ],
    );
  }
}
