import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:to_audit/data/backup/toaudit_format.dart';

const _iterations = 1000;
const _headerLength = 34;
const _blockOverhead = 1 + 4 + 16;

void main() {
  late Directory dir;

  setUp(() async => dir = await Directory.systemTemp.createTemp('toaudit_'));
  tearDown(() => dir.delete(recursive: true));

  Uint8List randomBytes(int length) {
    final random = Random(42);
    return Uint8List.fromList(
      List.generate(length, (_) => random.nextInt(256)),
    );
  }

  /// Splits [data] into uneven chunks, like a file stream would.
  Stream<List<int>> chunked(Uint8List data, [int size = 65536 + 7]) async* {
    for (var i = 0; i < data.length; i += size) {
      yield Uint8List.sublistView(data, i, min(i + size, data.length));
    }
  }

  Future<File> encryptTo(String name, Uint8List data, String password) async {
    final file = File('${dir.path}/$name');
    final sink = file.openWrite();
    await ToauditFormat.encrypt(
      chunked(data),
      sink,
      password,
      iterations: _iterations,
    );
    await sink.close();
    return file;
  }

  Future<Uint8List> decryptAll(File file, String password) async {
    final out = BytesBuilder(copy: false);
    await for (final chunk in ToauditFormat.decrypt(file, password)) {
      out.add(chunk);
    }
    return out.takeBytes();
  }

  final throwsDecrypt = throwsA(isA<BackupDecryptException>());

  test('round trip of 3.5 MB of random bytes is identical', () async {
    final data = randomBytes(3670016); // 3.5 MiB
    final file = await encryptTo('a.toaudit', data, 'correct horse');

    // 3 full blocks + 1 half block.
    expect(
      await file.length(),
      _headerLength + 4 * _blockOverhead + data.length,
    );
    expect(await decryptAll(file, 'correct horse'), data);
  });

  test('header layout: magic, version, iterations', () async {
    final file = await encryptTo('h.toaudit', randomBytes(10), 'password');
    final bytes = await file.readAsBytes();
    expect(ascii.decode(bytes.sublist(0, 8)), 'TOAUDIT1');
    final header = ByteData.sublistView(bytes);
    expect(header.getUint16(8), 1);
    expect(header.getUint32(26), _iterations);
    // First block is the last one, with a 10-byte ciphertext.
    expect(bytes[_headerLength], 1);
    expect(header.getUint32(_headerLength + 1), 10);
  });

  test('empty input and an exact multiple of the block size', () async {
    final empty = await encryptTo('e.toaudit', Uint8List(0), 'password');
    expect(await empty.length(), _headerLength + _blockOverhead);
    expect(await decryptAll(empty, 'password'), isEmpty);

    final data = randomBytes(2 * ToauditFormat.blockSize);
    final exact = await encryptTo('x.toaudit', data, 'password');
    // Two full blocks, the second one marked last: no empty trailing block.
    expect(
      await exact.length(),
      _headerLength + 2 * _blockOverhead + data.length,
    );
    expect(await decryptAll(exact, 'password'), data);
  });

  test('wrong password throws BackupDecryptException', () async {
    final file = await encryptTo('w.toaudit', randomBytes(5000), 'password1');
    await expectLater(decryptAll(file, 'password2'), throwsDecrypt);
  });

  test('a file without its last block throws', () async {
    final data = randomBytes(3670016);
    final file = await encryptTo('t.toaudit', data, 'password');
    final bytes = await file.readAsBytes();
    final fullBlocks = _headerLength + 3 * (_blockOverhead + (1 << 20));
    final cut = File('${dir.path}/cut.toaudit');

    await cut.writeAsBytes(bytes.sublist(0, fullBlocks));
    await expectLater(decryptAll(cut, 'password'), throwsDecrypt);

    // Cut in the middle of the last block too.
    await cut.writeAsBytes(bytes.sublist(0, bytes.length - 100));
    await expectLater(decryptAll(cut, 'password'), throwsDecrypt);

    // And cut inside the header.
    await cut.writeAsBytes(bytes.sublist(0, 20));
    await expectLater(decryptAll(cut, 'password'), throwsDecrypt);
  });

  test('one changed byte in a block throws', () async {
    final data = randomBytes(3670016);
    final file = await encryptTo('c.toaudit', data, 'password');
    final bytes = await file.readAsBytes();
    // A byte in the ciphertext of the second block.
    final at = _headerLength + (_blockOverhead + (1 << 20)) + 5 + 1234;
    bytes[at] ^= 0x01;
    final bad = File('${dir.path}/bad.toaudit');
    await bad.writeAsBytes(bytes);
    await expectLater(decryptAll(bad, 'password'), throwsDecrypt);
  });

  test('a changed isLast flag or trailing garbage throws', () async {
    final data = randomBytes(3000);
    final file = await encryptTo('f.toaudit', data, 'password');
    final bytes = await file.readAsBytes();
    final bad = File('${dir.path}/bad.toaudit');

    final flipped = Uint8List.fromList(bytes)..[_headerLength] = 0;
    await bad.writeAsBytes(flipped);
    await expectLater(decryptAll(bad, 'password'), throwsDecrypt);

    await bad.writeAsBytes([...bytes, 0]);
    await expectLater(decryptAll(bad, 'password'), throwsDecrypt);
  });

  test('a file that is not a .toaudit throws', () async {
    final bad = File('${dir.path}/plain.zip');
    await bad.writeAsBytes(randomBytes(200));
    await expectLater(decryptAll(bad, 'password'), throwsDecrypt);
  });
}
