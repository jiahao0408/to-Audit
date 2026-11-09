import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/security/biometric_auth.dart';
import 'package:to_audit/data/security/db_key_manager.dart';
import 'package:to_audit/data/security/key_store.dart';

void main() {
  test('getOrCreateKey returns 64 hex chars and the same key again', () async {
    final store = MemoryKeyStore();
    final keys = DbKeyManager(store);

    expect(await keys.existingKey(), isNull);
    final first = await keys.getOrCreateKey();
    expect(first, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(await keys.getOrCreateKey(), first);
    expect(await keys.existingKey(), first);
    expect(store.values['db_key'], first);

    // A new manager on the same store reads the stored key.
    expect(await DbKeyManager(store).getOrCreateKey(), first);
  });

  test('different stores get different random keys', () async {
    final a = await DbKeyManager(MemoryKeyStore()).getOrCreateKey();
    final b = await DbKeyManager(MemoryKeyStore()).getOrCreateKey();
    expect(a, isNot(b));
  });

  test('concurrent first calls agree on one key', () async {
    final store = MemoryKeyStore();
    final keys = DbKeyManager(store);
    final both = await Future.wait([
      keys.getOrCreateKey(),
      keys.getOrCreateKey(),
    ]);
    expect(both[0], both[1]);
    expect(store.values['db_key'], both[0]);
  });

  test('BiometricAuth can be constructed without touching the platform', () {
    expect(BiometricAuth(), isA<BiometricAuth>());
  });
}
