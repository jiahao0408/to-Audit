import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Placeholder: a later task replaces it with the real screen.
class ExpenseDetailScreen extends StatelessWidget {
  const ExpenseDetailScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.of(context)!.screenExpenseDetail;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
