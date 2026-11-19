import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/data/backup_codec.dart';
import 'package:fycle/data/fycle_data.dart';
import 'package:fycle/data/fycle_database.dart';
import 'package:fycle/data/local_store.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/mood.dart';

import 'fakes.dart';

const _password = 'correct horse battery';

void main() {
  late Directory dir;
  late InMemoryKeyStore keyStore;

  Future<LocalStore> open() =>
      LocalStore.open(directory: dir, keyStore: keyStore, codec: fastCodec);

  File dbFile() => File('${dir.path}${Platform.pathSeparator}fycle.db');

  setUp(() {
    dir = Directory.systemTemp.createTempSync('fycle_test_');
    keyStore = InMemoryKeyStore();
  });
  tearDown(() => dir.deleteSync(recursive: true));

  group('opening', () {
    test('first launch creates a key and an empty database', () async {
      final store = await open();
      addTearDown(store.close);
      expect(keyStore.key, hasLength(32));
      expect(dbFile().existsSync(), isTrue);
      expect(store.database.readDays(), isEmpty);
    });

    test('creates the folder if it does not exist yet', () async {
      final nested = Directory('${dir.path}${Platform.pathSeparator}new');
      final store = await LocalStore.open(
        directory: nested,
        keyStore: keyStore,
      );
      addTearDown(store.close);
      expect(nested.existsSync(), isTrue);
    });

    test('data is found again at the next launch', () async {
      final first = await open();
      first.database.replaceAll(sampleData());
      first.close();

      final second = await open();
      addTearDown(second.close);
      expect(second.database.readDays(), sampleData().days);
    });

    test('a key left by an earlier installation is replaced', () async {
      final leftover = Uint8List.fromList(List.filled(32, 7));
      keyStore.key = leftover;
      final store = await open();
      addTearDown(store.close);
      expect(keyStore.key, isNot(leftover));
    });

    test('a database without its key is reported, not erased', () async {
      (await open())
        ..database.replaceAll(sampleData())
        ..close();
      keyStore.key = null;

      await expectLater(open(), throwsA(isA<LocalStoreUnreadableException>()));
      expect(dbFile().existsSync(), isTrue);
    });

    test('a database with the wrong key is reported', () async {
      (await open())
        ..database.replaceAll(sampleData())
        ..close();
      keyStore.key = Uint8List.fromList(List.filled(32, 9));

      await expectLater(open(), throwsA(isA<DatabaseUnreadableException>()));
    });
  });

  group('export and import', () {
    test('an export restores everything on a fresh installation', () async {
      final old = await open();
      old.database.replaceAll(sampleData());
      final file = await old.exportEncrypted(_password);
      await old.deleteEverything();

      final fresh = await open();
      addTearDown(fresh.close);
      await fresh.importEncrypted(file, _password);

      expect(fresh.database.readDays(), sampleData().days);
      expect(fresh.database.usualCycleLength, 29);
    });

    test('works the same with the key derivation on another thread', () async {
      final store = await LocalStore.open(
        directory: dir,
        keyStore: keyStore,
        codec: fastCodec,
        codecInBackground: true,
      );
      store.database.replaceAll(sampleData());
      final file = await store.exportEncrypted(_password);

      store.database.replaceAll(FycleData());
      await expectLater(
        store.importEncrypted(file, 'not the password'),
        throwsA(isA<BackupException>()),
      );
      expect(store.database.readDays(), isEmpty);

      await store.importEncrypted(file, _password);
      expect(store.database.readDays(), sampleData().days);
      expect(store.database.usualCycleLength, 29);
      store.close();
    });

    test('an import replaces what was there', () async {
      final store = await open();
      addTearDown(store.close);
      store.database.replaceAll(sampleData());
      final file = await store.exportEncrypted(_password);

      store.database.saveDay(
        DayEntry(day: CalendarDay(2026, 6, 1), mood: Mood.calm),
      );
      await store.importEncrypted(file, _password);

      expect(store.database.readDays(), sampleData().days);
    });

    test('a wrong password changes nothing', () async {
      final store = await open();
      addTearDown(store.close);
      store.database.replaceAll(sampleData());
      final file = await store.exportEncrypted(_password);
      final kept = DayEntry(day: CalendarDay(2026, 6, 1), mood: Mood.calm);
      store.database.replaceAll(sampleData());
      store.database.saveDay(kept);

      await expectLater(
        store.importEncrypted(file, 'not the password'),
        throwsA(isA<BackupException>()),
      );
      expect(store.database.readDay(kept.day), kept);
      expect(store.database.readDays(), hasLength(4));
    });

    test('the CSV export lists the logged days', () async {
      final store = await open();
      addTearDown(store.close);
      store.database.replaceAll(sampleData());
      final csv = store.exportCsv();
      expect(csv.trim().split('\r\n'), hasLength(4));
      expect(csv, contains('2026-03-06,heavy'));
    });
  });

  group('deleting everything', () {
    test('removes the database file and the key', () async {
      final store = await open();
      store.database.replaceAll(sampleData());

      await store.deleteEverything();

      expect(keyStore.key, isNull);
      expect(dir.listSync(), isEmpty);
    });

    test('the next launch starts from nothing, with a new key', () async {
      final store = await open();
      store.database.replaceAll(sampleData());
      final oldKey = keyStore.key;
      await store.deleteEverything();

      final fresh = await open();
      addTearDown(fresh.close);
      expect(fresh.database.readDays(), isEmpty);
      expect(fresh.database.usualCycleLength, isNull);
      expect(keyStore.key, isNot(oldKey));
    });

    test('clears an unreadable store without opening it', () async {
      (await open())
        ..database.replaceAll(sampleData())
        ..close();
      keyStore.key = null;

      await LocalStore.wipe(directory: dir, keyStore: keyStore);

      expect(dir.listSync(), isEmpty);
      final fresh = await open();
      addTearDown(fresh.close);
      expect(fresh.database.readDays(), isEmpty);
    });
  });
}
