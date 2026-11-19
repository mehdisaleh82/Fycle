import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/data/file_gateway.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:material_ui/material_ui.dart';

import '../data/fakes.dart';
import 'harness.dart';

const _password = 'made-up password';

Future<Harness> openSettings(
  WidgetTester tester, {
  String locale = 'en',
}) async {
  final harness = Harness(tester);
  final data = sampleData();
  await harness.seed(days: data.days, usualCycleLength: data.usualCycleLength);
  await harness.pumpApp(locale: locale);
  await tester.tap(find.byIcon(Icons.settings_outlined));
  await tester.pumpAndSettle();
  return harness;
}

void main() {
  group('encrypted backup', () {
    testWidgets('warns that a forgotten password cannot be recovered', (
      tester,
    ) async {
      await openSettings(tester);
      await tapVisible(tester, find.text('Save an encrypted backup'));
      await tester.pumpAndSettle();

      expect(find.textContaining('nobody can open the file'), findsOneWidget);
      expect(find.textContaining('no way to recover'), findsOneWidget);
    });

    testWidgets('refuses a short or mistyped password', (tester) async {
      final harness = await openSettings(tester);
      await tapVisible(tester, find.text('Save an encrypted backup'));
      await tester.pumpAndSettle();

      await tester.enterText(dialogField(), 'short');
      await tester.tap(find.text('Create the file'));
      await tester.pumpAndSettle();
      expect(find.text('At least 8 characters.'), findsOneWidget);

      await tester.enterText(dialogField(), _password);
      await tester.enterText(dialogField(1), 'another password');
      await tester.tap(find.text('Create the file'));
      await tester.pumpAndSettle();
      expect(find.text('The two passwords are different.'), findsOneWidget);
      expect(harness.files.saved, isEmpty);
    });

    testWidgets('saves a file that the password opens', (tester) async {
      final harness = await openSettings(tester);
      await tapVisible(tester, find.text('Save an encrypted backup'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogField(), _password);
      await tester.enterText(dialogField(1), _password);
      await tester.tap(find.text('Create the file'));
      await tester.pumpAndSettle();

      expect(find.text('Backup saved.'), findsOneWidget);
      final bytes = harness.files.saved['fycle-backup-2026-03-20.fycle'];
      expect(bytes, isNotNull);
      final data = await tester.runAsync(
        () => fastCodec.decode(bytes!, _password),
      );
      expect(data!.usualCycleLength, 29);
      expect(data.days, sampleData().days);
    });

    testWidgets('says nothing was saved when the user cancels', (tester) async {
      final harness = await openSettings(tester);
      harness.files.cancelSave = true;
      await tapVisible(tester, find.text('Save an encrypted backup'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogField(), _password);
      await tester.enterText(dialogField(1), _password);
      await tester.tap(find.text('Create the file'));
      await tester.pumpAndSettle();

      expect(find.text('Backup saved.'), findsNothing);
    });
  });

  group('restoring a backup', () {
    Future<Uint8List> backupOf(WidgetTester tester) async {
      final bytes = await tester.runAsync(
        () => fastCodec.encode(sampleData(), _password),
      );
      return bytes!;
    }

    testWidgets('replaces everything, after a confirmation', (tester) async {
      final harness = Harness(tester);
      await harness.seed(
        days: periodFrom(CalendarDay(2026, 3, 1)),
        usualCycleLength: 40,
      );
      harness.files.nextPick = PickedFile(
        name: 'backup.fycle',
        bytes: await backupOf(tester),
      );
      await harness.pumpApp();
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      await tapVisible(tester, find.text('Restore a backup'));
      await tester.pumpAndSettle();
      expect(find.text('Replace everything?'), findsOneWidget);
      await tester.tap(find.text('Replace'));
      await tester.pumpAndSettle();

      // A wrong password changes nothing and can be corrected.
      await tester.enterText(dialogField(), 'not the password');
      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();
      expect(
        find.text('Wrong password, or damaged file. Nothing was changed.'),
        findsOneWidget,
      );
      expect(find.text('40 days'), findsOneWidget);

      await tester.enterText(dialogField(), _password);
      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();
      expect(find.text('Backup restored.'), findsOneWidget);
      expect(find.text('29 days'), findsOneWidget);
      final days = await harness.read((store) => store.database.readDays());
      expect(days, sampleData().days);
    });

    testWidgets('refuses a file that is not a backup', (tester) async {
      final harness = await openSettings(tester);
      harness.files.nextPick = PickedFile(
        name: 'holiday.jpg',
        bytes: Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]),
      );
      await tapVisible(tester, find.text('Restore a backup'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Replace'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogField(), _password);
      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();

      expect(
        find.text('This file is not a Fycle backup. Nothing was changed.'),
        findsOneWidget,
      );
      final days = await harness.read((store) => store.database.readDays());
      expect(days, sampleData().days);
    });
  });

  testWidgets('the CSV export is worded in the language of the app', (
    tester,
  ) async {
    final harness = await openSettings(tester, locale: 'fr');
    await tapVisible(tester, find.text('Exporter pour un tableur (CSV)'));
    await tester.pumpAndSettle();
    expect(find.textContaining("n'est pas chiffré"), findsOneWidget);
    await tester.tap(find.text('Exporter'));
    await tester.pumpAndSettle();

    final bytes = harness.files.saved['fycle-2026-03-20.csv']!;
    // Byte order mark, so that spreadsheets read the accents.
    expect(bytes.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
    final lines = utf8.decode(bytes).split('\r\n');
    expect(lines[0], 'Date,Règles,Douleur,Humeur,Symptômes,Note');
    expect(
      lines[1],
      '2026-03-05,Moyennes,Modérée,Irritabilité,Crampes; Mal de dos,'
      '"Stayed home, ""slow"" day"',
    );
  });

  group('deleting everything', () {
    testWidgets('asks first', (tester) async {
      final harness = await openSettings(tester);
      await tapVisible(tester, find.text('Delete everything'));
      await tester.pumpAndSettle();
      expect(find.text('Delete everything?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      final days = await harness.read((store) => store.database.readDays());
      expect(days, sampleData().days);
    });

    testWidgets('erases all data and returns to the first launch', (
      tester,
    ) async {
      final harness = await openSettings(tester);
      final oldKey = harness.keyStore.key;
      await tapVisible(tester, find.text('Delete everything'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete everything'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Fycle'), findsOneWidget);
      expect(harness.keyStore.key, isNot(oldKey));
      final stored = await harness.read(
        (store) => (store.database.readDays(), store.database.usualCycleLength),
      );
      expect(stored.$1, isEmpty);
      expect(stored.$2, isNull);
    });
  });

  testWidgets('the usual cycle length can be changed or forgotten', (
    tester,
  ) async {
    final harness = await openSettings(tester);
    expect(find.text('29 days'), findsOneWidget);

    await tapVisible(tester, find.text('Usual cycle length'));
    await tester.pumpAndSettle();
    await tester.enterText(dialogField(), '35');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('35 days'), findsOneWidget);

    await tapVisible(tester, find.text('Usual cycle length'));
    await tester.pumpAndSettle();
    await tester.enterText(dialogField(), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Not set'), findsOneWidget);
    final length = await harness.read(
      (store) => store.database.usualCycleLength,
    );
    expect(length, isNull);
  });
}
