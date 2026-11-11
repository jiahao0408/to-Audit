import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/dates.dart';
import '../../l10n/app_localizations.dart';

enum PeriodKind { today, week, month, lastMonth, custom }

/// A chosen period: [kind], plus the dates for [PeriodKind.custom].
class PeriodSelection {
  const PeriodSelection(this.kind, {this.from, this.to});

  final PeriodKind kind;
  final DateTime? from;
  final DateTime? to;

  /// The dates of this period as seen on [now].
  DateRange range(DateTime now) {
    final today = dateOnly(now);
    switch (kind) {
      case PeriodKind.today:
        return rangeToday(today);
      case PeriodKind.week:
        return rangeThisWeek(today);
      case PeriodKind.month:
        return rangeThisMonth(today);
      case PeriodKind.lastMonth:
        return rangeMonth(monthKey(DateTime.utc(today.year, today.month - 1)));
      case PeriodKind.custom:
        return rangeCustom(from ?? today, to ?? today);
    }
  }
}

/// Chips for today / week / month / (last month) / custom range, and the
/// dates of the chosen period underneath.
class PeriodPicker extends StatelessWidget {
  const PeriodPicker({
    super.key,
    required this.selection,
    required this.now,
    required this.onChanged,
    this.withLastMonth = false,
  });

  final PeriodSelection selection;
  final DateTime now;
  final ValueChanged<PeriodSelection> onChanged;
  final bool withLastMonth;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final range = selection.range(now);
    final fmt = DateFormat.yMd(locale);
    final label = range.start == range.end
        ? DateFormat.yMMMMd(locale).format(range.start)
        : '${fmt.format(range.start)} – ${fmt.format(range.end)}';
    final kinds = [
      (PeriodKind.today, l.periodToday),
      (PeriodKind.week, l.withdrawalsPeriodWeek),
      (PeriodKind.month, l.withdrawalsPeriodMonth),
      if (withLastMonth) (PeriodKind.lastMonth, l.reportPeriodLastMonth),
      (PeriodKind.custom, l.periodCustom),
    ];
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            alignment: WrapAlignment.center,
            children: [
              for (final (kind, text) in kinds)
                ChoiceChip(
                  label: Text(text),
                  selected: selection.kind == kind,
                  onSelected: (_) async {
                    if (kind != PeriodKind.custom) {
                      onChanged(PeriodSelection(kind));
                      return;
                    }
                    final today = dateOnly(now);
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(today.year + 1, 12, 31),
                      initialDateRange: DateTimeRange(
                        start: range.start,
                        end: range.end,
                      ),
                    );
                    if (picked != null) {
                      onChanged(
                        PeriodSelection(
                          PeriodKind.custom,
                          from: picked.start,
                          to: picked.end,
                        ),
                      );
                    }
                  },
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
