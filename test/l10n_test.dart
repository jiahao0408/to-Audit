import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> load(String name) =>
    jsonDecode(File('lib/l10n/$name').readAsStringSync())
        as Map<String, dynamic>;

Set<String> keysOf(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

void main() {
  final es = load('app_es.arb');
  final zh = load('app_zh.arb');

  test('both ARB files hold the same keys', () {
    expect(keysOf(zh).difference(keysOf(es)), isEmpty, reason: 'only in zh');
    expect(keysOf(es).difference(keysOf(zh)), isEmpty, reason: 'only in es');
  });

  test('no value is empty', () {
    for (final arb in [es, zh]) {
      for (final k in keysOf(arb)) {
        if (k == '@@locale') continue;
        final v = arb[k];
        expect(v, isA<String>(), reason: k);
        expect((v as String).trim(), isNotEmpty, reason: k);
      }
    }
  });

  test('every placeholder of a Spanish string is used in the Chinese one', () {
    final placeholder = RegExp(r'\{(\w+)\}');
    for (final k in keysOf(es)) {
      if (k == '@@locale') continue;
      final inEs = placeholder
          .allMatches(es[k] as String)
          .map((m) => m.group(1))
          .toSet();
      final inZh = placeholder
          .allMatches(zh[k] as String)
          .map((m) => m.group(1))
          .toSet();
      expect(inZh, inEs, reason: k);
    }
  });
}
