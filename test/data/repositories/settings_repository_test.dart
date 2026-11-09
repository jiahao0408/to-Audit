import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/audit/audit_writer.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/repositories/settings_repository.dart';
import 'package:to_audit/domain/money.dart';

void main() {
  late AppDatabase db;
  late SettingsRepository repo;

  setUp(() {
    db = AppDatabase.memory();
    repo = SettingsRepository(db, AuditWriter(db));
  });
  tearDown(() => db.close());

  test('defaults', () async {
    expect(await repo.threshold(), Money.zero);
    expect(await repo.backupEveryDays(), 7);
    expect(await repo.locale(), 'es');
    expect(await repo.restaurant(), isNull);
    expect(await repo.lastBackupAt(), isNull);
    expect(await repo.initialFloat(), Money.zero);
    expect(await repo.onboardingDone(), isFalse);
    expect(await repo.biometricsEnabled(), isFalse);
  });

  test('setThreshold stores the value and writes a history row', () async {
    await repo.setThreshold(const Money(100));
    expect(await repo.threshold(), const Money(100));
    final rows = await db.select(db.changeLog).get();
    expect(rows, hasLength(1));
    expect(rows.single.entity, 'ajustes');
    expect(rows.single.recordId, 'discrepancy_threshold_cents');
    expect(rows.single.field, 'value');
    expect(rows.single.oldValue, isNull);
    expect(rows.single.newValue, '100');

    await repo.setThreshold(const Money(250));
    final rows2 = await db.select(db.changeLog).get();
    expect(rows2, hasLength(2));
    final change = rows2.firstWhere((r) => r.newValue == '250');
    expect(change.oldValue, '100');
  });

  test('negative threshold and out-of-range backup days are rejected', () {
    expect(() => repo.setThreshold(const Money(-1)), throwsArgumentError);
    expect(() => repo.setBackupEveryDays(0), throwsArgumentError);
    expect(() => repo.setBackupEveryDays(61), throwsArgumentError);
  });

  test('backup days, float, locale round trip', () async {
    await repo.setBackupEveryDays(30);
    await repo.setInitialFloat(const Money(15000));
    await repo.setLocale('en');
    expect(await repo.backupEveryDays(), 30);
    expect(await repo.initialFloat(), const Money(15000));
    expect(await repo.locale(), 'en');
  });

  test('watchLocale emits default then changes', () async {
    final emitted = <String>[];
    final sub = repo.watchLocale().listen(emitted.add);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await repo.setLocale('en');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();
    expect(emitted.first, 'es');
    expect(emitted.last, 'en');
  });

  test('restaurant round trip with one history row per field', () async {
    const info = RestaurantInfo(name: 'Bar Pepe', nif: 'B123', address: 'C/ 1');
    await repo.setRestaurant(info);
    expect(await repo.restaurant(), info);
    expect(await db.select(db.changeLog).get(), hasLength(3));
    expect(
      const RestaurantInfo(name: 'a', nif: 'b', address: 'c'),
      const RestaurantInfo(name: 'a', nif: 'b', address: 'c'),
    );
  });

  test('lastBackupAt round trips as UTC', () async {
    final t = DateTime.utc(2026, 3, 4, 5, 6, 7);
    await repo.setLastBackupAt(t);
    expect(await repo.lastBackupAt(), t);
  });

  test('onboarding flag is audited once', () async {
    await repo.setOnboardingDone();
    expect(await repo.onboardingDone(), isTrue);
    await repo.setOnboardingDone();
    expect(await db.select(db.changeLog).get(), hasLength(1));
  });

  test('biometrics flag round trips and is audited', () async {
    await repo.setBiometricsEnabled(true);
    expect(await repo.biometricsEnabled(), isTrue);
    await repo.setBiometricsEnabled(false);
    expect(await repo.biometricsEnabled(), isFalse);
    final rows = await db.select(db.changeLog).get();
    expect(rows.map((r) => r.recordId), everyElement('biometrics_enabled'));
    expect(rows.map((r) => r.newValue), containsAll(['true', 'false']));
  });
}
