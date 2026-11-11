import 'package:flutter_test/flutter_test.dart';

import '../../tool/coverage_check.dart';

const _lcov = r'''
TN:
SF:lib/domain/a.dart
DA:1,1
DA:2,0
DA:3,4
DA:4,0
LF:4
LH:2
end_of_record
SF:lib\domain\b.dart
DA:1,1
DA:2,1
LF:2
LH:2
end_of_record
SF:lib/data/c.dart
DA:1,0
LF:1
LH:0
end_of_record
''';

void main() {
  test('parseLcov reads hit and total lines per file', () {
    final files = parseLcov(_lcov);
    expect(files.keys, [
      'lib/domain/a.dart',
      'lib/domain/b.dart',
      'lib/data/c.dart',
    ]);
    expect(files['lib/domain/a.dart']!.hit, 2);
    expect(files['lib/domain/a.dart']!.total, 4);
    expect(files['lib/domain/a.dart']!.percent, 50);
  });

  test('evaluate filters by prefix and applies the threshold', () {
    final low = evaluate(_lcov, 'lib/domain', 80);
    expect(low.passed, isFalse);
    expect(low.files.length, 2);
    expect(low.failing.map((f) => f.path), ['lib/domain/a.dart']);

    final ok = evaluate(_lcov, 'lib/domain', 50);
    expect(ok.passed, isTrue);
  });

  test('evaluate fails when no file matches the prefix', () {
    expect(evaluate(_lcov, 'lib/nothing', 80).passed, isFalse);
  });
}
