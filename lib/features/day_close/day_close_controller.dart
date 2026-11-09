import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/audit/period_guard.dart';
import '../../data/providers.dart';
import '../../data/repositories/catalog_repository.dart';
import '../../data/repositories/days_repository.dart';
import '../../data/repositories/expenses_repository.dart';
import '../../domain/cash_calc.dart';
import '../../domain/dates.dart';
import '../../domain/enums.dart';
import '../../domain/money.dart';

/// Why the last save or close did not go through. Shown inline by the screen.
enum DayCloseError {
  commentRequired,
  countedMissing,
  terminalMissing,
  periodLocked,
  notOpen,
  saveFailed,
}

const Object _keep = Object();

/// Everything the day screen shows and edits.
class DayCloseState {
  const DayCloseState({
    required this.dayId,
    required this.date,
    required this.status,
    required this.openingFloat,
    required this.countedCash,
    required this.denominations,
    required this.byDenominations,
    required this.terminalTotal,
    required this.cashTips,
    required this.cardTips,
    required this.comment,
    required this.sales,
    required this.covers,
    required this.summary,
    this.error,
  });

  final String dayId;
  final DateTime date;
  final DayStatus status;
  final Money openingFloat;
  final Money? countedCash;

  /// Denomination in cents -> pieces; only used when [byDenominations].
  final Map<int, int> denominations;
  final bool byDenominations;
  final Money? terminalTotal;
  final Money cashTips;
  final Money cardTips;
  final String comment;

  /// Amount per (payment method id, shift); a missing key is "not entered".
  final Map<(String, Shift), Money> sales;
  final Map<Shift, int> covers;
  final DaySummary summary;
  final DayCloseError? error;

  bool get isOpen => status == DayStatus.open;

  /// A comment is needed (by the last summary) and none is written.
  bool get commentMissing => summary.commentRequired && comment.trim().isEmpty;

  DayCloseState copyWith({
    Object? openingFloat = _keep,
    Object? countedCash = _keep,
    Object? denominations = _keep,
    Object? byDenominations = _keep,
    Object? terminalTotal = _keep,
    Object? cashTips = _keep,
    Object? cardTips = _keep,
    Object? comment = _keep,
    Object? sales = _keep,
    Object? covers = _keep,
    Object? summary = _keep,
    Object? error = _keep,
  }) => DayCloseState(
    dayId: dayId,
    date: date,
    status: status,
    openingFloat: identical(openingFloat, _keep)
        ? this.openingFloat
        : openingFloat! as Money,
    countedCash: identical(countedCash, _keep)
        ? this.countedCash
        : countedCash as Money?,
    denominations: identical(denominations, _keep)
        ? this.denominations
        : denominations! as Map<int, int>,
    byDenominations: identical(byDenominations, _keep)
        ? this.byDenominations
        : byDenominations! as bool,
    terminalTotal: identical(terminalTotal, _keep)
        ? this.terminalTotal
        : terminalTotal as Money?,
    cashTips: identical(cashTips, _keep) ? this.cashTips : cashTips! as Money,
    cardTips: identical(cardTips, _keep) ? this.cardTips : cardTips! as Money,
    comment: identical(comment, _keep) ? this.comment : comment! as String,
    sales: identical(sales, _keep)
        ? this.sales
        : sales! as Map<(String, Shift), Money>,
    covers: identical(covers, _keep) ? this.covers : covers! as Map<Shift, int>,
    summary: identical(summary, _keep) ? this.summary : summary! as DaySummary,
    error: identical(error, _keep) ? this.error : error as DayCloseError?,
  );

  /// The draft to store. In denomination mode the counted cash is the total
  /// of the pieces (null while none is counted).
  DayDraft toDraft() {
    final pieces = {
      for (final e in denominations.entries)
        if (e.value > 0) e.key: e.value,
    };
    return DayDraft(
      openingFloat: openingFloat,
      countedCash: byDenominations
          ? (pieces.isEmpty ? null : countDenominations(pieces))
          : countedCash,
      denominationCounts: byDenominations && pieces.isNotEmpty ? pieces : null,
      terminalTotal: terminalTotal,
      cashTips: cashTips,
      cardTips: cardTips,
      comment: comment.trim().isEmpty ? null : comment,
      sales: [
        for (final e in sales.entries)
          SaleLine(paymentMethodId: e.key.$1, shift: e.key.$2, amount: e.value),
      ],
      covers: covers,
    );
  }
}

DayCloseState _fromRecord(DayRecord r, DaySummary summary) {
  final d = r.draft;
  final counts = d.denominationCounts;
  return DayCloseState(
    dayId: r.id,
    date: r.date,
    status: r.status,
    openingFloat: d.openingFloat,
    countedCash: d.countedCash,
    denominations: counts == null ? const {} : Map.of(counts),
    byDenominations: counts != null,
    terminalTotal: d.terminalTotal,
    cashTips: d.cashTips,
    cardTips: d.cardTips,
    comment: d.comment ?? '',
    sales: {for (final s in d.sales) (s.paymentMethodId, s.shift): s.amount},
    covers: Map.of(d.covers),
    summary: summary,
  );
}

/// State of one day's screen. Edits are kept in memory at once and written
/// with a 300 ms debounce; the summary is recomputed after each write.
class DayCloseController extends AsyncNotifier<DayCloseState> {
  DayCloseController(this.date);

  final DateTime date;

  static const debounce = Duration(milliseconds: 300);

  late final DaysRepository _days;
  Timer? _timer;
  bool _dirty = false;
  bool _disposed = false;
  DayCloseState? _latest;
  Future<void> _queue = Future.value();

  @override
  Future<DayCloseState> build() async {
    _days = ref.watch(daysRepositoryProvider);
    ref.onDispose(() {
      _disposed = true;
      _timer?.cancel();
      // Whatever is still pending is written before the screen is gone.
      final pending = _latest;
      if (_dirty && pending != null) {
        _dirty = false;
        _queue = _queue.then((_) => _writeOnly(pending)).catchError((_) {});
      }
    });
    final record = await _days.openDay(date);
    final next = _fromRecord(record, await _days.summary(record.id));
    _latest = next;
    return next;
  }

  void _publish(DayCloseState next) {
    _latest = next;
    if (!_disposed) state = AsyncData(next);
  }

  void _edit(DayCloseState Function(DayCloseState s) change) {
    final current = _latest;
    if (current == null || !current.isOpen) return;
    _publish(change(current).copyWith(error: null));
    _dirty = true;
    _timer?.cancel();
    _timer = Timer(debounce, flush);
  }

  // --------------------------------------------------------------- edits

  void setSale(String paymentMethodId, Shift shift, Money? amount) =>
      _edit((s) {
        final sales = Map.of(s.sales);
        if (amount == null) {
          sales.remove((paymentMethodId, shift));
        } else {
          sales[(paymentMethodId, shift)] = amount;
        }
        return s.copyWith(sales: sales);
      });

  void setCovers(Shift shift, int count) => _edit((s) {
    final covers = Map.of(s.covers);
    if (count <= 0) {
      covers.remove(shift);
    } else {
      covers[shift] = count;
    }
    return s.copyWith(covers: covers);
  });

  /// An argument left out keeps its value; pass [Money.zero] to clear a tip.
  void setTips({Money? cash, Money? card}) => _edit(
    (s) =>
        s.copyWith(cashTips: cash ?? s.cashTips, cardTips: card ?? s.cardTips),
  );

  void setCountedTotal(Money? total) =>
      _edit((s) => s.copyWith(countedCash: total, byDenominations: false));

  void setDenominations(Map<int, int> counts) => _edit((s) {
    final clean = {
      for (final e in counts.entries)
        if (e.value > 0) e.key: e.value,
    };
    return s.copyWith(
      denominations: clean,
      byDenominations: true,
      countedCash: clean.isEmpty ? null : countDenominations(clean),
    );
  });

  /// Switches between counting a total and counting pieces.
  void setCountMode({required bool byDenominations}) => _edit((s) {
    if (byDenominations == s.byDenominations) return s;
    if (!byDenominations) return s.copyWith(byDenominations: false);
    return s.copyWith(
      byDenominations: true,
      countedCash: s.denominations.isEmpty
          ? null
          : countDenominations(s.denominations),
    );
  });

  void setTerminalTotal(Money? total) =>
      _edit((s) => s.copyWith(terminalTotal: total));

  void setOpeningFloat(Money value) =>
      _edit((s) => s.copyWith(openingFloat: value));

  void setComment(String value) => _edit((s) => s.copyWith(comment: value));

  // --------------------------------------------------------------- saving

  /// Writes pending edits now and waits for every write in flight.
  Future<void> flush() {
    _timer?.cancel();
    _timer = null;
    final pending = _latest;
    if (!_dirty || pending == null) return _queue;
    _dirty = false;
    return _queue = _queue.then((_) => _write(pending));
  }

  Future<void> _writeOnly(DayCloseState snapshot) =>
      _days.saveDraft(snapshot.dayId, snapshot.toDraft());

  Future<void> _write(DayCloseState snapshot) async {
    DayCloseError? error;
    try {
      await _writeOnly(snapshot);
    } on PeriodLockedException {
      error = DayCloseError.periodLocked;
    } on DayNotOpenException {
      error = DayCloseError.notOpen;
    } catch (_) {
      error = DayCloseError.saveFailed;
    }
    if (_disposed) return;
    try {
      final summary = await _days.summary(snapshot.dayId);
      final latest = _latest;
      if (latest != null && !_disposed) {
        _publish(latest.copyWith(summary: summary, error: error));
      }
    } catch (_) {
      final latest = _latest;
      if (latest != null && !_disposed) {
        _publish(latest.copyWith(error: error ?? DayCloseError.saveFailed));
      }
    }
  }

  /// Recomputes the summary after something outside the draft changed.
  Future<void> refreshSummary() async {
    await flush();
    final latest = _latest;
    if (latest == null || _disposed) return;
    final summary = await _days.summary(latest.dayId);
    final current = _latest;
    if (current != null && !_disposed) {
      _publish(current.copyWith(summary: summary));
    }
  }

  // ---------------------------------------------------------- close/reopen

  void _fail(DayCloseError error) {
    final s = _latest;
    if (s != null) _publish(s.copyWith(error: error));
  }

  /// Closes the day and returns the next pending date (null when there is
  /// none). When the day cannot be closed it returns null and
  /// [DayCloseState.error] says why; expected conditions never throw.
  Future<DateTime?> close() async {
    await flush();
    final s = _latest;
    if (s == null || !s.isOpen) return null;
    if (s.toDraft().countedCash == null) {
      _fail(DayCloseError.countedMissing);
      return null;
    }
    if (s.terminalTotal == null) {
      _fail(DayCloseError.terminalMissing);
      return null;
    }
    if (s.commentMissing) {
      _fail(DayCloseError.commentRequired);
      return null;
    }
    try {
      await _days.closeDay(s.dayId);
      final record = await _days.byId(s.dayId);
      _publish(_fromRecord(record, await _days.summary(s.dayId)));
      return await _days.nextPendingDate(
        after: s.date,
        today: dateOnly(ref.read(clockProvider)()),
      );
    } on CommentRequiredException {
      _fail(DayCloseError.commentRequired);
    } on PeriodLockedException {
      _fail(DayCloseError.periodLocked);
    } on DayNotOpenException {
      _fail(DayCloseError.notOpen);
    } catch (_) {
      _fail(DayCloseError.saveFailed);
    }
    return null;
  }

  /// Reopens a closed day (the caller has already asked for PIN and reason).
  Future<void> reopen(String reason) async {
    final s = _latest;
    if (s == null || s.isOpen) return;
    try {
      await _days.reopenDay(s.dayId, reason);
      final record = await _days.byId(s.dayId);
      _publish(_fromRecord(record, await _days.summary(s.dayId)));
    } on PeriodLockedException {
      _fail(DayCloseError.periodLocked);
    } catch (_) {
      _fail(DayCloseError.saveFailed);
    }
  }

  // ------------------------------------------------------- cash movements

  Future<String> _cashMethodId() async {
    final methods = await ref
        .read(catalogRepositoryProvider)
        .watch(CatalogKind.paymentMethod, includeInactive: true)
        .first;
    return methods.firstWhere((m) => m.code == 'cash').id;
  }

  Future<void> addWithdrawal({
    required Money amount,
    required String typeId,
    String? note,
  }) async {
    await flush();
    final cleanNote = note?.trim();
    await ref
        .read(withdrawalsRepositoryProvider)
        .add(
          dayId: _latest!.dayId,
          amount: amount,
          typeId: typeId,
          note: cleanNote == null || cleanNote.isEmpty ? null : cleanNote,
        );
    await refreshSummary();
  }

  Future<void> voidWithdrawal(String id, String reason) async {
    await flush();
    await ref.read(withdrawalsRepositoryProvider).voidRecord(id, reason);
    await refreshSummary();
  }

  /// A purchase paid from this day's till: paid, dated on the day, VAT split
  /// from the [total].
  Future<void> addCashExpense({
    required Money total,
    required String categoryId,
    required int vatPct,
    String? supplierId,
    String? invoiceNumber,
  }) async {
    await flush();
    final split = VatCalc.fromTotal(total, vatPct);
    final invoice = invoiceNumber?.trim();
    await ref
        .read(expensesRepositoryProvider)
        .create(
          ExpenseInput(
            date: date,
            supplierId: supplierId,
            categoryId: categoryId,
            invoiceNumber: invoice == null || invoice.isEmpty ? null : invoice,
            base: split.base,
            vatPct: vatPct,
            vat: split.vat,
            total: total,
            paymentMethodId: await _cashMethodId(),
            paidInCashDayId: _latest!.dayId,
            paymentStatus: PaymentStatus.paid,
          ),
        );
    await refreshSummary();
  }

  Future<void> voidCashExpense(String id, String reason) async {
    await flush();
    await ref.read(expensesRepositoryProvider).voidRecord(id, reason);
    await refreshSummary();
  }
}

final dayCloseControllerProvider = AsyncNotifierProvider.autoDispose
    .family<DayCloseController, DayCloseState, DateTime>(
      DayCloseController.new,
    );
