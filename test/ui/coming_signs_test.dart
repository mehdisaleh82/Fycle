import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/life_stage.dart';
import 'package:fycle/domain/symptom.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Three periods, 28 days apart, the last one on 28 February 2026: the
/// next one is estimated from 25 March.
List<DayEntry> threePeriods() => [
  ...periodFrom(CalendarDay(2026, 1, 3)),
  ...periodFrom(CalendarDay(2026, 1, 31)),
  ...periodFrom(CalendarDay(2026, 2, 28)),
];

/// Cravings two days before each of the two periods that followed.
List<DayEntry> withCravings() => [
  ...threePeriods(),
  DayEntry(day: CalendarDay(2026, 1, 29), symptoms: const {Symptom.cravings}),
  DayEntry(day: CalendarDay(2026, 2, 26), symptoms: const {Symptom.cravings}),
];

void main() {
  Finder key(String name) => find.byKey(ValueKey(name));
  String textOf(WidgetTester tester, String name) =>
      tester.widget<Text>(key(name)).data!;

  testWidgets('what she logged before her periods is announced', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: withCravings());
    await harness.pumpApp();

    expect(find.text('What comes back for you'), findsOneWidget);
    expect(find.text('Cravings'), findsOneWidget);
    expect(textOf(tester, 'coming-cravings'), '2 days before · 2 of 2 cycles');
    // 20 March: two days before the range is the 23rd.
    expect(textOf(tester, 'coming-when'), 'In about 3 days');
    // Nothing to log for a day that has not come.
    expect(key('coming-log-cravings'), findsNothing);
  });

  testWidgets('once the days have come, one tap logs the sign for today', (
    tester,
  ) async {
    final harness = Harness(tester, today: CalendarDay(2026, 3, 24));
    await harness.seed(days: withCravings());
    await harness.pumpApp();

    expect(textOf(tester, 'coming-when'), 'Around now');
    await tapVisible(tester, key('coming-log-cravings'));
    expect(
      await harness.read(
        (store) => store.database
            .readDays()
            .singleWhere((entry) => entry.day == harness.today)
            .symptoms,
      ),
      {Symptom.cravings},
    );

    // A second tap takes it back.
    await tapVisible(tester, key('coming-log-cravings'));
    expect(
      await harness.read(
        (store) => store.database.readDays().where(
          (entry) =>
              entry.day == harness.today &&
              entry.symptoms.contains(Symptom.cravings),
        ),
      ),
      isEmpty,
    );
  });

  testWidgets('with nothing of hers, a general benchmark, said as such', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    expect(find.text('Before a period, in general'), findsOneWidget);
    expect(
      find.text(
        'Often reported: Bloating, Cravings, Breast tenderness, Fatigue, '
        'Mood swings, Headache.',
      ),
      findsOneWidget,
    );
    expect(find.text('What comes back for you'), findsNothing);
    expect(key('coming-log-cravings'), findsNothing);
  });

  testWidgets('what she said in the setup stands from the first day', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.pumpApp();
    await tapVisible(tester, key('onboarding-next'));
    await setupTo(tester, 'Before your period, you often get…');
    await tapVisible(tester, key('before-bloating'));
    await finishSetup(tester, lastPeriod: CalendarDay(2026, 3, 1));

    expect(await harness.read((store) => store.database.signsBeforePeriod), {
      Symptom.bloating,
    });
    expect(find.text('What comes back for you'), findsOneWidget);
    expect(textOf(tester, 'coming-bloating'), 'From what you said');
  });

  testWidgets('nothing is said during a period', (tester) async {
    final during = Harness(tester, today: CalendarDay(2026, 3, 1));
    await during.seed(days: withCravings());
    await during.pumpApp();
    expect(key('coming-signs'), findsNothing);
  });

  testWidgets('nothing is said during a pregnancy', (tester) async {
    final harness = Harness(tester);
    await harness.seed(
      days: withCravings(),
      profile: Profile.pregnant,
      pregnancyStart: CalendarDay(2026, 2, 28),
    );
    await harness.pumpApp();
    expect(key('coming-signs'), findsNothing);
  });

  testWidgets('the reminder is off until she turns it on, and stays discreet', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: withCravings());
    await harness.pumpApp();
    expect(harness.reminders.scheduled, isEmpty);

    await tapVisible(tester, find.byIcon(Icons.settings_outlined));
    await tapVisible(tester, key('signs-reminder'));

    final settings = await harness.read(
      (store) => store.database.reminderSettings,
    );
    expect(settings.signsEnabled, isTrue);
    // One reminder, the day before the 23rd, that names neither a period
    // nor a sign on the lock screen.
    final reminder = harness.reminders.scheduled.single;
    expect(reminder.when, DateTime(2026, 3, 22, 9));
    expect(reminder.body, 'A note for the days ahead.');
  });
}
