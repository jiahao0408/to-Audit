import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../data/backup/backup_service.dart';
import '../../data/backup/offline_restore.dart';
import '../../data/backup/restore_recovery.dart';
import '../../data/backup/toaudit_format.dart';
import '../../data/db/app_database.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../common/platform_services.dart';

/// Backup screen: create an encrypted copy and share it, or restore one.
///
/// With [standalone] (the start-up error screen) there is no open database:
/// only the restore part is offered and it goes through
/// [applyPreviewWithoutOpenDb]; afterwards the user must reopen the app.
///
/// The slow part of an export or an inspect is the PBKDF2 key derivation; it
/// runs in a separate isolate ([keyDeriverProvider]). The database work and
/// the AES blocks stay on the main isolate (an open drift connection cannot be
/// sent to another isolate) behind an inline progress indicator.
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key, this.standalone = false});

  final bool standalone;

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  final _passCtl = TextEditingController();
  final _confirmCtl = TextEditingController();
  bool _obscure = true;
  bool _creating = false;

  BackupPreview? _preview;
  bool _inspecting = false;
  bool _restoring = false;

  @override
  void dispose() {
    _passCtl.dispose();
    _confirmCtl.dispose();
    _discardPreview();
    super.dispose();
  }

  /// Deletes the decrypted copy of a backup the user did not restore.
  void _discardPreview() {
    final preview = _preview;
    _preview = null;
    if (preview != null) {
      preview.decryptedDir.delete(recursive: true).ignore();
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  String? _passwordError(AppLocalizations l) {
    final pass = _passCtl.text;
    if (pass.isNotEmpty && pass.length < BackupService.minPasswordLength) {
      return l.backupPasswordTooShort;
    }
    return null;
  }

  String? _confirmError(AppLocalizations l) {
    final confirm = _confirmCtl.text;
    if (confirm.isNotEmpty && confirm != _passCtl.text) {
      return l.backupPasswordMismatch;
    }
    return null;
  }

  bool get _canCreate =>
      _passCtl.text.length >= BackupService.minPasswordLength &&
      _passCtl.text == _confirmCtl.text;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final busy = _creating || _inspecting || _restoring;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.standalone ? l.restoreBackupButton : l.screenBackup),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (!widget.standalone) ...[
                  _SectionTitle(label: l.backupSectionCreate),
                  Card(child: _createCard(l, busy)),
                  const SizedBox(height: 24),
                ],
                _SectionTitle(label: l.backupSectionRestore),
                Card(child: _restoreCard(l, busy)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createCard(AppLocalizations l, bool busy) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.backupPasswordWarning,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('backup-pass'),
            controller: _passCtl,
            obscureText: _obscure,
            enabled: !busy,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l.backupPasswordLabel,
              errorText: _passwordError(l),
              suffixIcon: IconButton(
                tooltip: l.backupPasswordLabel,
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('backup-pass-confirm'),
            controller: _confirmCtl,
            obscureText: _obscure,
            enabled: !busy,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: l.backupPasswordConfirm,
              errorText: _confirmError(l),
            ),
          ),
          const SizedBox(height: 16),
          if (_creating)
            const Center(child: CircularProgressIndicator())
          else
            FilledButton.icon(
              onPressed: _canCreate && !busy ? _create : null,
              icon: const Icon(Icons.backup_outlined),
              label: Text(l.backupCreateButton),
            ),
        ],
      ),
    );
  }

  Widget _restoreCard(AppLocalizations l, bool busy) {
    final preview = _preview;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_inspecting) ...[
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 8),
            Text(l.backupInspecting, textAlign: TextAlign.center),
          ] else if (_restoring) ...[
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 8),
            Text(l.backupRestoring, textAlign: TextAlign.center),
          ] else if (preview == null)
            OutlinedButton.icon(
              onPressed: busy ? null : _pickAndInspect,
              icon: const Icon(Icons.folder_open_outlined),
              label: Text(l.backupPickFile),
            )
          else ...[
            _PreviewCard(preview: preview),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(_discardPreview),
                    child: Text(l.backupCancelDelete),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _restore,
                    icon: const Icon(Icons.restore_outlined),
                    label: Text(l.backupRestoreButton),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _create() async {
    final l = AppLocalizations.of(context)!;
    final pass = _passCtl.text;
    setState(() => _creating = true);
    File? file;
    try {
      final now = ref.read(clockProvider)();
      file = await ref
          .read(backupServiceProvider)
          .export(pass, now: now, record: false);
      final shared = await ref.read(fileSharerProvider).shareFile(file);
      // A dismissed share sheet is not a backup: no success, no reminder reset.
      if (shared) {
        await ref.read(settingsRepositoryProvider).setLastBackupAt(now);
        if (mounted) {
          _passCtl.clear();
          _confirmCtl.clear();
          _snack(l.backupCreated);
        }
      }
    } catch (_) {
      _snack(l.backupErrCreate);
    } finally {
      // The copy leaves the phone through the share sheet only.
      try {
        if (file != null && await file.exists()) await file.delete();
      } catch (_) {}
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _pickAndInspect() async {
    final l = AppLocalizations.of(context)!;
    final picked = await ref.read(backupFilePickerProvider).pick();
    if (picked == null) return;
    if (p.extension(picked.path).toLowerCase() != '.toaudit') {
      _snack(l.backupErrNotToaudit);
      return;
    }
    if (!mounted) return;
    final password = await _askPassword();
    if (password == null || password.isEmpty || !mounted) return;

    setState(() => _inspecting = true);
    try {
      final BackupPreview preview;
      if (widget.standalone) {
        preview = await BackupService.inspectFile(
          picked,
          password,
          tempRoot: ref.read(tempRootProvider),
          currentSchemaVersion: AppDatabase.currentSchemaVersion,
          deriveKey: ref.read(keyDeriverProvider),
        );
      } else {
        preview = await ref
            .read(backupServiceProvider)
            .inspect(picked, password);
      }
      if (!mounted) {
        preview.decryptedDir.delete(recursive: true).ignore();
        return;
      }
      setState(() => _preview = preview);
    } on BackupDecryptException {
      _snack(l.backupErrDecrypt);
    } on BackupTooNewException {
      _snack(l.backupErrTooNew);
    } catch (_) {
      _snack(l.backupErrInspect);
    } finally {
      if (mounted) setState(() => _inspecting = false);
    }
  }

  Future<String?> _askPassword() async {
    final l = AppLocalizations.of(context)!;
    final ctl = TextEditingController();
    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.backupPasswordDialogTitle),
        content: TextField(
          key: const ValueKey('backup-restore-pass'),
          controller: ctl,
          obscureText: true,
          autofocus: true,
          decoration: InputDecoration(labelText: l.backupPasswordLabel),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(ctl.text),
            child: Text(l.actionContinue),
          ),
        ],
      ),
    );
    return result;
  }

  Future<void> _restore() async {
    final l = AppLocalizations.of(context)!;
    final preview = _preview;
    if (preview == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.backupRestoreButton),
        content: Text(l.backupRestoreConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            key: const ValueKey('backup-restore-confirm'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.backupRestoreButton),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    // Ownership of the decrypted folder passes to the restore, which deletes
    // it whatever the outcome.
    setState(() {
      _restoring = true;
      _preview = null;
    });
    // Read before the restore: it replaces the providers' state.
    final router = widget.standalone ? null : GoRouter.maybeOf(context);
    try {
      if (widget.standalone) {
        await applyPreviewWithoutOpenDb(
          preview: preview,
          dbFile: File(
            p.join(ref.read(documentsDirProvider).path, databaseFileName),
          ),
          filesRoot: ref.read(documentsDirProvider),
          keys: ref.read(dbKeyManagerProvider),
        );
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Text(l.backupRestoredTitle),
            content: Text(l.backupRestoredBody),
          ),
        );
      } else {
        await ref.read(backupServiceProvider).restore(preview);
        _snack(l.backupRestoredInApp);
        router?.go('/');
      }
    } on BackupVerifyException {
      _snack(l.backupErrVerify);
    } on RestoreNeedsRestartException {
      _snack(l.backupErrRestart);
    } catch (_) {
      _snack(l.backupErrRestore);
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      label,
      style: Theme.of(context).textTheme.titleMedium
          ?.copyWith(color: Theme.of(context).colorScheme.primary),
    ),
  );
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.preview});

  final BackupPreview preview;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final dateStr = DateFormat.yMd(locale)
        .add_Hm()
        .format(preview.createdAt.toLocal());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.backupPreviewTitle,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _InfoRow(label: l.backupPreviewDate, value: dateStr),
        _InfoRow(label: l.backupPreviewDays, value: '${preview.days}'),
        _InfoRow(label: l.backupPreviewExpenses, value: '${preview.expenses}'),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Text(value),
      ],
    ),
  );
}
