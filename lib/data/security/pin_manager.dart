import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import 'key_store.dart';

/// Outcome of [PinManager.verify].
sealed class PinResult {
  const PinResult();
}

final class PinOk extends PinResult {
  const PinOk();

  @override
  bool operator ==(Object other) => other is PinOk;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'PinOk()';
}

final class PinWrong extends PinResult {
  const PinWrong(this.attemptsLeftBeforeLock);

  final int attemptsLeftBeforeLock;

  @override
  bool operator ==(Object other) =>
      other is PinWrong &&
      other.attemptsLeftBeforeLock == attemptsLeftBeforeLock;

  @override
  int get hashCode => attemptsLeftBeforeLock.hashCode;

  @override
  String toString() => 'PinWrong($attemptsLeftBeforeLock)';
}

final class PinLocked extends PinResult {
  const PinLocked(this.remaining);

  final Duration remaining;

  @override
  bool operator ==(Object other) =>
      other is PinLocked && other.remaining == remaining;

  @override
  int get hashCode => remaining.hashCode;

  @override
  String toString() => 'PinLocked($remaining)';
}

/// 6-digit app PIN stored as a salted PBKDF2-HMAC-SHA256 hash, with lockout:
/// after [maxAttempts] failures in a row it locks for 30 s, and every further
/// failure doubles the lock. A success resets it.
class PinManager {
  PinManager(
    this._store, {
    DateTime Function()? clock,
    this.iterations = 100000,
  }) : _clock = clock ?? DateTime.now;

  final KeyStore _store;
  final DateTime Function() _clock;
  final int iterations;

  static const maxAttempts = 5;
  static const baseLock = Duration(seconds: 30);

  /// Lock doubling stops here (30 s × 2^20 ≈ 1 year) so it cannot overflow.
  static const _maxDoublings = 20;

  static const _hashKey = 'pin_hash';
  static const _saltKey = 'pin_salt';
  static const _iterationsKey = 'pin_iterations';
  static const _failuresKey = 'pin_failures';
  static const _lockedUntilKey = 'pin_locked_until';

  static final _sixDigits = RegExp(r'^[0-9]{6}$');

  Future<bool> hasPin() async => await _store.read(_hashKey) != null;

  /// Sets a new PIN (exactly 6 digits, else [ArgumentError]) and clears any
  /// failure count or lock.
  Future<void> setPin(String pin) async {
    if (!_sixDigits.hasMatch(pin)) {
      throw ArgumentError('The PIN must be exactly 6 digits');
    }
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final hash = await _hash(pin, salt, iterations);
    await _store.write(_saltKey, base64.encode(salt));
    await _store.write(_iterationsKey, '$iterations');
    await _store.write(_hashKey, base64.encode(hash));
    await _resetFailures();
  }

  /// Checks [pin]. While locked every call returns [PinLocked] without
  /// checking or counting. Throws [StateError] when no PIN is set.
  Future<PinResult> verify(String pin) async {
    final now = _clock().toUtc();
    final lockedUntil = await _store.read(_lockedUntilKey);
    if (lockedUntil != null) {
      final until = DateTime.parse(lockedUntil);
      if (now.isBefore(until)) return PinLocked(until.difference(now));
    }

    final storedHash = await _store.read(_hashKey);
    final storedSalt = await _store.read(_saltKey);
    if (storedHash == null || storedSalt == null) {
      throw StateError('No PIN has been set');
    }
    final rounds =
        int.tryParse(await _store.read(_iterationsKey) ?? '') ?? iterations;
    final hash = await _hash(pin, base64.decode(storedSalt), rounds);

    if (_constantTimeEquals(hash, base64.decode(storedHash))) {
      await _resetFailures();
      return const PinOk();
    }

    final failures =
        (int.tryParse(await _store.read(_failuresKey) ?? '') ?? 0) + 1;
    await _store.write(_failuresKey, '$failures');
    if (failures < maxAttempts) return PinWrong(maxAttempts - failures);

    final lock = baseLock * (1 << min(failures - maxAttempts, _maxDoublings));
    await _store.write(_lockedUntilKey, now.add(lock).toIso8601String());
    return PinLocked(lock);
  }

  Future<void> _resetFailures() async {
    await _store.delete(_failuresKey);
    await _store.delete(_lockedUntilKey);
  }

  static Future<List<int>> _hash(String pin, List<int> salt, int rounds) async {
    final key = await Pbkdf2.hmacSha256(
      iterations: rounds,
      bits: 256,
    ).deriveKeyFromPassword(password: pin, nonce: salt);
    return key.extractBytes();
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
