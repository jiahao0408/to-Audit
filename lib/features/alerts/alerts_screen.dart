import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/providers.dart';
import '../../domain/alerts_calc.dart';
import '../../domain/dates.dart';
import '../../l10n/app_localizations.dart';

final _alertsProvider = FutureProvider.autoDispose<List<Alert>>((ref) {
  final clock = ref.watch(clockProvider);
  return ref.watch(alertsServiceProvider).current(clock());
});

/// Alerts screen: current alerts grouped by type, with navigation.
class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).value ?? 'es';
    final alertsAsync = ref.watch(_alertsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.screenAlerts)),
      body: SafeArea(
        child: alertsAsync.when(
          data: (alerts) => alerts.isEmpty
              ? Center(child: Text(l.alertEmpty))
              : _AlertsList(alerts: alerts, locale: locale),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.homeLoadError),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () => ref.invalidate(_alertsProvider),
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

class _AlertsList extends StatelessWidget {
  const _AlertsList({required this.alerts, required this.locale});

  final List<Alert> alerts;
  final String locale;

  @override
  Widget build(BuildContext context) {
    // Group by type preserving declaration order.
    final groups = <AlertType, List<Alert>>{};
    for (final a in alerts) {
      (groups[a.type] ??= []).add(a);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final entry in groups.entries) ...[
          _SectionHeader(type: entry.key),
          for (final alert in entry.value)
            _AlertTile(alert: alert, locale: locale),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.type});

  final AlertType type;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final label = switch (type) {
      AlertType.discrepancy => l.dayCashDiff,
      AlertType.dayUnregistered => l.dayStateUnregistered,
      AlertType.dayOpen => l.dayStateOpen,
      AlertType.missingReceipt => l.expReceipts,
      AlertType.invoiceOverdue => l.expFieldDue,
      AlertType.floatMismatch => l.dayOpeningFloat,
      AlertType.backupOld => l.screenBackup,
    };
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(label, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert, required this.locale});

  final Alert alert;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final (description, actionLabel, route) = _info(l, locale);
    if (route == null) {
      return Card(
        color: scheme.errorContainer,
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: ListTile(
          leading: Icon(_icon, color: scheme.onErrorContainer),
          title: Text(
            description,
            style: TextStyle(color: scheme.onErrorContainer),
          ),
        ),
      );
    }
    return Card(
      color: scheme.errorContainer,
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        leading: Icon(_icon, color: scheme.onErrorContainer),
        title: Text(
          description,
          style: TextStyle(color: scheme.onErrorContainer),
        ),
        trailing: TextButton(
          onPressed: () => context.push(route),
          child: Text(actionLabel),
        ),
      ),
    );
  }

  IconData get _icon => switch (alert.type) {
    AlertType.discrepancy => Icons.balance_outlined,
    AlertType.dayUnregistered => Icons.event_busy_outlined,
    AlertType.dayOpen => Icons.lock_open_outlined,
    AlertType.missingReceipt => Icons.receipt_long_outlined,
    AlertType.invoiceOverdue => Icons.calendar_today_outlined,
    AlertType.floatMismatch => Icons.savings_outlined,
    AlertType.backupOld => Icons.backup_outlined,
  };

  (String, String, String?) _info(AppLocalizations l, String locale) {
    final date = alert.date;
    final dateStr = date == null ? '' : DateFormat.yMd(locale).format(date);
    final id = alert.recordId;
    return switch (alert.type) {
      AlertType.discrepancy => (
        l.alertDiscrepancy(dateStr),
        l.alertGoDay,
        date == null ? null : '/day/${ymd(date)}',
      ),
      AlertType.dayOpen => (
        l.alertDayOpen(dateStr),
        l.alertGoDay,
        date == null ? null : '/day/${ymd(date)}',
      ),
      AlertType.dayUnregistered => (
        l.alertDayUnregistered(dateStr),
        l.alertGoDay,
        date == null ? null : '/day/${ymd(date)}',
      ),
      AlertType.missingReceipt => (
        l.alertMissingReceipt,
        l.alertGoExpense,
        id == null ? null : '/expenses/$id',
      ),
      AlertType.invoiceOverdue => (
        l.alertInvoiceOverdue,
        l.alertGoExpense,
        id == null ? null : '/expenses/$id',
      ),
      AlertType.floatMismatch => (
        l.alertFloatMismatch(dateStr),
        l.alertGoDay,
        date == null ? null : '/day/${ymd(date)}',
      ),
      AlertType.backupOld => (l.alertBackupOld, l.alertGoBackup, '/backup'),
    };
  }
}
