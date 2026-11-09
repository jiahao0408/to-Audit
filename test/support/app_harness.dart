import 'dart:io';

import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/providers.dart';
import 'package:to_audit/data/security/biometric_auth.dart';
import 'package:to_audit/data/security/key_store.dart';
import 'package:to_audit/data/security/pin_manager.dart';

/// [BiometricAuth] without the platform: availability and the outcome of
/// [authenticate] are set by the test.
class FakeBiometricAuth implements BiometricAuth {
  FakeBiometricAuth({this.available = false, this.succeeds = true});

  bool available;
  bool succeeds;
  final List<String> reasons = [];

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate(String localizedReason) async {
    reasons.add(localizedReason);
    return succeeds;
  }
}

/// The overrides every widget test of the app shell needs: an in-memory
/// database, an in-memory key store, a fake biometric, a fixed clock and a
/// cheap PIN hash.
List<Override> appOverrides({
  required AppDatabase db,
  required MemoryKeyStore keyStore,
  required FakeBiometricAuth biometrics,
  required DateTime Function() clock,
  required Directory documents,
}) => [
  databaseProvider.overrideWith(() => DatabaseNotifier(db)),
  documentsDirProvider.overrideWithValue(documents),
  keyStoreProvider.overrideWithValue(keyStore),
  biometricProvider.overrideWithValue(biometrics),
  clockProvider.overrideWithValue(clock),
  pinManagerProvider.overrideWithValue(
    PinManager(keyStore, clock: clock, iterations: 1000),
  ),
];
