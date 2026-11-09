import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/audit/audit_writer.dart';
import 'package:to_audit/data/audit/period_guard.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/repositories/payroll_repository.dart';
import 'package:to_audit/domain/dates.dart';
import 'package:to_audit/domain/enums.dart';
import 'package:to_audit/domain/money.dart';

void main() {
  late AppDatabase db;
  late PayrollRepository repo;
  late String payId;

  DateTime d(int y, int m, int day) => DateTime.utc(y, m, day);

  setUp(() async {
    db = AppDatabase.memory();
    repo = PayrollRepository(
      db,
      audit: AuditWriter(db),
      guard: PeriodGuard(db),
    );
    payId = (await (db.select(
      db.paymentMethods,
    )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get()).first.id;
  });
  tearDown(() => db.close());

  EmployeeInput emp(String name, {DateTime? leftOn, DateTime? hiredOn}) =>
      EmployeeInput(
        name: name,
        role: 'Camarero',
        hiredOn: hiredOn ?? d(2026, 1, 1),
        leftOn: leftOn,
      );

  Future<void> pay(
    String employeeId,
    String month, {
    int gross = 200000,
    int net = 160000,
    int ss = 60000,
  }) => repo.savePayment(
    employeeId: employeeId,
    month: month,
    gross: Money(gross),
    net: Money(net),
    employerSs: Money(ss),
    paymentMethodId: payId,
  );

  test('employee left on 2026-10-15 shows in October, not November', () async {
    final id = await repo.createEmployee(emp('Ana', leftOn: d(2026, 10, 15)));
    await repo.createEmployee(emp('Beto'));
    final oct = await repo.month('2026-10');
    final nov = await repo.month('2026-11');
    expect(oct.map((r) => r.employee.name), ['Ana', 'Beto']);
    expect(nov.map((r) => r.employee.name), ['Beto']);
    expect(oct.first.employee.id, id);
    expect(oct.first.payment, isNull);
  });

  test('employee hired mid-month appears from that month only', () async {
    await repo.createEmployee(emp('Cris', hiredOn: d(2026, 11, 20)));
    expect(await repo.month('2026-10'), isEmpty);
    expect(await repo.month('2026-11'), hasLength(1));
  });

  test('savePayment twice in the same month leaves one payment', () async {
    final id = await repo.createEmployee(emp('Ana'));
    await pay(id, '2026-11');
    await pay(id, '2026-11', gross: 210000);
    final rows = await db.select(db.payrollPayments).get();
    expect(rows, hasLength(1));
    expect(rows.single.grossCents, 210000);
    final row = (await repo.month('2026-11')).single;
    expect(row.payment!.gross, const Money(210000));
    expect(row.payment!.voided, isFalse);
  });

  test('costs sums gross plus employer SS for the month', () async {
    final a = await repo.createEmployee(emp('Ana'));
    final b = await repo.createEmployee(emp('Beto'));
    await pay(a, '2026-11');
    await pay(b, '2026-11', gross: 100000, net: 80000, ss: 30000);
    await pay(a, '2026-10', gross: 1, net: 1, ss: 1);
    final costs = await repo.costs(rangeMonth('2026-11'));
    expect(costs, hasLength(1));
    expect(costs.single.month, '2026-11');
    expect(costs.single.cost, const Money(390000));
    final two = await repo.costs(rangeCustom(d(2026, 10, 20), d(2026, 11, 3)));
    expect(two.map((m) => m.month), ['2026-10', '2026-11']);
  });

  test('voided payments are excluded and a new one can be saved', () async {
    final id = await repo.createEmployee(emp('Ana'));
    await pay(id, '2026-11');
    final paymentId = (await repo.month('2026-11')).single.payment!.id;
    await expectLater(repo.voidPayment(paymentId, ' '), throwsArgumentError);
    await repo.voidPayment(paymentId, 'error');
    expect((await repo.month('2026-11')).single.payment, isNull);
    expect(await repo.costs(rangeMonth('2026-11')), isEmpty);
    await pay(id, '2026-11');
    expect(await db.select(db.payrollPayments).get(), hasLength(2));
    await expectLater(repo.voidPayment(paymentId, 'otra'), throwsStateError);
  });

  test('validation', () async {
    final id = await repo.createEmployee(emp('Ana', leftOn: d(2026, 10, 15)));
    await expectLater(
      repo.createEmployee(emp('X', leftOn: d(2025, 1, 1))),
      throwsArgumentError,
    );
    await expectLater(repo.createEmployee(emp(' ')), throwsArgumentError);
    await expectLater(pay(id, '2026-11'), throwsArgumentError); // not active
    await expectLater(pay(id, '2026-1'), throwsArgumentError);
    await expectLater(pay(id, '2026-10', net: 300000), throwsArgumentError);
    await expectLater(pay(id, '2026-10', gross: -1), throwsArgumentError);
    await expectLater(pay('nope', '2026-10'), throwsArgumentError);
  });

  test('closed month blocks payments', () async {
    final id = await repo.createEmployee(emp('Ana'));
    final now = nowIso();
    await db
        .into(db.periods)
        .insert(
          PeriodsCompanion.insert(
            id: newId(),
            createdAt: now,
            updatedAt: now,
            month: '2026-10',
            status: PeriodStatus.closed,
          ),
        );
    await expectLater(
      pay(id, '2026-10'),
      throwsA(isA<PeriodLockedException>()),
    );
  });

  test('updateEmployee, watchEmployees and audit', () async {
    final id = await repo.createEmployee(emp('Ana'));
    await repo.updateEmployee(id, emp('Ana B', leftOn: d(2026, 12, 31)));
    final list = await repo.watchEmployees().first;
    expect(list.single.name, 'Ana B');
    expect(list.single.leftOn, d(2026, 12, 31));
    expect(list.single.role, 'Camarero');
    final log = await db.select(db.changeLog).get();
    expect(
      log.where((l) => l.entity == 'empleado' && l.field == 'name'),
      hasLength(1),
    );
  });
}
