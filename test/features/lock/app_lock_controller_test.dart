import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/features/lock/app_lock_controller.dart';

void main() {
  late ProviderContainer container;

  AppLockController controller() => container.read(appLockProvider.notifier);
  bool locked() => container.read(appLockProvider);

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  test('starts locked and unlock / lock switch the state', () {
    expect(locked(), isTrue);
    controller().unlock();
    expect(locked(), isFalse);
    controller().lock();
    expect(locked(), isTrue);
  });

  test('coming back after 4:59 in the background stays unlocked', () {
    controller().unlock();
    controller().onPaused(DateTime(2026, 11, 9, 10, 0));
    controller().onResumed(DateTime(2026, 11, 9, 10, 4, 59));
    expect(locked(), isFalse);
  });

  test('coming back after exactly 5 minutes locks', () {
    controller().unlock();
    controller().onPaused(DateTime(2026, 11, 9, 10, 0));
    controller().onResumed(DateTime(2026, 11, 9, 10, 5));
    expect(locked(), isTrue);
  });

  test('a resume without a pause changes nothing', () {
    controller().unlock();
    controller().onResumed(DateTime(2026, 11, 9, 12));
    expect(locked(), isFalse);
  });

  test('the pause is forgotten once resumed', () {
    controller().unlock();
    controller().onPaused(DateTime(2026, 11, 9, 10, 0));
    controller().onResumed(DateTime(2026, 11, 9, 10, 1));
    controller().onResumed(DateTime(2026, 11, 9, 11, 0));
    expect(locked(), isFalse);
  });

  test('a clock that went back while paused locks', () {
    controller().unlock();
    controller().onPaused(DateTime(2026, 11, 9, 10, 0));
    controller().onResumed(DateTime(2026, 11, 9, 9, 0));
    expect(locked(), isTrue);
  });
}
