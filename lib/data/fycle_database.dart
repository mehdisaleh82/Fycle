import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../domain/calendar_day.dart';
import '../domain/day_entry.dart';
import '../domain/flow_intensity.dart';
import '../domain/mood.dart';
import '../domain/pain_level.dart';
import '../domain/period_predictor.dart';
import '../domain/reminders.dart';
import '../domain/symptom.dart';
import 'appearance.dart';
import 'database_key_store.dart';
import 'fycle_data.dart';

/// Thrown when the database file cannot be read with the given key, or when
/// encryption is not available.
final class DatabaseUnreadableException implements Exception {
  const DatabaseUnreadableException(this.message);

  final String message;

  @override
  String toString() => 'DatabaseUnreadableException: $message';
}

/// The local database: one row per logged day, plus a few settings.
///
/// Two kinds of settings are kept apart. `setting` describes the user's cycle
/// and travels with her data in an export. `device_setting` describes this
/// phone (reminders, app lock): it is never exported and an import leaves it
/// alone.
///
/// On disk the file is encrypted (SQLite3 Multiple Ciphers, ChaCha20-Poly1305)
/// with a random key kept outside the database. Days are stored as ISO dates
/// (`2026-03-05`) and choices as the names of their enum values.
final class FycleDatabase {
  FycleDatabase._(this._db);

  /// Opens the encrypted database stored at [path], creating it if needed.
  ///
  /// Throws a [DatabaseUnreadableException] if [key] is not the key of that
  /// file, or if the SQLite library in use cannot encrypt.
  factory FycleDatabase.open(String path, Uint8List key) {
    if (key.length != databaseKeyLength) {
      throw ArgumentError.value(key.length, 'key', 'Must be 32 bytes long');
    }
    // Never write health data through a library without encryption.
    final probe = sqlite3.openInMemory();
    try {
      probe.select('SELECT sqlite3mc_version()');
    } on SqliteException {
      throw const DatabaseUnreadableException(
        'The bundled SQLite library does not support encryption.',
      );
    } finally {
      probe.close();
    }

    final db = sqlite3.open(path);
    try {
      db.execute("PRAGMA cipher = 'chacha20'");
      db.execute('PRAGMA key = "raw:${_hex(key)}"');
      try {
        db.select('SELECT count(*) FROM sqlite_master');
      } on SqliteException {
        throw const DatabaseUnreadableException(
          'The key does not open this database.',
        );
      }
      return FycleDatabase._(db).._prepare();
    } catch (_) {
      db.close();
      rethrow;
    }
  }

  /// A database that lives in memory only and disappears when closed.
  /// Nothing reaches the disk, so no key is needed. Meant for tests.
  factory FycleDatabase.inMemory() =>
      FycleDatabase._(sqlite3.openInMemory()).._prepare();

  /// Version of the table layout. Raise it and add a step in [_prepare] when
  /// the tables change.
  static const int schemaVersion = 2;

  static const String _usualCycleLength = 'usual_cycle_length';

  static const String _periodReminder = 'reminder_period_enabled';
  static const String _periodReminderDays = 'reminder_period_days_before';
  static const String _periodReminderTime = 'reminder_period_minutes';
  static const String _dailyReminder = 'reminder_daily_enabled';
  static const String _dailyReminderTime = 'reminder_daily_minutes';
  static const String _appLock = 'app_lock_enabled';
  static const String _appearance = 'appearance';
  static const String _onboardingDone = 'onboarding_done';

  final Database _db;

  void _prepare() {
    _db.execute('PRAGMA foreign_keys = ON');
    // Overwrite deleted content instead of leaving it in the file.
    _db.execute('PRAGMA secure_delete = ON');

    final version = _db.userVersion;
    if (version > schemaVersion) {
      throw const DatabaseUnreadableException(
        'The database was written by a newer version of the app.',
      );
    }
    if (version < 1) {
      _transaction(() {
        _db.execute(
          'CREATE TABLE day_entry ('
          'day TEXT NOT NULL PRIMARY KEY, '
          'flow TEXT, '
          'pain TEXT, '
          'mood TEXT, '
          'note TEXT'
          ') WITHOUT ROWID',
        );
        _db.execute(
          'CREATE TABLE day_symptom ('
          'day TEXT NOT NULL REFERENCES day_entry (day) ON DELETE CASCADE, '
          'symptom TEXT NOT NULL, '
          'PRIMARY KEY (day, symptom)'
          ') WITHOUT ROWID',
        );
        _db.execute(
          'CREATE TABLE setting ('
          'name TEXT NOT NULL PRIMARY KEY, '
          'value TEXT NOT NULL'
          ') WITHOUT ROWID',
        );
        _db.userVersion = 1;
      });
    }
    if (version < 2) {
      _transaction(() {
        _db.execute(
          'CREATE TABLE device_setting ('
          'name TEXT NOT NULL PRIMARY KEY, '
          'value TEXT NOT NULL'
          ') WITHOUT ROWID',
        );
        _db.userVersion = 2;
      });
    }
  }

  /// Saves what was logged for one day, replacing any earlier entry for that
  /// day. Saving an empty entry removes the day.
  void saveDay(DayEntry entry) => _transaction(() => _writeDay(entry));

  /// Removes everything logged for [day].
  void deleteDay(CalendarDay day) =>
      _db.execute('DELETE FROM day_entry WHERE day = ?', ['$day']);

  /// What was logged for [day], or null if nothing was.
  DayEntry? readDay(CalendarDay day) {
    final days = _readDays('WHERE day = ?', ['$day']);
    return days.isEmpty ? null : days.single;
  }

  /// Logged days in chronological order, optionally limited to the days
  /// between [from] and [to], both included.
  List<DayEntry> readDays({CalendarDay? from, CalendarDay? to}) {
    // ISO dates sort as text in calendar order.
    return _readDays('WHERE day >= ? AND day <= ?', [
      from?.toString() ?? '0000-00-00',
      to?.toString() ?? '9999-99-99',
    ]);
  }

  /// The day-by-day flow log, in the shape expected by `periodStartsFrom`.
  /// Days without flow are absent.
  Map<CalendarDay, FlowIntensity> flowByDay() {
    final rows = _db.select(
      'SELECT day, flow FROM day_entry WHERE flow IS NOT NULL ORDER BY day',
    );
    final result = <CalendarDay, FlowIntensity>{};
    for (final row in rows) {
      final day = CalendarDay.tryParse(row['day'] as String);
      final flow = _byName(FlowIntensity.values, row['flow'] as String?);
      if (day != null && flow != null) {
        result[day] = flow;
      }
    }
    return result;
  }

  /// Usual cycle length in days, as declared at first launch, if known.
  int? get usualCycleLength {
    final rows = _db.select('SELECT value FROM setting WHERE name = ?', [
      _usualCycleLength,
    ]);
    return rows.isEmpty ? null : int.tryParse(rows.single['value'] as String);
  }

  /// Stores the declared cycle length, or forgets it if [days] is null.
  /// Throws an [ArgumentError] outside the range accepted by the predictor.
  set usualCycleLength(int? days) => _transaction(() => _writeLength(days));

  /// The reminders chosen on this phone. Off until the user turns them on.
  /// Not part of an export.
  ReminderSettings get reminderSettings {
    final days = int.tryParse(_deviceSetting(_periodReminderDays) ?? '');
    return ReminderSettings(
      periodEnabled: _deviceSetting(_periodReminder) == _on,
      periodDaysBefore: ReminderSettings.periodDaysBeforeChoices.contains(days)
          ? days!
          : ReminderSettings.defaultPeriodDaysBefore,
      periodTime: ClockTime.tryFromMinutes(
        int.tryParse(_deviceSetting(_periodReminderTime) ?? ''),
      ),
      dailyEnabled: _deviceSetting(_dailyReminder) == _on,
      dailyTime: ClockTime.tryFromMinutes(
        int.tryParse(_deviceSetting(_dailyReminderTime) ?? ''),
      ),
    );
  }

  set reminderSettings(ReminderSettings settings) => _transaction(() {
    _writeDeviceSetting(_periodReminder, settings.periodEnabled ? _on : null);
    _writeDeviceSetting(_periodReminderDays, '${settings.periodDaysBefore}');
    _writeDeviceSetting(
      _periodReminderTime,
      '${settings.periodTime.minutesSinceMidnight}',
    );
    _writeDeviceSetting(_dailyReminder, settings.dailyEnabled ? _on : null);
    _writeDeviceSetting(
      _dailyReminderTime,
      '${settings.dailyTime.minutesSinceMidnight}',
    );
  });

  /// Whether the app asks for Face ID, fingerprint or the phone passcode when
  /// it opens. Off by default. Not part of an export.
  bool get appLockEnabled => _deviceSetting(_appLock) == _on;

  set appLockEnabled(bool enabled) =>
      _writeDeviceSetting(_appLock, enabled ? _on : null);

  /// Light, dark, or like the phone. Light by default, and whenever the
  /// stored value is unknown. Not part of an export.
  Appearance get appearance {
    final stored = _deviceSetting(_appearance);
    for (final value in Appearance.values) {
      if (value.name == stored) {
        return value;
      }
    }
    return Appearance.light;
  }

  set appearance(Appearance value) => _writeDeviceSetting(
    _appearance,
    value == Appearance.light ? null : value.name,
  );

  /// Whether the first-launch screen was passed on this phone, with or
  /// without an answer. Not part of an export.
  bool get onboardingDone => _deviceSetting(_onboardingDone) == _on;

  set onboardingDone(bool done) =>
      _writeDeviceSetting(_onboardingDone, done ? _on : null);

  /// Everything stored, for export.
  FycleData readAll() =>
      FycleData(usualCycleLength: usualCycleLength, days: readDays());

  /// Replaces everything stored with [data], in one step: if anything fails,
  /// the previous content is kept untouched. The settings of this phone
  /// (reminders, app lock) are not part of [data] and stay as they are.
  void replaceAll(FycleData data) {
    _transaction(() {
      _db.execute('DELETE FROM day_entry');
      _db.execute('DELETE FROM setting');
      _writeLength(data.usualCycleLength);
      data.days.forEach(_writeDay);
    });
  }

  /// Closes the database. It must not be used afterwards.
  void close() => _db.close();

  static const String _on = '1';

  String? _deviceSetting(String name) {
    final rows = _db.select('SELECT value FROM device_setting WHERE name = ?', [
      name,
    ]);
    return rows.isEmpty ? null : rows.single['value'] as String;
  }

  void _writeDeviceSetting(String name, String? value) {
    if (value == null) {
      _db.execute('DELETE FROM device_setting WHERE name = ?', [name]);
      return;
    }
    _db.execute(
      'INSERT OR REPLACE INTO device_setting (name, value) VALUES (?, ?)',
      [name, value],
    );
  }

  void _writeLength(int? days) {
    if (days == null) {
      _db.execute('DELETE FROM setting WHERE name = ?', [_usualCycleLength]);
      return;
    }
    if (days < PeriodPredictor.minCycleLength ||
        days > PeriodPredictor.maxCycleLength) {
      throw ArgumentError.value(
        days,
        'usualCycleLength',
        'Must be between ${PeriodPredictor.minCycleLength} and '
            '${PeriodPredictor.maxCycleLength} days',
      );
    }
    _db.execute('INSERT OR REPLACE INTO setting (name, value) VALUES (?, ?)', [
      _usualCycleLength,
      '$days',
    ]);
  }

  void _writeDay(DayEntry entry) {
    final day = '${entry.day}';
    // Symptoms of the day go with it (ON DELETE CASCADE).
    _db.execute('DELETE FROM day_entry WHERE day = ?', [day]);
    if (entry.isEmpty) {
      return;
    }
    _db.execute(
      'INSERT INTO day_entry (day, flow, pain, mood, note) '
      'VALUES (?, ?, ?, ?, ?)',
      [day, entry.flow?.name, entry.pain?.name, entry.mood?.name, entry.note],
    );
    for (final symptom in entry.symptoms) {
      _db.execute('INSERT INTO day_symptom (day, symptom) VALUES (?, ?)', [
        day,
        symptom.name,
      ]);
    }
  }

  List<DayEntry> _readDays(String where, List<Object?> parameters) {
    final symptoms = <String, Set<Symptom>>{};
    for (final row in _db.select(
      'SELECT day, symptom FROM day_symptom $where',
      parameters,
    )) {
      final symptom = _byName(Symptom.values, row['symptom'] as String?);
      if (symptom != null) {
        symptoms.putIfAbsent(row['day'] as String, () => {}).add(symptom);
      }
    }

    final entries = <DayEntry>[];
    for (final row in _db.select(
      'SELECT day, flow, pain, mood, note FROM day_entry $where ORDER BY day',
      parameters,
    )) {
      final text = row['day'] as String;
      final day = CalendarDay.tryParse(text);
      if (day == null) {
        continue;
      }
      entries.add(
        DayEntry(
          day: day,
          flow: _byName(FlowIntensity.values, row['flow'] as String?),
          pain: _byName(PainLevel.values, row['pain'] as String?),
          mood: _byName(Mood.values, row['mood'] as String?),
          symptoms: symptoms[text] ?? const {},
          note: row['note'] as String?,
        ),
      );
    }
    return entries;
  }

  void _transaction(void Function() body) {
    _db.execute('BEGIN IMMEDIATE');
    try {
      body();
      _db.execute('COMMIT');
    } catch (_) {
      _db.execute('ROLLBACK');
      rethrow;
    }
  }
}

/// The value of [values] called [name], or null if there is none: a name
/// written by a newer version of the app is ignored rather than fatal.
T? _byName<T extends Enum>(List<T> values, String? name) {
  for (final value in values) {
    if (value.name == name) {
      return value;
    }
  }
  return null;
}

String _hex(Uint8List bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
