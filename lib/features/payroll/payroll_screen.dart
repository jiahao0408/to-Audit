import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Placeholder: a later task replaces it with the real screen.
class PayrollScreen extends StatelessWidget {
  const PayrollScreen({super.key, required this.month});

  final String month;

  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.of(context)!.screenPayroll;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
