import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/reminders.dart';
import 'package:fycle/l10n/app_localizations.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Three made-up periods, 28 days apart. Seen from 20 March 2026 at noon,
/// the next one is expected between 25 and 31 March.
List<DayEntry> threePeriods() => [
  ...periodFrom(CalendarDay(2026, 1, 3)),
  ...periodFrom(CalendarDay(2026, 1, 31)),
  ...periodFrom(CalendarDay(2026, 2, 28)),
];

Future<Harness> openSettings(
  WidgetTester tester, {
  String locale = 'en',
}) async {
  final harness = Harness(tester);
  await harness.seed(days: threePeriods());
  await harness.pumpApp(locale: locale);
  await tester.tap(find.byIcon(Icons.settings_outlined));
  await tester.pumpAndSettle();
  return harness;
}

Finder switchOf(String title) => find.widgetWithText(SwitchListTile, title);

bool isOn(WidgetTester tester, String title) =>
    tester.widget<SwitchListTile>(switchOf(title)).value;

Future<void> resume(WidgetTester tester) async {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('reminders are off until the user turns them on', (tester) async {
    final harness = await openSettings(tester);

    expect(isOn(tester, 'Period approaching'), isFalse);
    expect(isOn(tester, 'Daily entry reminder'), isFalse);
    // The phone was asked nothing and nothing was scheduled.
    expect(harness.reminders.permissionRequests, 0);
    expect(harness.reminders.replacements, 0);
  });

  group('period approaching', () {
    testWidgets('asks for permission, then schedules one discreet reminder', (
      tester,
    ) async {
      final harness = await openSettings(tester);
      await tapVisible(tester, switchOf('Period approaching'));

      expect(harness.reminders.permissionRequests, 1);
      expect(isOn(tester, 'Period approaching'), isTrue);
      final reminder = harness.reminders.scheduled.single;
      // Two days before 25 March, at 9:00.
      expect(reminder.when, DateTime(2026, 3, 23, 9));
      expect(reminder.title, 'Fycle');
      expect(reminder.body, 'A look at your calendar?');
      final stored = await harness.read(
        (store) => store.database.reminderSettings,
      );
      expect(stored.periodEnabled, isTrue);
    });

    testWidgets('stays off when the phone refuses notifications', (
      tester,
    ) async {
      final harness = await openSettings(tester);
      harness.reminders.allow = false;
      await tapVisible(tester, switchOf('Period approaching'));

      expect(find.text('Notifications are turned off'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(isOn(tester, 'Period approaching'), isFalse);
      expect(harness.reminders.scheduled, isEmpty);
      final stored = await harness.read(
        (store) => store.database.reminderSettings,
      );
      expect(stored.periodEnabled, isFalse);
    });

    testWidgets('follows the chosen number of days', (tester) async {
      final harness = await openSettings(tester);
      await tapVisible(tester, switchOf('Period approaching'));
      expect(find.text('2 days before'), findsOneWidget);

      await tapVisible(
        tester,
        find.byKey(const ValueKey('period-days-before')),
      );
      await tester.tap(find.text('3 days before'));
      await tester.pumpAndSettle();

      expect(find.text('3 days before'), findsOneWidget);
      expect(harness.reminders.scheduled.single.when, DateTime(2026, 3, 22, 9));
    });

    testWidgets('follows the chosen time', (tester) async {
      final harness = await openSettings(tester);
      await tapVisible(tester, switchOf('Period approaching'));
      expect(find.text('9:00 AM'), findsOneWidget);

      await tapVisible(tester, find.byKey(const ValueKey('period-time')));
      expect(find.byType(TimePickerDialog), findsOneWidget);
      // Typing is steadier than turning the dial.
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '7');
      await tester.enterText(find.byType(TextField).last, '30');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('7:30 AM'), findsOneWidget);
      expect(
        harness.reminders.scheduled.single.when,
        DateTime(2026, 3, 23, 7, 30),
      );
    });

    testWidgets('is scheduled again after each entry', (tester) async {
      final harness = await openSettings(tester);
      await tapVisible(tester, switchOf('Period approaching'));
      final before = harness.reminders.scheduled.single.when;

      // A period logged today moves the estimate to the next cycle.
      await tapVisible(tester, find.byIcon(Icons.home_outlined));
      await tapVisible(tester, find.byKey(const ValueKey('log-today')));
      await tester.tap(find.byKey(const ValueKey('flow-medium')));
      await tester.pumpAndSettle();

      final after = harness.reminders.scheduled.single.when;
      expect(before, DateTime(2026, 3, 23, 9));
      expect(after, DateTime(2026, 4, 6, 9));
    });

    testWidgets('is cancelled when turned off', (tester) async {
      final harness = await openSettings(tester);
      await tapVisible(tester, switchOf('Period approaching'));
      expect(harness.reminders.scheduled, hasLength(1));

      await tapVisible(tester, switchOf('Period approaching'));
      expect(harness.reminders.scheduled, isEmpty);
      // Turning a reminder off asks the phone nothing.
      expect(harness.reminders.permissionRequests, 1);
    });
  });

  group('daily entry', () {
    testWidgets('schedules one reminder per day for two weeks', (tester) async {
      final harness = await openSettings(tester);
      await tapVisible(tester, switchOf('Daily entry reminder'));

      expect(harness.reminders.permissionRequests, 1);
      final scheduled = harness.reminders.scheduled;
      expect(scheduled, hasLength(dailyReminderHorizonDays));
      expect(scheduled.first.when, DateTime(2026, 3, 20, 20));
      expect(scheduled.last.when, DateTime(2026, 4, 2, 20));
      expect(
        scheduled.every((r) => r.body == 'A moment to note your day?'),
        isTrue,
      );
    });

    testWidgets('skips today once the day is logged', (tester) async {
      final harness = await openSettings(tester);
      await tapVisible(tester, switchOf('Daily entry reminder'));

      await tapVisible(tester, find.byIcon(Icons.home_outlined));
      await tapVisible(tester, find.byKey(const ValueKey('log-today')));
      await tester.tap(find.byKey(const ValueKey('flow-medium')));
      await tester.pumpAndSettle();

      final scheduled = harness.reminders.scheduled;
      expect(scheduled, hasLength(dailyReminderHorizonDays - 1));
      expect(scheduled.first.when, DateTime(2026, 3, 21, 20));
    });

    testWidgets('moves forward each time the app comes back to the front', (
      tester,
    ) async {
      final harness = await openSettings(tester);
      await tapVisible(tester, switchOf('Daily entry reminder'));

      harness.now = DateTime(2026, 3, 24, 8);
      await resume(tester);

      final scheduled = harness.reminders.scheduled;
      expect(scheduled, hasLength(dailyReminderHorizonDays));
      expect(scheduled.first.when, DateTime(2026, 3, 24, 20));
      expect(scheduled.last.when, DateTime(2026, 4, 6, 20));
    });
  });

  testWidgets('the choices survive closing the app', (tester) async {
    final harness = await openSettings(tester);
    await tapVisible(tester, switchOf('Period approaching'));
    await tapVisible(tester, switchOf('Daily entry reminder'));

    await tester.pumpWidget(const SizedBox());
    harness.reminders.scheduled = const [];
    await harness.pumpApp();

    // Scheduled again at launch, without asking for permission again.
    expect(
      harness.reminders.scheduled,
      hasLength(dailyReminderHorizonDays + 1),
    );
    expect(harness.reminders.permissionRequests, 2);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(isOn(tester, 'Period approaching'), isTrue);
    expect(isOn(tester, 'Daily entry reminder'), isTrue);
  });

  testWidgets('deleting everything cancels the reminders', (tester) async {
    final harness = await openSettings(tester);
    await tapVisible(tester, switchOf('Daily entry reminder'));
    expect(harness.reminders.scheduled, isNotEmpty);

    await tapVisible(tester, find.text('Delete everything'));
    await tester.tap(find.widgetWithText(FilledButton, 'Delete everything'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Fycle'), findsOneWidget);
    expect(harness.reminders.scheduled, isEmpty);
    final stored = await harness.read(
      (store) => store.database.reminderSettings,
    );
    expect(stored, ReminderSettings());
  });

  testWidgets('reminders are worded in French', (tester) async {
    final harness = await openSettings(tester, locale: 'fr');
    await tapVisible(tester, switchOf('Règles qui approchent'));
    await tapVisible(tester, switchOf('Rappel de saisie quotidien'));

    expect(find.text('2 jours avant'), findsOneWidget);
    expect(find.text('09:00'), findsOneWidget);
    final bodies = {for (final r in harness.reminders.scheduled) r.body};
    expect(bodies, {
      "Un coup d'œil à ton calendrier ?",
      'Un moment pour noter ta journée ?',
    });
  });

  test('notification texts reveal nothing on a locked screen', () {
    // Words that would tell a passer-by what the app is about, or that
    // would read as pressure or as a medical statement.
    final revealing = RegExp(
      r'period|cycle|menstr|late|overdue|forgot|missed|fertil|ovul|pregnan|'
      r'health|règles|retard|oubli|manqu|enceinte|grossesse|santé',
      caseSensitive: false,
    );
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = lookupAppLocalizations(locale);
      for (final text in [
        l10n.notificationPeriodBody,
        l10n.notificationDailyBody,
        l10n.notificationChannelName,
      ]) {
        expect(revealing.hasMatch(text), isFalse, reason: '$locale: $text');
      }
    }
  });
}
