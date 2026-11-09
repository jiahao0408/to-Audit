import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Placeholder: Task 19 replaces it with the real screen.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.of(context)!.screenCalendar;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
