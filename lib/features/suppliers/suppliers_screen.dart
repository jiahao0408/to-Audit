import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Placeholder: a later task replaces it with the real screen.
class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.of(context)!.screenSuppliers;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
