# to Audit MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Construir la fase 1 (MVP) de to Audit: app Flutter offline y cifrada para registrar y cuadrar los días de caja, gastos, fijos, nóminas y retiradas de un restaurante, con informes, auditoría y copia cifrada.

**Architecture:** Tres capas con dependencias en un solo sentido: `lib/features` (UI, Riverpod) → `lib/data` (Drift + SQLCipher, repositorios que auditan y comprueban bloqueos) → `lib/domain` (cálculos puros en céntimos). La UI nunca toca la BD: solo llama a repositorios y servicios.

**Tech Stack:** Flutter stable, Dart 3, drift + drift_dev + build_runner, sqlcipher_flutter_libs, flutter_riverpod, go_router, flutter_secure_storage, local_auth, cryptography, archive, pdf, printing, excel, csv, share_plus, image_picker, file_picker, flutter_image_compress, path_provider, intl, uuid; dev: flutter_test, integration_test, mocktail.

**Spec:** `docs/superpowers/specs/2026-11-08-to-audit-mvp-design.md` (y el documento de requisitos enlazado en él; los códigos RF-/RNF- vienen de ahí).

## Global Constraints

- Android 9+ (`minSdk 28`) e iOS 15+ (`IPHONEOS_DEPLOYMENT_TARGET 15.0`), una sola base de código (RNF-01).
- Toda función salvo compartir funciona sin Internet; la build release de Android no declara `android.permission.INTERNET`; sin analítica (RNF-02/07).
- Importes siempre `int` en céntimos dentro de `Money`; nunca `double` para dinero; redondeo a 2 decimales, mitad hacia arriba alejándose de cero (RNF-08).
- Cada escritura es una transacción Drift; el historial se escribe en la misma transacción (RNF-09, RF-AUD-01).
- Nada se borra: los registros se anulan con motivo (RF-AUD-02). Los catálogos se desactivan.
- Todas las tablas llevan `id` UUID v4 (texto), `created_at`, `updated_at`, `author` (`'owner'` en el MVP) (RNF-19).
- Fechas de calendario como `DateTime.utc(y, m, d)` en Dart y como texto `'YYYY-MM-DD'` en BD; meses como `'YYYY-MM'`. Instantes (`created_at`, `cerrado_en`, historial) en UTC ISO-8601.
- Ningún texto visible fijo en el código: todo en `lib/l10n/app_es.arb` y `app_zh.arb` (RNF-13). Locale `es` y `zh` (chino simplificado).
- Umbral de descuadre por defecto 0 céntimos; recordatorio de copia cada 7 días (configurable); aviso al abrir si la última copia tiene más de 14 días; bloqueo tras 5 minutos en segundo plano (RF-CAJ-06, RNF-05/15).
- Fotos de justificantes: lado largo 1600 px, JPEG calidad 75 (~300 KB) (RNF-03).
- Botones táctiles ≥ 48 dp; teclado numérico para importes; modo oscuro; tamaño de letra del sistema respetado (RNF-12/14).
- Cobertura ≥ 80 % en `lib/domain/` (RNF-17).
- Mensajes de commit en inglés, convencionales (`feat:`, `test:`, `chore:`), terminando con `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Review Focus

1. **Cambio de mes:** cerrar el 31 de octubre pasa el fondo final al 1 de noviembre aunque sea otro mes; reabrir un día de un mes cerrado exige reabrir antes el mes. (Tests en Task 9 y Task 13.)
2. **Cambios de configuración posteriores:** cambiar el umbral o desactivar una forma de pago no reescribe los descuadres guardados de días ya cerrados, y la forma de pago desactivada sigue saliendo en días e informes antiguos. (Tests en Task 8 y Task 9.)
3. **Restauración que falla a mitad:** si la restauración lanza una excepción después de mover la BD actual, se recupera la BD anterior y la app sigue usable. (Test en Task 16.)
4. **Nombres en chino o con símbolos:** un proveedor `"蔬菜店 / Hnos. García"` produce un nombre de archivo válido en el ZIP del gestor, el CSV se abre bien en Excel (UTF-8 con BOM) y el PDF lo dibuja con Noto Sans SC. (Tests en Task 17.)
5. **Entrada de importes del usuario:** `"12,5"`, `"12.50"`, `" 7 "` se aceptan; `"1.234,56"`, `"-3"`, `"12,345"` y `""` se rechazan con error de formulario, no con excepción sin capturar. (Tests en Task 1 y Task 20.)

---

## File Structure

```
pubspec.yaml, analysis_options.yaml, l10n.yaml, build.yaml
lib/
  main.dart                         arranque: abre BD cifrada, ProviderScope, App
  app.dart                          MaterialApp.router, tema, locale, AppLockGate
  router.dart                       rutas go_router
  domain/
    money.dart                      Money, VatCalc
    dates.dart                      ymd(), parseYmd(), monthKey(), DateRange y constructores
    enums.dart                      DayStatus, Shift, PaymentKind, CategoryKind, PaymentStatus,
                                    ExpenseOrigin, FixedStatus, Periodicity, ReceiptKind
    cash_calc.dart                  expectedCash, discrepancias, recuento por billetes
    pnl_calc.dart                   computePnl, proratedPersonnel
    alerts_calc.dart                Alert, computeAlerts, backupReminderDue
  data/
    db/tables.dart                  tablas Drift
    db/app_database.dart            AppDatabase, migraciones, semillas
    db/open_database.dart           apertura cifrada en dispositivo
    audit/audit_writer.dart         AuditWriter
    audit/period_guard.dart         PeriodGuard, PeriodLockedException
    repositories/settings_repository.dart
    repositories/catalog_repository.dart
    repositories/days_repository.dart
    repositories/withdrawals_repository.dart
    repositories/suppliers_repository.dart
    repositories/expenses_repository.dart
    repositories/fixed_costs_repository.dart
    repositories/payroll_repository.dart
    repositories/periods_repository.dart
    repositories/history_repository.dart
    files/receipt_store.dart
    reports/report_service.dart     ReportData, HomeSummary
    reports/alerts_service.dart
    security/key_store.dart         KeyStore (+ SecureKeyStore, MemoryKeyStore)
    security/db_key_manager.dart
    security/pin_manager.dart
    security/biometric_auth.dart
    backup/toaudit_format.dart      cifrado por bloques
    backup/db_snapshotter.dart      instantánea sin cifrar ↔ BD cifrada
    backup/backup_service.dart
    export/pdf_report.dart
    export/xlsx_export.dart
    export/csv_zip_export.dart
    export/gestor_zip_export.dart
    providers.dart                  todos los Provider de Riverpod de la capa data
  features/
    lock/  onboarding/  home/  calendar/  day_close/  expenses/  suppliers/
    fixed_costs/  payroll/  withdrawals/  reports/  alerts/  settings/  backup/
    common/                         MoneyField, ConfirmReasonDialog, AuthGate, formateadores
  l10n/app_es.arb, app_zh.arb
assets/fonts/NotoSansSC-Regular.ttf
test/                               espejo de lib/
integration_test/encrypted_db_test.dart
tool/coverage_check.dart
```

---

### Task 0: Entorno, repositorio y esqueleto Flutter

**Files:**
- Create: `.gitignore`, `pubspec.yaml`, `analysis_options.yaml`, `l10n.yaml`, `lib/main.dart`, `lib/l10n/app_es.arb`, `lib/l10n/app_zh.arb`, `test/smoke_test.dart`
- Modify: `android/app/build.gradle(.kts)` (minSdk 28), `android/app/src/main/kotlin/.../MainActivity.kt` (`FlutterFragmentActivity`, requerido por local_auth), `ios/Podfile` y proyecto Xcode (iOS 15.0)

**Interfaces:**
- Produces: proyecto que compila; `flutter test` funciona con `NativeDatabase.memory()` en el host.

- [ ] **Step 1: Instalar herramientas (con aprobación del usuario).** Flutter SDK stable desde flutter.dev y JDK 17 (`winget install Microsoft.OpenJDK.17`). Pedir aprobación antes de descargar. Comprobar: `flutter doctor` muestra Flutter y Android toolchain en verde (Xcode no aplica en Windows).
- [ ] **Step 2:** `git init` en la raíz; commit del spec y de este plan (`docs: add MVP spec and plan`).
- [ ] **Step 3:** `flutter create --org com.toaudit --project-name to_audit --platforms android,ios .`
- [ ] **Step 4:** Añadir dependencias con `flutter pub add` (las del Tech Stack; dev: `drift_dev build_runner mocktail` y `integration_test` del SDK). Activar `generate: true` y `flutter_lints`. `l10n.yaml`: `arb-dir: lib/l10n`, `template-arb-file: app_es.arb`, `output-localization-file: app_localizations.dart`. Asset `assets/fonts/NotoSansSC-Regular.ttf` (descarga de Google Fonts, con aprobación).
- [ ] **Step 5:** Escribir `test/smoke_test.dart` que abre `NativeDatabase.memory()`, ejecuta `select 1` y espera `1`. Ejecutar `flutter test test/smoke_test.dart` → PASS. Si falla por no encontrar la librería sqlite3 en Windows, resolverlo antes de seguir (usar la versión de `sqlite3` con librería empaquetada) y anotar la solución en el README.
- [ ] **Step 6:** `flutter build apk --debug` → termina sin error.
- [ ] **Step 7: Commit** `chore: scaffold Flutter app with dependencies`.

---

### Task 1: Money e IVA

**Files:**
- Create: `lib/domain/money.dart`
- Test: `test/domain/money_test.dart`

**Interfaces:**
- Produces:
  - `class Money implements Comparable<Money>`: `const Money(int cents)`, `static const zero`, `int get cents`, `+`, `-`, unario `-`, `Money abs()`, `bool get isZero`, `bool get isNegative`, `==`/`hashCode`, `Money multiplyRatio(int numerator, int denominator)` (redondeo mitad alejándose de cero), `static Money sum(Iterable<Money>)`.
  - `static Money parse(String input)` → lanza `FormatException`.
  - `String format(String locale)` (`'es'` | `'zh'`).
  - `class VatCalc`: `static ({Money vat, Money total}) fromBase(Money base, int vatPct)`, `static ({Money base, Money vat}) fromTotal(Money total, int vatPct)`. `vatPct ∈ {0, 4, 10, 21}`, si no `ArgumentError`.

- [ ] **Step 1: Tests**

```dart
test('parse accepts comma or dot, up to 2 decimals, trims', () {
  expect(Money.parse('12,5'), const Money(1250));
  expect(Money.parse('12.50'), const Money(1250));
  expect(Money.parse(' 7 '), const Money(700));
  expect(Money.parse('0,05'), const Money(5));
});
test('parse rejects thousands, negatives, 3 decimals, empty', () {
  for (final s in ['1.234,56', '-3', '12,345', '', 'abc', '1,2,3']) {
    expect(() => Money.parse(s), throwsFormatException, reason: s);
  }
});
test('format es and zh', () {
  String n(String s) => s.replaceAll(' ', ' ');
  expect(n(const Money(123456).format('es')), '1.234,56 €');
  expect(n(const Money(-1).format('es')), '-0,01 €');
  expect(n(const Money(123456).format('zh')), '€1,234.56');
});
test('multiplyRatio rounds half away from zero', () {
  expect(const Money(5).multiplyRatio(1, 2), const Money(3));
  expect(const Money(-5).multiplyRatio(1, 2), const Money(-3));
  expect(const Money(300000).multiplyRatio(15, 30), const Money(150000));
});
test('VAT from base and from total', () {
  expect(VatCalc.fromBase(const Money(1000), 10), (vat: const Money(100), total: const Money(1100)));
  expect(VatCalc.fromBase(const Money(5), 10), (vat: const Money(1), total: const Money(6)));
  expect(VatCalc.fromTotal(const Money(1210), 21), (base: const Money(1000), vat: const Money(210)));
  expect(VatCalc.fromTotal(const Money(100), 21), (base: const Money(83), vat: const Money(17)));
  expect(() => VatCalc.fromBase(const Money(100), 7), throwsArgumentError);
});
```

- [ ] **Step 2:** `flutter test test/domain/money_test.dart` → FAIL (no existe `Money`).
- [ ] **Step 3:** Implementar en `lib/domain/money.dart`. `fromTotal`: `base = total.multiplyRatio(100, 100 + vatPct)`, `vat = total - base`. `format` usa `NumberFormat.currency(locale: 'es_ES' | 'zh_CN', symbol: '€')`.
- [ ] **Step 4:** Ejecutar el test → PASS.
- [ ] **Step 5: Commit** `feat(domain): add Money and VAT calculations`.

---

### Task 2: Fechas, períodos y enums

**Files:**
- Create: `lib/domain/dates.dart`, `lib/domain/enums.dart`
- Test: `test/domain/dates_test.dart`

**Interfaces:**
- Produces:
  - `String ymd(DateTime d)`, `DateTime parseYmd(String s)` (UTC a medianoche), `String monthKey(DateTime d)` → `'2026-11'`, `DateTime dateOnly(DateTime d)`, `int daysInMonth(int year, int month)`.
  - `class DateRange { final DateTime start; final DateTime end; /* ambos inclusive */ int get days; bool contains(DateTime d); Iterable<DateTime> get dates; }`
  - `DateRange rangeToday(DateTime now)`, `DateRange rangeThisWeek(DateTime now)` (lunes a domingo), `DateRange rangeThisMonth(DateTime now)`, `DateRange rangeMonth(String monthKey)`, `DateRange rangeCustom(DateTime from, DateTime to)` (`ArgumentError` si `to < from`).
  - `enums.dart`: `enum DayStatus { open, closed, noActivity }`, `enum Shift { lunch, dinner }`, `enum PaymentKind { cash, card, other }`, `enum CategoryKind { purchase, other }`, `enum PaymentStatus { paid, pending }`, `enum ExpenseOrigin { manual, fixed }`, `enum FixedStatus { planned, confirmed }`, `enum Periodicity { monthly, bimonthly, quarterly, annual }` con `int get months` (1, 2, 3, 12), `enum ReceiptKind { photo, pdf }`. En BD se guardan por `name`.

- [ ] **Step 1: Tests:** `rangeThisWeek(DateTime.utc(2026,11,8))` (domingo) → `2026-11-02..2026-11-08`; `rangeThisWeek(DateTime.utc(2026,11,9))` → `2026-11-09..2026-11-15`; `rangeThisMonth(DateTime.utc(2026,2,10)).days == 28`; `rangeMonth('2028-02').days == 29`; `rangeCustom` invertido → `throwsArgumentError`; `ymd(parseYmd('2026-03-29')) == '2026-03-29'`; `rangeCustom(d1,d2).dates` con 2026-10-30..2026-11-02 da 4 fechas.
- [ ] **Step 2:** Ejecutar → FAIL.
- [ ] **Step 3:** Implementar.
- [ ] **Step 4:** Ejecutar → PASS.
- [ ] **Step 5: Commit** `feat(domain): add dates, ranges and enums`.

---

### Task 3: Cálculos de caja

**Files:**
- Create: `lib/domain/cash_calc.dart`
- Test: `test/domain/cash_calc_test.dart`

**Interfaces:**
- Consumes: `Money` (Task 1).
- Produces:
  - `const List<int> euroDenominations = [50000, 20000, 10000, 5000, 2000, 1000, 500, 200, 100, 50, 20, 10, 5, 2, 1];`
  - `Money countDenominations(Map<int, int> countByDenomination)`; `ArgumentError` si la clave no está en la lista o la cantidad es negativa.
  - `class CashInputs { final Money openingFloat, cashSales, cashTips, cashExpenses, withdrawals; }`
  - `Money expectedCash(CashInputs i)`
  - `Money cashDiscrepancy({required Money counted, required Money expected})` = contado − esperado
  - `Money cardDiscrepancy({required Money terminalTotal, required Money cardSales, required Money cardTips})` = datáfono − (ventas + propinas)
  - `bool requiresComment({required Money cashDiff, required Money cardDiff, required Money threshold})` → `cashDiff.abs() > threshold || cardDiff.abs() > threshold`

- [ ] **Step 1: Tests**

```dart
test('expected cash and 1 cent shortfall needs comment', () {
  final exp = expectedCash(const CashInputs(
    openingFloat: Money(20000), cashSales: Money(85040), cashTips: Money(1200),
    cashExpenses: Money(4530), withdrawals: Money(50000)));
  expect(exp, const Money(51710));
  final diff = cashDiscrepancy(counted: const Money(51709), expected: exp);
  expect(diff, const Money(-1));
  expect(requiresComment(cashDiff: diff, cardDiff: Money.zero, threshold: Money.zero), isTrue);
  expect(requiresComment(cashDiff: Money.zero, cardDiff: Money.zero, threshold: Money.zero), isFalse);
  expect(requiresComment(cashDiff: const Money(50), cardDiff: Money.zero, threshold: const Money(100)), isFalse);
});
test('card discrepancy includes card tips', () {
  expect(cardDiscrepancy(terminalTotal: const Money(152000), cardSales: const Money(150000), cardTips: const Money(2000)), Money.zero);
  expect(cardDiscrepancy(terminalTotal: const Money(151000), cardSales: const Money(150000), cardTips: const Money(2000)), const Money(-1000));
});
test('denomination count', () {
  expect(countDenominations({5000: 3, 2000: 2, 200: 1, 1: 7}), const Money(19207));
  expect(() => countDenominations({300: 1}), throwsArgumentError);
  expect(() => countDenominations({100: -1}), throwsArgumentError);
});
```

- [ ] **Step 2:** Ejecutar → FAIL. **Step 3:** Implementar. **Step 4:** Ejecutar → PASS.
- [ ] **Step 5: Commit** `feat(domain): add cash reconciliation calculations`.

---

### Task 4: Cuenta de resultados

**Files:**
- Create: `lib/domain/pnl_calc.dart`
- Test: `test/domain/pnl_calc_test.dart`

**Interfaces:**
- Consumes: `Money`, `DateRange`, `daysInMonth`, `rangeMonth`.
- Produces:
  - `class PayrollMonth { final String month; final Money cost; }` (cost = bruto + SS empresa)
  - `Money proratedPersonnel(List<PayrollMonth> months, DateRange range)`: por cada mes, `cost.multiplyRatio(díasDelRangoEnEseMes, daysInMonth)`, y suma.
  - `class PnlInputs { final DateRange range; final Money sales, purchases, fixedCosts, otherExpenses, pendingFixed, vatPaid; final int covers; final List<PayrollMonth> payroll; }`
  - `class PnlResult { final Money sales, purchases, fixedCosts, otherExpenses, personnel, profit, pendingFixed, vatPaid; final Money? averageTicket; final double? personnelPct; }`
  - `PnlResult computePnl(PnlInputs i)`: `profit = sales − purchases − fixedCosts − otherExpenses − personnel`; `averageTicket = covers == 0 ? null : sales.multiplyRatio(1, covers)`; `personnelPct = sales.isZero ? null : personnel.cents / sales.cents` (solo para mostrar).

- [ ] **Step 1: Tests:** mes completo de noviembre de 2026 con `PayrollMonth('2026-11', Money(300000))` → personal `300000`; `2026-11-01..15` → `150000`; `2026-10-25..2026-11-05` con oct `310000` y nov `300000` → `70000 + 50000 = 120000`; `computePnl` con ventas `3000000`, compras `900000`, fijos `300000`, otros `50000`, personal (mes completo) `900000` → beneficio `850000`; con comensales 1000 → ticket medio `3000`; comensales 0 → `averageTicket == null`; ventas 0 → `personnelPct == null`.
- [ ] **Step 2:** FAIL. **Step 3:** Implementar. **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(domain): add P&L and payroll proration`.

---

### Task 5: Reglas de alertas

**Files:**
- Create: `lib/domain/alerts_calc.dart`
- Test: `test/domain/alerts_calc_test.dart`

**Interfaces:**
- Consumes: `Money`, `DayStatus`, `PaymentStatus`, fechas.
- Produces:
  - `enum AlertType { discrepancy, dayUnregistered, dayOpen, missingReceipt, invoiceOverdue, floatMismatch, backupOld }`
  - `class Alert { final AlertType type; final String? recordId; final DateTime? date; }` (con `==`)
  - `class DaySnapshot { final String id; final DateTime date; final DayStatus status; final Money openingFloat; final Money? countedCash; final Money cashDiff; final Money cardDiff; Money? get closingFloat; }`: `closed` → `countedCash`; `noActivity` → `openingFloat`; `open` → `null`.
  - `class ExpenseSnapshot { final String id; final bool voided; final int receiptCount; final PaymentStatus paymentStatus; final DateTime? dueDate; }`
  - `class AlertInputs { final DateTime today; final List<DaySnapshot> days; final List<ExpenseSnapshot> expenses; final Set<String> closedMonths; final DateTime? lastBackup; }`
  - `List<Alert> computeAlerts(AlertInputs i)`
  - `bool backupReminderDue({required DateTime? lastBackup, required DateTime now, required int everyDays})` (`null` → `true`)
  - `bool backupWarningOnOpen({required DateTime? lastBackup, required DateTime now})` (> 14 días, o `null` cuando ya hay días registrados; el que llama decide).

- [ ] **Step 1: Tests** (cada regla de la tabla 6.4 del spec, con un caso que la dispara y otro que no):
  - Un día cerrado con `cashDiff -1` en un mes abierto → `discrepancy`; el mismo día con su mes en `closedMonths` → nada.
  - Días: primero `2026-11-01`, registrados el 1 y el 3, hoy `2026-11-05` → `dayUnregistered` para el 2 y el 4, y no para el 5 (hoy) ni para el 31 de octubre (antes del primer día).
  - Día abierto el 4 con hoy el 5 → `dayOpen`; día abierto hoy → nada.
  - Gasto no anulado con 0 justificantes → `missingReceipt`; anulado → nada.
  - Gasto `pending` con vencimiento ayer → `invoiceOverdue`; vencimiento hoy → nada; `paid` → nada.
  - Día 2 con `openingFloat 20000` y día 1 cerrado con contado `19000` → `floatMismatch` en el día 2; si el día 1 está abierto → nada. "Día anterior" = el día registrado más reciente con fecha menor, no necesariamente la fecha − 1.
  - `backupOld`: último backup hace 15 días → alerta; hace 14 → nada.
  - `backupReminderDue`: hace 7 días con `everyDays: 7` → `true`; hace 6 → `false`; `null` → `true`.
- [ ] **Step 2:** FAIL. **Step 3:** Implementar. **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(domain): add alert rules`.

---

### Task 6: Esquema de base de datos y semillas

**Files:**
- Create: `lib/data/db/tables.dart`, `lib/data/db/app_database.dart`, `build.yaml`
- Test: `test/data/db/app_database_test.dart`

**Interfaces:**
- Consumes: enums (Task 2).
- Produces:
  - Clases Drift en inglés con `tableName` igual al nombre del spec §5: `Days`→`dia_caja`, `Sales`→`venta`, `Covers`→`comensales`, `PaymentMethods`→`forma_pago`, `Suppliers`→`proveedor`, `ExpenseCategories`→`categoria_gasto`, `Expenses`→`gasto`, `Receipts`→`justificante`, `FixedCosts`→`gasto_fijo`, `Employees`→`empleado`, `PayrollPayments`→`pago_nomina`, `Withdrawals`→`retirada`, `WithdrawalTypes`→`tipo_retirada`, `Periods`→`periodo`, `ChangeLog`→`historial_cambio`, `SettingsTable`→`ajustes`. Columnas del spec §5 en camelCase; importes `IntColumn` con sufijo `Cents`; enums como `TextColumn` con `textEnum<T>()`; `recuento_billetes` como texto JSON.
  - Restricciones únicas: `Days.date`; `Sales (dayId, shift, paymentMethodId)`; `Covers (dayId, shift)`; `Periods.month`; `PayrollPayments (employeeId, month)` entre los no anulados (se comprueba en el repositorio); `Expenses (fixedCostId, date)` para los de origen fijo.
  - `class AppDatabase extends _$AppDatabase`: `AppDatabase(QueryExecutor e)`, `factory AppDatabase.memory()` (`NativeDatabase.memory()`), `int get schemaVersion => 1`, `MigrationStrategy` con `onCreate` que crea todo y llama a `seedDefaults()`, y `beforeOpen` con `PRAGMA foreign_keys = ON`.
  - Semillas (`code` → nombre ES/ZH en la app):
    - formas de pago en este orden: `cash`(cash), `card`(card), `bizum`(other), `vouchers`(other), `glovo`(other), `justeat`(other), `ubereats`(other);
    - categorías: `meat`, `fish`, `vegetables`, `drinks`, `groceries` (purchase); `cleaning`, `utilities`, `rent`, `insurance`, `selfemployed`, `advisor`, `other` (other);
    - tipos de retirada: `bank_deposit`, `owner`, `cash_payment`, `change`.
  - `String newId()` (uuid v4) y `String nowIso()` en `app_database.dart`.
  - Nombres de clases de datos fijados con `@DataClassName`: `Receipts` → `ReceiptData`, `ChangeLog` → `ChangeLogData` (los usan los Tasks 7, 11 y 17).

- [ ] **Step 1: Tests:** BD en memoria → hay 7 formas de pago en orden con los códigos de arriba, 12 categorías y 4 tipos de retirada; insertar dos `Days` con la misma fecha lanza `SqliteException`; `foreign_keys` está activo (insertar `Sales` con `dayId` inexistente falla).
- [ ] **Step 2:** `dart run build_runner build --delete-conflicting-outputs`, ejecutar el test → FAIL hasta implementar las semillas.
- [ ] **Step 3:** Implementar tablas y semillas; regenerar.
- [ ] **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(data): add Drift schema and default catalogs`.

---

### Task 7: Historial y bloqueo de períodos

**Files:**
- Create: `lib/data/audit/audit_writer.dart`, `lib/data/audit/period_guard.dart`, `lib/data/repositories/history_repository.dart`
- Test: `test/data/audit/audit_writer_test.dart`, `test/data/audit/period_guard_test.dart`

**Interfaces:**
- Consumes: `AppDatabase`.
- Produces:
  - `class AuditWriter { AuditWriter(AppDatabase db, {String author = 'owner', DateTime Function()? clock}); Future<void> inserted(String entity, String id, Map<String, Object?> values, {String? reason}); Future<void> updated(String entity, String id, Map<String, Object?> before, Map<String, Object?> after, {String? reason}); Future<void> event(String entity, String id, String field, {Object? oldValue, Object? newValue, String? reason}); }`. `inserted` escribe una fila con `campo = '*'`, `valor_anterior = null` y `valor_nuevo` = JSON de `values`. `updated` escribe una fila por clave cuyo valor cambia, y ninguna si nada cambia. Debe llamarse dentro de `db.transaction`. `hash_anterior` queda `null`.
  - `class PeriodLockedException implements Exception { final String kind; /* 'day' | 'month' */ final String key; }`
  - `class PeriodGuard { PeriodGuard(AppDatabase db); Future<void> ensureMonthOpen(DateTime date); Future<void> ensureDayOpen(DateTime date); }`. `ensureDayOpen` lanza `month` si el mes está cerrado, y `day` si el día existe en estado `closed` o `noActivity`.
  - `class HistoryRepository { Stream<List<ChangeLogData>> watchFor(String entity, String id); Stream<List<ChangeLogData>> watchAll({int limit = 200}); }` (solo lectura; no existe ningún método de escritura ni borrado).

- [ ] **Step 1: Tests:** `updated` con `{a:1,b:2}` → `{a:1,b:3}` escribe una fila (`campo b`, `2` → `3`); con valores iguales, ninguna; si la transacción lanza después de `updated`, no queda ninguna fila (rollback); `ensureDayOpen` sobre un día cerrado lanza `PeriodLockedException(kind: 'day')`; sobre un día de un mes cerrado lanza `kind: 'month'`; sobre un día sin fila no lanza.
- [ ] **Step 2:** FAIL. **Step 3:** Implementar. **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(data): add audit writer and period guard`.

---

### Task 8: Ajustes y catálogos

**Files:**
- Create: `lib/data/repositories/settings_repository.dart`, `lib/data/repositories/catalog_repository.dart`
- Test: `test/data/repositories/settings_repository_test.dart`, `test/data/repositories/catalog_repository_test.dart`

**Interfaces:**
- Consumes: `AppDatabase`, `AuditWriter`.
- Produces:
  - `class RestaurantInfo { final String name, nif, address; }`
  - `class SettingsRepository`: `Future<RestaurantInfo?> restaurant()`, `Future<void> setRestaurant(RestaurantInfo)`, `Future<String> locale()` (por defecto `'es'`), `Future<void> setLocale(String)`, `Future<Money> threshold()` (por defecto 0), `Future<void> setThreshold(Money)`, `Future<int> backupEveryDays()` (por defecto 7), `Future<void> setBackupEveryDays(int)` (1–60), `Future<DateTime?> lastBackupAt()`, `Future<void> setLastBackupAt(DateTime)`, `Future<Money> initialFloat()`, `Future<void> setInitialFloat(Money)`, `Future<bool> onboardingDone()`, `Future<void> setOnboardingDone()`, `Stream<String> watchLocale()`. Todos los cambios pasan por `AuditWriter` con entidad `ajustes`.
  - `class CatalogItem { final String id; final String? code; final String name; final bool active; final int order; final PaymentKind? paymentKind; final CategoryKind? categoryKind; }`
  - `enum CatalogKind { paymentMethod, expenseCategory, withdrawalType }`
  - `class CatalogRepository`: `Stream<List<CatalogItem>> watch(CatalogKind kind, {bool includeInactive = false})`, `Future<String> add(CatalogKind kind, String name, {PaymentKind? paymentKind, CategoryKind? categoryKind})`, `Future<void> rename(CatalogKind, String id, String name)`, `Future<void> setActive(CatalogKind, String id, bool active)`, `Future<void> reorder(CatalogKind, List<String> idsInOrder)`, `Future<CatalogItem> byId(CatalogKind, String id)` (devuelve también los inactivos).

- [ ] **Step 1: Tests:** valores por defecto (`threshold` 0, `backupEveryDays` 7, `locale` `'es'`); `setThreshold(Money(100))` escribe una fila de historial; `add(paymentMethod, 'Cheque', paymentKind: other)` aparece al final; `setActive(false)` lo quita de `watch` pero `byId` lo devuelve (Review Focus 2); `reorder` cambia el orden; nombre vacío → `ArgumentError`.
- [ ] **Step 2:** FAIL. **Step 3:** Implementar. **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(data): add settings and catalog repositories`.

---

### Task 9: Repositorio de días de caja

**Files:**
- Create: `lib/data/repositories/days_repository.dart`
- Test: `test/data/repositories/days_repository_test.dart`

**Interfaces:**
- Consumes: `AppDatabase`, `AuditWriter`, `PeriodGuard`, `SettingsRepository.threshold/initialFloat`, `cash_calc` (Task 3), `DaySnapshot` (Task 5).
- Produces:
  - `class SaleLine { final String paymentMethodId; final Shift shift; final Money amount; }`
  - `class DayDraft { final Money openingFloat; final Money? countedCash; final Map<int, int>? denominationCounts; final Money? terminalTotal; final Money cashTips, cardTips; final String? comment; final List<SaleLine> sales; final Map<Shift, int> covers; }`
  - `class DayRecord { final String id; final DateTime date; final DayStatus status; final DayDraft draft; final Money? cashDiff, cardDiff; final DateTime? closedAt; }`
  - `class DaySummary { final Money cashSales, cardSales, totalSales, cashExpenses, withdrawals, expected; final Money? cashDiff, cardDiff; final bool commentRequired; }`
  - `class CommentRequiredException implements Exception {}`, `class DayNotOpenException implements Exception {}`
  - `class DaysRepository`:
    - `Future<DayRecord> openDay(DateTime date)`: si existe, lo devuelve; si no, lo crea abierto con `openingFloat` = fondo final del día cerrado o sin actividad más reciente anterior a `date`, o `initialFloat()` si no hay ninguno. `ensureMonthOpen`.
    - `Future<DayRecord?> getDay(DateTime date)`, `Future<DayRecord> byId(String id)`, `Stream<List<DayRecord>> watchRange(DateRange r)`.
    - `Future<void> saveDraft(String dayId, DayDraft draft)`: exige estado `open` (si no, `DayNotOpenException`); hace upsert de `Sales` por (turno, forma de pago) y de `Covers`; audita cada campo cambiado. Si `denominationCounts != null`, `countedCash` debe ser igual a `countDenominations(...)` (`ArgumentError` si no).
    - `Future<DaySummary> summary(String dayId)`: suma las ventas por `PaymentKind`, las retiradas no anuladas del día y los gastos no anulados con `paidInCashDayId == dayId`.
    - `Future<void> closeDay(String dayId)`: calcula `summary`; si `commentRequired` y el comentario está vacío → `CommentRequiredException`; guarda `cashDiff`, `cardDiff`, `closedAt` y estado `closed` (las diferencias quedan fijas: cambiar luego el umbral no las toca); si el día siguiente por fecha existe y está `open`, pone su `openingFloat` = contado de este día. Todo en una transacción, con evento de historial `estado`.
    - `Future<void> markNoActivity(DateTime date)`: crea o actualiza el día a `noActivity` con `openingFloat` = fondo heredado y sin ventas; propaga el fondo igual que `closeDay`.
    - `Future<void> reopenDay(String dayId, String reason)`: `ensureMonthOpen`; motivo no vacío; estado a `open`; evento de historial con motivo.
    - `Future<DateTime?> nextPendingDate({required DateTime after, required DateTime today})`: primera fecha `> after` y `<= today` sin fila o con estado `open`.
    - `Future<List<DaySnapshot>> snapshots(DateRange r)`.

- [ ] **Step 1: Tests**
  - `openDay` del primer día usa `initialFloat`; del día siguiente al cerrado usa su contado.
  - Ejemplo del Task 3 a través del repositorio: ventas en efectivo `85040`, propinas en efectivo `1200`, gasto en efectivo `4530`, retirada `50000`, fondo `20000`, contado `51709` → `summary.cashDiff == Money(-1)` y `commentRequired`; `closeDay` sin comentario → `CommentRequiredException`; con comentario → `closed`.
  - Cerrar el 31 de octubre con el 1 de noviembre abierto → el 1 de noviembre pasa a tener `openingFloat` = contado del 31 (Review Focus 1).
  - Reabrir un día y volver a cerrarlo con otro contado, con el día siguiente cerrado → el día siguiente no cambia.
  - `saveDraft` sobre un día cerrado → `DayNotOpenException`.
  - Cerrar un día con descuadre `-1`, cambiar el umbral a `Money(100)` → `byId(...).cashDiff` sigue siendo `-1` (Review Focus 2).
  - Ventas con una forma de pago desactivada después de cerrar → `summary` sigue sumándola (Review Focus 2).
  - `markNoActivity` → estado `noActivity`, el siguiente hereda el mismo fondo.
  - `nextPendingDate`: con el 1 y el 2 cerrados y hoy el 4 → el 3.
  - `denominationCounts` que no cuadra con `countedCash` → `ArgumentError`.
- [ ] **Step 2:** FAIL. **Step 3:** Implementar. **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(data): add cash day repository with close and reopen`.

---

### Task 10: Retiradas

**Files:**
- Create: `lib/data/repositories/withdrawals_repository.dart`
- Test: `test/data/repositories/withdrawals_repository_test.dart`

**Interfaces:**
- Consumes: `AuditWriter`, `PeriodGuard.ensureDayOpen`, `Days`.
- Produces:
  - `class WithdrawalRecord { final String id, dayId, typeId; final DateTime date; final Money amount; final String? note; final bool voided; final String? voidReason; }`
  - `class WithdrawalsRepository`: `Future<String> add({required String dayId, required Money amount, required String typeId, String? note})` (importe > 0), `Future<void> update(String id, {Money? amount, String? typeId, String? note})`, `Future<void> voidRecord(String id, String reason)`, `Stream<List<WithdrawalRecord>> watchDay(String dayId)`, `Stream<List<WithdrawalRecord>> watchRange(DateRange r)`, `Future<Map<String, Money>> totalsByType(DateRange r)` (sin anuladas; clave = typeId).

- [ ] **Step 1: Tests:** `add` en un día cerrado → `PeriodLockedException`; anular quita la retirada de `totalsByType` y de `DaysRepository.summary(...).withdrawals`; `voidRecord` sin motivo → `ArgumentError`; importe 0 → `ArgumentError`.
- [ ] **Step 2:** FAIL. **Step 3:** Implementar. **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(data): add withdrawals repository`.

---

### Task 11: Proveedores, gastos y justificantes

**Files:**
- Create: `lib/data/repositories/suppliers_repository.dart`, `lib/data/repositories/expenses_repository.dart`, `lib/data/files/receipt_store.dart`
- Test: `test/data/repositories/expenses_repository_test.dart`, `test/data/files/receipt_store_test.dart`

**Interfaces:**
- Consumes: `AuditWriter`, `PeriodGuard`, `VatCalc`, `ExpenseSnapshot`.
- Produces:
  - `class SupplierInput { final String name; final String? nif, phone, defaultCategoryId; }`, `class SupplierRecord` (+ `id`).
  - `SuppliersRepository`: `Future<String> create(SupplierInput)`, `Future<void> update(String id, SupplierInput)`, `Stream<List<SupplierRecord>> watchAll()`, `Future<List<SupplierRecord>> search(String query)` (sin distinguir mayúsculas; por nombre o NIF).
  - `typedef ImageCompressor = Future<List<int>> Function(File source, {int maxSide, int quality});`
  - `class ReceiptStore { ReceiptStore(Directory root, {ImageCompressor? compressor}); Future<String> save(File source, ReceiptKind kind); File fileFor(String relativePath); }`. Las fotos se comprimen con `maxSide: 1600, quality: 75` y se guardan como `receipts/<uuid>.jpg`; los PDF se copian a `receipts/<uuid>.pdf`. Devuelve la ruta relativa. El compresor por defecto usa `flutter_image_compress`.
  - `class ExpenseInput { final DateTime date; final String? supplierId; final String categoryId; final String? invoiceNumber; final Money base; final int vatPct; final Money vat; final Money total; final String paymentMethodId; final String? paidInCashDayId; final PaymentStatus paymentStatus; final DateTime? dueDate; }`. Validación: `base + vat == total` y `vatPct ∈ {0,4,10,21}`, si no `ArgumentError`.
  - `class ExpenseRecord { /* campos de ExpenseInput + */ final String id; final ExpenseOrigin origin; final String? fixedCostId; final FixedStatus? fixedStatus; final bool voided; final String? voidReason; final int receiptCount; bool get incomplete => receiptCount == 0; }`
  - `ExpensesRepository`: `Future<String> create(ExpenseInput)`, `Future<void> update(String id, ExpenseInput)`, `Future<void> voidRecord(String id, String reason)`, `Future<void> markPaid(String id, bool paid)`, `Future<void> attachReceipt(String expenseId, File source, ReceiptKind kind)`, `Future<List<ReceiptData>> receipts(String expenseId)`, `Stream<List<ExpenseRecord>> watchRange(DateRange r)`, `Stream<List<ExpenseRecord>> watchPending()` (pendientes y no anulados, por vencimiento ascendente, sin vencimiento al final), `Future<Map<String, Money>> totalsBySupplier(DateRange)`, `Future<Map<String, Money>> totalsByCategory(DateRange)`, `Future<List<ExpenseSnapshot>> snapshots()`.
  - Bloqueos: `ensureMonthOpen(date)`; si hay `paidInCashDayId`, también `ensureDayOpen` de ese día.

- [ ] **Step 1: Tests:** `create` con base `1000`, IVA 10, iva `100` y total `1100` → ok; total `1101` → `ArgumentError`; gasto sin justificantes → `incomplete`; tras `attachReceipt` → no; `watchPending` ordena por vencimiento con los nulos al final; gasto en efectivo vinculado a un día cerrado → `PeriodLockedException`; `voidRecord` lo saca de `totalsByCategory`. `ReceiptStore` con compresor falso (devuelve 3 bytes) guarda `receipts/<uuid>.jpg` con 3 bytes y recibe `maxSide: 1600, quality: 75`; con un PDF copia los bytes intactos.
- [ ] **Step 2:** FAIL. **Step 3:** Implementar. **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(data): add suppliers, expenses and receipts`.

---

### Task 12: Gastos fijos y nóminas

**Files:**
- Create: `lib/data/repositories/fixed_costs_repository.dart`, `lib/data/repositories/payroll_repository.dart`
- Test: `test/data/repositories/fixed_costs_repository_test.dart`, `test/data/repositories/payroll_repository_test.dart`

**Interfaces:**
- Consumes: `ExpensesRepository` (para crear gastos de origen fijo), `AuditWriter`, `PeriodGuard`, `PayrollMonth`.
- Produces:
  - `class FixedCostInput { final String concept, categoryId; final Money plannedAmount; final int vatPct; final Periodicity periodicity; final int chargeDay; /* 1–31 */ final String startMonth; /* 'YYYY-MM' */ }`
  - `FixedCostsRepository`: `Future<String> create(FixedCostInput)`, `Future<void> update(String id, FixedCostInput)`, `Future<void> setActive(String id, bool)`, `Stream<List<FixedCostRecord>> watchAll()`, `Future<int> generateDue(DateTime today)`, `Future<void> confirm(String expenseId, Money actualTotal)`.
    - `generateDue`: para cada fijo activo y cada mes `m` desde `startMonth` hasta `monthKey(today)` en que `(meses entre startMonth y m) % periodicity.months == 0`, crea un gasto planificado con fecha = `chargeDay` limitado al último día del mes, base/IVA desde `plannedAmount` con `VatCalc.fromTotal`, `PaymentStatus.pending`, vencimiento = esa fecha, si no existe ya uno para (fijo, fecha). Se salta los meses cerrados. Devuelve cuántos ha creado.
    - `confirm`: pone `fixedStatus = confirmed` y recalcula base/IVA desde `actualTotal`.
  - `FixedCostRecord`, `EmployeeRecord` y `PayrollPaymentRecord`: los campos de su `Input` (o de su tabla) más `id`, `active`/`voided` y `voidReason` donde aplique.
  - `class EmployeeInput { final String name, role; final DateTime hiredOn; final DateTime? leftOn; }`
  - `class PayrollRow { final EmployeeRecord employee; final PayrollPaymentRecord? payment; }`
  - `PayrollRepository`: `Future<String> createEmployee(EmployeeInput)`, `Future<void> updateEmployee(String id, EmployeeInput)`, `Stream<List<EmployeeRecord>> watchEmployees()`, `Future<List<PayrollRow>> month(String monthKey)` (empleados activos en algún día de ese mes), `Future<void> savePayment({required String employeeId, required String month, required Money gross, required Money net, required Money employerSs, required String paymentMethodId})` (upsert del pago no anulado; `ensureMonthOpen`), `Future<void> voidPayment(String id, String reason)`, `Future<List<PayrollMonth>> costs(DateRange r)` (bruto + SS empresa por mes que toca el rango).

- [ ] **Step 1: Tests:** un fijo trimestral desde `2026-09` con día 31, ejecutado con hoy `2026-12-05` → crea `2026-09-30` y `2026-12-31` (2); ejecutarlo dos veces no duplica; un fijo mensual desde `2026-02` con día 31 → `2026-02-28`; `confirm(id, Money(12100))` con IVA 21 → base `10000`, IVA `2100`, `confirmed`; un empleado dado de baja el `2026-10-15` sale en octubre y no en noviembre; `savePayment` dos veces en el mismo mes deja un solo pago; `costs(rangeMonth('2026-11'))` devuelve bruto + SS.
- [ ] **Step 2:** FAIL. **Step 3:** Implementar. **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(data): add fixed costs generation and payroll`.

---

### Task 13: Cierre y reapertura de mes

**Files:**
- Create: `lib/data/repositories/periods_repository.dart`
- Test: `test/data/repositories/periods_repository_test.dart`

**Interfaces:**
- Consumes: `DaysRepository.snapshots`, `AuditWriter`.
- Produces:
  - `class MonthNotReadyException implements Exception { final List<DateTime> pendingDates; }`
  - `PeriodsRepository`: `Future<bool> isClosed(String monthKey)`, `Stream<Set<String>> watchClosed()`, `Future<void> closeMonth(String monthKey, {required DateTime today})`, `Future<void> reopenMonth(String monthKey, String reason)`.
    - `closeMonth`: las fechas pendientes son las de `max(inicio de mes, primer día registrado)` a `min(fin de mes, today)` sin fila o con estado `open`. Si hay alguna → `MonthNotReadyException` con la lista; si no, se guarda `closed` y `cerrado_en`, con evento de historial.

- [ ] **Step 1: Tests:** octubre con todos los días cerrados o sin actividad → se cierra; después `DaysRepository.reopenDay` de un día de octubre → `PeriodLockedException(kind: 'month')` (Review Focus 1); `ExpensesRepository.create` con fecha de octubre → lanza; `reopenMonth` sin motivo → `ArgumentError`; noviembre con el día 3 sin registrar → `MonthNotReadyException([2026-11-03])`.
- [ ] **Step 2:** FAIL. **Step 3:** Implementar. **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(data): add month close and reopen`.

---

### Task 14: Servicios de informes y alertas

**Files:**
- Create: `lib/data/reports/report_service.dart`, `lib/data/reports/alerts_service.dart`
- Test: `test/data/reports/report_service_test.dart`, `test/data/reports/alerts_service_test.dart`

**Interfaces:**
- Consumes: todos los repositorios, `computePnl`, `computeAlerts`, `FixedCostsRepository.generateDue`.
- Produces:
  - `class DayRow { final DateTime date; final DayStatus status; final Money sales; final int covers; final Money expenses, cashDiff, cardDiff; }`
  - `class ReportData { final DateRange range; final PnlResult pnl; final List<DayRow> days; final Map<String, Money> salesByPaymentMethod; final Money withdrawalsTotal; final Map<String, Money> withdrawalsByType; final Money cashDiscrepancyTotal, cardDiscrepancyTotal; final List<ExpenseRecord> expenses; final List<PayrollRow> payroll; }`
  - `class HomeSummary { final Money monthSales; final Money profitToDate; final DateTime? lastClosedDay; final DateTime? nextPending; }`
  - `ReportService`: `Future<ReportData> build(DateRange range)`, `Future<HomeSummary> home(DateTime today)`.
    - Ventas y comensales: solo de días `closed`. Compras: gastos manuales no anulados con categoría `purchase`. Fijos: origen `fixed` y `confirmed`. Pendientes: origen `fixed` y `planned`. Otros: el resto de gastos no anulados. IVA soportado: suma del IVA de los gastos que cuentan. Personal: `proratedPersonnel(costs(range), range)`.
    - `home`: ventas del mes en curso; beneficio de `inicio de mes .. último día cerrado del mes`.
  - `AlertsService`: `Future<List<Alert>> current(DateTime today)` (llama antes a `generateDue(today)`).

- [ ] **Step 1: Tests:** un escenario de noviembre con 2 días cerrados (ventas `150000` y `120000`, comensales 50 y 40), 1 día abierto (ventas `99999`, que no deben contar), una compra de carne `30000`, un fijo de alquiler confirmado `100000`, un fijo de luz planificado `20000`, un gasto de limpieza `5000` y una nómina de bruto + SS `90000` → con `rangeMonth('2026-11')`: ventas `270000`, compras `30000`, fijos `100000`, pendientes `20000`, otros `5000`, personal `90000`, beneficio `45000`, ticket medio `3000`. `home(2026-11-08)` → `monthSales 270000`. Alertas: el día abierto anterior a hoy → `dayOpen`.
- [ ] **Step 2:** FAIL. **Step 3:** Implementar. **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(data): add report and alerts services`.

---

### Task 15: Seguridad: clave de BD, PIN, biometría y BD cifrada

**Files:**
- Create: `lib/data/security/key_store.dart`, `lib/data/security/db_key_manager.dart`, `lib/data/security/pin_manager.dart`, `lib/data/security/biometric_auth.dart`, `lib/data/db/open_database.dart`
- Test: `test/data/security/pin_manager_test.dart`, `test/data/security/db_key_manager_test.dart`, `integration_test/encrypted_db_test.dart`

**Interfaces:**
- Produces:
  - `abstract class KeyStore { Future<String?> read(String key); Future<void> write(String key, String value); Future<void> delete(String key); }`; `SecureKeyStore` (flutter_secure_storage) y `MemoryKeyStore` (tests).
  - `class DbKeyManager { DbKeyManager(KeyStore s); Future<String> getOrCreateKey(); /* 64 hex = 32 bytes de Random.secure */ Future<String?> existingKey(); }`
  - `sealed class PinResult`: `PinOk`, `PinWrong(int attemptsLeftBeforeLock)`, `PinLocked(Duration remaining)`.
  - `class PinManager { PinManager(KeyStore s, {DateTime Function()? clock, int iterations = 100000}); Future<bool> hasPin(); Future<void> setPin(String pin); /* exactamente 6 dígitos, si no ArgumentError */ Future<PinResult> verify(String pin); }`. El hash es PBKDF2-HMAC-SHA256 (paquete `cryptography`) con sal aleatoria de 16 bytes. Tras 5 fallos seguidos queda bloqueado 30 s; cada fallo siguiente dobla el bloqueo (60, 120…). Un acierto lo reinicia. El contador y el instante de desbloqueo se guardan en `KeyStore`.
  - `class BiometricAuth { Future<bool> isAvailable(); Future<bool> authenticate(String localizedReason); }`
  - `Future<AppDatabase> openEncryptedDatabase({required File file, required String hexKey})`: `NativeDatabase.createInBackground(file, setup: (db) { db.execute("PRAGMA key = \"x'$hexKey'\""); db.select('select count(*) from sqlite_master'); })`, con `open.overrideFor(OperatingSystem.android, openCipherOnAndroid)` y `applyWorkaroundToOpenSqlCipherOnOldAndroidVersions()`. Si hay archivo de BD pero `existingKey()` es null → `DatabaseKeyMissingException` (nunca crea una BD nueva encima).

- [ ] **Step 1: Tests unitarios** (con `iterations: 1000` y un reloj falso): `setPin('12345')` → `ArgumentError`; un acierto → `PinOk`; 4 fallos → `PinWrong(1)`; el 5.º → `PinLocked(30 s)`; durante el bloqueo, incluso con el PIN correcto → `PinLocked`; a los 31 s, otro fallo → `PinLocked(60 s)`; un acierto después reinicia el contador. `getOrCreateKey` devuelve 64 caracteres hex y lo mismo en la segunda llamada.
- [ ] **Step 2:** FAIL. **Step 3:** Implementar. **Step 4:** PASS.
- [ ] **Step 5: Test de integración en Android** (`integration_test/encrypted_db_test.dart`): crear la BD con la clave A, insertar un día y cerrar; abrir con la clave B → lanza; abrir con la clave A → el día está; los primeros 16 bytes del archivo no son `"SQLite format 3\0"`. Ejecutar `flutter test integration_test/encrypted_db_test.dart -d <emulador>` → PASS.
- [ ] **Step 6: Commit** `feat(security): add PIN, key management and encrypted database`.

---

### Task 16: Copia de seguridad `.toaudit`

**Files:**
- Create: `lib/data/backup/toaudit_format.dart`, `lib/data/backup/db_snapshotter.dart`, `lib/data/backup/backup_service.dart`
- Test: `test/data/backup/toaudit_format_test.dart`, `test/data/backup/backup_service_test.dart`

**Interfaces:**
- Consumes: `AppDatabase`, `ReceiptStore` (raíz de archivos), `SettingsRepository.setLastBackupAt`, `DbKeyManager`.
- Produces:
  - `class ToauditFormat { static const magic = 'TOAUDIT1'; static const version = 1; static const blockSize = 1 << 20; static Future<void> encrypt(Stream<List<int>> plain, IOSink out, String password, {int iterations = 600000}); static Stream<List<int>> decrypt(File input, String password); }`; `class BackupDecryptException implements Exception` (contraseña errónea, archivo dañado o truncado).
  - Formato:

    ```
    cabecera: magic(8) | version u16 BE | salt(16) | iterations u32 BE | noncePrefix(4)
    bloque*:  isLast u8 | len u32 BE | ciphertext(len) | tag(16)
    nonce = noncePrefix(4) ‖ índice de bloque u64 BE ; AAD = isLast(1) ‖ índice u64 BE
    clave = PBKDF2-HMAC-SHA256(password, salt, iterations, 32 bytes) ; cifrado AES-256-GCM
    ```

    Si el archivo termina sin un bloque `isLast = 1` → `BackupDecryptException`.
  - `abstract class DbSnapshotter { Future<void> exportPlain(File dest); Future<void> importPlain(File src, File destEncrypted, String hexKey); }`. `SqlCipherSnapshotter`: `ATTACH ... KEY ''` + `sqlcipher_export`. `PlainSnapshotter` (tests): `VACUUM INTO` / copia de archivo.
  - `class BackupPreview { final File decryptedDir; final DateTime createdAt; final int schemaVersion, days, expenses; }`
  - `class BackupTooNewException implements Exception {}`
  - `class BackupService { BackupService({required AppDatabase db, required DbSnapshotter snapshotter, required Directory filesRoot, required Directory tempRoot, required SettingsRepository settings, required Future<void> Function() closeDb, required Future<void> Function() reopenDb, required File dbFile, required Future<String> Function() hexKey, int iterations = 600000}); Future<File> export(String password, {required DateTime now}); Future<BackupPreview> inspect(File backup, String password); Future<void> restore(BackupPreview preview); }`
    - `export`: contraseña de al menos 8 caracteres (si no, `ArgumentError`); crea `to-audit-YYYY-MM-DD.toaudit` en `tempRoot`; el ZIP contiene `db.sqlite`, `receipts/...` y `manifest.json` (`{schemaVersion, createdAt, days, expenses, files: {ruta: sha256}}`); llama a `setLastBackupAt(now)`.
    - `inspect`: descifra a una carpeta temporal, comprueba todos los SHA-256 (si alguno no cuadra, `BackupDecryptException`), y si `schemaVersion > AppDatabase.schemaVersion` → `BackupTooNewException`.
    - `restore`: `closeDb()`; renombra la BD y `receipts/` actuales a `.bak`; `importPlain` y copia los justificantes; `reopenDb()`; borra los `.bak`. Si cualquier paso lanza, devuelve los `.bak` a su sitio, `reopenDb()` y vuelve a lanzar.

- [ ] **Step 1: Tests de formato** (`iterations: 1000`): ida y vuelta de 3,5 MB aleatorios → bytes idénticos; contraseña errónea → `BackupDecryptException`; archivo sin su último bloque → `BackupDecryptException`; un byte cambiado en un bloque → `BackupDecryptException`.
- [ ] **Step 2: Tests del servicio** (`PlainSnapshotter`, BD de archivo en una carpeta temporal): exportar → restaurar en una BD vacía → mismo número de días y gastos, y los justificantes con los mismos bytes; si `importPlain` lanza, la BD original sigue abriendo con sus datos (Review Focus 3); un `manifest.json` con `schemaVersion: 99` → `BackupTooNewException`; contraseña `'1234567'` → `ArgumentError`.
- [ ] **Step 3:** Ejecutar → FAIL. **Step 4:** Implementar. **Step 5:** Ejecutar → PASS.
- [ ] **Step 6: Commit** `feat(backup): add encrypted .toaudit export and restore`.

---

### Task 17: Exportación PDF, Excel, CSV y ZIP para el gestor

**Files:**
- Create: `lib/data/export/pdf_report.dart`, `lib/data/export/xlsx_export.dart`, `lib/data/export/csv_zip_export.dart`, `lib/data/export/gestor_zip_export.dart`
- Test: `test/data/export/export_test.dart`

**Interfaces:**
- Consumes: `ReportData`, `RestaurantInfo`, `ReceiptStore.fileFor`, `CatalogRepository.byId` (nombres), `AppLocalizations` mediante una función `String Function(String key)` pasada como `labels`.
- Produces:
  - `Future<Uint8List> buildPdfReport({required ReportData data, required RestaurantInfo restaurant, required String locale, required DateTime generatedAt, required ExportLabels labels, required ByteData cjkFont})`: cabecera con nombre y NIF del restaurante, período, fecha de generación; totales de ventas, gastos (compras + fijos + otros), nóminas, retiradas, descuadres de efectivo y tarjeta, beneficio; tabla diaria. Todo el texto usa `pw.Font.ttf(cjkFont)`.
  - `List<int> buildXlsx(ReportData data, ExportLabels labels)`: hojas `Resumen`, `Días`, `Ventas`, `Gastos`, `Nóminas`, `Retiradas` (nombres de hoja desde `labels`), importes como número con 2 decimales.
  - `List<int> buildCsvZip(ReportData data, ExportLabels labels)`: un CSV por hoja, UTF-8 con BOM, separador `;` y coma decimal cuando `locale == 'es'`.
  - `String receiptFileName({required DateTime date, String? supplier, String? invoice, required int index, required String ext})`: `'${ymd(date)}_${s(supplier ?? 'sin-proveedor')}_${s(invoice ?? 'sin-numero')}_$index.$ext'`, donde `s` cambia los espacios y los caracteres `\/:*?"<>|` por `-`, junta los `-` seguidos, quita los `-` de los extremos y conserva las letras Unicode.
  - `Future<File> buildGestorZip({required List<ExpenseRecord> expenses, required Map<String, List<ReceiptData>> receipts, required ReceiptStore store, required Directory out, required ExportLabels labels, required String Function(String? supplierId) supplierName})`: `gastos.csv` y `justificantes/<receiptFileName>`.
  - `class ExportLabels` con `String Function(String key) t` y `String locale`.

- [ ] **Step 1: Tests:** `receiptFileName(date: 2026-11-03, supplier: '蔬菜店 / Hnos. García', invoice: 'F 12/3', index: 1, ext: 'jpg')` → `'2026-11-03_蔬菜店-Hnos.-García_F-12-3_1.jpg'` (Review Focus 4); el CSV empieza por los bytes `EF BB BF` y contiene `'蔬菜店'` (Review Focus 4); el XLSX se vuelve a leer con `excel` y tiene 6 hojas, y `Resumen` tiene el beneficio `450,00`/`450.0`; el PDF del escenario del Task 14 no está vacío, empieza por `%PDF` y se genera sin excepción con un proveedor en chino usando la fuente real de `assets/fonts` (cargada con `File` en el test); el ZIP del gestor contiene `gastos.csv` y un archivo por justificante.
- [ ] **Step 2:** FAIL. **Step 3:** Implementar. **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(export): add PDF, XLSX, CSV and accountant ZIP exports`.

---

### Task 18: Shell de la app: providers, rutas, tema, idiomas, bloqueo y primer arranque

**Files:**
- Create: `lib/data/providers.dart`, `lib/app.dart`, `lib/router.dart`, `lib/features/lock/lock_screen.dart`, `lib/features/lock/app_lock_controller.dart`, `lib/features/onboarding/onboarding_flow.dart`, `lib/features/common/auth_gate.dart`, `lib/features/common/money_field.dart`, `lib/features/common/confirm_reason_dialog.dart`, `lib/features/common/catalog_label.dart`
- Modify: `lib/main.dart`, `lib/l10n/app_es.arb`, `lib/l10n/app_zh.arb`
- Test: `test/features/lock/app_lock_controller_test.dart`, `test/features/common/money_field_test.dart`, `test/l10n_test.dart`

**Interfaces:**
- Consumes: todos los repositorios y servicios, `PinManager`, `BiometricAuth`, `openEncryptedDatabase`.
- Produces:
  - `providers.dart`: `databaseProvider` (sobrescrito en `main` y en los tests), un `Provider` por repositorio y servicio, `clockProvider` (`DateTime Function()`, sobrescribible), `localeProvider` (de `SettingsRepository.watchLocale`).
  - `class AppLockController extends Notifier<bool /* locked */>`: `void onPaused(DateTime t)`, `void onResumed(DateTime t)` (bloquea si `t - pausa >= 5 min`), `void unlock()`, `void lock()`.
  - `Future<bool> requireAuth(BuildContext, WidgetRef, {required String reason})` en `auth_gate.dart`: biometría si está disponible y activada; si no, o si falla, PIN.
  - `Future<String?> askReason(BuildContext, {required String title})`: diálogo con motivo obligatorio.
  - `MoneyField` (`TextFormField` con `TextInputType.numberWithOptions(decimal: true)`, `validator` basado en `Money.parse`, `onChanged(Money?)`).
  - `String catalogLabel(AppLocalizations l, CatalogItem item)`: el nombre traducido de su `code` o, si no tiene, `item.name`.
  - Rutas: `/onboarding`, `/` (inicio), `/calendar`, `/day/:ymd`, `/expenses`, `/expenses/new`, `/expenses/:id`, `/suppliers`, `/fixed-costs`, `/payroll/:month`, `/withdrawals`, `/reports`, `/alerts`, `/history`, `/settings`, `/settings/catalogs/:kind`, `/backup`. Se redirige a `/onboarding` si `onboardingDone()` es falso.
  - Primer arranque (spec 6.1): idioma → datos del restaurante → PIN dos veces (y aviso de que, sin biometría, olvidarlo obliga a restaurar una copia) → activar biometría si `isAvailable` → fondo inicial → `setOnboardingDone`.
  - `main.dart`: `DbKeyManager` → `openEncryptedDatabase`; si lanza `DatabaseKeyMissingException`, muestra una pantalla de error con el botón "Restaurar copia" (spec §10).
  - Tema: Material 3, `ThemeMode.system`, `colorSchemeSeed` y `minimumSize` de 48×48 en los botones.

- [ ] **Step 1: Tests:** `AppLockController`: pausa a las 10:00, vuelta a las 10:04:59 → sigue desbloqueado; vuelta a las 10:05 → bloqueado. `MoneyField`: escribir `'12,5'` llama a `onChanged(Money(1250))`; `'-3'` muestra el error de validación y no lanza (Review Focus 5). `l10n_test.dart`: lee los dos ARB y comprueba que tienen el mismo conjunto de claves (sin las `@`) y ningún valor vacío.
- [ ] **Step 2:** FAIL. **Step 3:** Implementar. **Step 4:** PASS.
- [ ] **Step 5:** `flutter run` en el emulador: el primer arranque termina en el inicio; la app se bloquea tras 5 minutos en segundo plano; cambiar el idioma a chino cambia los textos.
- [ ] **Step 6: Commit** `feat(app): add app shell, lock, onboarding and localization`.

---

### Task 19: Inicio y calendario

**Files:**
- Create: `lib/features/home/home_screen.dart`, `lib/features/calendar/calendar_screen.dart`, `lib/features/calendar/month_grid.dart`
- Test: `test/features/calendar/month_grid_test.dart`, `test/features/home/home_screen_test.dart`

**Interfaces:**
- Consumes: `ReportService.home`, `AlertsService.current`, `DaysRepository.watchRange/nextPendingDate/markNoActivity`, `backupReminderDue`, `backupWarningOnOpen`.
- Produces:
  - `enum DayCellState { unregistered, open, balanced, discrepancy, noActivity, future }` y `DayCellState cellState(DayRecord? d, DateTime date, DateTime today)`: cerrado con las dos diferencias en 0 → `balanced`; cerrado con alguna distinta de 0 → `discrepancy`.
  - `MonthGrid({required int year, required int month, required Map<DateTime, DayCellState> states, required void Function(DateTime) onTap, required void Function(DateTime) onLongPress})`: semana de lunes a domingo, color por estado y además un icono o texto (el color no es la única señal, por accesibilidad).
  - Inicio: ventas del mes, beneficio acumulado, botón "Registrar siguiente día pendiente" (→ `/day/<nextPending>`, oculto si no hay ninguno), contador de alertas (→ `/alerts`), banner de copia si toca (→ `/backup`), y accesos a gastos, informes y ajustes.
  - Calendario: pulsar un día → `/day/:ymd`; pulsación larga en un día sin registrar → "Marcar sin actividad".

- [ ] **Step 1: Tests:** `cellState` para cada estado; `MonthGrid` de noviembre de 2026 empieza con la celda del lunes 26 de octubre vacía y el domingo 1 de noviembre en la 7.ª columna; widget test del inicio con un `ReportService` falso → muestra `2.700,00 €` y el botón apunta al día pendiente.
- [ ] **Step 2:** FAIL. **Step 3:** Implementar. **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(ui): add home and calendar`.

---

### Task 20: Pantalla de registro y cierre de día

**Files:**
- Create: `lib/features/day_close/day_close_screen.dart`, `lib/features/day_close/day_close_controller.dart`, `lib/features/day_close/denomination_counter.dart`, `lib/features/day_close/quick_withdrawal_sheet.dart`, `lib/features/day_close/quick_cash_expense_sheet.dart`
- Test: `test/features/day_close/day_close_screen_test.dart`, `test/features/day_close/day_close_controller_test.dart`

**Interfaces:**
- Consumes: `DaysRepository`, `WithdrawalsRepository.add`, `ExpensesRepository.create`, `CatalogRepository.watch(paymentMethod)`, `requireAuth`, `askReason`, `MoneyField`.
- Produces:
  - `DayCloseController`: un `AsyncNotifier` con parámetro de familia `DateTime` y estado `DayCloseState` (usar la forma que exija la versión de Riverpod instalada): `build(date)` → `openDay(date)` y `summary`; `void setSale(String paymentMethodId, Shift shift, Money? amount)`, `setCovers(Shift, int)`, `setTips({Money? cash, Money? card})`, `setCountedTotal(Money?)`, `setDenominations(Map<int,int>)`, `setTerminalTotal(Money?)`, `setOpeningFloat(Money)`, `setComment(String)`; cada cambio llama a `saveDraft` con un debounce de 300 ms y recalcula `summary`; `Future<DateTime?> close()` → cierra y devuelve `nextPendingDate`; `Future<void> reopen(String reason)`.
  - Pantalla (orden del spec 6.2): ventas por forma de pago activa (las inactivas con importe se muestran también) × turno, en el orden del catálogo; comensales comida y cena; propinas; lista de retiradas y gastos en efectivo con "+"; recuento con un conmutador Total / Billetes y monedas; total del datáfono; tarjeta de resultado con esperado, descuadre de efectivo y descuadre de tarjeta, cada uno con "Sobra"/"Falta"; comentario (obligatorio si hace falta); botón "Cerrar día". Un día cerrado se muestra en solo lectura con el botón "Reabrir" (→ `requireAuth` + `askReason`).
  - Al cerrar: `context.go('/day/<siguiente>')` o, si no hay, vuelta al inicio con un `SnackBar`.

- [ ] **Step 1: Tests del controlador** (repositorios reales sobre BD en memoria): los cambios rápidos se agrupan en un solo `saveDraft` (debounce); `close()` con descuadre y sin comentario expone un error de estado `commentRequired` en vez de lanzar.
- [ ] **Step 2: Widget tests:** con los importes del Task 3 → se ve `-0,01 €` y "Falta"; "Cerrar día" está desactivado hasta escribir un comentario; con todo cuadrado se cierra sin comentario y navega al siguiente día; `'1.234,56'` en un importe muestra el error de formulario (Review Focus 5); el modo Billetes con 3 × 50 € y 2 × 20 € muestra un total de `190,00 €`.
- [ ] **Step 3:** FAIL. **Step 4:** Implementar. **Step 5:** PASS.
- [ ] **Step 6: Prueba manual** en el emulador: registrar un día completo cronometrado (objetivo < 3 min, RNF-12) y anotar el tiempo en el PR o en el commit.
- [ ] **Step 7: Commit** `feat(ui): add day registration and close screen`.

---

### Task 21: Pantallas de gastos y proveedores

**Files:**
- Create: `lib/features/expenses/expenses_list_screen.dart`, `lib/features/expenses/expense_form_screen.dart`, `lib/features/expenses/receipt_picker.dart`, `lib/features/suppliers/suppliers_screen.dart`, `lib/features/suppliers/supplier_form.dart`
- Test: `test/features/expenses/expense_form_screen_test.dart`

**Interfaces:**
- Consumes: `ExpensesRepository`, `SuppliersRepository`, `CatalogRepository`, `ReceiptStore`, `image_picker`, `file_picker`, `askReason`.
- Produces:
  - Lista con pestañas "Pendientes" (`watchPending`) y "Todos" (`watchRange` del mes, con selector de mes); chip "Incompleto" si no tiene justificante; tachado si está anulado; totales por proveedor y categoría (RF-GAS-07) en una sección plegable.
  - Formulario: fecha; proveedor con búsqueda (al elegirlo se rellena su categoría por defecto) y alta rápida; categoría; nº de factura; base, IVA (segmentado 0/4/10/21) y total (si se edita la base, se calcula el total con `VatCalc.fromBase`; si se edita el total, se calcula la base con `VatCalc.fromTotal`); forma de pago; estado pagado/pendiente; vencimiento; justificantes (cámara, galería, PDF) con miniaturas; "Anular" (pide motivo).

- [ ] **Step 1: Widget test:** base `100,00` con IVA 21 → total `121,00 €`; cambiar el total a `110,00` con IVA 10 → base `100,00`; guardar sin justificante → se guarda y la lista lo muestra como "Incompleto".
- [ ] **Step 2:** FAIL. **Step 3:** Implementar. **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(ui): add expenses and suppliers screens`.

---

### Task 22: Pantallas de gastos fijos, nóminas y retiradas

**Files:**
- Create: `lib/features/fixed_costs/fixed_costs_screen.dart`, `lib/features/fixed_costs/fixed_cost_form.dart`, `lib/features/payroll/payroll_month_screen.dart`, `lib/features/payroll/employee_form.dart`, `lib/features/withdrawals/withdrawals_screen.dart`
- Test: `test/features/payroll/payroll_month_screen_test.dart`

**Interfaces:**
- Consumes: `FixedCostsRepository`, `PayrollRepository`, `WithdrawalsRepository.watchRange/totalsByType`, `ReportService` (para el % de personal).
- Produces:
  - Fijos: lista de definiciones (concepto, importe previsto, periodicidad) y la sección "Por confirmar" con los gastos planificados; confirmar pide el importe real.
  - Nóminas: selector de mes y una fila por empleado activo con bruto, neto, SS de la empresa y forma de pago; total del coste de personal y % sobre las ventas del mes (RF-NOM-04); alta y edición de empleados.
  - Retiradas: selector de período, lista y totales por tipo (RF-RET-03).

- [ ] **Step 1: Widget test:** dos empleados activos en noviembre; al guardar bruto `1500,00` y SS `450,00` en cada uno, el total muestra `3.900,00 €`; con ventas del mes `13.000,00 €` muestra `30,0 %`.
- [ ] **Step 2:** FAIL. **Step 3:** Implementar. **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(ui): add fixed costs, payroll and withdrawals screens`.

---

### Task 23: Informes, alertas, historial, ajustes y copia

**Files:**
- Create: `lib/features/reports/reports_screen.dart`, `lib/features/alerts/alerts_screen.dart`, `lib/features/settings/settings_screen.dart`, `lib/features/settings/catalog_screen.dart`, `lib/features/settings/history_screen.dart`, `lib/features/backup/backup_screen.dart`, `lib/features/settings/months_screen.dart`
- Test: `test/features/reports/reports_screen_test.dart`, `test/features/alerts/alerts_screen_test.dart`

**Interfaces:**
- Consumes: `ReportService`, export (Task 17), `share_plus`, `printing`, `AlertsService`, `HistoryRepository`, `SettingsRepository`, `CatalogRepository`, `PeriodsRepository`, `BackupService`, `PinManager`, `requireAuth`.
- Produces:
  - Informes: selector de período (hoy, semana, mes, desde–hasta) y resumen (ventas, comensales, ticket medio, compras, fijos, pendientes de confirmar, otros, personal y %, beneficio, retiradas, descuadres); botones PDF, Excel, CSV y ZIP para el gestor, todos compartidos con `share_plus` (menú del sistema); el PDF tiene además "Guardar" con `Printing.sharePdf`.
  - Alertas: lista agrupada por tipo; cada una navega a su registro (día → `/day/:ymd`, gasto → `/expenses/:id`, copia → `/backup`).
  - Ajustes: restaurante, idioma, umbral (`MoneyField`), catálogos (añadir, renombrar, desactivar, reordenar), días del recordatorio de copia, cambiar PIN (pide el PIN actual), activar o desactivar biometría, historial y "Meses" (cerrar o reabrir mes; `MonthNotReadyException` muestra las fechas pendientes; reabrir pide `requireAuth` + `askReason`).
  - Copia: "Crear copia" (contraseña dos veces y aviso de que sin ella no se puede restaurar) → `export` → compartir; "Restaurar" (`FilePicker`) → contraseña → `inspect` → resumen y confirmación → `restore` → la app vuelve al inicio. Los errores (`BackupDecryptException`, `BackupTooNewException`) se muestran con mensajes traducidos.

- [ ] **Step 1: Widget tests:** informes con un `ReportService` falso del escenario del Task 14 → muestra el beneficio `450,00 €` y "Pendientes de confirmar `200,00 €`"; pulsar PDF llama al exportador (falso); pulsar una alerta `dayOpen` navega a `/day/2026-11-07`.
- [ ] **Step 2:** FAIL. **Step 3:** Implementar. **Step 4:** PASS.
- [ ] **Step 5: Commit** `feat(ui): add reports, alerts, settings, history and backup screens`.

---

### Task 24: Verificación final y build de release

**Files:**
- Create: `tool/coverage_check.dart`, `README.md`, `docs/manual-test-checklist.md`
- Modify: `android/app/src/main/AndroidManifest.xml` solo si hace falta para RNF-07

**Interfaces:**
- Produces: `dart run tool/coverage_check.dart coverage/lcov.info lib/domain 80` → código de salida 0 si la cobertura de líneas de los archivos bajo `lib/domain` es ≥ 80 %; si no, imprime cada archivo con su porcentaje y sale con 1.

- [ ] **Step 1:** `flutter analyze` → sin problemas.
- [ ] **Step 2:** `flutter test --coverage` → todo PASS; `dart run tool/coverage_check.dart coverage/lcov.info lib/domain 80` → código de salida 0.
- [ ] **Step 3:** `flutter build apk --release` → genera el APK; `apkanalyzer manifest permissions build/app/outputs/flutter-apk/app-release.apk` no lista `android.permission.INTERNET` (RNF-07).
- [ ] **Step 4:** `flutter test integration_test -d <emulador>` → PASS.
- [ ] **Step 5:** Escribir `docs/manual-test-checklist.md` con las pruebas manuales del spec §11 (modo avión, cierre forzado durante un borrador, bloqueo a los 5 min, arranque < 2 s y lista mensual < 1 s en gama media, restauración en otro móvil, Android → iOS pendiente de Mac) y ejecutar las que se puedan en Android, anotando el resultado.
- [ ] **Step 6:** `README.md`: requisitos (Flutter, JDK 17), `dart run build_runner build`, cómo ejecutar los tests, las builds y el aviso de iOS.
- [ ] **Step 7: Commit** `chore: add coverage gate, README and manual test checklist`.
