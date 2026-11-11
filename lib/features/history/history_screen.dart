import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

final _historyProvider = StreamProvider<List<ChangeLogData>>(
  (ref) => ref.watch(historyRepositoryProvider).watchAll(),
);

/// History screen: latest changes across all records, newest first.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).value ?? 'es';
    final historyAsync = ref.watch(_historyProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.screenHistory)),
      body: SafeArea(
        child: historyAsync.when(
          data: (rows) => rows.isEmpty
              ? Center(child: Text(l.historyEmpty))
              : ListView.separated(
                  padding: const EdgeInsets.all(8),
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) =>
                      _HistoryTile(row: rows[i], locale: locale),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.historyErrLoad),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => ref.invalidate(_historyProvider),
                  child: Text(l.actionRetry),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.row, required this.locale});

  final ChangeLogData row;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final at = DateTime.tryParse(row.at)?.toLocal();
    final timeStr = at == null
        ? row.at
        : DateFormat.yMd(locale).add_Hm().format(at);

    final old = row.oldValue;
    final next = row.newValue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${row.entity} · ${row.field}',
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(timeStr, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (old != null) ...[
                Expanded(
                  child: _ValueChip(
                    label: l.historyOldValue,
                    value: old,
                    strikethrough: true,
                    color: theme.colorScheme.errorContainer,
                    onColor: theme.colorScheme.onErrorContainer,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (next != null)
                Expanded(
                  child: _ValueChip(
                    label: l.historyNewValue,
                    value: next,
                    color: theme.colorScheme.primaryContainer,
                    onColor: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
            ],
          ),
          if (row.reason != null) ...[
            const SizedBox(height: 4),
            Text(
              row.reason!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ValueChip extends StatelessWidget {
  const _ValueChip({
    required this.label,
    required this.value,
    required this.color,
    required this.onColor,
    this.strikethrough = false,
  });

  final String label;
  final String value;
  final Color color;
  final Color onColor;
  final bool strikethrough;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: onColor)),
          Text(
            value,
            style: TextStyle(
              color: onColor,
              decoration: strikethrough ? TextDecoration.lineThrough : null,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
