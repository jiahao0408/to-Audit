import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/alerts_calc.dart';
import '../../domain/cash_calc.dart';
import '../../domain/dates.dart';
import '../../domain/enums.dart';
import '../../domain/money.dart';
import '../audit/audit_writer.dart';
import '../audit/period_guard.dart';
import '../db/app_database.dart';
import 'settings_repository.dart';

/// Thrown by [DaysRepository.closeDay] when a discrepancy exceeds the
/// threshold and the day has no comment.
class CommentRequiredException implements Exception {
  const CommentRequiredException();

  @override
  String toString() =>
      'CommentRequiredException: a comment is required to close a day '
      'with a discrepancy';
}

/// Thrown when an operation needs an open day and the day is not open.
class DayNotOpenException implements Exception {
  const DayNotOpenException();

  @override
  String toString() => 'DayNotOpenException: the day is not open';
}

/// Sales of one payment method in one shift.
class SaleLine {
  const SaleLine({
    required this.paymentMethodId,
    required this.shift,
    required this.amount,
  });

  final String paymentMethodId;
  final Shift shift;
  final Money amount;

  @override
  bool operator ==(Object other) =>
      other is SaleLine &&
      other.paymentMethodId == paymentMethodId &&
      other.shift == shift &&
      other.amount == amount;

  @override
  int get hashCode => Object.hash(paymentMethodId, shift, amount);
}

/// The editable data of a day.
class DayDraft {
  const DayDraft({
    required this.openingFloat,
    this.countedCash,
    this.denominationCounts,
    this.terminalTotal,
    this.cashTips = Money.zero,
    this.cardTips = Money.zero,
    this.comment,
    this.sales = const [],
    this.covers = const {},
  });

  final Money openingFloat;
  final Money? countedCash;

  /// Denomination in cents -> pieces counted.
  final Map<int, int>? denominationCounts;
  final Money? terminalTotal;
  final Money cashTips;
  final Money cardTips;
  final String? comment;
  final List<SaleLine> sales;
  final Map<Shift, int> covers;
}

class DayRecord {
  const DayRecord({
    required this.id,
    required this.date,
    required this.status,
    required this.draft,
    this.cashDiff,
    this.cardDiff,
    this.closedAt,
  });

  final String id;
  final DateTime date;
  final DayStatus status;
  final DayDraft draft;

  /// Stored when the day is closed; fixed afterwards.
  final Money? cashDiff;
  final Money? cardDiff;
  final DateTime? closedAt;
}

class DaySummary {
  const DaySummary({
    required this.cashSales,
    required this.cardSales,
    required this.totalSales,
    required this.cashExpenses,
    required this.withdrawals,
    required this.expected,
    required this.cashDiff,
    required this.cardDiff,
    required this.commentRequired,
  });

  final Money cashSales;
  final Money cardSales;
  final Money totalSales;
  final Money cashExpenses;
  final Money withdrawals;
  final Money expected;

  /// Null until counted cash is known.
  final Money? cashDiff;

  /// Null until the terminal total is known.
  final Money? cardDiff;
  final bool commentRequired;
}

/// Cash days: opening, drafts, live summary, close and reopen.
class DaysRepository {
  DaysRepository(
    this._db, {
    required AuditWriter audit,
    required PeriodGuard guard,
    required SettingsRepository settings,
  }) : _audit = audit,
       _guard = guard,
       _settings = settings;

  final AppDatabase _db;
  final AuditWriter _audit;
  final PeriodGuard _guard;
  final SettingsRepository _settings;

  static const _dayEntity = 'dia_caja';
  static const _saleEntity = 'venta';
  static const _coversEntity = 'comensales';

  // ---------------------------------------------------------------- reads

  Future<DayData?> _row(DateTime date) => (_db.select(
    _db.days,
  )..where((d) => d.date.equals(ymd(date)))).getSingleOrNull();

  Future<DayData> _rowById(String id) async {
    final row = await (_db.select(
      _db.days,
    )..where((d) => d.id.equals(id))).getSingleOrNull();
    if (row == null) throw StateError('No dia_caja with id $id');
    return row;
  }

  Future<DayRecord?> getDay(DateTime date) async {
    final row = await _row(date);
    return row == null ? null : (await _records([row])).single;
  }

  Future<DayRecord> byId(String id) async =>
      (await _records([await _rowById(id)])).single;

  Stream<List<DayRecord>> watchRange(DateRange r) {
    // customSelect so that changes to sales and covers also re-emit.
    return _db
        .customSelect('SELECT 1', readsFrom: {_db.days, _db.sales, _db.covers})
        .watch()
        .asyncMap((_) async => _records(await _rowsInRange(r)));
  }

  Future<List<DayData>> _rowsInRange(DateRange r) =>
      (_db.select(_db.days)
            ..where((d) => d.date.isBetweenValues(ymd(r.start), ymd(r.end)))
            ..orderBy([(d) => OrderingTerm.asc(d.date)]))
          .get();

  Future<List<DayRecord>> _records(List<DayData> rows) async {
    if (rows.isEmpty) return const [];
    final ids = rows.map((r) => r.id).toList();
    final sales = await (_db.select(
      _db.sales,
    )..where((s) => s.dayId.isIn(ids))).get();
    final covers = await (_db.select(
      _db.covers,
    )..where((c) => c.dayId.isIn(ids))).get();
    return [
      for (final d in rows)
        DayRecord(
          id: d.id,
          date: parseYmd(d.date),
          status: d.status,
          draft: DayDraft(
            openingFloat: Money(d.openingFloatCents),
            countedCash: _money(d.countedCashCents),
            denominationCounts: _decodeCounts(d.denominationCounts),
            terminalTotal: _money(d.terminalTotalCents),
            cashTips: Money(d.cashTipsCents),
            cardTips: Money(d.cardTipsCents),
            comment: d.comment,
            sales: [
              for (final s in sales.where((s) => s.dayId == d.id))
                SaleLine(
                  paymentMethodId: s.paymentMethodId,
                  shift: s.shift,
                  amount: Money(s.amountCents),
                ),
            ],
            covers: {
              for (final c in covers.where((c) => c.dayId == d.id))
                c.shift: c.count,
            },
          ),
          cashDiff: _money(d.cashDiffCents),
          cardDiff: _money(d.cardDiffCents),
          closedAt: d.closedAt == null ? null : DateTime.parse(d.closedAt!),
        ),
    ];
  }

  static Money? _money(int? cents) => cents == null ? null : Money(cents);

  static Map<int, int>? _decodeCounts(String? json) {
    if (json == null) return null;
    final raw = jsonDecode(json) as Map<String, dynamic>;
    return {for (final e in raw.entries) int.parse(e.key): e.value as int};
  }

  static String? _encodeCounts(Map<int, int>? counts) => counts == null
      ? null
      : jsonEncode({
          for (final e
              in (counts.entries.toList()
                ..sort((a, b) => a.key.compareTo(b.key))))
            e.key.toString(): e.value,
        });

  // ------------------------------------------------------------ open day

  /// Closing float of the most recent closed / no-activity day before [date],
  /// or the configured initial float when there is none.
  Future<Money> _inheritedFloat(DateTime date) async {
    final prev =
        await (_db.select(_db.days)
              ..where(
                (d) =>
                    d.date.isSmallerThanValue(ymd(date)) &
                    d.status.isIn([
                      DayStatus.closed.name,
                      DayStatus.noActivity.name,
                    ]),
              )
              ..orderBy([(d) => OrderingTerm.desc(d.date)])
              ..limit(1))
            .getSingleOrNull();
    if (prev == null) return _settings.initialFloat();
    return Money(
      prev.status == DayStatus.closed
          ? (prev.countedCashCents ?? prev.openingFloatCents)
          : prev.openingFloatCents,
    );
  }

  /// Returns the day when it exists; otherwise creates it open (the month
  /// must not be closed).
  Future<DayRecord> openDay(DateTime date) => _db.transaction(() async {
    final existing = await getDay(date);
    if (existing != null) return existing;
    await _guard.ensureMonthOpen(date);
    final float = await _inheritedFloat(date);
    final id = await _insertDay(date, DayStatus.open, float);
    return byId(id);
  });

  Future<String> _insertDay(
    DateTime date,
    DayStatus status,
    Money float, {
    DateTime? closedAt,
  }) async {
    final id = newId();
    final now = nowIso();
    await _db
        .into(_db.days)
        .insert(
          DaysCompanion.insert(
            id: id,
            createdAt: now,
            updatedAt: now,
            date: ymd(date),
            status: status,
            openingFloatCents: float.cents,
            closedAt: Value(closedAt?.toUtc().toIso8601String()),
          ),
        );
    await _audit.inserted(_dayEntity, id, {
      'date': ymd(date),
      'status': status,
      'openingFloat': float.cents,
    });
    return id;
  }

  // ---------------------------------------------------------- save draft

  static Map<String, Object?> _dayFields(DayData d) => {
    'openingFloat': d.openingFloatCents,
    'countedCash': d.countedCashCents,
    'denominationCounts': d.denominationCounts,
    'terminalTotal': d.terminalTotalCents,
    'cashTips': d.cashTipsCents,
    'cardTips': d.cardTipsCents,
    'comment': d.comment,
  };

  Future<void> saveDraft(String dayId, DayDraft draft) {
    final counts = draft.denominationCounts;
    if (counts != null) {
      final total = countDenominations(counts);
      if (draft.countedCash != total) {
        throw ArgumentError.value(
          draft.countedCash,
          'countedCash',
          'must equal the denomination count total (${total.cents} cents)',
        );
      }
    }
    final keys = <(Shift, String)>{};
    for (final s in draft.sales) {
      if (!keys.add((s.shift, s.paymentMethodId))) {
        throw ArgumentError.value(
          s,
          'sales',
          'duplicate line for shift and payment method',
        );
      }
    }
    return _db.transaction(() async {
      final day = await _rowById(dayId);
      if (day.status != DayStatus.open) throw const DayNotOpenException();
      await _guard.ensureMonthOpen(parseYmd(day.date));

      final before = _dayFields(day);
      final after = <String, Object?>{
        'openingFloat': draft.openingFloat.cents,
        'countedCash': draft.countedCash?.cents,
        'denominationCounts': _encodeCounts(counts),
        'terminalTotal': draft.terminalTotal?.cents,
        'cashTips': draft.cashTips.cents,
        'cardTips': draft.cardTips.cents,
        'comment': draft.comment,
      };
      if (!_sameMap(before, after)) {
        await (_db.update(_db.days)..where((d) => d.id.equals(dayId))).write(
          DaysCompanion(
            openingFloatCents: Value(draft.openingFloat.cents),
            countedCashCents: Value(draft.countedCash?.cents),
            denominationCounts: Value(_encodeCounts(counts)),
            terminalTotalCents: Value(draft.terminalTotal?.cents),
            cashTipsCents: Value(draft.cashTips.cents),
            cardTipsCents: Value(draft.cardTips.cents),
            comment: Value(draft.comment),
            updatedAt: Value(nowIso()),
          ),
        );
        await _audit.updated(_dayEntity, dayId, before, after);
      }
      await _saveSales(dayId, draft.sales);
      await _saveCovers(dayId, draft.covers);
    });
  }

  static bool _sameMap(Map<String, Object?> a, Map<String, Object?> b) =>
      a.keys.every((k) => a[k] == b[k]);

  /// Upserts the given lines; stored lines missing from [lines] go to zero so
  /// the draft is authoritative.
  Future<void> _saveSales(String dayId, List<SaleLine> lines) async {
    final stored = await (_db.select(
      _db.sales,
    )..where((s) => s.dayId.equals(dayId))).get();
    final wanted = {
      for (final l in lines) (l.shift, l.paymentMethodId): l.amount.cents,
    };
    for (final row in stored) {
      final key = (row.shift, row.paymentMethodId);
      final cents = wanted.remove(key) ?? 0;
      if (cents == row.amountCents) continue;
      await (_db.update(_db.sales)..where((s) => s.id.equals(row.id))).write(
        SalesCompanion(amountCents: Value(cents), updatedAt: Value(nowIso())),
      );
      await _audit.updated(
        _saleEntity,
        row.id,
        {'amountCents': row.amountCents},
        {'amountCents': cents},
      );
    }
    for (final e in wanted.entries) {
      final (shift, methodId) = e.key;
      final id = newId();
      final now = nowIso();
      await _db
          .into(_db.sales)
          .insert(
            SalesCompanion.insert(
              id: id,
              createdAt: now,
              updatedAt: now,
              dayId: dayId,
              shift: shift,
              paymentMethodId: methodId,
              amountCents: e.value,
            ),
          );
      await _audit.inserted(_saleEntity, id, {
        'dayId': dayId,
        'shift': shift,
        'paymentMethodId': methodId,
        'amountCents': e.value,
      });
    }
  }

  Future<void> _saveCovers(String dayId, Map<Shift, int> covers) async {
    final stored = await (_db.select(
      _db.covers,
    )..where((c) => c.dayId.equals(dayId))).get();
    final wanted = Map<Shift, int>.of(covers);
    for (final row in stored) {
      final count = wanted.remove(row.shift) ?? 0;
      if (count == row.count) continue;
      await (_db.update(_db.covers)..where((c) => c.id.equals(row.id))).write(
        CoversCompanion(count: Value(count), updatedAt: Value(nowIso())),
      );
      await _audit.updated(
        _coversEntity,
        row.id,
        {'count': row.count},
        {'count': count},
      );
    }
    for (final e in wanted.entries) {
      final id = newId();
      final now = nowIso();
      await _db
          .into(_db.covers)
          .insert(
            CoversCompanion.insert(
              id: id,
              createdAt: now,
              updatedAt: now,
              dayId: dayId,
              shift: e.key,
              count: e.value,
            ),
          );
      await _audit.inserted(_coversEntity, id, {
        'dayId': dayId,
        'shift': e.key,
        'count': e.value,
      });
    }
  }

  // ------------------------------------------------------------- summary

  Future<DaySummary> summary(String dayId) async {
    final day = await _rowById(dayId);
    final rows = await (_db.select(_db.sales).join([
      innerJoin(
        _db.paymentMethods,
        _db.paymentMethods.id.equalsExp(_db.sales.paymentMethodId),
      ),
    ])..where(_db.sales.dayId.equals(dayId))).get();
    var cash = Money.zero;
    var card = Money.zero;
    var total = Money.zero;
    for (final r in rows) {
      final amount = Money(r.readTable(_db.sales).amountCents);
      total += amount;
      switch (r.readTable(_db.paymentMethods).kind) {
        case PaymentKind.cash:
          cash += amount;
        case PaymentKind.card:
          card += amount;
        case PaymentKind.other:
          break;
      }
    }
    final withdrawalRows = await (_db.select(
      _db.withdrawals,
    )..where((w) => w.dayId.equals(dayId) & w.voided.equals(false))).get();
    final expenseRows =
        await (_db.select(_db.expenses)..where(
              (e) => e.paidInCashDayId.equals(dayId) & e.voided.equals(false),
            ))
            .get();
    final withdrawals = Money.sum(
      withdrawalRows.map((w) => Money(w.amountCents)),
    );
    final cashExpenses = Money.sum(expenseRows.map((e) => Money(e.totalCents)));
    final cashTips = Money(day.cashTipsCents);
    final cardTips = Money(day.cardTipsCents);
    final expected = expectedCash(
      CashInputs(
        openingFloat: Money(day.openingFloatCents),
        cashSales: cash,
        cashTips: cashTips,
        cashExpenses: cashExpenses,
        withdrawals: withdrawals,
      ),
    );
    final counted = _money(day.countedCashCents);
    final terminal = _money(day.terminalTotalCents);
    final cashDiff = counted == null
        ? null
        : cashDiscrepancy(counted: counted, expected: expected);
    final cardDiff = terminal == null
        ? null
        : cardDiscrepancy(
            terminalTotal: terminal,
            cardSales: card,
            cardTips: cardTips,
          );
    final threshold = await _settings.threshold();
    return DaySummary(
      cashSales: cash,
      cardSales: card,
      totalSales: total,
      cashExpenses: cashExpenses,
      withdrawals: withdrawals,
      expected: expected,
      cashDiff: cashDiff,
      cardDiff: cardDiff,
      commentRequired: requiresComment(
        cashDiff: cashDiff ?? Money.zero,
        cardDiff: cardDiff ?? Money.zero,
        threshold: threshold,
      ),
    );
  }

  // ---------------------------------------------------------- transitions

  Future<void> closeDay(String dayId) => _db.transaction(() async {
    final day = await _rowById(dayId);
    if (day.status != DayStatus.open) throw const DayNotOpenException();
    final date = parseYmd(day.date);
    await _guard.ensureMonthOpen(date);
    final counted = day.countedCashCents;
    if (counted == null) {
      throw StateError('Cannot close ${day.date}: counted cash is not set');
    }
    if (day.terminalTotalCents == null) {
      throw StateError('Cannot close ${day.date}: terminal total is not set');
    }
    final s = await summary(dayId);
    if (s.commentRequired && (day.comment ?? '').trim().isEmpty) {
      throw const CommentRequiredException();
    }
    final closedAt = DateTime.now().toUtc().toIso8601String();
    await (_db.update(_db.days)..where((d) => d.id.equals(dayId))).write(
      DaysCompanion(
        status: const Value(DayStatus.closed),
        cashDiffCents: Value(s.cashDiff!.cents),
        cardDiffCents: Value(s.cardDiff!.cents),
        closedAt: Value(closedAt),
        updatedAt: Value(nowIso()),
      ),
    );
    await _audit.updated(
      _dayEntity,
      dayId,
      {
        'cashDiff': day.cashDiffCents,
        'cardDiff': day.cardDiffCents,
        'closedAt': day.closedAt,
      },
      {
        'cashDiff': s.cashDiff!.cents,
        'cardDiff': s.cardDiff!.cents,
        'closedAt': closedAt,
      },
    );
    await _audit.event(
      _dayEntity,
      dayId,
      'status',
      oldValue: DayStatus.open,
      newValue: DayStatus.closed,
    );
    await _propagateFloat(date, Money(counted));
  });

  /// Sets the opening float of the next day by date, when that day is open.
  Future<void> _propagateFloat(DateTime date, Money float) async {
    final next =
        await (_db.select(_db.days)
              ..where((d) => d.date.isBiggerThanValue(ymd(date)))
              ..orderBy([(d) => OrderingTerm.asc(d.date)])
              ..limit(1))
            .getSingleOrNull();
    if (next == null || next.status != DayStatus.open) return;
    if (next.openingFloatCents == float.cents) return;
    await (_db.update(_db.days)..where((d) => d.id.equals(next.id))).write(
      DaysCompanion(
        openingFloatCents: Value(float.cents),
        updatedAt: Value(nowIso()),
      ),
    );
    await _audit.updated(
      _dayEntity,
      next.id,
      {'openingFloat': next.openingFloatCents},
      {'openingFloat': float.cents},
    );
  }

  Future<void> markNoActivity(DateTime date) => _db.transaction(() async {
    final d = dateOnly(date);
    await _guard.ensureMonthOpen(d);
    final float = await _inheritedFloat(d);
    final closedAt = DateTime.now().toUtc();
    final row = await _row(d);
    if (row == null) {
      await _insertDay(d, DayStatus.noActivity, float, closedAt: closedAt);
    } else {
      if (row.status != DayStatus.open) {
        throw StateError('${row.date} is not open: cannot mark no activity');
      }
      final sales =
          await (_db.select(_db.sales)..where(
                (s) => s.dayId.equals(row.id) & s.amountCents.equals(0).not(),
              ))
              .get();
      if (sales.isNotEmpty) {
        throw StateError('${row.date} has sales: cannot mark no activity');
      }
      final closedText = closedAt.toIso8601String();
      await (_db.update(_db.days)..where((x) => x.id.equals(row.id))).write(
        DaysCompanion(
          status: const Value(DayStatus.noActivity),
          openingFloatCents: Value(float.cents),
          closedAt: Value(closedText),
          updatedAt: Value(nowIso()),
        ),
      );
      await _audit.updated(
        _dayEntity,
        row.id,
        {'openingFloat': row.openingFloatCents, 'closedAt': row.closedAt},
        {'openingFloat': float.cents, 'closedAt': closedText},
      );
      await _audit.event(
        _dayEntity,
        row.id,
        'status',
        oldValue: DayStatus.open,
        newValue: DayStatus.noActivity,
      );
    }
    await _propagateFloat(d, float);
  });

  Future<void> reopenDay(String dayId, String reason) {
    final why = reason.trim();
    if (why.isEmpty) {
      throw ArgumentError.value(reason, 'reason', 'must not be blank');
    }
    return _db.transaction(() async {
      final day = await _rowById(dayId);
      await _guard.ensureMonthOpen(parseYmd(day.date));
      if (day.status == DayStatus.open) {
        throw StateError('${day.date} is already open');
      }
      // The stored discrepancies stay until the next close.
      await (_db.update(_db.days)..where((d) => d.id.equals(dayId))).write(
        DaysCompanion(
          status: const Value(DayStatus.open),
          closedAt: const Value(null),
          updatedAt: Value(nowIso()),
        ),
      );
      await _audit.updated(
        _dayEntity,
        dayId,
        {'closedAt': day.closedAt},
        {'closedAt': null},
        reason: why,
      );
      await _audit.event(
        _dayEntity,
        dayId,
        'status',
        oldValue: day.status,
        newValue: DayStatus.open,
        reason: why,
      );
    });
  }

  // -------------------------------------------------------------- queries

  /// First date in `(after, today]` with no row or with an open day.
  Future<DateTime?> nextPendingDate({
    required DateTime after,
    required DateTime today,
  }) async {
    final from = dateOnly(after).add(const Duration(days: 1));
    final to = dateOnly(today);
    if (to.isBefore(from)) return null;
    final range = DateRange(from, to);
    final rows = await _rowsInRange(range);
    final byDate = {for (final r in rows) r.date: r.status};
    for (final d in range.dates) {
      final status = byDate[ymd(d)];
      if (status == null || status == DayStatus.open) return d;
    }
    return null;
  }

  Future<List<DaySnapshot>> snapshots(DateRange r) async => [
    for (final d in await _rowsInRange(r))
      DaySnapshot(
        id: d.id,
        date: parseYmd(d.date),
        status: d.status,
        openingFloat: Money(d.openingFloatCents),
        countedCash: _money(d.countedCashCents),
        cashDiff: Money(d.cashDiffCents ?? 0),
        cardDiff: Money(d.cardDiffCents ?? 0),
      ),
  ];
}
