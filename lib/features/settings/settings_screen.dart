import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/security/pin_manager.dart';
import '../../domain/money.dart';
import '../../l10n/app_localizations.dart';
import '../common/auth_gate.dart';
import '../common/money_field.dart';
import '../lock/pin_entry.dart';

final _restaurantProvider = FutureProvider<RestaurantInfo?>(
  (ref) => ref.watch(settingsRepositoryProvider).restaurant(),
);

final _localeProvider = StreamProvider<String>(
  (ref) => ref.watch(settingsRepositoryProvider).watchLocale(),
);

final _thresholdProvider = FutureProvider<Money>(
  (ref) => ref.watch(settingsRepositoryProvider).threshold(),
);

final _backupDaysProvider = FutureProvider<int>(
  (ref) => ref.watch(settingsRepositoryProvider).backupEveryDays(),
);

final _biometricsEnabledProvider = FutureProvider<bool>(
  (ref) => ref.watch(settingsRepositoryProvider).biometricsEnabled(),
);

final _biometricAvailableProvider = FutureProvider<bool>(
  (ref) => ref.watch(biometricProvider).isAvailable(),
);

/// Settings screen: restaurant info, language, threshold, backup interval,
/// PIN change, biometrics, catalog links, period close, history and backup.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.screenSettings)),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionTitle(label: l.settingsRestaurant),
                _RestaurantCard(),
                const SizedBox(height: 16),
                _SectionTitle(label: l.screenSettings),
                _LanguageTile(),
                _ThresholdTile(),
                _BackupDaysTile(),
                const Divider(),
                _SectionTitle(label: l.screenCatalogs),
                _CatalogTile(
                  label: l.settingsCatalogPayments,
                  icon: Icons.payment_outlined,
                  path: '/settings/catalogs/payment_method',
                ),
                _CatalogTile(
                  label: l.settingsCatalogCategories,
                  icon: Icons.category_outlined,
                  path: '/settings/catalogs/expense_category',
                ),
                _CatalogTile(
                  label: l.settingsCatalogWithdrawals,
                  icon: Icons.atm_outlined,
                  path: '/settings/catalogs/withdrawal_type',
                ),
                const Divider(),
                _SectionTitle(label: l.settingsMonths),
                ListTile(
                  leading: const Icon(Icons.event_available_outlined),
                  title: Text(l.settingsMonths),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/months'),
                ),
                const Divider(),
                _SectionTitle(label: l.screenBackup),
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: Text(l.screenBackup),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/backup'),
                ),
                ListTile(
                  leading: const Icon(Icons.history_outlined),
                  title: Text(l.screenHistory),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/history'),
                ),
                const Divider(),
                _SectionTitle(label: l.settingsChangePin),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: Text(l.settingsChangePin),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _changePin(context, ref),
                ),
                _BiometricsTile(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _changePin(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final authed = await requireAuth(context, ref, reason: l.settingsChangePin);
    if (!authed || !context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _NewPinDialog(),
    );
    if (!context.mounted) return;
    if (ok == true) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.settingsPinChanged)));
    } else if (ok == false) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l.settingsErrPin)));
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: Text(
      label,
      style: Theme.of(context).textTheme.titleSmall
          ?.copyWith(color: Theme.of(context).colorScheme.primary),
    ),
  );
}

class _RestaurantCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final info = ref.watch(_restaurantProvider);
    return Card(
      child: info.when(
        data: (r) => ListTile(
          leading: const Icon(Icons.store_outlined),
          title: Text(r?.name ?? ''),
          subtitle: Text(
            [
              r?.nif ?? '',
              r?.address ?? '',
            ].where((s) => s.isNotEmpty).join(' · '),
          ),
          trailing: const Icon(Icons.edit_outlined),
          onTap: () => _editRestaurant(context, ref, r),
        ),
        loading: () => const ListTile(
          leading: Icon(Icons.store_outlined),
          title: Text('…'),
        ),
        error: (_, _) => ListTile(
          leading: const Icon(Icons.store_outlined),
          title: Text(l.settingsErrSave),
          onTap: () => ref.invalidate(_restaurantProvider),
        ),
      ),
    );
  }

  Future<void> _editRestaurant(
    BuildContext context,
    WidgetRef ref,
    RestaurantInfo? current,
  ) async {
    final l = AppLocalizations.of(context)!;
    final nameCtl = TextEditingController(text: current?.name ?? '');
    final nifCtl = TextEditingController(text: current?.nif ?? '');
    final addrCtl = TextEditingController(text: current?.address ?? '');
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settingsRestaurant),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtl,
                decoration: InputDecoration(labelText: l.restaurantName),
              ),
              TextField(
                controller: nifCtl,
                decoration: InputDecoration(labelText: l.restaurantNif),
              ),
              TextField(
                controller: addrCtl,
                decoration: InputDecoration(labelText: l.restaurantAddress),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.actionSave),
          ),
        ],
      ),
    );
    if (result != true || !context.mounted) return;
    try {
      await ref
          .read(settingsRepositoryProvider)
          .setRestaurant(
            RestaurantInfo(
              name: nameCtl.text.trim(),
              nif: nifCtl.text.trim(),
              address: addrCtl.text.trim(),
            ),
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.settingsSaved)));
      }
      ref.invalidate(_restaurantProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.settingsErrSave)));
      }
    }
    nameCtl.dispose();
    nifCtl.dispose();
    addrCtl.dispose();
  }
}

class _LanguageTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final locale = ref.watch(_localeProvider).value ?? 'es';
    return ListTile(
      leading: const Icon(Icons.language_outlined),
      title: Text(l.settingsLanguage),
      subtitle: Text(switch (locale) {
        'es' => l.languageEs,
        'zh' => l.languageZh,
        _ => locale,
      }),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _chooseLanguage(context, ref, locale),
    );
  }

  Future<void> _chooseLanguage(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final l = AppLocalizations.of(context)!;
    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l.settingsLanguage),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(ctx).pop('es'),
            child: Row(
              children: [
                Icon(
                  current == 'es'
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                const SizedBox(width: 8),
                Text(l.languageEs),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(ctx).pop('zh'),
            child: Row(
              children: [
                Icon(
                  current == 'zh'
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                ),
                const SizedBox(width: 8),
                Text(l.languageZh),
              ],
            ),
          ),
        ],
      ),
    );
    if (chosen == null || chosen == current || !context.mounted) return;
    try {
      await ref.read(settingsRepositoryProvider).setLocale(chosen);
      ref.invalidate(_localeProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.settingsErrSave)));
      }
    }
  }
}

class _ThresholdTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).value ?? 'es';
    final threshold = ref.watch(_thresholdProvider);
    return ListTile(
      leading: const Icon(Icons.balance_outlined),
      title: Text(l.settingsThreshold),
      subtitle: threshold.when(
        data: (m) => Text(m.format(locale)),
        loading: () => const Text('…'),
        error: (_, _) => const Text('—'),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _editThreshold(context, ref),
    );
  }

  Future<void> _editThreshold(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final current = await ref.read(settingsRepositoryProvider).threshold();
    if (!context.mounted) return;
    final ctl = TextEditingController(text: MoneyField.text(current));
    Money? picked = current;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settingsThreshold),
        content: MoneyField(
          controller: ctl,
          label: l.settingsThreshold,
          onChanged: (v) => picked = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.actionSave),
          ),
        ],
      ),
    );
    if (result != true || !context.mounted) return;
    try {
      final value = picked;
      if (value == null) throw const FormatException();
      await ref.read(settingsRepositoryProvider).setThreshold(value);
      ref.invalidate(_thresholdProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.settingsSaved)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.settingsErrSave)));
      }
    }
    ctl.dispose();
  }
}

class _BackupDaysTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final days = ref.watch(_backupDaysProvider);
    return ListTile(
      leading: const Icon(Icons.schedule_outlined),
      title: Text(l.settingsBackupEvery),
      subtitle: days.when(
        data: (d) => Text('$d'),
        loading: () => const Text('…'),
        error: (_, _) => const Text('—'),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _editDays(context, ref),
    );
  }

  Future<void> _editDays(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final current = await ref
        .read(settingsRepositoryProvider)
        .backupEveryDays();
    if (!context.mounted) return;
    final ctl = TextEditingController(text: current.toString());
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.settingsBackupEvery),
        content: TextField(
          controller: ctl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: l.settingsBackupEvery),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.actionSave),
          ),
        ],
      ),
    );
    if (result != true || !context.mounted) return;
    final n = int.tryParse(ctl.text.trim());
    if (n == null || n < 1 || n > 60) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.settingsErrSave)));
      }
      ctl.dispose();
      return;
    }
    try {
      await ref.read(settingsRepositoryProvider).setBackupEveryDays(n);
      ref.invalidate(_backupDaysProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.settingsSaved)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.settingsErrSave)));
      }
    }
    ctl.dispose();
  }
}

class _CatalogTile extends StatelessWidget {
  const _CatalogTile({
    required this.label,
    required this.icon,
    required this.path,
  });

  final String label;
  final IconData icon;
  final String path;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(label),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => context.push(path),
  );
}

class _BiometricsTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final enabled = ref.watch(_biometricsEnabledProvider).value ?? false;
    final available = ref.watch(_biometricAvailableProvider).value ?? false;
    if (!available) return const SizedBox.shrink();
    return SwitchListTile(
      secondary: const Icon(Icons.fingerprint_outlined),
      title: Text(l.settingsBiometrics),
      value: enabled && available,
      onChanged: available ? (v) => _toggle(context, ref, v) : null,
      subtitle: !available ? Text(l.settingsBiometricsNotAvailable) : null,
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref, bool enable) async {
    final l = AppLocalizations.of(context)!;
    try {
      await ref.read(settingsRepositoryProvider).setBiometricsEnabled(enable);
      ref.invalidate(_biometricsEnabledProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.settingsSaved)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l.settingsErrSave)));
      }
    }
  }
}

class _NewPinDialog extends ConsumerStatefulWidget {
  const _NewPinDialog();

  @override
  ConsumerState<_NewPinDialog> createState() => _NewPinDialogState();
}

class _NewPinDialogState extends ConsumerState<_NewPinDialog> {
  bool _confirming = false;
  String? _firstPin;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final pinManager = ref.watch(pinManagerProvider);
    return AlertDialog(
      title: Text(l.settingsChangePin),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_confirming ? l.onbPinConfirmLabel : l.onbPinCreateLabel),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            PinEntry(
              clock: ref.read(clockProvider),
              verify: (pin) async {
                if (!_confirming) {
                  _firstPin = pin;
                  setState(() {
                    _confirming = true;
                    _error = null;
                  });
                  return const PinOk();
                }
                if (pin != _firstPin) {
                  setState(() {
                    _confirming = false;
                    _firstPin = null;
                    _error = l.onbPinMismatch;
                  });
                  return const PinWrong(2);
                }
                try {
                  await pinManager.setPin(pin);
                  if (!mounted) return const PinOk();
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop(true);
                  return const PinOk();
                } catch (_) {
                  if (mounted) {
                    setState(() => _error = l.settingsErrPin);
                    _confirming = false;
                    _firstPin = null;
                  }
                  return const PinWrong(1);
                }
              },
              onSuccess: () {},
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.actionCancel),
        ),
      ],
    );
  }
}
