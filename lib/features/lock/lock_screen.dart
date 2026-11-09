import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import 'app_lock_controller.dart';
import 'pin_entry.dart';

/// Whether a PIN exists. The lock only applies once one has been created
/// (the first-run onboarding creates it).
final hasPinProvider = FutureProvider<bool>(
  (ref) => ref.watch(pinManagerProvider).hasPin(),
);

/// PIN pad, with a biometric button when it is enabled and available.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  bool _biometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final enabled = await ref
        .read(settingsRepositoryProvider)
        .biometricsEnabled();
    final available =
        enabled && await ref.read(biometricProvider).isAvailable();
    if (!mounted || !available) return;
    setState(() => _biometrics = true);
    await _askBiometrics();
  }

  Future<void> _askBiometrics() async {
    final reason = AppLocalizations.of(context)!.biometricReason;
    final ok = await ref.read(biometricProvider).authenticate(reason);
    if (ok && mounted) ref.read(appLockProvider.notifier).unlock();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final pins = ref.watch(pinManagerProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l.lockTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                PinEntry(
                  clock: ref.read(clockProvider),
                  verify: pins.verify,
                  onSuccess: () => ref.read(appLockProvider.notifier).unlock(),
                  extraAction: _biometrics
                      ? Semantics(
                          label: l.pinUseBiometrics,
                          button: true,
                          excludeSemantics: true,
                          child: IconButton(
                            key: const ValueKey('lock-biometric'),
                            onPressed: _askBiometrics,
                            icon: const Icon(Icons.fingerprint, size: 32),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
