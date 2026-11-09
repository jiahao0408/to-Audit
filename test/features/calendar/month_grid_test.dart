import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/repositories/days_repository.dart';
import 'package:to_audit/domain/dates.dart';
import 'package:to_audit/domain/enums.dart';
import 'package:to_audit/domain/money.dart';
import 'package:to_audit/features/calendar/month_grid.dart';
import 'package:to_audit/l10n/app_localizations.dart';

DateTime d(int month, int day) => DateTime.utc(2026, month, day);

DayRecord record(DateTime date, DayStatus status, {Money? cash, Money? card}) =>
    DayRecord(
      id: 'id-${ymd(date)}',
      date: date,
      status: status,
      draft: const DayDraft(openingFloat: Money.zero),
      cashDiff: cash,
      cardDiff: card,
    );

Widget host(Widget child, {String locale = 'es'}) => MaterialApp(
  locale: Locale(locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  group('cellState', () {
    final today = d(11, 9);

    test('no record: unregistered up to today, future after', () {
      expect(cellState(null, d(11, 8), today), DayCellState.unregistered);
      expect(cellState(null, today, today), DayCellState.unregistered);
      expect(cellState(null, d(11, 10), today), DayCellState.future);
    });

    test('open and no-activity records', () {
      expect(
        cellState(record(d(11, 8), DayStatus.open), d(11, 8), today),
        DayCellState.open,
      );
      expect(
        cellState(record(d(11, 8), DayStatus.noActivity), d(11, 8), today),
        DayCellState.noActivity,
      );
    });

    test('closed with both differences at zero is balanced', () {
      final r = record(
        d(11, 8),
        DayStatus.closed,
        cash: Money.zero,
        card: Money.zero,
      );
      expect(cellState(r, d(11, 8), today), DayCellState.balanced);
    });

    test('closed with any difference is a discrepancy', () {
      for (final (cash, card) in [
        (const Money(-50), Money.zero),
        (Money.zero, const Money(120)),
        (const Money(10), const Money(-10)),
      ]) {
        final r = record(d(11, 8), DayStatus.closed, cash: cash, card: card);
        expect(cellState(r, d(11, 8), today), DayCellState.discrepancy);
      }
    });

    test('the time of day of the arguments does not matter', () {
      expect(
        cellState(null, DateTime(2026, 11, 9, 23, 59), DateTime(2026, 11, 9)),
        DayCellState.unregistered,
      );
    });
  });

  group('MonthGrid', () {
    Future<void> pump(
      WidgetTester tester, {
      int year = 2026,
      int month = 11,
      Map<DateTime, DayCellState> states = const {},
      void Function(DateTime)? onTap,
      void Function(DateTime)? onLongPress,
      String locale = 'es',
    }) => tester.pumpWidget(
      host(
        MonthGrid(
          year: year,
          month: month,
          states: states,
          onTap: onTap ?? (_) {},
          onLongPress: onLongPress ?? (_) {},
        ),
        locale: locale,
      ),
    );

    testWidgets('November 2026 starts with six empty cells, Sunday 1st last', (
      tester,
    ) async {
      await pump(tester);

      // Monday 26 Oct .. Saturday 31 Oct are empty.
      for (var i = 0; i < 6; i++) {
        expect(find.byKey(ValueKey('empty-$i')), findsOneWidget);
      }
      expect(find.byKey(const ValueKey('empty-6')), findsNothing);

      final headers = [
        for (var i = 0; i < 7; i++)
          tester.getCenter(find.byKey(ValueKey('weekday-$i'))).dx,
      ];
      Offset center(String key) => tester.getCenter(find.byKey(ValueKey(key)));
      final first = center('day-2026-11-01');
      final second = center('day-2026-11-02');
      final eighth = center('day-2026-11-08');
      // 1 Nov (Sunday) sits in the 7th column, 2 Nov (Monday) starts row 2.
      expect(first.dx, closeTo(headers[6], 0.5));
      expect(second.dx, closeTo(headers[0], 0.5));
      expect(second.dy, greaterThan(first.dy));
      // 8 Nov is the Sunday that ends the second row; 9 Nov starts the third.
      expect(eighth.dx, closeTo(headers[6], 0.5));
      expect(eighth.dy, second.dy);
      expect(center('day-2026-11-09').dy, greaterThan(eighth.dy));
    });

    testWidgets('weekday headers run Monday to Sunday', (tester) async {
      await pump(tester);
      final names = [
        for (var i = 0; i < 7; i++)
          (tester.widget<Text>(
            find.descendant(
              of: find.byKey(ValueKey('weekday-$i')),
              matching: find.byType(Text),
            ),
          )).data!.toLowerCase(),
      ];
      expect(names.first, startsWith('l')); // lun
      expect(names.last, startsWith('d')); // dom
    });

    testWidgets('a month that starts on Monday has no empty cell', (
      tester,
    ) async {
      await pump(tester, year: 2026, month: 6); // 1 June 2026 is a Monday
      expect(find.byKey(const ValueKey('empty-0')), findsNothing);
      expect(find.byKey(const ValueKey('day-2026-06-30')), findsOneWidget);
    });

    testWidgets('every day of the month is there (leap February)', (
      tester,
    ) async {
      await pump(tester, year: 2028, month: 2);
      expect(find.byKey(const ValueKey('day-2028-02-29')), findsOneWidget);
      expect(find.byKey(const ValueKey('day-2028-02-30')), findsNothing);
    });

    testWidgets('tap and long press report the date', (tester) async {
      final taps = <DateTime>[];
      final longs = <DateTime>[];
      await pump(tester, onTap: taps.add, onLongPress: longs.add);

      await tester.tap(find.byKey(const ValueKey('day-2026-11-09')));
      await tester.longPress(find.byKey(const ValueKey('day-2026-11-10')));
      expect(taps, [d(11, 9)]);
      expect(longs, [d(11, 10)]);
    });

    testWidgets('each state has its own icon and a spoken label', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pump(
        tester,
        states: {
          d(11, 2): DayCellState.balanced,
          d(11, 3): DayCellState.discrepancy,
          d(11, 4): DayCellState.open,
          d(11, 5): DayCellState.noActivity,
          d(11, 6): DayCellState.unregistered,
          d(11, 7): DayCellState.future,
        },
      );

      IconData? iconOf(String key) {
        final icons = find.descendant(
          of: find.byKey(ValueKey(key)),
          matching: find.byType(Icon),
        );
        return icons.evaluate().isEmpty
            ? null
            : tester.widget<Icon>(icons.first).icon;
      }

      final icons = [
        for (final day in ['02', '03', '04', '05', '06'])
          iconOf('day-2026-11-$day'),
      ];
      expect(icons.every((i) => i != null), isTrue);
      expect(icons.toSet().length, 5, reason: 'color is not the only signal');

      final labels = {
        '02': 'Cuadrado',
        '03': 'Descuadre',
        '04': 'Abierto',
        '05': 'Sin actividad',
        '06': 'Sin registrar',
        '07': 'Futuro',
      };
      for (final e in labels.entries) {
        expect(
          find.bySemanticsLabel(RegExp('${e.value}\$')),
          findsWidgets,
          reason: e.key,
        );
      }
      semantics.dispose();
    });

    testWidgets('a day with no entry in states counts as unregistered', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pump(tester);
      expect(find.bySemanticsLabel(RegExp(r'Sin registrar$')), findsWidgets);
      semantics.dispose();
    });

    testWidgets('keeps the layout with big system text', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: host(
            MonthGrid(
              year: 2026,
              month: 11,
              states: {d(11, 9): DayCellState.discrepancy},
              onTap: (_) {},
              onLongPress: (_) {},
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('Chinese weekday headers', (tester) async {
      await pump(tester, locale: 'zh');
      final first = (tester.widget<Text>(
        find.descendant(
          of: find.byKey(const ValueKey('weekday-0')),
          matching: find.byType(Text),
        ),
      )).data!;
      expect(first, contains('一'));
    });
  });
}
