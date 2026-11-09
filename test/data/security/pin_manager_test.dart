import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/security/key_store.dart';
import 'package:to_audit/data/security/pin_manager.dart';

void main() {
  late MemoryKeyStore store;
  late DateTime now;
  late PinManager pins;

  setUp(() {
    store = MemoryKeyStore();
    now = DateTime.utc(2026, 11, 9, 12);
    pins = PinManager(store, clock: () => now, iterations: 1000);
  });

  test('hasPin is false until a PIN is set', () async {
    expect(await pins.hasPin(), isFalse);
    await pins.setPin('123456');
    expect(await pins.hasPin(), isTrue);
  });

  test('setPin rejects anything that is not exactly 6 digits', () async {
    for (final bad in ['12345', '1234567', '12345a', '', '12 456']) {
      expect(() => pins.setPin(bad), throwsArgumentError, reason: bad);
    }
    expect(await pins.hasPin(), isFalse);
  });

  test('stores a salted hash, never the PIN itself', () async {
    await pins.setPin('123456');
    expect(store.values.values, isNot(contains('123456')));
    expect(store.values.keys, containsAll(['pin_hash', 'pin_salt']));

    // A random salt: the same PIN hashes differently in another store.
    final otherStore = MemoryKeyStore();
    await PinManager(otherStore, iterations: 1000).setPin('123456');
    expect(otherStore.values['pin_hash'], isNot(store.values['pin_hash']));
  });

  test('the right PIN is PinOk', () async {
    await pins.setPin('123456');
    expect(await pins.verify('123456'), const PinOk());
  });

  test('lockout: 5 failures lock 30 s, then each failure doubles', () async {
    await pins.setPin('123456');

    expect(await pins.verify('000000'), const PinWrong(4));
    expect(await pins.verify('000000'), const PinWrong(3));
    expect(await pins.verify('000000'), const PinWrong(2));
    expect(await pins.verify('000000'), const PinWrong(1));
    expect(await pins.verify('000000'), const PinLocked(Duration(seconds: 30)));

    // While locked even the right PIN is refused, and it does not count.
    now = now.add(const Duration(seconds: 10));
    expect(await pins.verify('123456'), const PinLocked(Duration(seconds: 20)));

    now = now.add(const Duration(seconds: 21)); // 31 s after the lock
    expect(await pins.verify('000000'), const PinLocked(Duration(seconds: 60)));

    now = now.add(const Duration(seconds: 61));
    expect(
      await pins.verify('000000'),
      const PinLocked(Duration(seconds: 120)),
    );

    now = now.add(const Duration(seconds: 121));
    expect(await pins.verify('123456'), const PinOk());

    // The success reset the counter: back to 4 attempts before a lock.
    expect(await pins.verify('000000'), const PinWrong(4));
  });

  test(
    'failures and lock survive a new PinManager on the same store',
    () async {
      await pins.setPin('123456');
      for (var i = 0; i < 5; i++) {
        await pins.verify('000000');
      }
      final again = PinManager(store, clock: () => now, iterations: 1000);
      now = now.add(const Duration(seconds: 5));
      expect(
        await again.verify('123456'),
        const PinLocked(Duration(seconds: 25)),
      );
    },
  );

  test('setPin clears a previous lock', () async {
    await pins.setPin('123456');
    for (var i = 0; i < 5; i++) {
      await pins.verify('000000');
    }
    await pins.setPin('654321');
    expect(await pins.verify('654321'), const PinOk());
  });

  test('verify without a PIN throws StateError', () async {
    expect(() => pins.verify('123456'), throwsStateError);
  });
}
