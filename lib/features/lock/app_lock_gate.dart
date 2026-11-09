import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';
import 'app_lock_controller.dart';
import 'lock_screen.dart';

/// Covers [child] with the lock screen while the app is locked, and feeds the
/// app lifecycle to [AppLockController] (lock after 5 minutes in background).
///
/// [child] stays mounted underneath, so the screen the user was on (and what
/// they had typed) is still there after unlocking; it is hidden from taps,
/// focus and screen readers while locked.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lock = ref.read(appLockProvider.notifier);
    final now = ref.read(clockProvider)();
    switch (state) {
      case AppLifecycleState.paused:
        lock.onPaused(now);
      case AppLifecycleState.resumed:
        lock.onResumed(now);
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = ref.watch(appLockProvider);
    final hasPin = ref.watch(hasPinProvider);
    // Unknown (still reading) counts as locked once a PIN may exist.
    final covered = locked && (hasPin.value ?? true);
    final loading = hasPin.isLoading;
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeFocus(
          excluding: covered,
          child: Offstage(
            offstage: covered,
            child: TickerMode(enabled: !covered, child: widget.child),
          ),
        ),
        if (covered)
          loading
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : const LockScreen(),
      ],
    );
  }
}
