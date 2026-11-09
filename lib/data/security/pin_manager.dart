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

  /// One JSON value `{salt, iterations, hash}` (base64 salt and hash), so a
  /// new PIN is written atomically.
  static const _pinKey = 'pin_hash';
  static const _failuresKey = 'pin_failures';
  static const _lockedUntilKey = 'pin_locked_until';

  static final _sixDigits = RegExp(r'^[0-9]{6}$');

  Future<bool> hasPin() async => await _store.read(_pinKey) != null;

  /// Sets a new PIN (exactly 6 digits, else [ArgumentError]) and clears any
  /// failure count or lock.
  Future<void> setPin(String pin) async {
    if (!_sixDigits.hasMatch(pin)) {
      throw ArgumentError('The PIN must be exactly 6 digits');
    }
    final random = Random.secure();
    final salt = List<int>.generate(16, (_) => random.nextInt(256));
    final hash = await _hash(pin, salt, iterations);
    await _store.write(
      _pinKey,
      jsonEncode({
        'salt': base64.encode(salt),
        'iterations': iterations,
        'hash': base64.encode(hash),
      }),
    );
    await _resetFailures();
  }

  /// Checks [pin]. While locked every call returns [PinLocked] without
  /// checking or counting. Throws [StateError] when no PIN is set or the
  /// stored one is unreadable.
  Future<PinResult> verify(String pin) async {
    final now = _clock().toUtc();
    final locked = await _lockRemaining(now);
    if (locked != null) return PinLocked(locked);

    final (salt, rounds, storedHash) = _decode(await _store.read(_pinKey));
    final hash = await _hash(pin, salt, rounds);

    if (_constantTimeEquals(hash, storedHash)) {
      await _resetFailures();
      return const PinOk();
    }

    final failures = await _failures() + 1;
    await _store.write(_failuresKey, '$failures');
    if (failures < maxAttempts) return PinWrong(maxAttempts - failures);

    final lock = _lockFor(failures);
    await _store.write(_lockedUntilKey, now.add(lock).toIso8601String());
    return PinLocked(lock);
  }

  /// Time left of the current lock, or null when not locked. A corrupt
  /// instant counts as no lock and is cleared. When the clock moved back the
  /// remaining time is capped at the lock duration (and stored again).
  Future<Duration?> _lockRemaining(DateTime now) async {
    final raw = await _store.read(_lockedUntilKey);
    if (raw == null) return null;
    final until = DateTime.tryParse(raw);
    if (until == null) {
      await _store.delete(_lockedUntilKey);
      return null;
    }
    if (!now.isBefore(until)) return null;
    final remaining = until.difference(now);
    final lock = _lockFor(max(await _failures(), maxAttempts));
    if (remaining <= lock) return remaining;
    await _store.write(_lockedUntilKey, now.add(lock).toIso8601String());
    return lock;
  }

  Future<int> _failures() async =>
      int.tryParse(await _store.read(_failuresKey) ?? '') ?? 0;

  /// Lock after [failures] failures in a row (at least [maxAttempts]).
  static Duration _lockFor(int failures) =>
      baseLock * (1 << min(failures - maxAttempts, _maxDoublings));

  static (List<int>, int, List<int>) _decode(String? raw) {
    if (raw == null) throw StateError('No PIN has been set');
    Object? json;
    try {
      json = jsonDecode(raw);
    } on FormatException {
      json = null;
    }
    if (json is Map<String, dynamic>) {
      final salt = json['salt'];
      final rounds = json['iterations'];
      final hash = json['hash'];
      if (salt is String && rounds is int && rounds > 0 && hash is String) {
        try {
          return (base64.decode(salt), rounds, base64.decode(hash));
        } on FormatException {
          // Falls through to the error below.
        }
      }
    }
    throw StateError('The stored PIN is unreadable');
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
