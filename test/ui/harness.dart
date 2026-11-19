import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/data/file_gateway.dart';
import 'package:fycle/data/local_store.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/ui/app.dart';
import 'package:fycle/ui/app_environment.dart';
import 'package:material_ui/material_ui.dart';

import '../data/fakes.dart';

/// Stands in for the system file dialogs.
final class FakeFiles implements FileGateway {
  /// Files "saved" by the app, by name.
  final Map<String, Uint8List> saved = {};

  /// What the next call to [pick] returns; null means the user cancelled.
  PickedFile? nextPick;

  /// When true, [save] behaves as if the user cancelled.
  bool cancelSave = false;

  @override
  Future<bool> save({
    required String fileName,
    required Uint8List bytes,
  }) async {
    if (cancelSave) {
      return false;
    }
    saved[fileName] = bytes;
    return true;
  }

  @override
  Future<PickedFile?> pick() async => nextPick;
}

/// The app on a phone-sized screen, with a real encrypted database in a
/// temporary folder, a fake keychain, fake file dialogs and a fixed date.
/// All data is made up.
final class Harness {
  Harness(this.tester, {CalendarDay? today})
    : today = today ?? CalendarDay(2026, 3, 20) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(() async {
      // Unmount the app so that it closes the database before the folder
      // is removed.
      await tester.pumpWidget(const SizedBox());
      try {
        dir.deleteSync(recursive: true);
      } on FileSystemException {
        // Still open after a failed test: left to the system.
      }
    });
  }

  final WidgetTester tester;
  CalendarDay today;
  final Directory dir = Directory.systemTemp.createTempSync('fycle_ui_');
  final InMemoryKeyStore keyStore = InMemoryKeyStore();
  final FakeFiles files = FakeFiles();

  Future<LocalStore> openStore() =>
      LocalStore.open(directory: dir, keyStore: keyStore, codec: fastCodec);

  /// Writes made-up data before the app starts.
  Future<void> seed({
    Iterable<DayEntry> days = const [],
    int? usualCycleLength,
  }) async {
    final store = await openStore();
    days.forEach(store.database.saveDay);
    store.database.usualCycleLength = usualCycleLength;
    store.close();
  }

  /// Reads the database behind the running app's back.
  Future<T> read<T>(T Function(LocalStore store) body) async {
    final store = await openStore();
    try {
      return body(store);
    } finally {
      store.close();
    }
  }

  Future<void> pumpApp({
    String locale = 'en',
    ThemeMode themeMode = ThemeMode.light,
  }) async {
    await tester.pumpWidget(
      FycleApp(
        locale: Locale(locale),
        themeMode: themeMode,
        environment: AppEnvironment(
          openStore: openStore,
          wipeStore: () => LocalStore.wipe(directory: dir, keyStore: keyStore),
          files: files,
          today: () => today,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }
}

/// A made-up period of [length] days starting on [start].
List<DayEntry> periodFrom(CalendarDay start, {int length = 4}) => [
  for (var i = 0; i < length; i++)
    DayEntry(day: start.addDays(i), flow: FlowIntensity.medium),
];

/// The text fields of the dialog on screen, in order.
Finder dialogField([int index = 0]) => find
    .descendant(of: find.byType(AlertDialog), matching: find.byType(TextField))
    .at(index);

/// Scrolls to [finder] if needed, then taps it.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}
