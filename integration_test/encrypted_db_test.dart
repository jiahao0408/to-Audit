import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:to_audit/data/db/app_database.dart';
import 'package:to_audit/data/db/open_database.dart';
import 'package:to_audit/domain/enums.dart';

const keyA = '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';
const keyB = 'ffeeddccbbaa99887766554433221100ffeeddccbbaa99887766554433221100';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('encrypted database: key A opens, key B throws', (_) async {
    final dir = await Directory.systemTemp.createTemp('to_audit_db_');
    final file = File('${dir.path}/to_audit.db');
    try {
      final created = await openEncryptedDatabase(file: file, hexKey: keyA);
      await created
          .into(created.days)
          .insert(
            DaysCompanion.insert(
              id: 'day-1',
              createdAt: nowIso(),
              updatedAt: nowIso(),
              date: '2026-11-09',
              status: DayStatus.open,
              openingFloatCents: 0,
            ),
          );
      await created.close();

      final wrong = await openEncryptedDatabase(file: file, hexKey: keyB);
      await expectLater(wrong.select(wrong.days).get(), throwsA(anything));
      await wrong.close().catchError((_) {});

      final right = await openEncryptedDatabase(file: file, hexKey: keyA);
      final days = await right.select(right.days).get();
      expect(days.map((d) => d.date), ['2026-11-09']);
      await right.close();

      final header = (await file.openRead(0, 16).first).take(16).toList();
      expect(header, isNot(ascii.encode('SQLite format 3\u0000')));
    } finally {
      await dir.delete(recursive: true);
    }
  });
}
