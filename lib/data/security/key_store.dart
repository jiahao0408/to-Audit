import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Small string key/value store for secrets (DB key, PIN hash, lockout).
abstract class KeyStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// [KeyStore] backed by the Android Keystore / iOS Keychain through
/// flutter_secure_storage.
class SecureKeyStore implements KeyStore {
  SecureKeyStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage(aOptions: _android);

  /// `resetOnError: false`: a Keystore error must surface instead of wiping
  /// the stored DB key, which would leave the database unreadable.
  static const _android = AndroidOptions(resetOnError: false);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// In-memory [KeyStore] for tests.
class MemoryKeyStore implements KeyStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}
