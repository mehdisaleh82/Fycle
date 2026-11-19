import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/data/appearance.dart';
import 'package:fycle/data/fycle_database.dart';
import 'package:fycle/data/local_store.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/reminders.dart';
import 'package:sqlite3/sqlite3.dart';

import 'fakes.dart';

void main() {
  group('settings of this phone', () {
    late FycleDatabase db;
    setUp(() => db = FycleDatabase.inMemory());
    tearDown(() => db.close());

    test('reminders and app lock are off by default', () {
      expect(db.reminderSettings, ReminderSettings());
      expect(db.appLockEnabled, isFalse);
    });

    test('reminder choices are stored', () {
      final chosen = ReminderSettings(
        periodEnabled: true,
        periodDaysBefore: 3,
        periodTime: ClockTime(7, 45),
        dailyEnabled: true,
        dailyTime: ClockTime(21, 15),
      );
      db.reminderSettings = chosen;
      expect(db.reminderSettings, chosen);

      db.reminderSettings = chosen.copyWith(periodEnabled: false);
      expect(db.reminderSettings.periodEnabled, isFalse);
      expect(db.reminderSettings.periodTime, ClockTime(7, 45));
    });

    test('the app lock is stored', () {
      db.appLockEnabled = true;
      expect(db.appLockEnabled, isTrue);
      db.appLockEnabled = false;
      expect(db.appLockEnabled, isFalse);
    });

    test('the appearance is light by default, and stored', () {
      expect(db.appearance, Appearance.light);
      for (final chosen in [
        Appearance.dark,
        Appearance.system,
        Appearance.light,
      ]) {
        db.appearance = chosen;
        expect(db.appearance, chosen);
      }
    });

    test('an import replaces the data, not the settings of the phone', () {
      final chosen = ReminderSettings(dailyEnabled: true);
      db
        ..reminderSettings = chosen
        ..appLockEnabled = true
        ..appearance = Appearance.dark
        ..replaceAll(sampleData());

      expect(db.appearance, Appearance.dark);
      expect(db.readDays(), sampleData().days);
      expect(db.reminderSettings, chosen);
      expect(db.appLockEnabled, isTrue);
    });
  });

  group('on disk', () {
    late Directory dir;
    final key = Uint8List.fromList(List.generate(32, (i) => i + 1));

    setUp(() => dir = Directory.systemTemp.createTempSync('fycle_test_'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('a database of the first layout is upgraded, data intact', () {
      final path = '${dir.path}${Platform.pathSeparator}test.db';
      final hex = key
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join();
      // The layout written by the first versions of the app.
      sqlite3.open(path)
        ..execute("PRAGMA cipher = 'chacha20'")
        ..execute('PRAGMA key = "raw:$hex"')
        ..execute(
          'CREATE TABLE day_entry (day TEXT NOT NULL PRIMARY KEY, flow TEXT, '
          'pain TEXT, mood TEXT, note TEXT) WITHOUT ROWID',
        )
        ..execute(
          'CREATE TABLE day_symptom ('
          'day TEXT NOT NULL REFERENCES day_entry (day) ON DELETE CASCADE, '
          'symptom TEXT NOT NULL, PRIMARY KEY (day, symptom)) WITHOUT ROWID',
        )
        ..execute(
          'CREATE TABLE setting (name TEXT NOT NULL PRIMARY KEY, '
          'value TEXT NOT NULL) WITHOUT ROWID',
        )
        ..execute(
          "INSERT INTO day_entry (day, flow) VALUES ('2026-03-05', 'medium')",
        )
        ..execute("INSERT INTO setting VALUES ('usual_cycle_length', '31')")
        ..userVersion = 1
        ..close();

      final db = FycleDatabase.open(path, key);
      addTearDown(db.close);
      expect(db.readDays(), [
        DayEntry(day: CalendarDay(2026, 3, 5), flow: FlowIntensity.medium),
      ]);
      expect(db.usualCycleLength, 31);
      expect(db.appLockEnabled, isFalse);
      db.appLockEnabled = true;
      expect(db.appLockEnabled, isTrue);
    });

    test('an export does not carry the settings of the phone', () async {
      final keyStore = InMemoryKeyStore();
      final store = await LocalStore.open(
        directory: dir,
        keyStore: keyStore,
        codec: fastCodec,
      );
      store.database
        ..replaceAll(sampleData())
        ..appLockEnabled = true
        ..appearance = Appearance.dark
        ..reminderSettings = ReminderSettings(periodEnabled: true);
      final backup = await store.exportEncrypted('made-up password');
      store.close();

      // The same file, restored on another phone.
      final otherDir = Directory.systemTemp.createTempSync('fycle_test_');
      addTearDown(() => otherDir.deleteSync(recursive: true));
      final other = await LocalStore.open(
        directory: otherDir,
        keyStore: InMemoryKeyStore(),
        codec: fastCodec,
      );
      addTearDown(other.close);
      await other.importEncrypted(backup, 'made-up password');

      expect(other.database.readDays(), sampleData().days);
      expect(other.database.appLockEnabled, isFalse);
      expect(other.database.appearance, Appearance.light);
      expect(other.database.reminderSettings, ReminderSettings());
    });
  });
}
