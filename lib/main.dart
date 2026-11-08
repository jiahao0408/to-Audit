import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';

void main() {
  runApp(const ToAuditApp());
}

class ToAuditApp extends StatelessWidget {
  const ToAuditApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('zh')],
      theme: ThemeData(colorSchemeSeed: Colors.teal, fontFamily: 'NotoSansSC'),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
        fontFamily: 'NotoSansSC',
      ),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(child: Text(AppLocalizations.of(context)!.appTitle)),
        ),
      ),
    );
  }
}
