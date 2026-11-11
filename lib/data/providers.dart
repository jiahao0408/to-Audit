import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'audit/audit_writer.dart';
import 'audit/period_guard.dart';
import 'backup/backup_service.dart';
import 'backup/db_snapshotter.dart';
import 'backup/toaudit_format.dart';
import 'db/app_database.dart';
import 'db/open_database.dart';
import 'files/receipt_store.dart';
import 'repositories/catalog_repository.dart';
import 'repositories/days_repository.dart';
import 'repositories/expenses_repository.dart';
import 'repositories/fixed_costs_repository.dart';
import 'repositories/history_repository.dart';
import 'repositories/payroll_repository.dart';
import 'repositories/periods_repository.dart';
import 'repositories/settings_repository.dart';
import 'repositories/suppliers_repository.dart';
import 'repositories/withdrawals_repository.dart';
import 'reports/alerts_service.dart';
import 'reports/report_service.dart';
import 'security/biometric_auth.dart';
import 'security/db_key_manager.dart';
import 'security/key_store.dart';
import 'security/pin_manager.dart';

/// File name of the encrypted database inside the documents directory.
const databaseFileName = 'to_audit.db';

/// Folder for export and restore work files; [BackupService.cleanTemp] cleans
/// it at app start.
Directory defaultTempRoot() =>
    Directory(p.join(Directory.systemTemp.path, 'to_audit'));

/// Holds the open database. `main` and the tests override it with
/// `databaseProvider.overrideWith(() => DatabaseNotifier(db))`.
///
/// A restore swaps the file under the app: [replace] publishes the database
/// the restore reopened, and every provider that watches this one (the
/// repositories, the services, [BackupService]) is rebuilt on it.
class DatabaseNotifier extends Notifier<AppDatabase> {
  DatabaseNotifier([this._initial]);

  final AppDatabase? _initial;

  @override
  AppDatabase build() =>
      _initial ??
      (throw UnimplementedError('databaseProvider must be overridden'));

  void replace(AppDatabase db) => state = db;
}

final databaseProvider = NotifierProvider<DatabaseNotifier, AppDatabase>(
  DatabaseNotifier.new,
);

/// The app documents directory (database file and `receipts/`). Overridden in
/// `main` and in tests.
final documentsDirProvider = Provider<Directory>(
  (ref) => throw UnimplementedError('documentsDirProvider must be overridden'),
);

final tempRootProvider = Provider<Directory>((ref) => defaultTempRoot());

/// Current time; tests override it with a fixed clock.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final keyStoreProvider = Provider<KeyStore>((ref) => SecureKeyStore());

final biometricProvider = Provider<BiometricAuth>((ref) => BiometricAuth());

final dbKeyManagerProvider = Provider<DbKeyManager>(
  (ref) => DbKeyManager(ref.watch(keyStoreProvider)),
);

final pinManagerProvider = Provider<PinManager>(
  (ref) =>
      PinManager(ref.watch(keyStoreProvider), clock: ref.watch(clockProvider)),
);

final receiptStoreProvider = Provider<ReceiptStore>(
  (ref) => ReceiptStore(ref.watch(documentsDirProvider)),
);

final auditWriterProvider = Provider<AuditWriter>(
  (ref) =>
      AuditWriter(ref.watch(databaseProvider), clock: ref.watch(clockProvider)),
);

final periodGuardProvider = Provider<PeriodGuard>(
  (ref) => PeriodGuard(ref.watch(databaseProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(
    ref.watch(databaseProvider),
    ref.watch(auditWriterProvider),
  ),
);

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(
    ref.watch(databaseProvider),
    ref.watch(auditWriterProvider),
  ),
);

final suppliersRepositoryProvider = Provider<SuppliersRepository>(
  (ref) => SuppliersRepository(
    ref.watch(databaseProvider),
    audit: ref.watch(auditWriterProvider),
  ),
);

final daysRepositoryProvider = Provider<DaysRepository>(
  (ref) => DaysRepository(
    ref.watch(databaseProvider),
    audit: ref.watch(auditWriterProvider),
    guard: ref.watch(periodGuardProvider),
    settings: ref.watch(settingsRepositoryProvider),
  ),
);

final expensesRepositoryProvider = Provider<ExpensesRepository>(
  (ref) => ExpensesRepository(
    ref.watch(databaseProvider),
    audit: ref.watch(auditWriterProvider),
    guard: ref.watch(periodGuardProvider),
    receipts: ref.watch(receiptStoreProvider),
  ),
);

final fixedCostsRepositoryProvider = Provider<FixedCostsRepository>(
  (ref) => FixedCostsRepository(
    ref.watch(databaseProvider),
    audit: ref.watch(auditWriterProvider),
    guard: ref.watch(periodGuardProvider),
    expenses: ref.watch(expensesRepositoryProvider),
  ),
);

final payrollRepositoryProvider = Provider<PayrollRepository>(
  (ref) => PayrollRepository(
    ref.watch(databaseProvider),
    audit: ref.watch(auditWriterProvider),
    guard: ref.watch(periodGuardProvider),
  ),
);

final withdrawalsRepositoryProvider = Provider<WithdrawalsRepository>(
  (ref) => WithdrawalsRepository(
    ref.watch(databaseProvider),
    audit: ref.watch(auditWriterProvider),
    guard: ref.watch(periodGuardProvider),
  ),
);

final periodsRepositoryProvider = Provider<PeriodsRepository>(
  (ref) => PeriodsRepository(
    ref.watch(databaseProvider),
    audit: ref.watch(auditWriterProvider),
  ),
);

final historyRepositoryProvider = Provider<HistoryRepository>(
  (ref) => HistoryRepository(ref.watch(databaseProvider)),
);

final reportServiceProvider = Provider<ReportService>(
  (ref) => ReportService(
    db: ref.watch(databaseProvider),
    days: ref.watch(daysRepositoryProvider),
    expenses: ref.watch(expensesRepositoryProvider),
    payroll: ref.watch(payrollRepositoryProvider),
    withdrawals: ref.watch(withdrawalsRepositoryProvider),
    catalog: ref.watch(catalogRepositoryProvider),
  ),
);

final alertsServiceProvider = Provider<AlertsService>(
  (ref) => AlertsService(
    days: ref.watch(daysRepositoryProvider),
    expenses: ref.watch(expensesRepositoryProvider),
    periods: ref.watch(periodsRepositoryProvider),
    settings: ref.watch(settingsRepositoryProvider),
    fixedCosts: ref.watch(fixedCostsRepositoryProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Key derivation for backups: PBKDF2 in a separate isolate. Tests may
/// override it with a cheap one.
final keyDeriverProvider = Provider<KeyDeriver>((ref) => isolateKeyDeriver);

/// PBKDF2 iterations of new backups (tests lower it).
final backupIterationsProvider = Provider<int>((ref) => 600000);

/// Export and restore of `.toaudit` copies. Rebuilt on the new database after
/// a restore, because the instance given to a restore is spent.
final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(databaseProvider);
  final documents = ref.watch(documentsDirProvider);
  final keys = ref.watch(dbKeyManagerProvider);
  final holder = ref.read(databaseProvider.notifier);
  final dbFile = File(p.join(documents.path, databaseFileName));
  return BackupService(
    db: db,
    snapshotter: SqlCipherSnapshotter(db),
    filesRoot: documents,
    tempRoot: ref.watch(tempRootProvider),
    settings: ref.watch(settingsRepositoryProvider),
    closeDb: db.close,
    // openEncryptedDatabase, not openAppDatabase: start-up recovery must not
    // run in the middle of a restore. The service publishes the live one to
    // every dependent provider only after its counts were verified.
    reopenDb: () async => openEncryptedDatabase(
      file: dbFile,
      hexKey: await keys.getOrCreateKey(),
    ),
    publishDb: holder.replace,
    dbFile: dbFile,
    hexKey: keys.getOrCreateKey,
    deriveKey: ref.watch(keyDeriverProvider),
    iterations: ref.watch(backupIterationsProvider),
  );
});

/// The UI language code (`'es'` or `'zh'`), from the stored setting.
final localeProvider = StreamProvider<String>(
  (ref) => ref.watch(settingsRepositoryProvider).watchLocale(),
);
