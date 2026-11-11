import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../data/repositories/periods_repository.dart';
import '../../domain/dates.dart';
import '../../domain/enums.dart';
import '../../l10n/app_localizations.dart';
import '../common/auth_gate.dart';
import '../common/confirm_reason_dialog.dart';

/// A month entry: the key and its status.
class _MonthEntry {
  const _MonthEntry({required this.key, required this.status});

  final String key;
  final PeriodStatus? status; // null = open/never closed
}

final _monthsProvider = StreamProvider<List<_MonthEntry>>((ref) {
  final db = ref.watch(databaseProvider);
  return _combineMonths(db);
});

Stream<List<_MonthEntry>> _combineMonths(AppDatabase db) {
  return db
      .customSelect(
        'SELECT DISTINCT substr(date,1,7) AS month FROM dia_caja ORDER BY month DESC',
        readsFrom: {db.days, db.periods},
      )
      .watch()
      .asyncMap((rows) async {
        final months = rows.map((r) => r.read<String>('month')).toList();
        final periods = await (db.select(
          db.periods,
        )..where((p) => p.month.isIn(months))).get();
        final byKey = {for (final p in periods) p.month: p.status};
        return [for (final m in months) _MonthEntry(key: m, status: byKey[m])];
      });
}

/// Months screen: list months with activity, close/reopen each.
class MonthsScreen extends ConsumerWidget {
  const MonthsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).value ?? 'es';
    final monthsAsync = ref.watch(_monthsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsMonths)),
      body: SafeArea(
        child: monthsAsync.when(
          data: (months) => months.isEmpty
              ? Center(child: Text(l.monthsEmpty))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: months.length,
                  itemBuilder: (ctx, i) =>
                      _MonthTile(entry: months[i], locale: locale),
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.monthsErrSave),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => ref.invalidate(_monthsProvider),
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

class _MonthTile extends ConsumerWidget {
  const _MonthTile({required this.entry, required this.locale});

  final _MonthEntry entry;
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final closed = entry.status == PeriodStatus.closed;

    // Parse month key for a human-readable label.
    final dt = DateTime.utc(
      int.parse(entry.key.substring(0, 4)),
      int.parse(entry.key.substring(5, 7)),
    );
    final label = DateFormat.yMMMM(locale).format(dt);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Icon(
          closed ? Icons.lock_outline : Icons.lock_open_outlined,
          color: closed
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
        ),
        title: Text(label),
        subtitle: Text(closed ? l.monthsStatusClosed : l.monthsStatusOpen),
        trailing: closed
            ? OutlinedButton(
                onPressed: () => _reopen(context, ref),
                child: Text(l.monthsReopen),
              )
            : FilledButton(
                onPressed: () => _close(context, ref),
                child: Text(l.monthsClose),
              ),
      ),
    );
  }

  Future<void> _close(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final today = ref.read(clockProvider)();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.monthsCloseConfirmTitle),
        content: Text(
          entry.key == monthKey(today)
              ? '${l.monthsCloseConfirmBody}\n\n${l.monthsCloseConfirmCurrent}'
              : l.monthsCloseConfirmBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.monthsClose),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref
          .read(periodsRepositoryProvider)
          .closeMonth(entry.key, today: today);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.monthsStatusClosed)));
      }
    } on MonthNotReadyException catch (e) {
      if (!context.mounted) return;
      final locale = ref.read(localeProvider).value ?? 'es';
      final dates = e.pendingDates
          .map((d) => DateFormat.MMMd(locale).format(d))
          .join(', ');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.monthsErrNotReady(dates))));
    } on StateError {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.monthsErrAlreadyClosed)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.monthsErrSave)));
      }
    }
  }

  Future<void> _reopen(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final authed = await requireAuth(context, ref, reason: l.monthsReopen);
    if (!authed || !context.mounted) return;
    final reason = await askReason(context, title: l.monthsReopenReasonTitle);
    if (reason == null || !context.mounted) return;
    try {
      await ref.read(periodsRepositoryProvider).reopenMonth(entry.key, reason);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.monthsStatusOpen)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.monthsErrSave)));
      }
    }
  }
}
