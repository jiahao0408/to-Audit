import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/domain/alerts_calc.dart';
import 'package:to_audit/domain/enums.dart';
import 'package:to_audit/domain/money.dart';

DateTime d(int y, int m, int day) => DateTime.utc(y, m, day);

DaySnapshot day(
  String id,
  DateTime date, {
  DayStatus status = DayStatus.closed,
  int opening = 0,
  int? counted,
  int cashDiff = 0,
  int cardDiff = 0,
}) => DaySnapshot(
  id: id,
  date: date,
  status: status,
  openingFloat: Money(opening),
  countedCash: counted == null ? null : Money(counted),
  cashDiff: Money(cashDiff),
  cardDiff: Money(cardDiff),
);

ExpenseSnapshot exp(
  String id, {
  bool voided = false,
  int receipts = 1,
  PaymentStatus status = PaymentStatus.paid,
  DateTime? due,
}) => ExpenseSnapshot(
  id: id,
  voided: voided,
  receiptCount: receipts,
  paymentStatus: status,
  dueDate: due,
);

AlertInputs inputs({
  DateTime? today,
  List<DaySnapshot> days = const [],
  List<ExpenseSnapshot> expenses = const [],
  Set<String> closedMonths = const {},
  DateTime? lastBackup,
}) => AlertInputs(
  today: today ?? d(2026, 11, 5),
  days: days,
  expenses: expenses,
  closedMonths: closedMonths,
  lastBackup: lastBackup,
);

List<AlertType> types(List<Alert> a) => a.map((e) => e.type).toList();

void main() {
  group('closingFloat', () {
    test('closed -> countedCash, noActivity -> openingFloat, open -> null', () {
      expect(
        day('a', d(2026, 11, 1), counted: 500).closingFloat,
        const Money(500),
      );
      expect(
        day(
          'a',
          d(2026, 11, 1),
          status: DayStatus.noActivity,
          opening: 700,
        ).closingFloat,
        const Money(700),
      );
      expect(
        day('a', d(2026, 11, 1), status: DayStatus.open).closingFloat,
        isNull,
      );
    });
  });

  group('discrepancy', () {
    test('closed day with cash diff in open month alerts', () {
      final a = computeAlerts(
        inputs(
          today: d(2026, 11, 2),
          days: [day('a', d(2026, 11, 1), counted: 0, cashDiff: -1)],
        ),
      );
      expect(a, [
        Alert(type: AlertType.discrepancy, recordId: 'a', date: d(2026, 11, 1)),
      ]);
    });
    test('card diff alerts too', () {
      final a = computeAlerts(
        inputs(
          today: d(2026, 11, 2),
          days: [day('a', d(2026, 11, 1), counted: 0, cardDiff: 5)],
        ),
      );
      expect(types(a), [AlertType.discrepancy]);
    });
    test('closed month suppresses', () {
      final a = computeAlerts(
        inputs(
          today: d(2026, 11, 2),
          days: [day('a', d(2026, 11, 1), counted: 0, cashDiff: -1)],
          closedMonths: {'2026-11'},
        ),
      );
      expect(a, isEmpty);
    });
    test('zero diffs and non-closed days do not alert', () {
      final a = computeAlerts(
        inputs(
          days: [
            day('a', d(2026, 11, 5), counted: 0),
            day('b', d(2026, 11, 5), status: DayStatus.noActivity, cashDiff: 3),
          ],
        ),
      );
      expect(types(a).contains(AlertType.discrepancy), isFalse);
    });
  });

  group('dayUnregistered', () {
    test('gaps between first day and today (exclusive)', () {
      final a = computeAlerts(
        inputs(
          days: [
            day('a', d(2026, 11, 1), counted: 0),
            day('b', d(2026, 11, 3), counted: 0),
          ],
        ),
      );
      expect(a, [
        Alert(type: AlertType.dayUnregistered, date: d(2026, 11, 2)),
        Alert(type: AlertType.dayUnregistered, date: d(2026, 11, 4)),
      ]);
    });
    test('no snapshots -> none', () {
      expect(computeAlerts(inputs()), isEmpty);
    });
    test('nothing before first day', () {
      final a = computeAlerts(
        inputs(days: [day('a', d(2026, 11, 5), status: DayStatus.open)]),
      );
      expect(a, isEmpty);
    });
  });

  group('dayOpen', () {
    test('open day before today alerts', () {
      final a = computeAlerts(
        inputs(days: [day('a', d(2026, 11, 4), status: DayStatus.open)]),
      );
      expect(a, [
        Alert(type: AlertType.dayOpen, recordId: 'a', date: d(2026, 11, 4)),
      ]);
    });
    test('open today does not alert', () {
      final a = computeAlerts(
        inputs(days: [day('a', d(2026, 11, 5), status: DayStatus.open)]),
      );
      expect(a, isEmpty);
    });
  });

  group('missingReceipt', () {
    test('no receipts alerts, voided does not', () {
      final a = computeAlerts(
        inputs(
          expenses: [
            exp('e1', receipts: 0),
            exp('e2', receipts: 0, voided: true),
            exp('e3', receipts: 2),
          ],
        ),
      );
      expect(a, [const Alert(type: AlertType.missingReceipt, recordId: 'e1')]);
    });
  });

  group('invoiceOverdue', () {
    test('pending due yesterday alerts', () {
      final a = computeAlerts(
        inputs(
          expenses: [
            exp('e1', status: PaymentStatus.pending, due: d(2026, 11, 4)),
          ],
        ),
      );
      expect(a, [const Alert(type: AlertType.invoiceOverdue, recordId: 'e1')]);
    });
    test('due today, paid, no due date, voided do not alert', () {
      final a = computeAlerts(
        inputs(
          expenses: [
            exp('e1', status: PaymentStatus.pending, due: d(2026, 11, 5)),
            exp('e2', status: PaymentStatus.paid, due: d(2026, 11, 1)),
            exp('e3', status: PaymentStatus.pending),
            exp(
              'e4',
              status: PaymentStatus.pending,
              due: d(2026, 11, 1),
              voided: true,
            ),
          ],
        ),
      );
      expect(a, isEmpty);
    });
  });

  group('floatMismatch', () {
    test('previous closed counted differs from opening', () {
      final a = computeAlerts(
        inputs(
          days: [
            day('a', d(2026, 11, 1), counted: 19000),
            day('b', d(2026, 11, 2), status: DayStatus.open, opening: 20000),
          ],
        ),
      );
      expect(a.where((x) => x.type == AlertType.floatMismatch).toList(), [
        Alert(
          type: AlertType.floatMismatch,
          recordId: 'b',
          date: d(2026, 11, 2),
        ),
      ]);
    });
    test('previous open -> none', () {
      final a = computeAlerts(
        inputs(
          days: [
            day('a', d(2026, 11, 1), status: DayStatus.open),
            day('b', d(2026, 11, 2), status: DayStatus.open, opening: 20000),
          ],
        ),
      );
      expect(types(a).contains(AlertType.floatMismatch), isFalse);
    });
    test('equal floats -> none', () {
      final a = computeAlerts(
        inputs(
          days: [
            day('a', d(2026, 11, 1), counted: 20000),
            day('b', d(2026, 11, 2), status: DayStatus.open, opening: 20000),
          ],
        ),
      );
      expect(types(a).contains(AlertType.floatMismatch), isFalse);
    });
    test('noActivity previous uses its openingFloat', () {
      final a = computeAlerts(
        inputs(
          days: [
            day(
              'a',
              d(2026, 11, 1),
              status: DayStatus.noActivity,
              opening: 15000,
            ),
            day('b', d(2026, 11, 2), status: DayStatus.open, opening: 20000),
          ],
        ),
      );
      expect(types(a).contains(AlertType.floatMismatch), isTrue);
    });
    test('previous is latest earlier registered day, not date - 1', () {
      final a = computeAlerts(
        inputs(
          days: [
            day('a', d(2026, 11, 1), counted: 19000),
            day('c', d(2026, 11, 4), status: DayStatus.open, opening: 20000),
          ],
        ),
      );
      expect(a.where((x) => x.type == AlertType.floatMismatch).toList(), [
        Alert(
          type: AlertType.floatMismatch,
          recordId: 'c',
          date: d(2026, 11, 4),
        ),
      ]);
    });
    test('independent of input order', () {
      final a = computeAlerts(
        inputs(
          days: [
            day('b', d(2026, 11, 2), status: DayStatus.open, opening: 20000),
            day('a', d(2026, 11, 1), counted: 19000),
          ],
        ),
      );
      expect(types(a).contains(AlertType.floatMismatch), isTrue);
    });
  });

  group('backupOld', () {
    test('15 days ago alerts, 14 does not, null does not', () {
      expect(computeAlerts(inputs(lastBackup: DateTime(2026, 10, 21, 9))), [
        const Alert(type: AlertType.backupOld),
      ]);
      expect(
        computeAlerts(inputs(lastBackup: DateTime(2026, 10, 22, 23))),
        isEmpty,
      );
      expect(computeAlerts(inputs()), isEmpty);
    });
  });

  group('backupReminderDue', () {
    final now = DateTime(2026, 11, 8, 10);
    test('7 days with everyDays 7 -> true', () {
      expect(
        backupReminderDue(
          lastBackup: DateTime(2026, 11, 1, 23),
          now: now,
          everyDays: 7,
        ),
        isTrue,
      );
    });
    test('6 days -> false', () {
      expect(
        backupReminderDue(
          lastBackup: DateTime(2026, 11, 2, 1),
          now: now,
          everyDays: 7,
        ),
        isFalse,
      );
    });
    test('null -> true', () {
      expect(
        backupReminderDue(lastBackup: null, now: now, everyDays: 7),
        isTrue,
      );
    });
  });

  group('backupWarningOnOpen', () {
    final now = DateTime(2026, 11, 8, 10);
    test('null -> true, 15 -> true, 14 -> false', () {
      expect(backupWarningOnOpen(lastBackup: null, now: now), isTrue);
      expect(
        backupWarningOnOpen(lastBackup: DateTime(2026, 10, 24), now: now),
        isTrue,
      );
      expect(
        backupWarningOnOpen(lastBackup: DateTime(2026, 10, 25), now: now),
        isFalse,
      );
    });
  });

  group('ordering', () {
    test('type order, then date asc nulls last, then recordId', () {
      final a = computeAlerts(
        inputs(
          days: [
            day('x', d(2026, 11, 3), counted: 0, cashDiff: 1),
            day('y', d(2026, 11, 1), counted: 0, cashDiff: 1),
          ],
          expenses: [exp('z', receipts: 0), exp('w', receipts: 0)],
          lastBackup: DateTime(2026, 1, 1),
        ),
      );
      expect(
        a.where((x) => x.type == AlertType.discrepancy).map((x) => x.recordId),
        ['y', 'x'],
      );
      expect(
        a
            .where((x) => x.type == AlertType.missingReceipt)
            .map((x) => x.recordId),
        ['w', 'z'],
      );
      expect(a.last.type, AlertType.backupOld);
    });
  });

  test('Alert equality and toString', () {
    const a = Alert(type: AlertType.dayOpen, recordId: 'r');
    expect(a, const Alert(type: AlertType.dayOpen, recordId: 'r'));
    expect(
      a.hashCode,
      const Alert(type: AlertType.dayOpen, recordId: 'r').hashCode,
    );
    expect(a, isNot(const Alert(type: AlertType.dayOpen)));
    expect(a.toString(), contains('dayOpen'));
  });
}
