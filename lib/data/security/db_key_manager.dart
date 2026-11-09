import 'dart:math';

import 'key_store.dart';

/// Owns the random SQLCipher key of the database, kept in the [KeyStore].
class DbKeyManager {
  DbKeyManager(this._store);

  final KeyStore _store;
  Future<String>? _creating;

  static const storageKey = 'db_key';

  /// The stored key (64 lowercase hex chars), or null when none exists.
  Future<String?> existingKey() => _store.read(storageKey);

  /// Returns the stored key, creating and storing a new one from 32 bytes of
  /// [Random.secure] when there is none. Concurrent calls share one key.
  Future<String> getOrCreateKey() =>
      _creating ??= _getOrCreate().whenComplete(() => _creating = null);

  Future<String> _getOrCreate() async {
    final existing = await existingKey();
    if (existing != null) return existing;
    final random = Random.secure();
    final key = List.generate(
      32,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    await _store.write(storageKey, key);
    return key;
  }
}
