import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/security/pin_manager.dart';
import '../../l10n/app_localizations.dart';

/// Six PIN dots and a numeric pad. Checks the PIN with [verify], shows the
/// attempts left or the lock countdown, and calls [onSuccess] on a match.
///
/// Used by the lock screen and by the PIN fallback of `requireAuth`. It has
/// no tooltips so it can sit outside a Navigator's Overlay.
class PinEntry extends StatefulWidget {
  const PinEntry({
    super.key,
    required this.verify,
    required this.onSuccess,
    this.extraAction,
    this.clock,
  });

  final Future<PinResult> Function(String pin) verify;
  final VoidCallback onSuccess;

  /// Shown in the bottom-left slot of the pad (the biometric button).
  final Widget? extraAction;

  /// Time source for the lock countdown. Defaults to [DateTime.now].
  final DateTime Function()? clock;

  @override
  State<PinEntry> createState() => _PinEntryState();
}

enum _Message { none, wrong, locked, error }

class _PinEntryState extends State<PinEntry> {
  static const _length = 6;

  String _digits = '';
  bool _busy = false;
  _Message _message = _Message.none;
  int _attemptsLeft = 0;
  DateTime? _lockedUntil;
  Timer? _timer;

  DateTime _now() => (widget.clock ?? DateTime.now)();

  Duration get _lockRemaining {
    final until = _lockedUntil;
    if (until == null) return Duration.zero;
    final left = until.difference(_now());
    return left.isNegative ? Duration.zero : left;
  }

  bool get _isLocked => _lockedUntil != null && _lockRemaining > Duration.zero;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    if (!mounted) return;
    if (_lockRemaining == Duration.zero) {
      _timer?.cancel();
      setState(() {
        _lockedUntil = null;
        _message = _Message.none;
      });
    } else {
      setState(() {});
    }
  }

  void _startLock(Duration remaining) {
    _lockedUntil = _now().add(remaining);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Future<void> _digit(String d) async {
    if (_busy || _isLocked || _digits.length >= _length) return;
    setState(() {
      _digits += d;
      _message = _Message.none;
    });
    if (_digits.length < _length) return;

    final pin = _digits;
    setState(() => _busy = true);
    PinResult? result;
    try {
      result = await widget.verify(pin);
    } on StateError {
      result = null;
    }
    if (!mounted) return;
    switch (result) {
      case PinOk():
        widget.onSuccess();
        if (mounted) {
          setState(() {
            _busy = false;
            _digits = '';
          });
        }
        return;
      case PinWrong(:final attemptsLeftBeforeLock):
        _message = _Message.wrong;
        _attemptsLeft = attemptsLeftBeforeLock;
      case PinLocked(:final remaining):
        _message = _Message.locked;
        _startLock(remaining);
      case null:
        _message = _Message.error;
    }
    setState(() {
      _busy = false;
      _digits = '';
    });
  }

  void _delete() {
    if (_busy || _digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  String? _messageText(AppLocalizations l) {
    switch (_message) {
      case _Message.none:
        return null;
      case _Message.wrong:
        return l.pinWrong(_attemptsLeft);
      case _Message.error:
        return l.pinCheckError;
      case _Message.locked:
        final seconds = _lockRemaining.inSeconds + 1;
        return seconds > 90
            ? l.pinLockedMinutes((seconds / 60).ceil())
            : l.pinLockedSeconds(seconds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final text = _messageText(l);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _length; i++)
              Container(
                key: ValueKey('pin-dot-$i'),
                width: 16,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: scheme.primary, width: 2),
                  color: i < _digits.length ? scheme.primary : null,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: text == null
              ? null
              : Text(
                  text,
                  key: const ValueKey('pin-message'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.error),
                ),
        ),
        const SizedBox(height: 8),
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          _row([for (final d in row) _digitKey(d)]),
        _row([
          widget.extraAction ?? const SizedBox.shrink(),
          _digitKey('0'),
          Semantics(
            label: l.pinDelete,
            button: true,
            excludeSemantics: true,
            child: IconButton(
              key: const ValueKey('pin-delete'),
              onPressed: _delete,
              icon: const Icon(Icons.backspace_outlined),
            ),
          ),
        ]),
      ],
    );
  }

  Widget _row(List<Widget> children) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final c in children)
          SizedBox(width: 72, height: 64, child: Center(child: c)),
      ],
    ),
  );

  Widget _digitKey(String d) => SizedBox(
    width: 64,
    height: 56,
    child: TextButton(
      key: ValueKey('pin-key-$d'),
      onPressed: _busy || _isLocked ? null : () => _digit(d),
      child: Text(d, style: Theme.of(context).textTheme.headlineSmall),
    ),
  );
}
