import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/audit/period_guard.dart';
import '../../data/providers.dart';
import '../../data/repositories/payroll_repository.dart';
import '../../l10n/app_localizations.dart';

/// Opens the employee form as a bottom sheet. Returns the saved id, or null
/// if the user cancelled.
Future<String?> showEmployeeForm(BuildContext context, {String? id}) async {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _EmployeeSheet(id: id),
  );
}

class _EmployeeSheet extends ConsumerStatefulWidget {
  const _EmployeeSheet({this.id});

  final String? id;

  @override
  ConsumerState<_EmployeeSheet> createState() => _EmployeeSheetState();
}

class _EmployeeSheetState extends ConsumerState<_EmployeeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _role = TextEditingController();

  bool _loading = true;
  bool _busy = false;
  DateTime? _hiredOn;
  DateTime? _leftOn;

  bool get _isNew => widget.id == null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = widget.id;
    if (id == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final employees =
          await ref.read(payrollRepositoryProvider).watchEmployees().first;
      final e = employees.where((e) => e.id == id).firstOrNull;
      if (!mounted) return;
      if (e == null) {
        setState(() => _loading = false);
        return;
      }
      setState(() {
        _name.text = e.name;
        _role.text = e.role;
        _hiredOn = e.hiredOn;
        _leftOn = e.leftOn;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate({required bool hired}) async {
    final initial = (hired ? _hiredOn : _leftOn) ??
        (hired ? DateTime.utc(2020, 1, 1) : DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      final day = DateTime.utc(picked.year, picked.month, picked.day);
      if (hired) {
        _hiredOn = day;
      } else {
        _leftOn = day;
      }
    });
  }

  Future<void> _save() async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_hiredOn == null) {
      messenger.showSnackBar(SnackBar(content: Text(l.fieldRequired)));
      return;
    }
    final input = EmployeeInput(
      name: _name.text,
      role: _role.text,
      hiredOn: _hiredOn!,
      leftOn: _leftOn,
    );
    setState(() => _busy = true);
    try {
      final repo = ref.read(payrollRepositoryProvider);
      final id = widget.id;
      if (_isNew) {
        final newId = await repo.createEmployee(input);
        if (mounted) Navigator.of(context).pop(newId);
      } else {
        await repo.updateEmployee(id!, input);
        if (mounted) Navigator.of(context).pop(id);
      }
    } on PeriodLockedException {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l.dayErrLocked)));
        setState(() => _busy = false);
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l.payrollErrEmployee)));
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final title = _isNew ? l.payrollEmployeeNewTitle : l.payrollEmployeeEditTitle;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          key: const ValueKey('employee-name'),
                          controller: _name,
                          decoration: InputDecoration(
                            labelText: l.suppFieldName,
                          ),
                          textCapitalization: TextCapitalization.words,
                          validator: (v) =>
                              (v ?? '').trim().isEmpty ? l.fieldRequired : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const ValueKey('employee-role'),
                          controller: _role,
                          decoration: InputDecoration(
                            labelText: l.payrollFieldHiredOn.split('(')[0],
                            hintText: l.export_colRole,
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          key: const ValueKey('employee-hired'),
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.calendar_today_outlined),
                          title: Text(l.payrollFieldHiredOn),
                          subtitle: Text(
                            _hiredOn == null
                                ? l.fieldRequired
                                : DateFormat.yMMMMd(locale).format(_hiredOn!),
                          ),
                          onTap: () => _pickDate(hired: true),
                        ),
                        ListTile(
                          key: const ValueKey('employee-left'),
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.event_busy_outlined),
                          title: Text(l.payrollFieldLeftOn),
                          subtitle: Text(
                            _leftOn == null
                                ? '—'
                                : DateFormat.yMMMMd(locale).format(_leftOn!),
                          ),
                          trailing: _leftOn == null
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () =>
                                      setState(() => _leftOn = null),
                                ),
                          onTap: () => _pickDate(hired: false),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          key: const ValueKey('employee-save'),
                          onPressed: _busy ? null : _save,
                          child: Text(l.actionSave),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
