import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Time in the background after which the app locks again.
const lockAfterBackground = Duration(minutes: 5);

/// Whether the app is locked (`true`). It starts locked; the lock gate only
/// shows the PIN screen when a PIN exists.
class AppLockController extends Notifier<bool> {
  DateTime? _pausedAt;

  @override
  bool build() => true;

  void onPaused(DateTime t) => _pausedAt = t;

  /// Locks when the app was in the background for [lockAfterBackground] or
  /// more. A clock that went back while paused counts as a lock too, since
  /// the time away cannot be trusted.
  void onResumed(DateTime t) {
    final paused = _pausedAt;
    if (paused == null) return;
    _pausedAt = null;
    final away = t.difference(paused);
    if (away >= lockAfterBackground || away.isNegative) lock();
  }

  void unlock() => state = false;

  void lock() => state = true;
}

final appLockProvider = NotifierProvider<AppLockController, bool>(
  AppLockController.new,
);
