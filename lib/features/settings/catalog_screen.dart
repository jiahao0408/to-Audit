import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Placeholder: a later task replaces it with the real screen.
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key, required this.kind});

  final String kind;

  @override
  Widget build(BuildContext context) {
    final title = AppLocalizations.of(context)!.screenCatalogs;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
