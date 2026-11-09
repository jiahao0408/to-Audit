import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// A `.toaudit` file cannot be decrypted: wrong password, damaged or
/// truncated file, or contents that fail verification.
class BackupDecryptException implements Exception {
  const BackupDecryptException([this.message = 'Cannot decrypt the backup']);

  final String message;

  @override
  String toString() => 'BackupDecryptException: $message';
}

/// Password-encrypted, chunked AES-256-GCM container.
///
/// ```
/// header: magic(8) | version u16 BE | salt(16) | iterations u32 BE | noncePrefix(4)
/// block*: isLast u8 | len u32 BE | ciphertext(len) | tag(16)
/// nonce = noncePrefix(4) ‖ block index u64 BE ; AAD = isLast(1) ‖ index u64 BE
/// key = PBKDF2-HMAC-SHA256(password, salt, iterations, 32 bytes)
/// ```
///
/// Every block holds [blockSize] plaintext bytes except the last one, which
/// is marked `isLast = 1` and is empty only when the whole input is empty.
class ToauditFormat {
  static const magic = 'TOAUDIT1';
  static const version = 1;
  static const blockSize = 1 << 20;

  static const _saltLength = 16;
  static const _noncePrefixLength = 4;
  static const _tagLength = 16;
  static const _headerLength = 8 + 2 + _saltLength + 4 + _noncePrefixLength;

  /// Upper bound accepted when reading, so a crafted header cannot make the
  /// key derivation run for hours.
  static const _maxIterations = 10000000;

  static final _aes = AesGcm.with256bits();

  /// Encrypts [plain] into [out] (which the caller closes).
  static Future<void> encrypt(
    Stream<List<int>> plain,
    IOSink out,
    String password, {
    int iterations = 600000,
  }) async {
    final random = Random.secure();
    List<int> randomBytes(int n) =>
        List.generate(n, (_) => random.nextInt(256));
    final salt = randomBytes(_saltLength);
    final noncePrefix = randomBytes(_noncePrefixLength);
    final key = await _deriveKey(password, salt, iterations);

    final header = ByteData(_headerLength);
    final headerBytes = header.buffer.asUint8List();
    headerBytes.setAll(0, ascii.encode(magic));
    header.setUint16(8, version);
    headerBytes.setAll(10, salt);
    header.setUint32(26, iterations);
    headerBytes.setAll(30, noncePrefix);
    out.add(headerBytes);

    var index = 0;
    Future<void> writeBlock(List<int> data, {required bool isLast}) async {
      final box = await _aes.encrypt(
        data,
        secretKey: key,
        nonce: _nonce(noncePrefix, index),
        aad: _aad(isLast, index),
      );
      final prefix = ByteData(5)
        ..setUint8(0, isLast ? 1 : 0)
        ..setUint32(1, box.cipherText.length);
      out
        ..add(prefix.buffer.asUint8List())
        ..add(box.cipherText)
        ..add(box.mac.bytes);
      index++;
    }

    // A full block is written only once more data is known to follow, so the
    // final block always carries isLast = 1.
    final pending = BytesBuilder();
    await for (final chunk in plain) {
      pending.add(chunk);
      while (pending.length > blockSize) {
        final all = pending.takeBytes();
        await writeBlock(
          Uint8List.sublistView(all, 0, blockSize),
          isLast: false,
        );
        pending.add(Uint8List.sublistView(all, blockSize));
      }
    }
    await writeBlock(pending.takeBytes(), isLast: true);
    await out.flush();
  }

  /// Decrypts [input] block by block. The stream fails with
  /// [BackupDecryptException] on a wrong password or a damaged, truncated or
  /// extended file; blocks already emitted were authentic.
  static Stream<List<int>> decrypt(File input, String password) async* {
    final RandomAccessFile file;
    try {
      file = await input.open();
    } on FileSystemException {
      throw const BackupDecryptException('Cannot open the backup file');
    }
    try {
      final header = await _readExactly(file, _headerLength);
      final view = ByteData.sublistView(header);
      if (ascii.decode(header.sublist(0, 8), allowInvalid: true) != magic) {
        throw const BackupDecryptException('Not a .toaudit file');
      }
      if (view.getUint16(8) != version) {
        throw const BackupDecryptException('Unsupported .toaudit version');
      }
      final salt = header.sublist(10, 26);
      final iterations = view.getUint32(26);
      final noncePrefix = header.sublist(30, 34);
      if (iterations < 1 || iterations > _maxIterations) {
        throw const BackupDecryptException('Invalid header');
      }
      final key = await _deriveKey(password, salt, iterations);

      for (var index = 0; ; index++) {
        // Ending here, before a block with isLast = 1, is a truncation.
        final prefix = await _readExactly(file, 5);
        final flag = prefix[0];
        final length = ByteData.sublistView(prefix).getUint32(1);
        if (flag > 1 || length > blockSize) {
          throw const BackupDecryptException('The backup is damaged');
        }
        final isLast = flag == 1;
        final body = await _readExactly(file, length + _tagLength);
        final List<int> clear;
        try {
          clear = await _aes.decrypt(
            SecretBox(
              Uint8List.sublistView(body, 0, length),
              nonce: _nonce(noncePrefix, index),
              mac: Mac(Uint8List.sublistView(body, length)),
            ),
            secretKey: key,
            aad: _aad(isLast, index),
          );
        } on SecretBoxAuthenticationError {
          throw const BackupDecryptException(
            'Wrong password or damaged backup',
          );
        }
        yield clear;
        if (isLast) {
          if ((await file.read(1)).isNotEmpty) {
            throw const BackupDecryptException('Unexpected data after the end');
          }
          return;
        }
      }
    } finally {
      await file.close();
    }
  }

  static Future<SecretKey> _deriveKey(
    String password,
    List<int> salt,
    int iterations,
  ) => Pbkdf2.hmacSha256(
    iterations: iterations,
    bits: 256,
  ).deriveKeyFromPassword(password: password, nonce: salt);

  static List<int> _nonce(List<int> prefix, int index) {
    final nonce = ByteData(12);
    final bytes = nonce.buffer.asUint8List()..setAll(0, prefix);
    nonce.setUint64(4, index);
    return bytes;
  }

  static List<int> _aad(bool isLast, int index) {
    final aad = ByteData(9)
      ..setUint8(0, isLast ? 1 : 0)
      ..setUint64(1, index);
    return aad.buffer.asUint8List();
  }

  /// Reads exactly [n] bytes or throws [BackupDecryptException].
  static Future<Uint8List> _readExactly(RandomAccessFile file, int n) async {
    final out = Uint8List(n);
    var read = 0;
    while (read < n) {
      final got = await file.readInto(out, read, n);
      if (got == 0) {
        throw const BackupDecryptException('The backup is truncated');
      }
      read += got;
    }
    return out;
  }
}
