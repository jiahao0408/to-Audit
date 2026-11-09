import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/domain/alerts_calc.dart';

import 'scenario.dart';

void main() {
  late ReportScenario s;

  setUp(() async => s = await ReportScenario.create());
  tearDown(() => s.dispose());

  test('an open day before today raises dayOpen', () async {
    final alerts = await s.alerts.current(ReportScenario.d(8));
    expect(
      alerts.where((a) => a.type == AlertType.dayOpen).map((a) => a.date),
      [ReportScenario.d(7)],
    );
    expect(alerts.any((a) => a.type == AlertType.discrepancy), isTrue);
    expect(
      alerts
          .where((a) => a.type == AlertType.dayUnregistered)
          .map((a) => a.date),
      containsAll([ReportScenario.d(4), ReportScenario.d(6)]),
    );
  });

  test('generates due fixed costs before computing', () async {
    final before = await s.db.select(s.db.expenses).get();
    await s.alerts.current(DateTime.utc(2026, 12, 8));
    final after = await s.db.select(s.db.expenses).get();
    expect(after.length, before.length + 2);
  });
}
