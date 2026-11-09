import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Placeholder: a later task replaces it with the real screen.
class DayScreen extends StatelessWidget {
  const DayScreen({super.key, required this.ymd});

  final String ymd;

  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.of(context)!.screenDay;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
