import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/domain/money.dart';
import 'package:to_audit/features/common/money_field.dart';
import 'package:to_audit/l10n/app_localizations.dart';

Widget host(Widget child) => MaterialApp(
  locale: const Locale('es'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [Locale('es'), Locale('zh')],
  home: Scaffold(body: Form(child: child)),
);

void main() {
  testWidgets('typing 12,5 reports Money(1250) and uses a decimal keyboard', (
    tester,
  ) async {
    final values = <Money?>[];
    await tester.pumpWidget(
      host(MoneyField(label: 'Importe', onChanged: values.add)),
    );

    await tester.enterText(find.byType(TextFormField), '12,5');
    expect(values.last, const Money(1250));

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(
      field.keyboardType,
      const TextInputType.numberWithOptions(decimal: true),
    );
  });

  testWidgets(
    '-3 shows the validation error, reports null and does not throw',
    (tester) async {
      final values = <Money?>[];
      await tester.pumpWidget(
        host(MoneyField(label: 'Importe', onChanged: values.add)),
      );

      await tester.enterText(find.byType(TextFormField), '-3');
      await tester.pump();

      expect(values.last, isNull);
      expect(find.text('Importe no válido'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('an empty required field asks for a value', (tester) async {
    final key = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Form(
            key: key,
            child: const MoneyField(label: 'Importe'),
          ),
        ),
      ),
    );
    expect(key.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Obligatorio'), findsOneWidget);
  });

  testWidgets('an optional field accepts empty and shows the initial value', (
    tester,
  ) async {
    final key = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Form(
            key: key,
            child: const MoneyField(
              label: 'Importe',
              required: false,
              initialValue: Money(1205),
            ),
          ),
        ),
      ),
    );
    expect(find.text('12,05'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '');
    expect(key.currentState!.validate(), isTrue);
  });
}
