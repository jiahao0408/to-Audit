import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/files/receipt_store.dart';
import 'package:to_audit/domain/enums.dart';

void main() {
  late Directory tmp;
  late File photo;
  late File pdf;
  int? seenMaxSide;
  int? seenQuality;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('receipt_store_test');
    photo = File('${tmp.path}/in.png')..writeAsBytesSync([9, 9, 9, 9, 9, 9]);
    pdf = File('${tmp.path}/in.pdf')..writeAsBytesSync([37, 80, 68, 70, 1, 2]);
    seenMaxSide = null;
    seenQuality = null;
  });
  tearDown(() => tmp.delete(recursive: true));

  ReceiptStore store() => ReceiptStore(
    Directory('${tmp.path}/root'),
    compressor: (source, {int maxSide = 1600, int quality = 75}) async {
      seenMaxSide = maxSide;
      seenQuality = quality;
      return [1, 2, 3];
    },
  );

  test(
    'photo is compressed with 1600/75 and saved as receipts/<uuid>.jpg',
    () async {
      final s = store();
      final rel = await s.save(photo, ReceiptKind.photo);
      expect(rel, matches(RegExp(r'^receipts/[0-9a-f-]{36}\.jpg$')));
      expect(seenMaxSide, 1600);
      expect(seenQuality, 75);
      expect(s.fileFor(rel).readAsBytesSync(), [1, 2, 3]);
      expect(s.fileFor(rel).path.replaceAll(r'\', '/'), contains('/root/'));
    },
  );

  test('pdf is copied byte for byte as receipts/<uuid>.pdf', () async {
    final s = store();
    final rel = await s.save(pdf, ReceiptKind.pdf);
    expect(rel, matches(RegExp(r'^receipts/[0-9a-f-]{36}\.pdf$')));
    expect(s.fileFor(rel).readAsBytesSync(), [37, 80, 68, 70, 1, 2]);
    expect(seenMaxSide, isNull);
  });

  test('each save gets a distinct name', () async {
    final s = store();
    final a = await s.save(pdf, ReceiptKind.pdf);
    final b = await s.save(pdf, ReceiptKind.pdf);
    expect(a, isNot(b));
  });
}
