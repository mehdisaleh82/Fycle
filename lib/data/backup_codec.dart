import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import '../domain/calendar_day.dart';
import '../domain/day_entry.dart';
import '../domain/flow_intensity.dart';
import '../domain/libido_level.dart';
import '../domain/mood.dart';
import '../domain/pain_level.dart';
import '../domain/period_predictor.dart';
import '../domain/sleep_quality.dart';
import '../domain/start_profile.dart';
import '../domain/symptom.dart';
import 'fycle_data.dart';

/// Why an export file could not be read.
enum BackupProblem {
  /// The file was not produced by the app.
  notABackup,

  /// The file was produced by a newer version of the app.
  unsupportedVersion,

  /// The password is wrong, or the file was altered. The two cannot be told
  /// apart, by design.
  wrongPasswordOrDamaged,
}

/// Thrown when an export file cannot be read.
final class BackupException implements Exception {
  const BackupException(this.problem);

  final BackupProblem problem;

  @override
  String toString() => 'BackupException: ${problem.name}';
}

/// Shortest password accepted for an export file, in characters.
const int minBackupPasswordLength = 8;

/// Suggested extension of an encrypted export file.
const String backupFileExtension = 'fycle';

/// Writes and reads the encrypted export file.
///
/// The file is protected by a password chosen by the user, so that it can be
/// read back on another phone. There is no way to recover a lost password.
///
/// Layout of format version 1 (integers are big-endian):
///
/// | offset | size | content                                   |
/// |--------|------|-------------------------------------------|
/// | 0      | 5    | the ASCII letters `FYCLE`                 |
/// | 5      | 1    | format version (1)                        |
/// | 6      | 1    | key derivation (1 = Argon2id)             |
/// | 7      | 4    | Argon2id memory, in KiB                   |
/// | 11     | 1    | Argon2id passes                           |
/// | 12     | 1    | Argon2id lanes                            |
/// | 13     | 16   | salt                                      |
/// | 29     | 12   | nonce                                     |
/// | 41     | n    | AES-256-GCM ciphertext                    |
/// | 41 + n | 16   | AES-256-GCM authentication tag            |
///
/// The first 41 bytes are authenticated together with the content. The
/// content is UTF-8 JSON, see [_toJson].
final class BackupCodec {
  /// The key derivation cost can be lowered in tests to keep them fast.
  const BackupCodec({this.memoryKib = 19456, this.passes = 2});

  /// Argon2id memory in KiB. The default (19 MiB, 2 passes) is the minimum
  /// recommended by OWASP for password storage.
  final int memoryKib;

  /// Argon2id passes.
  final int passes;

  static const List<int> _magic = [0x46, 0x59, 0x43, 0x4c, 0x45]; // FYCLE
  static const int _formatVersion = 1;
  static const int _contentVersion = 1;
  static const int _argon2id = 1;
  static const int _lanes = 1;
  static const int _saltLength = 16;
  static const int _nonceLength = 12;
  static const int _tagLength = 16;
  static const int _headerLength = 41;

  // Limits on what a file may ask of the phone, so that a crafted file cannot
  // freeze the app.
  static const int _maxMemoryKib = 262144; // 256 MiB
  static const int _maxPasses = 10;
  static const int _maxLanes = 4;

  /// Encrypts [data] with [password].
  ///
  /// Throws an [ArgumentError] if the password is shorter than
  /// [minBackupPasswordLength] characters.
  Future<Uint8List> encode(FycleData data, String password) async {
    if (password.runes.length < minBackupPasswordLength) {
      throw ArgumentError.value(
        password.runes.length,
        'password',
        'Must be at least $minBackupPasswordLength characters long',
      );
    }
    final random = Random.secure();
    final salt = _randomBytes(random, _saltLength);
    final nonce = _randomBytes(random, _nonceLength);

    final header = BytesBuilder()
      ..add(_magic)
      ..addByte(_formatVersion)
      ..addByte(_argon2id)
      ..add((ByteData(4)..setUint32(0, memoryKib)).buffer.asUint8List())
      ..addByte(passes)
      ..addByte(_lanes)
      ..add(salt)
      ..add(nonce);
    final headerBytes = header.toBytes();

    final key = await _deriveKey(password, salt, memoryKib, passes, _lanes);
    final box = await AesGcm.with256bits().encrypt(
      utf8.encode(jsonEncode(_toJson(data))),
      secretKey: key,
      nonce: nonce,
      aad: headerBytes,
    );

    return (BytesBuilder()
          ..add(headerBytes)
          ..add(box.cipherText)
          ..add(box.mac.bytes))
        .toBytes();
  }

  /// Decrypts a file produced by [encode].
  ///
  /// Throws a [BackupException] if the file is not an export file, comes from
  /// a newer version, was altered, or if [password] is wrong.
  Future<FycleData> decode(Uint8List bytes, String password) async {
    if (bytes.length < _magic.length + 1) {
      throw const BackupException(BackupProblem.notABackup);
    }
    for (var i = 0; i < _magic.length; i++) {
      if (bytes[i] != _magic[i]) {
        throw const BackupException(BackupProblem.notABackup);
      }
    }
    if (bytes[5] != _formatVersion) {
      throw const BackupException(BackupProblem.unsupportedVersion);
    }
    if (bytes.length < _headerLength + _tagLength) {
      throw const BackupException(BackupProblem.wrongPasswordOrDamaged);
    }

    final view = ByteData.sublistView(bytes);
    final kdf = bytes[6];
    final memory = view.getUint32(7);
    final filePasses = bytes[11];
    final lanes = bytes[12];
    if (kdf != _argon2id ||
        memory < 8 * lanes ||
        memory > _maxMemoryKib ||
        filePasses < 1 ||
        filePasses > _maxPasses ||
        lanes < 1 ||
        lanes > _maxLanes) {
      throw const BackupException(BackupProblem.wrongPasswordOrDamaged);
    }
    final salt = bytes.sublist(13, 29);
    final nonce = bytes.sublist(29, _headerLength);
    final cipherText = bytes.sublist(_headerLength, bytes.length - _tagLength);
    final tag = bytes.sublist(bytes.length - _tagLength);

    final key = await _deriveKey(password, salt, memory, filePasses, lanes);
    final List<int> clear;
    try {
      clear = await AesGcm.with256bits().decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(tag)),
        secretKey: key,
        aad: bytes.sublist(0, _headerLength),
      );
    } on SecretBoxAuthenticationError {
      throw const BackupException(BackupProblem.wrongPasswordOrDamaged);
    }

    try {
      return _fromJson(jsonDecode(utf8.decode(clear)));
    } on FormatException {
      throw const BackupException(BackupProblem.wrongPasswordOrDamaged);
    }
  }

  static Future<SecretKey> _deriveKey(
    String password,
    List<int> salt,
    int memoryKib,
    int passes,
    int lanes,
  ) {
    final argon2id = Argon2id(
      parallelism: lanes,
      memory: memoryKib,
      iterations: passes,
      hashLength: 32,
    );
    return argon2id.deriveKeyFromPassword(password: password, nonce: salt);
  }

  static Uint8List _randomBytes(Random random, int length) =>
      Uint8List.fromList([
        for (var i = 0; i < length; i++) random.nextInt(256),
      ]);

  /// Content of the file once decrypted, for content version 1:
  ///
  /// ```json
  /// {
  ///   "content": 1,
  ///   "usualCycleLength": 28,
  ///   "birthYear": 1990,
  ///   "usualPeriodLength": 5,
  ///   "regularity": "regular",
  ///   "days": [
  ///     {
  ///       "day": "2026-03-05",
  ///       "flow": "medium",
  ///       "pain": "mild",
  ///       "mood": "calm",
  ///       "sleep": "good",
  ///       "libido": "medium",
  ///       "symptoms": ["cramps"],
  ///       "note": "..."
  ///     }
  ///   ]
  /// }
  /// ```
  ///
  /// Absent fields mean "not logged". Fields may be added without raising
  /// the content version: a reader ignores the ones it does not know.
  static Map<String, Object?> _toJson(FycleData data) => {
    'content': _contentVersion,
    'usualCycleLength': ?data.usualCycleLength,
    'birthYear': ?data.birthYear,
    'usualPeriodLength': ?data.usualPeriodLength,
    'regularity': ?data.regularity?.name,
    'days': [
      for (final entry in data.days)
        {
          'day': '${entry.day}',
          'flow': ?entry.flow?.name,
          'pain': ?entry.pain?.name,
          'mood': ?entry.mood?.name,
          'sleep': ?entry.sleep?.name,
          'libido': ?entry.libido?.name,
          if (entry.symptoms.isNotEmpty)
            'symptoms': [for (final symptom in entry.symptoms) symptom.name]
              ..sort(),
          'note': ?entry.note,
        },
    ],
  };

  static FycleData _fromJson(Object? json) {
    if (json is! Map<String, Object?>) {
      throw const FormatException('Not an object');
    }
    final content = json['content'];
    if (content is! int || content < 1) {
      throw const FormatException('No content version');
    }
    if (content > _contentVersion) {
      throw const BackupException(BackupProblem.unsupportedVersion);
    }

    final length = json['usualCycleLength'];
    if (length != null &&
        (length is! int ||
            length < PeriodPredictor.minCycleLength ||
            length > PeriodPredictor.maxCycleLength)) {
      throw const FormatException('Invalid cycle length');
    }

    final birthYear = json['birthYear'];
    if (birthYear != null &&
        (birthYear is! int || birthYear < 1900 || birthYear > 2200)) {
      throw const FormatException('Invalid year of birth');
    }

    // Added later: an unexpected value is ignored rather than fatal.
    final periodLength = json['usualPeriodLength'];
    final validPeriodLength =
        periodLength is int &&
        periodLength >= minPeriodLength &&
        periodLength <= maxPeriodLength;

    final days = json['days'];
    if (days is! List<Object?>) {
      throw const FormatException('No days');
    }
    final byDay = <CalendarDay, DayEntry>{};
    for (final item in days) {
      if (item is! Map<String, Object?>) {
        throw const FormatException('Invalid day');
      }
      final dayText = item['day'];
      final day = dayText is String ? CalendarDay.tryParse(dayText) : null;
      if (day == null || byDay.containsKey(day)) {
        throw const FormatException('Invalid or repeated day');
      }
      final symptoms = item['symptoms'];
      final note = item['note'];
      if ((symptoms != null && symptoms is! List<Object?>) ||
          (note != null && note is! String)) {
        throw const FormatException('Invalid day');
      }
      byDay[day] = DayEntry(
        day: day,
        flow: _byName(FlowIntensity.values, item['flow']),
        pain: _byName(PainLevel.values, item['pain']),
        mood: _byName(Mood.values, item['mood']),
        sleep: _byName(SleepQuality.values, item['sleep']),
        libido: _byName(LibidoLevel.values, item['libido']),
        symptoms: {
          if (symptoms is List<Object?>)
            for (final name in symptoms) ?_byName(Symptom.values, name),
        },
        note: note as String?,
      );
    }

    final sorted = byDay.values.where((entry) => !entry.isEmpty).toList()
      ..sort((a, b) => a.day.compareTo(b.day));
    return FycleData(
      usualCycleLength: length as int?,
      birthYear: birthYear as int?,
      usualPeriodLength: validPeriodLength ? periodLength : null,
      regularity: _byName(CycleRegularity.values, json['regularity']),
      days: sorted,
    );
  }
}

/// The value of [values] called [name], or null. A name written by a newer
/// version of the app is ignored rather than fatal.
T? _byName<T extends Enum>(List<T> values, Object? name) {
  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }
  return null;
}
