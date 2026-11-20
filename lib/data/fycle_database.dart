import 'dart:typed_data';

import 'package:sqlite3/sqlite3.dart';

import '../domain/calendar_day.dart';
import '../domain/day_entry.dart';
import '../domain/flow_intensity.dart';
import '../domain/libido_level.dart';
import '../domain/mood.dart';
import '../domain/pain_level.dart';
import '../domain/period_predictor.dart';
import '../domain/reminders.dart';
import '../domain/sleep_quality.dart';
import '../domain/start_profile.dart';
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
  static const int schemaVersion = 3;

  static const String _usualCycleLength = 'usual_cycle_length';
  static const String _birthYear = 'birth_year';
  static const String _usualPeriodLength = 'usual_period_length';
  static const String _regularity = 'cycle_regularity';
  static const String _firstName = 'first_name';
  static const String _goals = 'goals';
  static const String _recentChanges = 'recent_changes';
  static const String _wishes = 'wishes';
  static const String _contraception = 'contraception';
  static const String _tracked = 'tracked';
  static const String _usualFlow = 'usual_flow';
  static const String _usualPain = 'usual_pain';
  static const String _startSigns = 'start_signs';

  static const String _periodReminder = 'reminder_period_enabled';
  static const String _periodReminderDays = 'reminder_period_days_before';
  static const String _periodReminderTime = 'reminder_period_minutes';
  static const String _dailyReminder = 'reminder_daily_enabled';
  static const String _dailyReminderTime = 'reminder_daily_minutes';
  static const String _appLock = 'app_lock_enabled';
  static const String _appearance = 'appearance';
  static const String _onboardingDone = 'onboarding_done';
  static const String _summaryDismissed = 'cycle_summary_dismissed';
  static const String _fertilityEstimate = 'fertility_estimate_enabled';
  static const String _suggestionDismissed = 'suggestion_dismissed_';
  static const String _widget = 'widget_enabled';

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
    if (version < 3) {
      _transaction(() {
        _db.execute('ALTER TABLE day_entry ADD COLUMN sleep TEXT');
        _db.execute('ALTER TABLE day_entry ADD COLUMN libido TEXT');
        _db.userVersion = 3;
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

  /// Year of birth, if the user gave it. Part of an export.
  int? get birthYear {
    final rows = _db.select('SELECT value FROM setting WHERE name = ?', [
      _birthYear,
    ]);
    return rows.isEmpty ? null : int.tryParse(rows.single['value'] as String);
  }

  /// Usual period length in days, if the user gave it. Part of an export.
  int? get usualPeriodLength {
    final days = int.tryParse(_setting(_usualPeriodLength) ?? '');
    return days == null || days < minPeriodLength || days > maxPeriodLength
        ? null
        : days;
  }

  set usualPeriodLength(int? days) =>
      _transaction(() => _writePeriodLength(days));

  /// Whether she calls her cycles regular, if she said. Part of an export.
  CycleRegularity? get regularity =>
      _byName(CycleRegularity.values, _setting(_regularity));

  set regularity(CycleRegularity? value) =>
      _transaction(() => _writeSetting(_regularity, value?.name));

  /// The first name she gave, to be greeted by. Stays on this phone: not
  /// part of an export.
  String? get firstName => _deviceSetting(_firstName);

  set firstName(String? name) {
    final trimmed = name?.trim() ?? '';
    _writeDeviceSetting(_firstName, trimmed.isEmpty ? null : trimmed);
  }

  /// Why she uses the app. Not part of an export.
  Set<Goal> get goals => _names(Goal.values, _deviceSetting(_goals));

  set goals(Set<Goal> goals) => _writeDeviceSetting(_goals, _joined(goals));

  /// The changes she noticed in her periods when the app was set up. Not
  /// part of an export.
  Set<RecentChange> get recentChanges =>
      _names(RecentChange.values, _deviceSetting(_recentChanges));

  set recentChanges(Set<RecentChange> changes) =>
      _writeDeviceSetting(_recentChanges, _joined(changes));

  /// What she wants to know, in more detail. Not part of an export.
  Set<Wish> get wishes => _names(Wish.values, _deviceSetting(_wishes));

  set wishes(Set<Wish> wishes) => _writeDeviceSetting(_wishes, _joined(wishes));

  /// The contraception she said she uses. Not part of an export.
  Contraception? get contraception =>
      _byName(Contraception.values, _deviceSetting(_contraception));

  set contraception(Contraception? value) =>
      _writeDeviceSetting(_contraception, value?.name);

  /// What she wants to follow day by day. Not part of an export.
  Set<Tracked> get tracked => _names(Tracked.values, _deviceSetting(_tracked));

  set tracked(Set<Tracked> tracked) =>
      _writeDeviceSetting(_tracked, _joined(tracked));

  /// How heavy and how painful her periods usually are, as she said when
  /// the app was set up. Not part of an export.
  FlowIntensity? get usualFlow =>
      _byName(FlowIntensity.values, _deviceSetting(_usualFlow));

  set usualFlow(FlowIntensity? flow) =>
      _writeDeviceSetting(_usualFlow, flow?.name);

  PainLevel? get usualPain =>
      _byName(PainLevel.values, _deviceSetting(_usualPain));

  set usualPain(PainLevel? pain) => _writeDeviceSetting(_usualPain, pain?.name);

  /// The signs she said she had when the app was set up. Not part of an
  /// export.
  Set<Symptom> get startSigns =>
      _names(Symptom.values, _deviceSetting(_startSigns));

  set startSigns(Set<Symptom> signs) =>
      _writeDeviceSetting(_startSigns, _joined(signs));

  /// Stores the year of birth, or forgets it if [year] is null.
  set birthYear(int? year) => _transaction(() => _writeBirthYear(year));

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

  /// First day of the last cycle whose end-of-cycle summary was closed on
  /// this phone, so that it is not shown again. Not part of an export.
  CalendarDay? get dismissedSummaryStart =>
      CalendarDay.tryParse(_deviceSetting(_summaryDismissed) ?? '');

  set dismissedSummaryStart(CalendarDay? start) =>
      _writeDeviceSetting(_summaryDismissed, start?.toString());

  /// Whether the estimate of ovulation and of the fertile window is shown.
  /// On unless the user turned it off. Not part of an export.
  bool get fertilityEstimateEnabled =>
      _deviceSetting(_fertilityEstimate) != _off;

  set fertilityEstimateEnabled(bool enabled) =>
      _writeDeviceSetting(_fertilityEstimate, enabled ? null : _off);

  /// Whether the suggestion called [name] was answered on this phone, so
  /// that it is not made again. Not part of an export.
  bool suggestionDismissed(String name) =>
      _deviceSetting('$_suggestionDismissed$name') == _on;

  void dismissSuggestion(String name) =>
      _writeDeviceSetting('$_suggestionDismissed$name', _on);

  /// Whether the home-screen widget is given something to show. On unless
  /// the user turned it off. Not part of an export.
  bool get widgetEnabled => _deviceSetting(_widget) != _off;

  set widgetEnabled(bool enabled) =>
      _writeDeviceSetting(_widget, enabled ? null : _off);

  /// Everything stored, for export.
  FycleData readAll() => FycleData(
    usualCycleLength: usualCycleLength,
    birthYear: birthYear,
    usualPeriodLength: usualPeriodLength,
    regularity: regularity,
    days: readDays(),
  );

  /// Replaces everything stored with [data], in one step: if anything fails,
  /// the previous content is kept untouched. The settings of this phone
  /// (reminders, app lock) are not part of [data] and stay as they are.
  void replaceAll(FycleData data) {
    _transaction(() {
      _db.execute('DELETE FROM day_entry');
      _db.execute('DELETE FROM setting');
      _writeLength(data.usualCycleLength);
      _writeBirthYear(data.birthYear);
      _writePeriodLength(data.usualPeriodLength);
      _writeSetting(_regularity, data.regularity?.name);
      data.days.forEach(_writeDay);
    });
  }

  /// Closes the database. It must not be used afterwards.
  void close() => _db.close();

  static const String _on = '1';
  static const String _off = '0';

  String? _setting(String name) {
    final rows = _db.select('SELECT value FROM setting WHERE name = ?', [name]);
    return rows.isEmpty ? null : rows.single['value'] as String;
  }

  void _writeSetting(String name, String? value) {
    if (value == null) {
      _db.execute('DELETE FROM setting WHERE name = ?', [name]);
      return;
    }
    _db.execute('INSERT OR REPLACE INTO setting (name, value) VALUES (?, ?)', [
      name,
      value,
    ]);
  }

  void _writePeriodLength(int? days) {
    if (days != null && (days < minPeriodLength || days > maxPeriodLength)) {
      throw ArgumentError.value(
        days,
        'usualPeriodLength',
        'Must be between $minPeriodLength and $maxPeriodLength days',
      );
    }
    _writeSetting(_usualPeriodLength, days == null ? null : '$days');
  }

  /// The values of [values] named in [stored], names separated by commas.
  /// A name written by a newer version of the app is ignored.
  static Set<T> _names<T extends Enum>(List<T> values, String? stored) => {
    for (final name in (stored ?? '').split(',')) ?_byName(values, name),
  };

  static String? _joined(Set<Enum> values) => values.isEmpty
      ? null
      : ([for (final value in values) value.name]..sort()).join(',');

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

  void _writeBirthYear(int? year) {
    if (year == null) {
      _db.execute('DELETE FROM setting WHERE name = ?', [_birthYear]);
      return;
    }
    if (year < 1900 || year > 2200) {
      throw ArgumentError.value(year, 'birthYear', 'Not a year of birth');
    }
    _db.execute('INSERT OR REPLACE INTO setting (name, value) VALUES (?, ?)', [
      _birthYear,
      '$year',
    ]);
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
      'INSERT INTO day_entry (day, flow, pain, mood, sleep, libido, note) '
      'VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        day,
        entry.flow?.name,
        entry.pain?.name,
        entry.mood?.name,
        entry.sleep?.name,
        entry.libido?.name,
        entry.note,
      ],
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
      'SELECT day, flow, pain, mood, sleep, libido, note FROM day_entry '
      '$where ORDER BY day',
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
          sleep: _byName(SleepQuality.values, row['sleep'] as String?),
          libido: _byName(LibidoLevel.values, row['libido'] as String?),
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
