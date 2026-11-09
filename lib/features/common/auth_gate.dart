import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../lock/pin_entry.dart';

/// Asks the owner to confirm a sensitive action ([reason] is shown to them).
///
/// Uses the biometrics when they are enabled and available; if that is not
/// possible, or it fails or is cancelled, falls back to the PIN. Returns true
/// only when one of them succeeded.
Future<bool> requireAuth(
  BuildContext context,
  WidgetRef ref, {
  required String reason,
}) async {
  final settings = ref.read(settingsRepositoryProvider);
  final biometrics = ref.read(biometricProvider);
  if (await settings.biometricsEnabled() && await biometrics.isAvailable()) {
    if (await biometrics.authenticate(reason)) return true;
  }
  if (!context.mounted) return false;
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _PinDialog(reason: reason),
  );
  return ok ?? false;
}

class _PinDialog extends ConsumerWidget {
  const _PinDialog({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final pins = ref.watch(pinManagerProvider);
    return AlertDialog(
      title: Text(l.authPinTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(reason, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            PinEntry(
              clock: ref.read(clockProvider),
              verify: pins.verify,
              onSuccess: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l.actionCancel),
        ),
      ],
    );
  }
}
