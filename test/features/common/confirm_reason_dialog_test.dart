import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/features/common/confirm_reason_dialog.dart';
import 'package:to_audit/l10n/app_localizations.dart';

void main() {
  String? result = 'unset';

  Future<void> open(WidgetTester tester) async {
    result = 'unset';
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async =>
                result = await askReason(context, title: 'Reabrir día'),
            child: const Text('go'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
  }

  testWidgets('the reason is mandatory and is returned trimmed', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Reabrir día'), findsOneWidget);
    FilledButton accept() => tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Aceptar'),
    );
    expect(accept().onPressed, isNull);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(accept().onPressed, isNull);

    await tester.enterText(find.byType(TextField), '  error de caja ');
    await tester.pump();
    await tester.tap(find.text('Aceptar'));
    await tester.pumpAndSettle();
    expect(result, 'error de caja');
  });

  testWidgets('cancel returns null', (tester) async {
    await open(tester);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });
}
