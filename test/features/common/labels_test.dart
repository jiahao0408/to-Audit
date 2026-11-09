import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/export/export_keys.dart';
import 'package:to_audit/data/repositories/catalog_repository.dart';
import 'package:to_audit/features/common/catalog_label.dart';
import 'package:to_audit/features/common/export_labels.dart';
import 'package:to_audit/l10n/app_localizations.dart';
import 'package:to_audit/l10n/app_localizations_es.dart';
import 'package:to_audit/l10n/app_localizations_zh.dart';

CatalogItem item(String? code, String name) =>
    CatalogItem(id: 'id', code: code, name: name, active: true, order: 0);

void main() {
  final es = AppLocalizationsEs();
  final zh = AppLocalizationsZh();

  const seeded = [
    'cash', 'card', 'bizum', 'vouchers', 'glovo', 'justeat', 'ubereats', //
    'meat', 'fish', 'vegetables', 'drinks', 'groceries', 'cleaning',
    'utilities', 'rent', 'insurance', 'selfemployed', 'advisor', 'other',
    'bank_deposit', 'owner', 'cash_payment', 'change',
  ];

  test('every seeded code has a Spanish and a Chinese label', () {
    for (final code in seeded) {
      final spanish = catalogLabel(es, item(code, 'stored'));
      final chinese = catalogLabel(zh, item(code, 'stored'));
      expect(spanish, isNot('stored'), reason: code);
      expect(chinese, isNot('stored'), reason: code);
    }
  });

  test('a translated code ignores the stored name', () {
    expect(catalogLabel(es, item('cash', 'Caja')), 'Efectivo');
    expect(catalogLabel(zh, item('cash', 'Caja')), '现金');
  });

  test('a user row shows its own name', () {
    expect(catalogLabel(es, item(null, 'Pastelería')), 'Pastelería');
    expect(catalogLabel(zh, item(null, 'Pastelería')), 'Pastelería');
    expect(catalogLabel(zh, item('custom_code', 'Mío')), 'Mío');
  });

  test('exportLabels translates every ExportKeys constant', () {
    final source = File('lib/data/export/export_keys.dart').readAsStringSync();
    final keys = RegExp(r"static const \w+ = '(\w+)';")
        .allMatches(source)
        .map((m) => m.group(1)!)
        .toList();
    expect(keys.length, greaterThan(50));

    final spanish = exportLabels(es, 'es');
    final chinese = exportLabels(zh, 'zh');
    expect(spanish.locale, 'es');
    expect(chinese.locale, 'zh');
    for (final key in keys) {
      expect(spanish.t(key), isNotEmpty, reason: key);
      expect(chinese.t(key), isNotEmpty, reason: key);
    }
    expect(spanish.t(ExportKeys.profit), 'Beneficio');
    expect(chinese.t(ExportKeys.profit), '利润');
    expect(() => spanish.t('nope'), throwsArgumentError);
  });

  test('AppLocalizations supports exactly es and zh', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode),
      unorderedEquals(['es', 'zh']),
    );
  });
}
