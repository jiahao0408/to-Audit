// Named constructor parameters cannot be private, hence the initializer list.
// ignore_for_file: prefer_initializing_formals

import 'package:drift/drift.dart';

import '../../domain/dates.dart';
import '../../domain/money.dart';
import '../../domain/pnl_calc.dart';
import '../audit/audit_writer.dart';
import '../audit/period_guard.dart';
import '../db/app_database.dart';

/// The user-editable fields of an employee.
class EmployeeInput {
  const EmployeeInput({
    required this.name,
    required this.role,
    required this.hiredOn,
    this.leftOn,
  });

  final String name;
  final String role;
  final DateTime hiredOn;
  final DateTime? leftOn;
}

class EmployeeRecord {
  const EmployeeRecord({
    required this.id,
    required this.name,
    required this.role,
    required this.hiredOn,
    required this.leftOn,
  });

  final String id;
  final String name;
  final String role;
  final DateTime hiredOn;
  final DateTime? leftOn;
}

class PayrollPaymentRecord {
  const PayrollPaymentRecord({
    required this.id,
    required this.employeeId,
    required this.month,
    required this.gross,
    required this.net,
    required this.employerSs,
    required this.paymentMethodId,
    required this.voided,
    required this.voidReason,
  });

  final String id;
  final String employeeId;

  /// `YYYY-MM`.
  final String month;
  final Money gross;
  final Money net;
  final Money employerSs;
  final String? paymentMethodId;
  final bool voided;
  final String? voidReason;
}

/// An employee and, if registered, their payment for the month.
class PayrollRow {
  const PayrollRow({required this.employee, required this.payment});

  final EmployeeRecord employee;
  final PayrollPaymentRecord? payment;
}

/// Employees and their monthly payroll payments.
class PayrollRepository {
  PayrollRepository(
    this._db, {
    required AuditWriter audit,
    required PeriodGuard guard,
  }) : _audit = audit,
       _guard = guard;

  final AppDatabase _db;
  final AuditWriter _audit;
  final PeriodGuard _guard;

  static const _employeeEntity = 'empleado';
  static const _paymentEntity = 'pago_nomina';
  static final RegExp _monthPattern = RegExp(r'^\d{4}-(0[1-9]|1[0-2])$');

  // ------------------------------------------------------------ employees

  static EmployeeRecord _employee(EmployeeData e) => EmployeeRecord(
    id: e.id,
    name: e.name,
    role: e.position ?? '',
    hiredOn: parseYmd(e.hireDate!),
    leftOn: e.terminationDate == null ? null : parseYmd(e.terminationDate!),
  );

  static PayrollPaymentRecord _payment(PayrollPaymentData p) =>
      PayrollPaymentRecord(
        id: p.id,
        employeeId: p.employeeId,
        month: p.month,
        gross: Money(p.grossCents),
        net: Money(p.netCents),
        employerSs: Money(p.employerSsCents),
        paymentMethodId: p.paymentMethodId,
        voided: p.voided,
        voidReason: p.voidReason,
      );

  Stream<List<EmployeeRecord>> watchEmployees() =>
      (_db.select(_db.employees)..orderBy([
            (t) => OrderingTerm.asc(t.name),
            (t) => OrderingTerm.asc(t.createdAt),
          ]))
          .watch()
          .map((rows) => [for (final r in rows) _employee(r)]);

  static void _validateEmployee(EmployeeInput i) {
    if (i.name.trim().isEmpty) {
      throw ArgumentError.value(i.name, 'name', 'must not be blank');
    }
    final left = i.leftOn;
    if (left != null && dateOnly(left).isBefore(dateOnly(i.hiredOn))) {
      throw ArgumentError.value(left, 'leftOn', 'must not be before hiredOn');
    }
  }

  static Map<String, Object?> _employeeValues(EmployeeInput i) => {
    'name': i.name.trim(),
    'position': i.role.trim(),
    'hireDate': ymd(i.hiredOn),
    'terminationDate': i.leftOn == null ? null : ymd(i.leftOn!),
  };

  Future<String> createEmployee(EmployeeInput input) =>
      _db.transaction(() async {
        _validateEmployee(input);
        final id = newId();
        final now = nowIso();
        await _db
            .into(_db.employees)
            .insert(
              EmployeesCompanion.insert(
                id: id,
                createdAt: now,
                updatedAt: now,
                name: input.name.trim(),
                position: Value(input.role.trim()),
                hireDate: Value(ymd(input.hiredOn)),
                terminationDate: Value(
                  input.leftOn == null ? null : ymd(input.leftOn!),
                ),
              ),
            );
        await _audit.inserted(_employeeEntity, id, _employeeValues(input));
        return id;
      });

  Future<EmployeeData> _employeeRow(String id) async {
    final row = await (_db.select(
      _db.employees,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) throw ArgumentError.value(id, 'id', 'unknown employee');
    return row;
  }

  Future<void> updateEmployee(String id, EmployeeInput input) =>
      _db.transaction(() async {
        final row = await _employeeRow(id);
        _validateEmployee(input);
        await (_db.update(_db.employees)..where((t) => t.id.equals(id))).write(
          EmployeesCompanion(
            name: Value(input.name.trim()),
            position: Value(input.role.trim()),
            hireDate: Value(ymd(input.hiredOn)),
            terminationDate: Value(
              input.leftOn == null ? null : ymd(input.leftOn!),
            ),
            updatedAt: Value(nowIso()),
          ),
        );
        await _audit.updated(_employeeEntity, id, {
          'name': row.name,
          'position': row.position,
          'hireDate': row.hireDate,
          'terminationDate': row.terminationDate,
        }, _employeeValues(input));
      });

  // -------------------------------------------------------------- payroll

  /// Whether [e] was employed on any day of the month [r].
  static bool _activeIn(EmployeeData e, DateRange r) {
    final hired = parseYmd(e.hireDate!);
    final left = e.terminationDate == null
        ? null
        : parseYmd(e.terminationDate!);
    return !hired.isAfter(r.end) && (left == null || !left.isBefore(r.start));
  }

  /// Employees active on some day of [monthKey] (ordered by name) with their
  /// non-voided payment for that month, if any.
  Future<List<PayrollRow>> month(String monthKey) async {
    final r = rangeMonth(monthKey);
    final employees = await (_db.select(
      _db.employees,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).get();
    final payments = await (_db.select(
      _db.payrollPayments,
    )..where((p) => p.month.equals(monthKey) & p.voided.equals(false))).get();
    final byEmployee = {for (final p in payments) p.employeeId: p};
    return [
      for (final e in employees)
        if (_activeIn(e, r))
          PayrollRow(
            employee: _employee(e),
            payment: byEmployee[e.id] == null
                ? null
                : _payment(byEmployee[e.id]!),
          ),
    ];
  }

  /// Registers or replaces the non-voided payment of [employeeId] for [month]
  /// (`YYYY-MM`).
  Future<void> savePayment({
    required String employeeId,
    required String month,
    required Money gross,
    required Money net,
    required Money employerSs,
    required String paymentMethodId,
  }) async {
    if (!_monthPattern.hasMatch(month)) {
      throw ArgumentError.value(month, 'month', 'expected YYYY-MM');
    }
    if (gross.cents < 0 || net.cents < 0 || employerSs.cents < 0) {
      throw ArgumentError('amounts must not be negative');
    }
    if (net.cents > gross.cents) {
      throw ArgumentError.value(net, 'net', 'must not exceed gross');
    }
    final range = rangeMonth(month);
    return _db.transaction(() async {
      final employee = await _employeeRow(employeeId);
      if (!_activeIn(employee, range)) {
        throw ArgumentError.value(
          month,
          'month',
          'employee is not active in this month',
        );
      }
      final method = await (_db.select(
        _db.paymentMethods,
      )..where((t) => t.id.equals(paymentMethodId))).getSingleOrNull();
      if (method == null) {
        throw ArgumentError.value(
          paymentMethodId,
          'paymentMethodId',
          'unknown payment method',
        );
      }
      await _guard.ensureMonthOpen(range.start);
      final existing =
          await (_db.select(_db.payrollPayments)..where(
                (p) =>
                    p.employeeId.equals(employeeId) &
                    p.month.equals(month) &
                    p.voided.equals(false),
              ))
              .getSingleOrNull();
      final after = {
        'grossCents': gross.cents,
        'netCents': net.cents,
        'employerSsCents': employerSs.cents,
        'paymentMethodId': paymentMethodId,
      };
      if (existing == null) {
        final id = newId();
        final now = nowIso();
        await _db
            .into(_db.payrollPayments)
            .insert(
              PayrollPaymentsCompanion.insert(
                id: id,
                createdAt: now,
                updatedAt: now,
                employeeId: employeeId,
                month: month,
                grossCents: gross.cents,
                netCents: net.cents,
                employerSsCents: employerSs.cents,
                paymentMethodId: Value(paymentMethodId),
              ),
            );
        await _audit.inserted(_paymentEntity, id, {
          'employeeId': employeeId,
          'month': month,
          ...after,
        });
      } else {
        await (_db.update(
          _db.payrollPayments,
        )..where((p) => p.id.equals(existing.id))).write(
          PayrollPaymentsCompanion(
            grossCents: Value(gross.cents),
            netCents: Value(net.cents),
            employerSsCents: Value(employerSs.cents),
            paymentMethodId: Value(paymentMethodId),
            updatedAt: Value(nowIso()),
          ),
        );
        await _audit.updated(_paymentEntity, existing.id, {
          'grossCents': existing.grossCents,
          'netCents': existing.netCents,
          'employerSsCents': existing.employerSsCents,
          'paymentMethodId': existing.paymentMethodId,
        }, after);
      }
    });
  }

  Future<void> voidPayment(String id, String reason) async {
    final why = reason.trim();
    if (why.isEmpty) {
      throw ArgumentError.value(reason, 'reason', 'must not be blank');
    }
    return _db.transaction(() async {
      final row = await (_db.select(
        _db.payrollPayments,
      )..where((p) => p.id.equals(id))).getSingleOrNull();
      if (row == null) throw ArgumentError.value(id, 'id', 'unknown payment');
      await _guard.ensureMonthOpen(rangeMonth(row.month).start);
      if (row.voided) throw StateError('Payment $id is already voided');
      await (_db.update(
        _db.payrollPayments,
      )..where((p) => p.id.equals(id))).write(
        PayrollPaymentsCompanion(
          voided: const Value(true),
          voidReason: Value(why),
          updatedAt: Value(nowIso()),
        ),
      );
      await _audit.event(
        _paymentEntity,
        id,
        'voided',
        oldValue: false,
        newValue: true,
        reason: why,
      );
    });
  }

  /// Gross pay plus employer social security of each payroll month touched by
  /// [r]; months without payments are omitted.
  Future<List<PayrollMonth>> costs(DateRange r) async {
    final rows =
        await (_db.select(_db.payrollPayments)
              ..where(
                (p) =>
                    p.voided.equals(false) &
                    p.month.isBetweenValues(monthKey(r.start), monthKey(r.end)),
              )
              ..orderBy([(p) => OrderingTerm.asc(p.month)]))
            .get();
    final totals = <String, int>{};
    for (final p in rows) {
      totals[p.month] =
          (totals[p.month] ?? 0) + p.grossCents + p.employerSsCents;
    }
    return [
      for (final e in totals.entries) PayrollMonth(e.key, Money(e.value)),
    ];
  }
}
