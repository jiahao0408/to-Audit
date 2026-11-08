import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/audit/period_guard.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/domain/enums.dart';

void main() {
  late AppDatabase db;
  late PeriodGuard guard;

  setUp(() {
    db = AppDatabase.memory();
    guard = PeriodGuard(db);
  });
  tearDown(() => db.close());

  Future<void> addDay(String date, DayStatus s) => db
      .into(db.days)
      .insert(
        DaysCompanion.insert(
          id: newId(),
          createdAt: nowIso(),
          updatedAt: nowIso(),
          date: date,
          status: s,
          openingFloatCents: 0,
        ),
      );

  Future<void> addPeriod(String month, PeriodStatus s) => db
      .into(db.periods)
      .insert(
        PeriodsCompanion.insert(
          id: newId(),
          createdAt: nowIso(),
          updatedAt: nowIso(),
          month: month,
          status: s,
        ),
      );

  Matcher locked(String kind, String key) => throwsA(
    isA<PeriodLockedException>()
        .having((e) => e.kind, 'kind', kind)
        .having((e) => e.key, 'key', key),
  );

  test('closed day throws day', () async {
    await addDay('2026-03-05', DayStatus.closed);
    await expectLater(
      guard.ensureDayOpen(DateTime.utc(2026, 3, 5)),
      locked('day', '2026-03-05'),
    );
  });

  test('noActivity day throws day', () async {
    await addDay('2026-03-06', DayStatus.noActivity);
    await expectLater(
      guard.ensureDayOpen(DateTime.utc(2026, 3, 6)),
      locked('day', '2026-03-06'),
    );
  });

  test('open day passes', () async {
    await addDay('2026-03-07', DayStatus.open);
    await guard.ensureDayOpen(DateTime.utc(2026, 3, 7));
  });

  test('closed month throws month, even for an open day', () async {
    await addPeriod('2026-02', PeriodStatus.closed);
    await addDay('2026-02-10', DayStatus.open);
    await expectLater(
      guard.ensureDayOpen(DateTime.utc(2026, 2, 10)),
      locked('month', '2026-02'),
    );
    await expectLater(
      guard.ensureMonthOpen(DateTime.utc(2026, 2, 1)),
      locked('month', '2026-02'),
    );
  });

  test('day without row passes; open period passes', () async {
    await addPeriod('2026-04', PeriodStatus.open);
    await guard.ensureDayOpen(DateTime.utc(2026, 4, 9));
    await guard.ensureMonthOpen(DateTime.utc(2026, 4, 9));
  });
}
