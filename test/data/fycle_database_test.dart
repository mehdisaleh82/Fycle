import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/data/database_key_store.dart';
import 'package:fycle/data/fycle_data.dart';
import 'package:fycle/data/fycle_database.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/mood.dart';
import 'package:fycle/domain/pain_level.dart';
import 'package:fycle/domain/period_predictor.dart';
import 'package:fycle/domain/period_starts.dart';
import 'package:fycle/domain/symptom.dart';

import 'fakes.dart';

void main() {
  group('daily entries', () {
    late FycleDatabase db;
    setUp(() => db = FycleDatabase.inMemory());
    tearDown(() => db.close());

    test('starts empty', () {
      expect(db.readDays(), isEmpty);
      expect(db.flowByDay(), isEmpty);
      expect(db.usualCycleLength, isNull);
      expect(db.readDay(CalendarDay(2026, 3, 5)), isNull);
    });

    test('reads back a full entry', () {
      final entry = sampleData().days.first;
      db.saveDay(entry);
      expect(db.readDay(entry.day), entry);
    });

    test('saving a day again replaces it, symptoms included', () {
      final day = CalendarDay(2026, 3, 5);
      db.saveDay(
        DayEntry(
          day: day,
          flow: FlowIntensity.light,
          symptoms: {Symptom.cramps, Symptom.nausea},
        ),
      );
      final updated = DayEntry(
        day: day,
        pain: PainLevel.mild,
        symptoms: {Symptom.headache},
      );
      db.saveDay(updated);
      expect(db.readDay(day), updated);
      expect(db.readDays(), hasLength(1));
    });

    test('saving an empty entry removes the day', () {
      final day = CalendarDay(2026, 3, 5);
      db.saveDay(DayEntry(day: day, mood: Mood.sad));
      db.saveDay(DayEntry(day: day));
      expect(db.readDay(day), isNull);
    });

    test('deletes a day', () {
      final entry = sampleData().days.first;
      db.saveDay(entry);
      db.deleteDay(entry.day);
      expect(db.readDays(), isEmpty);
    });

    test('lists days in calendar order, whatever the order of entry', () {
      for (final entry in sampleData().days.reversed) {
        db.saveDay(entry);
      }
      expect(db.readDays(), sampleData().days);
    });

    test('limits a listing to a range of days, both ends included', () {
      sampleData().days.forEach(db.saveDay);
      final some = db.readDays(
        from: CalendarDay(2026, 3, 6),
        to: CalendarDay(2026, 3, 20),
      );
      expect(some.map((entry) => entry.day), [
        CalendarDay(2026, 3, 6),
        CalendarDay(2026, 3, 20),
      ]);
      expect(db.readDays(to: CalendarDay(2026, 3, 5)), hasLength(1));
    });

    test('keeps a note exactly as typed', () {
      final day = CalendarDay(2026, 3, 5);
      const note = "Line one\nLine two; it's \"quoted\" — ça va 🙂";
      db.saveDay(DayEntry(day: day, note: note));
      expect(db.readDay(day)!.note, note);
    });
  });

  group('usual cycle length', () {
    late FycleDatabase db;
    setUp(() => db = FycleDatabase.inMemory());
    tearDown(() => db.close());

    test('is stored, changed and forgotten', () {
      db.usualCycleLength = 28;
      expect(db.usualCycleLength, 28);
      db.usualCycleLength = 31;
      expect(db.usualCycleLength, 31);
      db.usualCycleLength = null;
      expect(db.usualCycleLength, isNull);
    });

    test('refuses a length the predictor would refuse', () {
      expect(() => db.usualCycleLength = 14, throwsArgumentError);
      expect(() => db.usualCycleLength = 91, throwsArgumentError);
      expect(db.usualCycleLength, isNull);
    });
  });

  group('feeding the domain', () {
    test('the flow log gives period starts and a prediction', () {
      final db = FycleDatabase.inMemory();
      addTearDown(db.close);
      // Three periods of four days, 28 days apart.
      var start = CalendarDay(2026, 1, 3);
      for (var period = 0; period < 3; period++) {
        for (var i = 0; i < 4; i++) {
          db.saveDay(
            DayEntry(day: start.addDays(i), flow: FlowIntensity.medium),
          );
        }
        start = start.addDays(28);
      }
      // A day without flow and a day of spotting must not count.
      db.saveDay(DayEntry(day: CalendarDay(2026, 1, 15), mood: Mood.calm));
      db.saveDay(
        DayEntry(day: CalendarDay(2026, 1, 16), flow: FlowIntensity.spotting),
      );
      db.usualCycleLength = 28;

      final flow = db.flowByDay();
      expect(flow, hasLength(13));
      expect(flow.containsKey(CalendarDay(2026, 1, 15)), isFalse);

      final starts = periodStartsFrom(flow);
      expect(starts, [
        CalendarDay(2026, 1, 3),
        CalendarDay(2026, 1, 31),
        CalendarDay(2026, 2, 28),
      ]);

      final prediction = const PeriodPredictor().predict(
        periodStarts: starts,
        usualCycleLength: db.usualCycleLength,
      );
      expect(prediction, isNotNull);
    });
  });

  group('replacing everything', () {
    test('swaps the whole content', () {
      final db = FycleDatabase.inMemory();
      addTearDown(db.close);
      db.saveDay(DayEntry(day: CalendarDay(2025, 1, 1), mood: Mood.sad));
      db.usualCycleLength = 40;

      db.replaceAll(sampleData());

      final all = db.readAll();
      expect(all.days, sampleData().days);
      expect(all.usualCycleLength, 29);
    });

    test('keeps the previous content if the new one is refused', () {
      final db = FycleDatabase.inMemory();
      addTearDown(db.close);
      final before = DayEntry(day: CalendarDay(2025, 1, 1), mood: Mood.sad);
      db.saveDay(before);
      db.usualCycleLength = 40;

      expect(
        () => db.replaceAll(
          FycleData(usualCycleLength: 500, days: sampleData().days),
        ),
        throwsArgumentError,
      );

      expect(db.readDays(), [before]);
      expect(db.usualCycleLength, 40);
    });
  });

  group('encryption on disk', () {
    late Directory dir;
    late String path;
    final key = Uint8List.fromList(List.generate(32, (i) => i + 1));
    final otherKey = Uint8List.fromList(List.generate(32, (i) => 200 - i));
    const marker = 'VISIBLE-MARKER-0123456789';

    setUp(() {
      dir = Directory.systemTemp.createTempSync('fycle_test_');
      path = '${dir.path}${Platform.pathSeparator}test.db';
    });
    tearDown(() => dir.deleteSync(recursive: true));

    test('data survives closing and reopening with the same key', () {
      FycleDatabase.open(path, key)
        ..replaceAll(sampleData())
        ..close();

      final reopened = FycleDatabase.open(path, key);
      addTearDown(reopened.close);
      expect(reopened.readAll().days, sampleData().days);
      expect(reopened.usualCycleLength, 29);
    });

    test('the file shows neither the content nor a database header', () {
      FycleDatabase.open(path, key)
        ..saveDay(DayEntry(day: CalendarDay(2026, 3, 5), note: marker))
        ..close();

      final raw = latin1.decode(File(path).readAsBytesSync());
      expect(raw, isNot(contains(marker)));
      expect(raw, isNot(contains('SQLite format')));
      expect(raw, isNot(contains('day_entry')));
      expect(raw, isNot(contains('2026-03-05')));
    });

    test('another key does not open the file', () {
      FycleDatabase.open(path, key)
        ..saveDay(DayEntry(day: CalendarDay(2026, 3, 5), note: marker))
        ..close();

      expect(
        () => FycleDatabase.open(path, otherKey),
        throwsA(isA<DatabaseUnreadableException>()),
      );
    });

    test('refuses a key of the wrong length', () {
      expect(
        () => FycleDatabase.open(path, Uint8List(16)),
        throwsArgumentError,
      );
      expect(File(path).existsSync(), isFalse);
    });
  });

  group('generated keys', () {
    test('are 32 bytes long and differ each time', () {
      final a = generateDatabaseKey();
      final b = generateDatabaseKey();
      expect(a, hasLength(databaseKeyLength));
      expect(a, isNot(b));
    });
  });
}
