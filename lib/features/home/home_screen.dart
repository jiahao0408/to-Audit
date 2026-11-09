import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/providers.dart';
import '../../data/reports/report_service.dart';
import '../../domain/alerts_calc.dart';
import '../../domain/dates.dart';
import '../../l10n/app_localizations.dart';
import '../lock/app_lock_controller.dart';
import '../lock/lock_screen.dart' show hasPinProvider;

/// Month sales and profit for the home screen, for the clock day [today].
final homeSummaryProvider = FutureProvider.family<HomeSummary, DateTime>(
  (ref, today) => ref.watch(reportServiceProvider).home(today),
);

/// The alerts that apply on [today].
final homeAlertsProvider = FutureProvider.family<List<Alert>, DateTime>(
  (ref, today) => ref.watch(alertsServiceProvider).current(today),
);

/// When the last backup was made (local time) and how often to remind.
final backupStatusProvider =
    FutureProvider<({DateTime? lastBackup, int everyDays})>((ref) async {
      final settings = ref.watch(settingsRepositoryProvider);
      return (
        lastBackup: (await settings.lastBackupAt())?.toLocal(),
        everyDays: await settings.backupEveryDays(),
      );
    });

/// Whether the "backup pending" dialog was already handled in this run of the
/// app, so it shows at most once per app open.
class BackupWarningShown extends Notifier<bool> {
  @override
  bool build() => false;

  void mark() => state = true;
}

final backupWarningShownProvider = NotifierProvider<BackupWarningShown, bool>(
  BackupWarningShown.new,
);

/// Home (spec 6.6): month sales, profit to date, the next pending day, the
/// alert counter, the backup reminder and shortcuts.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _warnAboutBackup());
  }

  bool _warningPending = false;

  /// Decides whether the "backup pending" dialog applies, then shows it as
  /// soon as the app is unlocked. It counts as handled for this run once it
  /// is shown, or once it is known that it does not apply.
  Future<void> _warnAboutBackup() async {
    if (!mounted || _warningPending || ref.read(backupWarningShownProvider)) {
      return;
    }
    final last = (await ref.read(settingsRepositoryProvider).lastBackupAt())
        ?.toLocal();
    final now = ref.read(clockProvider)();
    final applies =
        backupWarningOnOpen(lastBackup: last, now: now) &&
        await ref.read(daysRepositoryProvider).hasAnyDay();
    if (!mounted) return;
    if (!applies) {
      ref.read(backupWarningShownProvider.notifier).mark();
      return;
    }
    _warningPending = true;
    await _showWarningIfUnlocked();
  }

  Future<void> _showWarningIfUnlocked() async {
    if (!_warningPending || !mounted) return;
    final hasPin = await ref.read(hasPinProvider.future);
    if (!mounted || !_warningPending) return;
    if (hasPin && ref.read(appLockProvider)) return;
    _warningPending = false;
    ref.read(backupWarningShownProvider.notifier).mark();
    final l = AppLocalizations.of(context)!;
    final backupNow = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.homeBackupDialogTitle),
        content: Text(l.homeBackupDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.homeBackupDialogLater),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.homeBackupDialogNow),
          ),
        ],
      ),
    );
    if (backupNow == true && mounted) await _open('/backup');
  }

  /// Opens [path] and refreshes the figures when the user comes back.
  Future<void> _open(String path) async {
    await context.push(path);
    if (!mounted) return;
    ref.invalidate(homeSummaryProvider);
    ref.invalidate(homeAlertsProvider);
    ref.invalidate(backupStatusProvider);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(appLockProvider, (_, locked) {
      if (!locked) _showWarningIfUnlocked();
    });
    final l = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).value ?? 'es';
    final now = ref.watch(clockProvider)();
    final today = dateOnly(now);
    final summary = ref.watch(homeSummaryProvider(today));
    final alerts = ref.watch(homeAlertsProvider(today));
    final backup = ref.watch(backupStatusProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.screenHome),
        actions: [
          IconButton(
            tooltip: l.screenSettings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _open('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (backup != null &&
                    backupReminderDue(
                      lastBackup: backup.lastBackup,
                      now: now,
                      everyDays: backup.everyDays,
                    ))
                  _BackupBanner(
                    lastBackup: backup.lastBackup,
                    now: now,
                    onTap: () => _open('/backup'),
                  ),
                summary.when(
                  data: (s) => _Summary(
                    summary: s,
                    locale: locale,
                    onRegister: s.nextPending == null
                        ? null
                        : () => _open('/day/${ymd(s.nextPending!)}'),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => _LoadError(
                    onRetry: () => ref.invalidate(homeSummaryProvider),
                  ),
                ),
                const SizedBox(height: 8),
                _AlertsTile(
                  count: alerts.value?.length,
                  onTap: () => _open('/alerts'),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      _Shortcut(
                        icon: Icons.calendar_month_outlined,
                        label: l.screenCalendar,
                        onTap: () => _open('/calendar'),
                      ),
                      _Shortcut(
                        icon: Icons.receipt_long_outlined,
                        label: l.screenExpenses,
                        onTap: () => _open('/expenses'),
                      ),
                      _Shortcut(
                        icon: Icons.bar_chart_outlined,
                        label: l.screenReports,
                        onTap: () => _open('/reports'),
                      ),
                      _Shortcut(
                        icon: Icons.settings_outlined,
                        label: l.screenSettings,
                        onTap: () => _open('/settings'),
                      ),
                    ],
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

class _Summary extends StatelessWidget {
  const _Summary({
    required this.summary,
    required this.locale,
    required this.onRegister,
  });

  final HomeSummary summary;
  final String locale;
  final VoidCallback? onRegister;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final closed = summary.lastClosedDay;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MetricCard(
          title: l.homeMonthSales,
          value: summary.monthSales.format(locale),
        ),
        const SizedBox(height: 8),
        _MetricCard(
          title: l.homeProfit,
          value: summary.profitToDate.format(locale),
          caption: closed == null
              ? l.homeProfitNone
              : l.homeProfitUntil(DateFormat.MMMd(locale).format(closed)),
        ),
        const SizedBox(height: 16),
        if (onRegister != null)
          FilledButton.icon(
            onPressed: onRegister,
            icon: const Icon(Icons.edit_note),
            label: Text(l.homeRegisterNext),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Flexible(child: Text(l.homeAllUpToDate)),
            ],
          ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, this.caption});

  final String title;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.headlineMedium),
            if (caption != null) ...[
              const SizedBox(height: 4),
              Text(caption!, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _AlertsTile extends StatelessWidget {
  const _AlertsTile({required this.count, required this.onTap});

  /// Null while the alerts are being computed.
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final any = (count ?? 0) > 0;
    return Card(
      color: any ? scheme.errorContainer : null,
      child: ListTile(
        minTileHeight: 56,
        leading: Icon(
          any ? Icons.notifications_active_outlined : Icons.notifications_none,
          color: any ? scheme.onErrorContainer : null,
        ),
        title: Text(
          count == null ? l.screenAlerts : l.homeAlertsCount(count!),
          style: any ? TextStyle(color: scheme.onErrorContainer) : null,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _BackupBanner extends StatelessWidget {
  const _BackupBanner({
    required this.lastBackup,
    required this.now,
    required this.onTap,
  });

  final DateTime? lastBackup;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final last = lastBackup;
    final text = last == null
        ? l.homeBackupBannerNever
        : l.homeBackupBannerDays(
            dateOnly(now).difference(dateOnly(last)).inDays,
          );
    return Card(
      color: scheme.tertiaryContainer,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Icon(Icons.backup_outlined, color: scheme.onTertiaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: scheme.onTertiaryContainer),
              ),
            ),
            TextButton(onPressed: onTap, child: Text(l.homeBackupAction)),
          ],
        ),
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    minTileHeight: 56,
    leading: Icon(icon),
    title: Text(label),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(l.homeLoadError, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onRetry, child: Text(l.actionRetry)),
        ],
      ),
    );
  }
}
