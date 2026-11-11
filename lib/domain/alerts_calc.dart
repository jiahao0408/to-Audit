/// Pure-Dart alert rules. Alerts are computed on the fly and never stored.
library;

import 'dates.dart';
import 'enums.dart';
import 'money.dart';

/// Declaration order is the output order of [computeAlerts].
enum AlertType {
  discrepancy,
  dayUnregistered,
  dayOpen,
  missingReceipt,
  invoiceOverdue,
  floatMismatch,
  backupOld,
}

/// Days after which a backup is considered old.
const int _backupOldDays = 14;

class Alert {
  const Alert({required this.type, this.recordId, this.date});

  final AlertType type;
  final String? recordId;
  final DateTime? date;

  @override
  bool operator ==(Object other) =>
      other is Alert &&
      other.type == type &&
      other.recordId == recordId &&
      other.date == date;

  @override
  int get hashCode => Object.hash(type, recordId, date);

  @override
  String toString() =>
      'Alert(${type.name}, recordId: $recordId, '
      'date: ${date == null ? null : ymd(date!)})';
}

class DaySnapshot {
  const DaySnapshot({
    required this.id,
    required this.date,
    required this.status,
    required this.openingFloat,
    required this.countedCash,
    required this.cashDiff,
    required this.cardDiff,
  });

  final String id;
  final DateTime date;
  final DayStatus status;
  final Money openingFloat;
  final Money? countedCash;
  final Money cashDiff;
  final Money cardDiff;

  /// Float left in the drawer: counted cash when closed, the opening float
  /// when there was no activity, unknown (null) while the day is open.
  Money? get closingFloat => switch (status) {
    DayStatus.closed => countedCash,
    DayStatus.noActivity => openingFloat,
    DayStatus.open => null,
  };
}

class ExpenseSnapshot {
  const ExpenseSnapshot({
    required this.id,
    required this.voided,
    required this.receiptCount,
    required this.paymentStatus,
    required this.dueDate,
    this.planned = false,
  });

  final String id;
  final bool voided;

  /// A fixed cost generated but not yet confirmed with its real invoice: no
  /// receipt or overdue alert until it is confirmed.
  final bool planned;
  final int receiptCount;
  final PaymentStatus paymentStatus;
  final DateTime? dueDate;
}

class AlertInputs {
  const AlertInputs({
    required this.today,
    required this.days,
    required this.expenses,
    required this.closedMonths,
    required this.lastBackup,
  });

  final DateTime today;
  final List<DaySnapshot> days;
  final List<ExpenseSnapshot> expenses;
  final Set<String> closedMonths;
  final DateTime? lastBackup;
}

List<Alert> computeAlerts(AlertInputs i) {
  final today = dateOnly(i.today);
  final alerts = <Alert>[];

  final days = [...i.days]..sort((a, b) => a.date.compareTo(b.date));

  for (final day in days) {
    final date = dateOnly(day.date);
    if (day.status == DayStatus.closed &&
        (!day.cashDiff.isZero || !day.cardDiff.isZero) &&
        !i.closedMonths.contains(monthKey(date))) {
      alerts.add(
        Alert(type: AlertType.discrepancy, recordId: day.id, date: date),
      );
    }
    if (day.status == DayStatus.open && date.isBefore(today)) {
      alerts.add(Alert(type: AlertType.dayOpen, recordId: day.id, date: date));
    }
  }

  if (days.isNotEmpty) {
    final registered = {for (final d in days) dateOnly(d.date)};
    final first = dateOnly(days.first.date);
    if (first.isBefore(today)) {
      for (final d in DateRange(first, today).dates) {
        if (!d.isBefore(today)) break;
        if (!registered.contains(d)) {
          alerts.add(Alert(type: AlertType.dayUnregistered, date: d));
        }
      }
    }
  }

  for (final e in i.expenses) {
    if (e.voided || e.planned) continue;
    if (e.receiptCount == 0) {
      alerts.add(Alert(type: AlertType.missingReceipt, recordId: e.id));
    }
    final due = e.dueDate;
    if (e.paymentStatus == PaymentStatus.pending &&
        due != null &&
        dateOnly(due).isBefore(today)) {
      alerts.add(Alert(type: AlertType.invoiceOverdue, recordId: e.id));
    }
  }

  for (var k = 1; k < days.length; k++) {
    final prev = days[k - 1];
    final cur = days[k];
    final prevDate = dateOnly(prev.date);
    final curDate = dateOnly(cur.date);
    if (!prevDate.isBefore(curDate)) continue; // same date: no earlier day
    final closing = prev.closingFloat;
    if (closing != null && closing != cur.openingFloat) {
      alerts.add(
        Alert(type: AlertType.floatMismatch, recordId: cur.id, date: curDate),
      );
    }
  }

  final last = i.lastBackup;
  // Never backed up counts as old as soon as there is data to lose.
  if ((last == null && days.isNotEmpty) ||
      (last != null && _daysBetween(last, today) > _backupOldDays)) {
    alerts.add(const Alert(type: AlertType.backupOld));
  }

  alerts.sort(_compareAlerts);
  return alerts;
}

bool backupReminderDue({
  required DateTime? lastBackup,
  required DateTime now,
  required int everyDays,
}) {
  if (lastBackup == null) return true;
  return _daysBetween(lastBackup, now) >= everyDays;
}

bool backupWarningOnOpen({
  required DateTime? lastBackup,
  required DateTime now,
}) {
  if (lastBackup == null) return true;
  return _daysBetween(lastBackup, now) > _backupOldDays;
}

int _daysBetween(DateTime from, DateTime to) =>
    dateOnly(to).difference(dateOnly(from)).inDays;

int _compareAlerts(Alert a, Alert b) {
  final byType = a.type.index.compareTo(b.type.index);
  if (byType != 0) return byType;
  final ad = a.date;
  final bd = b.date;
  if (ad != null && bd != null) {
    final c = ad.compareTo(bd);
    if (c != 0) return c;
  } else if (ad != null) {
    return -1;
  } else if (bd != null) {
    return 1;
  }
  return (a.recordId ?? '').compareTo(b.recordId ?? '');
}
