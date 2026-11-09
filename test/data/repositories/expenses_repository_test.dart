import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/audit/audit_writer.dart';
import 'package:to_audit/data/audit/period_guard.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/files/receipt_store.dart';
import 'package:to_audit/data/repositories/days_repository.dart';
import 'package:to_audit/data/repositories/expenses_repository.dart';
import 'package:to_audit/data/repositories/settings_repository.dart';
import 'package:to_audit/data/repositories/suppliers_repository.dart';
import 'package:to_audit/domain/dates.dart';
import 'package:to_audit/domain/enums.dart';
import 'package:to_audit/domain/money.dart';

void main() {
  late AppDatabase db;
  late Directory tmp;
  late DaysRepository days;
  late SuppliersRepository suppliers;
  late ExpensesRepository repo;
  late String catA;
  late String catB;
  late String cashId;
  late String cardId;

  DateTime d(int month, int day) => DateTime.utc(2026, month, day);

  setUp(() async {
    db = AppDatabase.memory();
    tmp = await Directory.systemTemp.createTemp('expenses_repo_test');
    final audit = AuditWriter(db);
    final guard = PeriodGuard(db);
    days = DaysRepository(
      db,
      audit: audit,
      guard: guard,
      settings: SettingsRepository(db, audit),
    );
    suppliers = SuppliersRepository(db, audit: audit);
    repo = ExpensesRepository(
      db,
      audit: audit,
      guard: guard,
      receipts: ReceiptStore(
        tmp,
        compressor: (s, {int maxSide = 1600, int quality = 75}) async => [
          1,
          2,
          3,
        ],
      ),
    );
    final cats = await (db.select(
      db.expenseCategories,
    )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
    catA = cats[0].id;
    catB = cats[1].id;
    final pays = await (db.select(
      db.paymentMethods,
    )..orderBy([(t) => OrderingTerm.asc(t.sortOrder)])).get();
    cashId = pays[0].id;
    cardId = pays[1].id;
  });
  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  ExpenseInput input({
    DateTime? date,
    String? supplierId,
    String? categoryId,
    int base = 1000,
    int vatPct = 10,
    int vat = 100,
    int total = 1100,
    String? paidInCashDayId,
    PaymentStatus status = PaymentStatus.paid,
    DateTime? dueDate,
    String? paymentMethodId,
  }) => ExpenseInput(
    date: date ?? d(10, 1),
    supplierId: supplierId,
    categoryId: categoryId ?? catA,
    invoiceNumber: 'F-1',
    base: Money(base),
    vatPct: vatPct,
    vat: Money(vat),
    total: Money(total),
    paymentMethodId: paymentMethodId ?? cardId,
    paidInCashDayId: paidInCashDayId,
    paymentStatus: status,
    dueDate: dueDate,
  );

  File pdf() => File('${tmp.path}/x.pdf')..writeAsBytesSync([1, 2]);

  Future<ExpenseRecord> only() async =>
      (await repo.watchRange(DateRange(d(1, 1), d(12, 31))).first).single;

  Future<void> closeDay(String dayId) async {
    await days.saveDraft(
      dayId,
      const DayDraft(
        openingFloat: Money.zero,
        countedCash: Money.zero,
        terminalTotal: Money.zero,
        comment: 'x',
      ),
    );
    await days.closeDay(dayId);
  }

  group('suppliers', () {
    test('create, update, search and watch', () async {
      final id = await suppliers.create(
        const SupplierInput(name: 'Carnes Paco', nif: 'B123', phone: '600'),
      );
      await suppliers.create(const SupplierInput(name: 'Pescados Lola'));
      expect((await suppliers.watchAll().first).map((s) => s.name), [
        'Carnes Paco',
        'Pescados Lola',
      ]);
      expect((await suppliers.search('paco')).single.id, id);
      expect((await suppliers.search('b12')).single.id, id);
      expect(await suppliers.search('zzz'), isEmpty);
      await suppliers.update(
        id,
        SupplierInput(name: 'Paco SL', defaultCategoryId: catA),
      );
      final s = (await suppliers.search('paco')).single;
      expect(s.name, 'Paco SL');
      expect(s.nif, isNull);
      expect(s.defaultCategoryId, catA);
      final log = await db.select(db.changeLog).get();
      expect(
        log.where((l) => l.entity == 'proveedor' && l.recordId == id),
        isNotEmpty,
      );
    });

    test('blank name and unknown id are rejected', () async {
      await expectLater(
        suppliers.create(const SupplierInput(name: '  ')),
        throwsArgumentError,
      );
      await expectLater(
        suppliers.update('nope', const SupplierInput(name: 'x')),
        throwsArgumentError,
      );
    });
  });

  group('expenses', () {
    test('create stores and audits a valid invoice', () async {
      final sup = await suppliers.create(const SupplierInput(name: 'P'));
      final id = await repo.create(input(supplierId: sup));
      final e = await only();
      expect(e.id, id);
      expect(e.date, d(10, 1));
      expect(e.base, const Money(1000));
      expect(e.vat, const Money(100));
      expect(e.total, const Money(1100));
      expect(e.vatPct, 10);
      expect(e.origin, ExpenseOrigin.manual);
      expect(e.fixedCostId, isNull);
      expect(e.fixedStatus, isNull);
      expect(e.voided, isFalse);
      expect(e.supplierId, sup);
      final log = await db.select(db.changeLog).get();
      expect(
        log.where((l) => l.entity == 'gasto' && l.recordId == id),
        hasLength(1),
      );
    });

    test('validation: totals, vat pct, amounts and references', () async {
      await expectLater(repo.create(input(total: 1101)), throwsArgumentError);
      await expectLater(repo.create(input(vatPct: 7)), throwsArgumentError);
      await expectLater(
        repo.create(input(base: 0, vat: 0, total: 0, vatPct: 0)),
        throwsArgumentError,
      );
      await expectLater(
        repo.create(input(base: -100, vat: 0, total: -100, vatPct: 0)),
        throwsArgumentError,
      );
      await expectLater(
        repo.create(input(categoryId: 'nope')),
        throwsArgumentError,
      );
      await expectLater(
        repo.create(input(paymentMethodId: 'nope')),
        throwsArgumentError,
      );
      await expectLater(
        repo.create(input(supplierId: 'nope')),
        throwsArgumentError,
      );
      await expectLater(
        repo.create(input(paidInCashDayId: 'nope')),
        throwsArgumentError,
      );
      expect(await db.select(db.expenses).get(), isEmpty);
    });

    test('incomplete until a receipt is attached', () async {
      final id = await repo.create(input());
      expect((await only()).incomplete, isTrue);
      await repo.attachReceipt(id, pdf(), ReceiptKind.pdf);
      final e = await only();
      expect(e.receiptCount, 1);
      expect(e.incomplete, isFalse);
      final rs = await repo.receipts(id);
      expect(rs.single.kind, ReceiptKind.pdf);
      expect(rs.single.sizeBytes, 2);
      expect(
        File('${tmp.path}/${rs.single.relativePath}').existsSync(),
        isTrue,
      );
      final log = await db.select(db.changeLog).get();
      expect(log.where((l) => l.entity == 'justificante'), hasLength(1));
    });

    test('attachReceipt deletes the saved file when the tx fails', () async {
      final id = await repo.create(input());
      await repo.voidRecord(id, 'x');
      await expectLater(
        repo.attachReceipt(id, pdf(), ReceiptKind.pdf),
        throwsStateError,
      );
      final dir = Directory('${tmp.path}/receipts');
      expect(!dir.existsSync() || dir.listSync().isEmpty, isTrue);
      expect(await db.select(db.receipts).get(), isEmpty);
    });

    test(
      'watchPending orders by due date with nulls last, skips paid/void',
      () async {
        final late = await repo.create(
          input(status: PaymentStatus.pending, dueDate: d(11, 20)),
        );
        final none = await repo.create(input(status: PaymentStatus.pending));
        final soon = await repo.create(
          input(status: PaymentStatus.pending, dueDate: d(10, 5)),
        );
        await repo.create(input());
        final gone = await repo.create(
          input(status: PaymentStatus.pending, dueDate: d(10, 1)),
        );
        await repo.voidRecord(gone, 'x');
        final list = await repo.watchPending().first;
        expect(list.map((e) => e.id), [soon, late, none]);
        expect(list.first.dueDate, d(10, 5));
      },
    );

    test('markPaid toggles status and audits', () async {
      final id = await repo.create(
        input(status: PaymentStatus.pending, dueDate: d(10, 5)),
      );
      await repo.markPaid(id, true);
      expect((await only()).paymentStatus, PaymentStatus.paid);
      await repo.markPaid(id, false);
      expect((await only()).paymentStatus, PaymentStatus.pending);
      final log = await db.select(db.changeLog).get();
      expect(
        log.where((l) => l.recordId == id && l.field == 'paymentStatus'),
        hasLength(2),
      );
    });

    test('cash expense on a closed day is locked', () async {
      final day = await days.openDay(d(10, 1));
      final id = await repo.create(
        input(paidInCashDayId: day.id, paymentMethodId: cashId),
      );
      await closeDay(day.id);
      await expectLater(
        repo.create(input(paidInCashDayId: day.id, paymentMethodId: cashId)),
        throwsA(isA<PeriodLockedException>()),
      );
      await expectLater(
        repo.update(id, input(base: 2000, vat: 200, total: 2200)),
        throwsA(isA<PeriodLockedException>()),
      );
      await expectLater(
        repo.voidRecord(id, 'x'),
        throwsA(isA<PeriodLockedException>()),
      );
      // A non-cash expense on the same date is still allowed.
      await repo.create(input());
    });

    test(
      'closed month blocks create, update, void, markPaid, attach',
      () async {
        final id = await repo.create(input(status: PaymentStatus.pending));
        await db
            .into(db.periods)
            .insert(
              PeriodsCompanion.insert(
                id: 'p1',
                createdAt: nowIso(),
                updatedAt: nowIso(),
                month: '2026-10',
                status: PeriodStatus.closed,
              ),
            );
        final locked = throwsA(isA<PeriodLockedException>());
        await expectLater(repo.create(input()), locked);
        await expectLater(
          repo.update(id, input(base: 2000, vat: 200, total: 2200)),
          locked,
        );
        await expectLater(repo.voidRecord(id, 'x'), locked);
        await expectLater(repo.markPaid(id, true), locked);
        await expectLater(
          repo.attachReceipt(id, pdf(), ReceiptKind.pdf),
          locked,
        );
        final dir = Directory('${tmp.path}/receipts');
        expect(!dir.existsSync() || dir.listSync().isEmpty, isTrue);
      },
    );

    test('update changes fields and audits them', () async {
      final id = await repo.create(input());
      await repo.update(
        id,
        input(categoryId: catB, base: 2000, vat: 200, total: 2200),
      );
      final e = await only();
      expect(e.categoryId, catB);
      expect(e.total, const Money(2200));
      final log = await db.select(db.changeLog).get();
      expect(
        log.where(
          (l) =>
              l.entity == 'gasto' &&
              l.field == 'totalCents' &&
              l.oldValue == '1100' &&
              l.newValue == '2200',
        ),
        hasLength(1),
      );
      await expectLater(repo.update(id, input(total: 5)), throwsArgumentError);
      await expectLater(repo.update('nope', input()), throwsArgumentError);
    });

    test('void removes from totals; reason and state are validated', () async {
      final sup = await suppliers.create(const SupplierInput(name: 'P'));
      await repo.create(input(supplierId: sup, categoryId: catA));
      final gone = await repo.create(
        input(
          supplierId: sup,
          categoryId: catA,
          base: 500,
          vat: 50,
          total: 550,
        ),
      );
      await repo.create(
        input(categoryId: catB, base: 200, vat: 20, total: 220),
      );
      final range = DateRange(d(10, 1), d(10, 31));
      expect(await repo.totalsByCategory(range), {
        catA: const Money(1650),
        catB: const Money(220),
      });
      expect(await repo.totalsBySupplier(range), {
        sup: const Money(1650),
        '': const Money(220),
      });
      await expectLater(repo.voidRecord(gone, ' '), throwsArgumentError);
      await repo.voidRecord(gone, '  duplicado ');
      expect(await repo.totalsByCategory(range), {
        catA: const Money(1100),
        catB: const Money(220),
      });
      expect(await repo.totalsBySupplier(range), {
        sup: const Money(1100),
        '': const Money(220),
      });
      final all = await repo.watchRange(range).first;
      expect(all.firstWhere((e) => e.id == gone).voided, isTrue);
      expect(all.firstWhere((e) => e.id == gone).voidReason, 'duplicado');
      await expectLater(repo.voidRecord(gone, 'again'), throwsStateError);
      await expectLater(repo.update(gone, input()), throwsStateError);
      await expectLater(repo.markPaid(gone, true), throwsStateError);
      final log = await db.select(db.changeLog).get();
      expect(
        log.where(
          (l) =>
              l.recordId == gone &&
              l.field == 'voided' &&
              l.reason == 'duplicado',
        ),
        hasLength(1),
      );
    });

    test(
      'watchRange filters by date and orders by date then creation',
      () async {
        final b = await repo.create(input(date: d(10, 2)));
        final a = await repo.create(input(date: d(10, 1)));
        final c = await repo.create(input(date: d(10, 1)));
        await repo.create(input(date: d(11, 1)));
        final list = await repo
            .watchRange(DateRange(d(10, 1), d(10, 31)))
            .first;
        expect(list.map((e) => e.id), [a, c, b]);
      },
    );

    test('snapshots expose receipts, status and due date', () async {
      final id = await repo.create(
        input(status: PaymentStatus.pending, dueDate: d(10, 9)),
      );
      await repo.attachReceipt(id, pdf(), ReceiptKind.pdf);
      final s = (await repo.snapshots()).single;
      expect(s.id, id);
      expect(s.receiptCount, 1);
      expect(s.paymentStatus, PaymentStatus.pending);
      expect(s.dueDate, d(10, 9));
      expect(s.voided, isFalse);
    });
  });

  test('byId returns the expense with its receipt count, or null', () async {
    final id = await repo.create(input());
    expect((await repo.byId(id))!.receiptCount, 0);
    await repo.attachReceipt(id, pdf(), ReceiptKind.pdf);
    final found = (await repo.byId(id))!;
    expect(found.receiptCount, 1);
    expect(found.total, const Money(1100));
    expect(await repo.byId('missing'), isNull);
  });
}
