import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/data/backup_codec.dart';
import 'package:fycle/data/fycle_data.dart';

import 'fakes.dart';

const _password = 'correct horse battery';

Matcher _fails(BackupProblem problem) => throwsA(
  isA<BackupException>().having((e) => e.problem, 'problem', problem),
);

void main() {
  group('round trip', () {
    test('gives back exactly what was exported', () async {
      final bytes = await fastCodec.encode(sampleData(), _password);
      final data = await fastCodec.decode(bytes, _password);
      expect(data.usualCycleLength, 29);
      expect(data.days, sampleData().days);
    });

    test('works with nothing logged', () async {
      final bytes = await fastCodec.encode(FycleData(), _password);
      final data = await fastCodec.decode(bytes, _password);
      expect(data.usualCycleLength, isNull);
      expect(data.days, isEmpty);
    });

    test('works with the real key derivation cost', () async {
      const codec = BackupCodec();
      final bytes = await codec.encode(sampleData(), _password);
      expect((await codec.decode(bytes, _password)).days, sampleData().days);
    });

    test('a file is read with the cost written in it', () async {
      final bytes = await fastCodec.encode(sampleData(), _password);
      final data = await const BackupCodec().decode(bytes, _password);
      expect(data.days, sampleData().days);
    });
  });

  group('file content', () {
    test('starts with the FYCLE marker and format version 1', () async {
      final bytes = await fastCodec.encode(sampleData(), _password);
      expect(ascii.decode(bytes.sublist(0, 5)), 'FYCLE');
      expect(bytes[5], 1);
    });

    test('shows nothing of the data', () async {
      final bytes = await fastCodec.encode(sampleData(), _password);
      final raw = latin1.decode(bytes);
      expect(raw, isNot(contains('2026-03-05')));
      expect(raw, isNot(contains('cramps')));
      expect(raw, isNot(contains('Stayed home')));
    });

    test('differs every time, even for the same data', () async {
      final a = await fastCodec.encode(sampleData(), _password);
      final b = await fastCodec.encode(sampleData(), _password);
      expect(a, isNot(b));
    });
  });

  group('password', () {
    test('a wrong password is refused', () async {
      final bytes = await fastCodec.encode(sampleData(), _password);
      await expectLater(
        fastCodec.decode(bytes, 'correct horse batterx'),
        _fails(BackupProblem.wrongPasswordOrDamaged),
      );
    });

    test('a password under 8 characters is refused at export', () async {
      await expectLater(
        fastCodec.encode(sampleData(), '1234567'),
        throwsArgumentError,
      );
    });

    test('accented and non-Latin passwords work', () async {
      const password = 'été à 北京 🙂!';
      final bytes = await fastCodec.encode(sampleData(), password);
      expect((await fastCodec.decode(bytes, password)).days, hasLength(3));
    });
  });

  group('damaged or foreign files', () {
    test('a file that is not an export is recognised', () async {
      await expectLater(
        fastCodec.decode(utf8.encode('date,flow\r\n2026-03-05,light'), 'x'),
        _fails(BackupProblem.notABackup),
      );
      await expectLater(
        fastCodec.decode(Uint8List(0), _password),
        _fails(BackupProblem.notABackup),
      );
    });

    test('a file from a newer format is recognised', () async {
      final bytes = await fastCodec.encode(sampleData(), _password);
      bytes[5] = 2;
      await expectLater(
        fastCodec.decode(bytes, _password),
        _fails(BackupProblem.unsupportedVersion),
      );
    });

    test('a cut file is refused', () async {
      final bytes = await fastCodec.encode(sampleData(), _password);
      for (final length in [6, 30, 41, bytes.length - 1]) {
        await expectLater(
          fastCodec.decode(bytes.sublist(0, length), _password),
          _fails(BackupProblem.wrongPasswordOrDamaged),
        );
      }
    });

    test('changing any single part of the file is detected', () async {
      final bytes = await fastCodec.encode(sampleData(), _password);
      // Salt, nonce, first and last content bytes, authentication tag.
      for (final index in [13, 29, 41, bytes.length - 17, bytes.length - 1]) {
        final altered = Uint8List.fromList(bytes);
        altered[index] ^= 0x01;
        await expectLater(
          fastCodec.decode(altered, _password),
          _fails(BackupProblem.wrongPasswordOrDamaged),
        );
      }
    });

    test('a file asking for an absurd amount of memory is refused', () async {
      final bytes = await fastCodec.encode(sampleData(), _password);
      ByteData.sublistView(bytes).setUint32(7, 0xFFFFFFFF);
      await expectLater(
        fastCodec.decode(bytes, _password),
        _fails(BackupProblem.wrongPasswordOrDamaged),
      );
    });
  });
}
