import 'package:drift/drift.dart';

import '../../domain/money.dart';
import '../audit/audit_writer.dart';
import '../db/app_database.dart';

/// Name, tax id and address of the restaurant.
class RestaurantInfo {
  const RestaurantInfo({
    required this.name,
    required this.nif,
    required this.address,
  });

  final String name;
  final String nif;
  final String address;

  @override
  bool operator ==(Object other) =>
      other is RestaurantInfo &&
      other.name == name &&
      other.nif == nif &&
      other.address == address;

  @override
  int get hashCode => Object.hash(name, nif, address);
}

/// Key/value application settings. Every change is audited.
class SettingsRepository {
  SettingsRepository(this._db, this._audit);

  final AppDatabase _db;
  final AuditWriter _audit;

  static const _entity = 'ajustes';
  static const _restaurantName = 'restaurant_name';
  static const _restaurantNif = 'restaurant_nif';
  static const _restaurantAddress = 'restaurant_address';
  static const _locale = 'locale';
  static const _threshold = 'discrepancy_threshold_cents';
  static const _backupEveryDays = 'backup_every_days';
  static const _lastBackupAt = 'last_backup_at';
  static const _initialFloat = 'initial_float_cents';
  static const _onboardingDone = 'onboarding_done';

  Future<String?> _get(String key) async {
    final row = await (_db.select(
      _db.settingsTable,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  /// Writes [value] and audits it; does nothing when unchanged.
  /// Must run inside a transaction opened by the caller or by [_set].
  Future<void> _put(String key, String value) async {
    final old = await _get(key);
    if (old == value) return;
    await _db
        .into(_db.settingsTable)
        .insertOnConflictUpdate(
          SettingsTableCompanion.insert(key: key, value: Value(value)),
        );
    await _audit.event(_entity, key, 'value', oldValue: old, newValue: value);
  }

  Future<void> _set(String key, String value) =>
      _db.transaction(() => _put(key, value));

  Future<RestaurantInfo?> restaurant() async {
    final name = await _get(_restaurantName);
    if (name == null) return null;
    return RestaurantInfo(
      name: name,
      nif: await _get(_restaurantNif) ?? '',
      address: await _get(_restaurantAddress) ?? '',
    );
  }

  Future<void> setRestaurant(RestaurantInfo info) => _db.transaction(() async {
    await _put(_restaurantName, info.name);
    await _put(_restaurantNif, info.nif);
    await _put(_restaurantAddress, info.address);
  });

  Future<String> locale() async => await _get(_locale) ?? 'es';

  Future<void> setLocale(String locale) => _set(_locale, locale);

  Stream<String> watchLocale() =>
      (_db.select(_db.settingsTable)..where((s) => s.key.equals(_locale)))
          .watchSingleOrNull()
          .map((row) => row?.value ?? 'es')
          .distinct();

  Future<Money> _money(String key) async {
    final v = await _get(key);
    return v == null ? Money.zero : Money(int.parse(v));
  }

  Future<Money> threshold() => _money(_threshold);

  Future<void> setThreshold(Money value) {
    if (value.isNegative) {
      throw ArgumentError.value(value.cents, 'value', 'must not be negative');
    }
    return _set(_threshold, value.cents.toString());
  }

  Future<int> backupEveryDays() async {
    final v = await _get(_backupEveryDays);
    return v == null ? 7 : int.parse(v);
  }

  Future<void> setBackupEveryDays(int days) {
    if (days < 1 || days > 60) {
      throw ArgumentError.value(days, 'days', 'must be between 1 and 60');
    }
    return _set(_backupEveryDays, days.toString());
  }

  Future<DateTime?> lastBackupAt() async {
    final v = await _get(_lastBackupAt);
    return v == null ? null : DateTime.parse(v);
  }

  Future<void> setLastBackupAt(DateTime at) =>
      _set(_lastBackupAt, at.toUtc().toIso8601String());

  Future<Money> initialFloat() => _money(_initialFloat);

  Future<void> setInitialFloat(Money value) =>
      _set(_initialFloat, value.cents.toString());

  Future<bool> onboardingDone() async => await _get(_onboardingDone) == 'true';

  Future<void> setOnboardingDone() => _set(_onboardingDone, 'true');
}
