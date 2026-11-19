import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/mood.dart';
import 'package:fycle/domain/pain_level.dart';
import 'package:fycle/domain/sleep_quality.dart';
import 'package:fycle/domain/symptom.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Three made-up periods, 28 days apart: two complete cycles. Seen from
/// 20 March 2026, today is day 21 of the cycle.
List<DayEntry> threePeriods() => [
  ...periodFrom(CalendarDay(2026, 1, 3)),
  ...periodFrom(CalendarDay(2026, 1, 31)),
  ...periodFrom(CalendarDay(2026, 2, 28)),
];

String textOf(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(ValueKey(key))).data!;

Finder within(String key, String text) =>
    find.descendant(of: find.byKey(ValueKey(key)), matching: find.text(text));

void main() {
  group('home tab', () {
    testWidgets('is kept to the ring and the journal of the day', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.read(
        (store) => store.database
          ..dismissSuggestion('reminders')
          ..dismissSuggestion('lock'),
      );
      await harness.pumpApp();

      expect(find.text('Day 21 of your cycle'), findsOneWidget);
      expect(find.text('Period in 5 to 11 days'), findsOneWidget);
      expect(find.text('My journal today'), findsOneWidget);
      // Everything else is in the review.
      expect(find.byType(Card), findsNWidgets(2));
      expect(find.byKey(const ValueKey('figure-cycle')), findsNothing);
      expect(find.byKey(const ValueKey('unlock-card')), findsNothing);
      expect(find.byKey(const ValueKey('open-doctor-report')), findsNothing);
      // No study, no source, no reference is named anywhere on it.
      for (final word in ['stud', 'reference', 'FIGO', 'Source']) {
        expect(find.textContaining(word), findsNothing, reason: word);
      }
    });

    testWidgets('a period can be logged the day it comes, in one tap', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.pumpApp();
      await tapVisible(tester, find.byKey(const ValueKey('onboarding-skip')));

      expect(find.text('No estimate yet'), findsOneWidget);
      await tapVisible(
        tester,
        find.byKey(const ValueKey('period-starts-today')),
      );

      expect(find.text('Day 1 of your period'), findsOneWidget);
      expect(find.text('Day 1 of your cycle'), findsOneWidget);
      expect(find.byKey(const ValueKey('period-starts-today')), findsNothing);
      expect(
        await harness.read((store) => store.database.readDay(harness.today)),
        DayEntry(day: harness.today, flow: FlowIntensity.medium),
      );
    });

    testWidgets('that button is worded in French, and gone once a period is '
        'logged', (tester) async {
      final harness = Harness(tester);
      await harness.pumpApp(locale: 'fr');
      await tapVisible(tester, find.byKey(const ValueKey('onboarding-skip')));
      expect(find.text("Mes règles commencent aujourd'hui"), findsOneWidget);

      await harness.seed(days: threePeriods());
      await harness.pumpApp(locale: 'fr');
      expect(find.byKey(const ValueKey('period-starts-today')), findsNothing);
    });

    testWidgets('it comes back for a log left aside for months', (
      tester,
    ) async {
      final harness = Harness(tester, today: CalendarDay(2026, 11, 19));
      await harness.seed(days: threePeriods());
      await harness.pumpApp();

      expect(find.text('No recent entry'), findsOneWidget);
      await tapVisible(
        tester,
        find.byKey(const ValueKey('period-starts-today')),
      );
      expect(find.text('Day 1 of your period'), findsOneWidget);
    });

    testWidgets('pain and mood are logged in one tap each', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();

      expect(
        textOf(tester, 'today-progress'),
        '0 of 6 sections filled in today',
      );
      await tapVisible(
        tester,
        find.byKey(const ValueKey('quick-pain-moderate')),
      );
      await tapVisible(tester, find.byKey(const ValueKey('quick-mood-calm')));
      expect(
        textOf(tester, 'today-progress'),
        '2 of 6 sections filled in today',
      );
      expect(
        await harness.read((store) => store.database.readDay(harness.today)),
        DayEntry(day: harness.today, pain: PainLevel.moderate, mood: Mood.calm),
      );

      // A second tap takes it back, and the rest is kept.
      await tapVisible(tester, find.byKey(const ValueKey('quick-mood-calm')));
      expect(
        await harness.read((store) => store.database.readDay(harness.today)),
        DayEntry(day: harness.today, pain: PainLevel.moderate),
      );
    });

    testWidgets('recalls what was logged around this day in past cycles', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(
        days: [
          ...threePeriods(),
          // Day 21 of the two complete cycles.
          DayEntry(day: CalendarDay(2026, 1, 23), sleep: SleepQuality.poor),
          DayEntry(day: CalendarDay(2026, 2, 20), sleep: SleepQuality.poor),
          DayEntry(day: CalendarDay(2026, 2, 21), symptoms: {Symptom.bloating}),
        ],
      );
      await harness.pumpApp();

      expect(find.text('Usually around this day'), findsOneWidget);
      expect(
        find.text('Sleep: Poor: in 2 of your last 2 cycles'),
        findsOneWidget,
      );
      expect(find.textContaining('Bloating: in'), findsNothing);
    });

    testWidgets('says nothing of past cycles when nothing comes back', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();
      expect(find.byKey(const ValueKey('usual-signs')), findsNothing);
    });
  });

  group('tabs', () {
    testWidgets('each one is named', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp(locale: 'fr');

      for (final label in ['Accueil', 'Journal', 'Bilan', 'Réglages']) {
        expect(find.text(label), findsWidgets, reason: label);
      }
    });

    testWidgets('the home button leads back home', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();
      await tapVisible(tester, find.byIcon(Icons.settings_outlined));
      expect(find.byKey(const ValueKey('cycle-day')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('app-title')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('cycle-day')), findsOneWidget);
    });
  });

  group('journal tab', () {
    testWidgets('lists the latest pages, most recent first, with the note', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(
        days: [
          ...periodFrom(CalendarDay(2026, 2, 28)),
          DayEntry(
            day: CalendarDay(2026, 3, 18),
            mood: Mood.calm,
            symptoms: {Symptom.fatigue},
            note: 'Made-up note',
          ),
        ],
      );
      await harness.pumpApp();
      await openJournal(tester);

      expect(find.text('Your latest pages'), findsOneWidget);
      final page = find.byKey(const ValueKey('page-2026-03-18'));
      expect(
        find.descendant(
          of: page,
          matching: find.text('Wednesday, March 18, 2026'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: page, matching: find.text('Mood: Calm · Fatigue')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: page, matching: find.text('Made-up note')),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(page).dy,
        lessThan(
          tester.getTopLeft(find.byKey(const ValueKey('page-2026-03-03'))).dy,
        ),
      );
    });

    testWidgets('a page opens the entry of its day', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
      await harness.pumpApp();
      await openJournal(tester);

      await tapVisible(tester, find.byKey(const ValueKey('page-2026-03-01')));
      expect(find.byKey(const ValueKey('day-done')), findsOneWidget);
      final chip = tester.widget<ChoiceChip>(
        find.byKey(const ValueKey('flow-medium')),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('with nothing written, invites to write today', (tester) async {
      final harness = Harness(tester);
      await harness.pumpApp(locale: 'fr');
      await tapVisible(tester, find.byKey(const ValueKey('onboarding-skip')));
      await openJournal(tester);

      expect(find.textContaining("Rien d'écrit pour l'instant"), findsOne);
      await tapVisible(
        tester,
        find.byKey(const ValueKey('journal-write-today')),
      );
      expect(find.byKey(const ValueKey('day-done')), findsOneWidget);
    });
  });

  group('review tab', () {
    testWidgets('gives figures from the very first date', (tester) async {
      final harness = Harness(tester);
      await harness.pumpApp();
      await tapVisible(tester, find.byKey(const ValueKey('last-period-today')));
      await tapVisible(tester, find.text('Start'));
      await openReview(tester);

      expect(within('figure-cycle', '28 days'), findsOneWidget);
      expect(within('figure-cycle', 'estimate for now'), findsOneWidget);
      expect(within('figure-period', '1 day'), findsOneWidget);
      expect(within('figure-period', 'so far'), findsOneWidget);
      expect(within('figure-logged', '1'), findsOneWidget);
      expect(within('figure-logged', 'no complete cycle yet'), findsOneWidget);
    });

    testWidgets('the figures follow the log', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods(), usualCycleLength: 30);
      await harness.pumpApp();
      await openReview(tester);

      expect(within('figure-cycle', '28 days'), findsOneWidget);
      expect(within('figure-cycle', 'from your entries'), findsOneWidget);
      expect(within('figure-period', '4 days'), findsOneWidget);
      expect(within('figure-logged', '12'), findsOneWidget);
      expect(within('figure-logged', '2 complete cycles'), findsOneWidget);
    });

    testWidgets('names no study and no reference', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();
      await openReview(tester);

      for (final word in ['stud', 'reference', 'FIGO', 'Source', '2019']) {
        expect(find.textContaining(word), findsNothing, reason: word);
      }
      // The usual ranges are still given, as plain figures.
      expect(find.text('Usual range: 24 to 38 days'), findsOneWidget);
    });

    testWidgets('shows what the entries bring, step by step', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
      await harness.pumpApp();
      await openReview(tester);

      expect(find.text('The more you log, the more you see'), findsOneWidget);
      expect(textOf(tester, 'unlock-overall'), '1 of 4 available');
      expect(within('unlock-estimate', 'Available'), findsOneWidget);
      expect(
        within('unlock-averages', 'After one complete cycle · 0 of 1'),
        findsOneWidget,
      );
      expect(
        within('unlock-trends', 'After two complete cycles · 0 of 2'),
        findsOneWidget,
      );
    });

    testWidgets('the steps move forward as cycles are logged', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp(locale: 'fr');
      await openReview(tester);

      expect(find.text('Plus tu saisis, plus tu en vois'), findsOneWidget);
      expect(textOf(tester, 'unlock-overall'), '3 sur 4 disponibles');
      expect(within('unlock-trends', 'Disponible'), findsOneWidget);
      expect(
        within(
          'unlock-reliableEstimate',
          'Avec quatre cycles réguliers ou plus · 2 sur 4',
        ),
        findsOneWidget,
      );
    });

    testWidgets('the report of the cycle can be read at any time', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(
        days: [
          ...threePeriods(),
          DayEntry(
            day: CalendarDay(2026, 3, 1),
            flow: FlowIntensity.medium,
            pain: PainLevel.severe,
            symptoms: {Symptom.cramps},
          ),
          DayEntry(
            day: CalendarDay(2026, 3, 10),
            sleep: SleepQuality.poor,
            symptoms: {Symptom.cramps, Symptom.headache},
          ),
        ],
      );
      await harness.pumpApp();
      await openReview(tester);

      for (final line in [
        'Day 21 of your cycle',
        'Started on Feb 28, 2026',
        'Period: 4 days',
        '5 days logged in this cycle',
        'Pain on 1 day',
        'Poor sleep on 1 night',
        'Logged most: Cramps, Headache.',
      ]) {
        expect(within('cycle-report', line), findsOneWidget, reason: line);
      }
    });

    testWidgets('with nothing logged, says how to start', (tester) async {
      final harness = Harness(tester);
      await harness.pumpApp(locale: 'fr');
      await tapVisible(tester, find.byKey(const ValueKey('onboarding-skip')));
      await openReview(tester);

      expect(
        within(
          'cycle-report',
          'Saisis le premier jour de tes règles pour commencer ton '
              'bilan.',
        ),
        findsOneWidget,
      );
    });
  });

  group('first launch', () {
    testWidgets('reminders are on afterwards, if the phone agrees', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.pumpApp();
      await tapVisible(tester, find.byKey(const ValueKey('last-period-today')));
      await tapVisible(tester, find.text('Start'));

      expect(harness.reminders.permissionRequests, 1);
      final settings = await harness.read(
        (store) => store.database.reminderSettings,
      );
      expect(settings.periodEnabled, isTrue);
      expect(settings.dailyEnabled, isTrue);
      expect(find.byKey(const ValueKey('suggest-reminders')), findsNothing);
    });

    testWidgets('a phone that refuses leaves them off, and is asked once more '
        'on the home tab', (tester) async {
      final harness = Harness(tester);
      harness.reminders.allow = false;
      await harness.pumpApp();
      await tapVisible(tester, find.byKey(const ValueKey('last-period-today')));
      await tapVisible(tester, find.text('Start'));

      final settings = await harness.read(
        (store) => store.database.reminderSettings,
      );
      expect(settings.periodEnabled, isFalse);
      expect(settings.dailyEnabled, isFalse);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byKey(const ValueKey('suggest-reminders')), findsOneWidget);
    });
  });

  group('reminders by default', () {
    testWidgets('an app set up before gets them at its next opening', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods(), remindersDefaultApplied: false);
      await harness.pumpApp();

      expect(harness.reminders.permissionRequests, 1);
      final settings = await harness.read(
        (store) => store.database.reminderSettings,
      );
      expect(settings.periodEnabled, isTrue);
      expect(settings.dailyEnabled, isTrue);
      expect(harness.reminders.scheduled, isNotEmpty);
    });

    testWidgets('once only: turned off afterwards, they stay off', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods(), remindersDefaultApplied: false);
      await harness.pumpApp();
      await harness.read(
        (store) => store.database.reminderSettings = store
            .database
            .reminderSettings
            .copyWith(periodEnabled: false, dailyEnabled: false),
      );

      await harness.pumpApp();
      expect(harness.reminders.permissionRequests, 1);
      final settings = await harness.read(
        (store) => store.database.reminderSettings,
      );
      expect(settings.periodEnabled, isFalse);
      expect(settings.dailyEnabled, isFalse);
    });

    testWidgets('a phone that refuses is asked once, then left alone', (
      tester,
    ) async {
      final harness = Harness(tester);
      harness.reminders.allow = false;
      await harness.seed(days: threePeriods(), remindersDefaultApplied: false);
      await harness.pumpApp();
      await harness.pumpApp();

      expect(harness.reminders.permissionRequests, 1);
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        (await harness.read((store) => store.database.reminderSettings))
            .dailyEnabled,
        isFalse,
      );
    });

    testWidgets('a choice already made is not touched', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods(), remindersDefaultApplied: false);
      await harness.read(
        (store) => store.database.reminderSettings = store
            .database
            .reminderSettings
            .copyWith(dailyEnabled: true),
      );
      await harness.pumpApp();

      expect(harness.reminders.permissionRequests, 0);
      final settings = await harness.read(
        (store) => store.database.reminderSettings,
      );
      expect(settings.periodEnabled, isFalse);
      expect(settings.dailyEnabled, isTrue);
    });
  });

  group('suggestions', () {
    testWidgets('reminders are offered once, and "not now" is kept', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();

      expect(find.text('A daily reminder to log?'), findsOneWidget);
      await tapVisible(tester, find.text('Not now'));
      expect(find.text('A daily reminder to log?'), findsNothing);
      expect(harness.reminders.permissionRequests, 0);

      await harness.pumpApp();
      expect(find.text('A daily reminder to log?'), findsNothing);
    });

    testWidgets('accepting turns both reminders on', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();

      await tapVisible(
        tester,
        find.descendant(
          of: find.byKey(const ValueKey('suggest-reminders')),
          matching: find.text('Turn on'),
        ),
      );
      final settings = await harness.read(
        (store) => store.database.reminderSettings,
      );
      expect(settings.periodEnabled, isTrue);
      expect(settings.dailyEnabled, isTrue);
      expect(harness.reminders.scheduled, isNotEmpty);
    });

    testWidgets('then the lock is offered, and asks who holds the phone', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp(locale: 'fr');
      await tapVisible(tester, find.text('Plus tard'));

      expect(
        find.text('Verrouiller Fycle par Face ID ou par code ?'),
        findsOneWidget,
      );
      await tapVisible(
        tester,
        find.descendant(
          of: find.byKey(const ValueKey('suggest-lock')),
          matching: find.text('Activer'),
        ),
      );
      expect(harness.deviceAuth.prompts, ['Déverrouiller Fycle']);
      expect(
        await harness.read((store) => store.database.appLockEnabled),
        isTrue,
      );
      expect(find.byKey(const ValueKey('suggest-lock')), findsNothing);
    });

    testWidgets('a phone without a passcode gets an explanation', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      harness.deviceAuth.available = false;
      await harness.pumpApp();
      await tapVisible(tester, find.text('Not now'));

      await tapVisible(
        tester,
        find.descendant(
          of: find.byKey(const ValueKey('suggest-lock')),
          matching: find.text('Turn on'),
        ),
      );
      expect(find.text('No passcode on this phone'), findsOneWidget);
      expect(
        await harness.read((store) => store.database.appLockEnabled),
        isFalse,
      );
    });
  });

  for (final locale in ['en', 'fr']) {
    for (final scale in [1.0, 2.5]) {
      testWidgets(
        'the home tab and the journal hold from right to left, in dark '
        '($locale, × $scale)',
        (tester) async {
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final harness = Harness(tester);
          if (scale > 1) {
            // A small phone.
            tester.view.physicalSize = const Size(320, 568);
          }
          await harness.seed(
            days: [
              ...threePeriods(),
              DayEntry(day: CalendarDay(2026, 1, 23), sleep: SleepQuality.poor),
              DayEntry(day: CalendarDay(2026, 2, 20), sleep: SleepQuality.poor),
              DayEntry(
                day: CalendarDay(2026, 3, 18),
                mood: Mood.calm,
                symptoms: {Symptom.fatigue, Symptom.cramps},
                note: 'Made-up note, long enough to wrap on a small phone.',
              ),
            ],
          );
          await harness.pumpApp(
            locale: locale,
            themeMode: ThemeMode.dark,
            textDirection: TextDirection.rtl,
          );
          await tester.drag(
            find.byType(SingleChildScrollView).first,
            const Offset(0, -6000),
          );
          await tester.pumpAndSettle();
          await openJournal(tester);
          await tester.drag(
            find.byType(SingleChildScrollView).first,
            const Offset(0, -6000),
          );
          await tester.pumpAndSettle();
        },
      );

      testWidgets('the home tab with nothing logged holds from right to left '
          '($locale, × $scale)', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final harness = Harness(tester);
        if (scale > 1) {
          tester.view.physicalSize = const Size(320, 568);
        }
        await harness.pumpApp(locale: locale, textDirection: TextDirection.rtl);
        await tapVisible(tester, find.byKey(const ValueKey('onboarding-skip')));
        expect(
          find.byKey(const ValueKey('period-starts-today')),
          findsOneWidget,
        );
      });
    }
  }
}
