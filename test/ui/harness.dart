import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/data/device_auth.dart';
import 'package:fycle/data/file_gateway.dart';
import 'package:fycle/data/local_store.dart';
import 'package:fycle/data/reminder_gateway.dart';
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

/// Stands in for the notifications of the phone.
final class FakeReminders implements ReminderGateway {
  /// What the user answers when asked to allow notifications.
  bool allow = true;

  /// How many times she was asked.
  int permissionRequests = 0;

  /// What is currently scheduled.
  List<ScheduledReminder> scheduled = const [];

  /// How many times the schedule was replaced.
  int replacements = 0;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return allow;
  }

  @override
  Future<void> replaceAll(
    List<ScheduledReminder> reminders, {
    required String channelName,
  }) async {
    replacements++;
    scheduled = List.of(reminders);
  }
}

/// Stands in for Face ID, the fingerprint reader and the phone passcode.
final class FakeDeviceAuth implements DeviceAuth {
  /// False for a phone with no passcode at all.
  bool available = true;

  /// What the next prompts answer.
  AuthOutcome outcome = AuthOutcome.success;

  /// The sentences shown in the prompts so far.
  final List<String> prompts = [];

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<AuthOutcome> authenticate(String reason) async {
    prompts.add(reason);
    return available ? outcome : AuthOutcome.unavailable;
  }
}

/// The app on a phone-sized screen, with a real encrypted database in a
/// temporary folder, a fake keychain, fake file dialogs, fake notifications,
/// a fake Face ID and a fixed date (at noon unless [now] is changed).
/// All data is made up.
final class Harness {
  Harness(this.tester, {CalendarDay? today}) {
    final day = today ?? CalendarDay(2026, 3, 20);
    now = DateTime(day.year, day.month, day.day, 12);
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
  late DateTime now;

  CalendarDay get today => CalendarDay.fromDateTime(now);
  final Directory dir = Directory.systemTemp.createTempSync('fycle_ui_');
  final InMemoryKeyStore keyStore = InMemoryKeyStore();
  final FakeFiles files = FakeFiles();
  final FakeReminders reminders = FakeReminders();
  final FakeDeviceAuth deviceAuth = FakeDeviceAuth();

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

  /// Starts the app. Without [themeMode], the appearance chosen in the
  /// settings applies, as on a phone.
  Future<void> pumpApp({
    String locale = 'en',
    ThemeMode? themeMode,
    TextDirection? textDirection,
  }) async {
    await tester.pumpWidget(
      FycleApp(
        // A new launch, not an update of the running app.
        key: UniqueKey(),
        locale: Locale(locale),
        themeMode: themeMode,
        textDirection: textDirection,
        environment: AppEnvironment(
          openStore: openStore,
          wipeStore: () => LocalStore.wipe(directory: dir, keyStore: keyStore),
          files: files,
          reminders: reminders,
          deviceAuth: deviceAuth,
          now: () => now,
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

/// From the first launch, goes through every screen and opens every dialog.
/// A layout that overflows makes the test fail.
Future<void> walkEveryScreen(WidgetTester tester, Harness harness) async {
  await tapVisible(tester, find.byIcon(Icons.calendar_today));
  await tapVisible(tester, find.byType(TextButton).last);
  await tapVisible(tester, find.byType(FilledButton));

  // Home, then the entry of the day.
  expect(find.byType(FloatingActionButton), findsOneWidget);
  await tapVisible(tester, find.byType(FloatingActionButton));
  await tapVisible(tester, find.byKey(const ValueKey('flow-medium')));
  await tapVisible(tester, find.byType(FilledButton));

  // Settings and its dialogs.
  await tapVisible(tester, find.byIcon(Icons.settings_outlined));
  for (final icon in [
    Icons.loop,
    Icons.brightness_6_outlined,
    Icons.lock_outline,
    Icons.table_chart_outlined,
    Icons.delete_forever,
  ]) {
    await tapVisible(tester, find.byIcon(icon));
    expect(find.byType(AlertDialog), findsOneWidget);
    await tapVisible(
      tester,
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextButton),
      ),
    );
  }

  // Reminders: both switches, then their dialogs.
  await tapVisible(tester, find.byIcon(Icons.notifications_outlined));
  await tapVisible(tester, find.byIcon(Icons.edit_notifications_outlined));
  await tapVisible(tester, find.byKey(const ValueKey('period-days-before')));
  expect(find.byType(AlertDialog), findsOneWidget);
  await tapVisible(
    tester,
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextButton),
    ),
  );
  for (final key in ['period-time', 'daily-time']) {
    await tapVisible(tester, find.byKey(ValueKey(key)));
    expect(find.byType(TimePickerDialog), findsOneWidget);
    await tapVisible(
      tester,
      find
          .descendant(
            of: find.byType(TimePickerDialog),
            matching: find.byType(TextButton),
          )
          .first,
    );
  }

  // A reminder the phone refuses, then the lock on a phone without a
  // passcode: two notices.
  await tapVisible(tester, find.byIcon(Icons.notifications_outlined));
  harness.reminders.allow = false;
  await tapVisible(tester, find.byIcon(Icons.notifications_outlined));
  expect(find.byType(AlertDialog), findsOneWidget);
  await tapVisible(
    tester,
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextButton),
    ),
  );
  harness.deviceAuth.available = false;
  await tapVisible(tester, find.byIcon(Icons.fingerprint));
  expect(find.byType(AlertDialog), findsOneWidget);
  await tapVisible(
    tester,
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextButton),
    ),
  );
}
