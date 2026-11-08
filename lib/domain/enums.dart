/// Shared domain enums. Persisted in the database by their `name`.
library;

enum DayStatus { open, closed, noActivity }

enum Shift { lunch, dinner }

enum PaymentKind { cash, card, other }

enum CategoryKind { purchase, other }

enum PaymentStatus { paid, pending }

enum ExpenseOrigin { manual, fixed }

enum FixedStatus { planned, confirmed }

enum Periodicity {
  monthly(1),
  bimonthly(2),
  quarterly(3),
  annual(12);

  const Periodicity(this.months);

  /// Number of months between occurrences.
  final int months;
}

enum ReceiptKind { photo, pdf }

enum PeriodStatus { open, closed }
