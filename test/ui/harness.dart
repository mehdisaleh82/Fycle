import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/data/auto_backup.dart';
import 'package:fycle/data/device_auth.dart';
import 'package:fycle/data/file_gateway.dart';
import 'package:fycle/data/health_gateway.dart';
import 'package:fycle/data/local_store.dart';
import 'package:fycle/data/reminder_gateway.dart';
import 'package:fycle/data/widget_gateway.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/device_readings.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/life_stage.dart';
import 'package:fycle/domain/start_profile.dart';
import 'package:fycle/domain/symptom.dart';
import 'package:fycle/domain/widget_snapshot.dart';
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

/// Stands in for the folder the automatic backup is written to.
final class FakeAutoBackup implements AutoBackupGateway {
  /// Every backup written so far, oldest first.
  final List<Uint8List> written = [];

  @override
  Future<void> write(Uint8List bytes) async => written.add(bytes);
}

/// Stands in for the Keychain entry of the backup password.
final class FakeBackupPasswords implements BackupPasswordStore {
  String? password;

  @override
  Future<String?> read() async => password;

  @override
  Future<void> write(String value) async => password = value;

  @override
  Future<void> delete() async => password = null;
}

/// Stands in for the health data of the phone.
final class FakeHealth implements HealthGateway {
  /// What the phone knows; null when she does not allow reading it.
  Map<CalendarDay, FlowIntensity>? days;

  @override
  Future<Map<CalendarDay, FlowIntensity>?> readPeriodDays({
    required DateTime now,
  }) async => days;

  /// What a watch measured; null when she does not allow reading it.
  List<DeviceDay>? deviceDays;

  @override
  Future<List<DeviceDay>?> readDeviceDays({required DateTime now}) async =>
      deviceDays;
}

/// Stands in for the home-screen widget of the phone.
final class FakeWidgets implements WidgetGateway {
  /// Everything handed to the widget so far, in order. Null clears it.
  final List<WidgetSnapshot?> handed = [];

  /// What the widget shows now, or null when it shows nothing.
  WidgetSnapshot? get current => handed.isEmpty ? null : handed.last;

  @override
  Future<void> update(WidgetSnapshot? snapshot) async => handed.add(snapshot);
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

  /// The build number the app believes it is. Empty, as a build made by
  /// hand: reminders are then not asked for again.
  String build = '';

  final FakeReminders reminders = FakeReminders();
  final FakeAutoBackup autoBackup = FakeAutoBackup();
  final FakeHealth health = FakeHealth();
  final FakeBackupPasswords backupPasswords = FakeBackupPasswords();
  final FakeWidgets widgets = FakeWidgets();
  final FakeDeviceAuth deviceAuth = FakeDeviceAuth();

  Future<LocalStore> openStore() =>
      LocalStore.open(directory: dir, keyStore: keyStore, codec: fastCodec);

  /// Writes made-up data before the app starts.
  ///
  /// By default the phone has already turned reminders on once, as an app
  /// that was opened before: they are not turned on again when it starts.
  /// Pass [remindersDefaultApplied] false for an app updated from a version
  /// that left them off.
  Future<void> seed({
    Iterable<DayEntry> days = const [],
    int? usualCycleLength,
    int? birthYear,
    Set<Goal> goals = const {},
    Set<RecentChange> recentChanges = const {},
    Set<Tracked> tracked = const {},
    Set<Symptom> startSigns = const {},
    Profile? profile,
    CalendarDay? pregnancyStart,
    CalendarDay? deliveryDate,
    bool remindersDefaultApplied = true,
  }) async {
    final store = await openStore();
    days.forEach(store.database.saveDay);
    store.database.usualCycleLength = usualCycleLength;
    store.database.birthYear = birthYear;
    store.database.goals = goals;
    store.database.recentChanges = recentChanges;
    store.database.tracked = tracked;
    store.database.startSigns = startSigns;
    store.database.profile = profile;
    store.database.pregnancyStart = pregnancyStart;
    store.database.deliveryDate = deliveryDate;
    if (remindersDefaultApplied) {
      store.database.dismissSuggestion('reminders_default');
    }
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
  /// settings applies, as on a phone. With [settle] false, the launch
  /// animation is still playing when this returns.
  Future<void> pumpApp({
    String locale = 'en',
    ThemeMode? themeMode,
    TextDirection? textDirection,
    bool settle = true,
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
          widgets: widgets,
          deviceAuth: deviceAuth,
          now: () => now,
          build: build,
          autoBackup: autoBackup,
          health: health,
          backupPasswords: backupPasswords,
        ),
      ),
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
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

/// Opens the journal tab: the calendar and the latest pages.
Future<void> openJournal(WidgetTester tester) =>
    tapVisible(tester, find.byIcon(Icons.menu_book_outlined));

/// Opens the review tab.
Future<void> openReview(WidgetTester tester) =>
    tapVisible(tester, find.byIcon(Icons.insights_outlined));

/// Opens the review tab, then what it keeps one tap away: the clinical
/// sheet, the trends and the list of cycles.
Future<void> openReviewDetail(WidgetTester tester) async {
  await openReview(tester);
  await tapVisible(tester, find.byKey(const ValueKey('open-review-detail')));
}

/// Comes back to the home tab.
Future<void> openHome(WidgetTester tester) =>
    tapVisible(tester, find.byIcon(Icons.home_outlined));

/// Scrolls to [finder] if needed, then taps it.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Goes on in the setup, without answering, until the screen that shows
/// [text]. Reminders passed on the way stay off.
Future<void> setupTo(WidgetTester tester, String text) async {
  const skip = ValueKey('onboarding-step-skip');
  for (var i = 0; i < 30 && find.text(text).evaluate().isEmpty; i++) {
    await tapVisible(
      tester,
      find.byKey(
        find.byKey(skip).evaluate().isEmpty
            ? const ValueKey('onboarding-next')
            : skip,
      ),
    );
  }
  expect(find.text(text), findsOneWidget);
}

/// Goes through the setup of the first launch without answering, except for
/// the first day of the last period when [lastPeriod] is given. Reminders
/// are left as proposed: both on.
Future<void> finishSetup(WidgetTester tester, {CalendarDay? lastPeriod}) async {
  const next = ValueKey('onboarding-next');
  const finish = ValueKey('onboarding-finish');
  await tapVisible(tester, find.byKey(next));
  for (var i = 0; i < 30 && find.byKey(finish).evaluate().isEmpty; i++) {
    final pick = find.byKey(ValueKey('pick-$lastPeriod'));
    if (pick.evaluate().isNotEmpty) {
      await tapVisible(tester, pick);
      await tapVisible(tester, find.byKey(next));
    } else if (find
        .byKey(const ValueKey('setup-period-reminder'))
        .evaluate()
        .isNotEmpty) {
      await tapVisible(tester, find.byKey(next));
    } else {
      const skip = ValueKey('onboarding-step-skip');
      await tapVisible(
        tester,
        find.byKey(find.byKey(skip).evaluate().isEmpty ? next : skip),
      );
    }
  }
  await tapVisible(tester, find.byKey(finish));
}

/// From the first launch, goes through every screen and opens every dialog.
/// A layout that overflows makes the test fail.
Future<void> walkEveryScreen(WidgetTester tester, Harness harness) async {
  // The setup, screen by screen, with the last period today.
  const next = ValueKey('onboarding-next');
  const finish = ValueKey('onboarding-finish');
  await tapVisible(tester, find.byKey(next));
  for (var i = 0; i < 30 && find.byKey(finish).evaluate().isEmpty; i++) {
    final today = find.byKey(ValueKey('pick-${harness.today}'));
    if (today.evaluate().isNotEmpty) {
      await tapVisible(tester, today);
    }
    // The year of birth cannot be confirmed before the wheel was turned.
    final blocked =
        tester.widget<FilledButton>(find.byKey(next)).onPressed == null;
    await tapVisible(
      tester,
      find.byKey(blocked ? const ValueKey('onboarding-step-skip') : next),
    );
  }
  await tapVisible(tester, find.byKey(finish));

  // Home, then the entry of the day.
  expect(find.byKey(const ValueKey('log-today')), findsOneWidget);
  await tapVisible(tester, find.byKey(const ValueKey('log-today')));
  await tapVisible(tester, find.byKey(const ValueKey('flow-medium')));
  await tapVisible(tester, find.byKey(const ValueKey('day-done')));

  // The journal and the review.
  await openJournal(tester);
  await tapVisible(tester, find.byKey(const ValueKey('journal-write-today')));
  await tapVisible(tester, find.byKey(const ValueKey('day-done')));
  await openReviewDetail(tester);
  expect(find.byKey(const ValueKey('cycle-report')), findsOneWidget);
  await tapVisible(tester, find.byType(BackButton));

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

  // The ovulation estimate is on: off, then on again, which asks first.
  await tapVisible(tester, find.byIcon(Icons.egg_outlined));
  await tapVisible(tester, find.byIcon(Icons.egg_outlined));
  expect(find.byType(AlertDialog), findsOneWidget);
  await tapVisible(
    tester,
    find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextButton),
    ),
  );

  // Reminders, turned on at the end of the first launch: their dialogs.
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
