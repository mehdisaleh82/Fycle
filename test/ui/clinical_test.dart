import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/study_facts.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Three made-up periods, 28 days apart: two complete cycles of 28 days.
List<DayEntry> threePeriods() => [
  ...periodFrom(CalendarDay(2026, 1, 3)),
  ...periodFrom(CalendarDay(2026, 1, 31)),
  ...periodFrom(CalendarDay(2026, 2, 28)),
];

/// Made-up cycles of 20, 44 and 30 days, with periods of 10 days.
List<DayEntry> unusualCycles() => [
  ...periodFrom(CalendarDay(2025, 12, 1), length: 10),
  ...periodFrom(CalendarDay(2025, 12, 21), length: 10),
  ...periodFrom(CalendarDay(2026, 2, 3), length: 10),
  ...periodFrom(CalendarDay(2026, 3, 5), length: 10),
];

String textOf(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(ValueKey(key))).data!;

Finder within(String key, String text) =>
    find.descendant(of: find.byKey(ValueKey(key)), matching: find.text(text));

/// The first day on or after [from] on which [fact] is shown.
CalendarDay dayOf(StudyFact fact, {CalendarDay? from}) {
  var day = from ?? CalendarDay(2026, 3, 20);
  while (studyFactOn(day) != fact) {
    day = day.addDays(1);
  }
  return day;
}

void main() {
  group('study of the day', () {
    testWidgets('sets a published finding against her own figure', (
      tester,
    ) async {
      final harness = Harness(tester, today: dayOf(StudyFact.exactly28));
      await harness.seed(days: threePeriods());
      await harness.pumpApp();

      expect(find.text('What the studies say'), findsOneWidget);
      expect(
        textOf(tester, 'study-fact'),
        'Only about 13% of cycles last exactly 28 days.',
      );
      expect(textOf(tester, 'study-you'), 'Your average cycle: 28 days.');
      expect(textOf(tester, 'study-source'), contains('612,613 cycles'));
    });

    testWidgets('changes from one day to the next', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();
      final first = textOf(tester, 'study-fact');

      harness.now = harness.now.add(const Duration(days: 1));
      await harness.pumpApp();
      expect(textOf(tester, 'study-fact'), isNot(first));
    });

    testWidgets('says what to log when she has no figure yet', (tester) async {
      final harness = Harness(tester, today: dayOf(StudyFact.variesMoreThan7));
      await harness.seed(days: periodFrom(harness.today.addDays(-3)));
      await harness.pumpApp(locale: 'fr');

      expect(textOf(tester, 'study-fact'), contains('4 femmes sur 10'));
      expect(
        textOf(tester, 'study-you'),
        'Saisissez deux débuts de règles pour vous situer.',
      );
    });

    testWidgets('uses her age when she gave it', (tester) async {
      final harness = Harness(tester, today: dayOf(StudyFact.shortensWithAge));
      await harness.seed(days: periodFrom(harness.today.addDays(-3)));
      await harness.pumpApp();
      expect(textOf(tester, 'study-you'), contains('year of birth'));

      await harness.read((store) => store.database.birthYear = 1986);
      await harness.pumpApp();
      expect(
        textOf(tester, 'study-you'),
        'At 40, the reference cycle is 28 days.',
      );
    });

    testWidgets('lists its sources', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp(locale: 'fr');

      await tapVisible(tester, find.byKey(const ValueKey('open-sources')));
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('npj Digital Medicine, 2019'), findsWidgets);
      expect(find.textContaining('New England Journal'), findsWidgets);
      expect(find.textContaining('FIGO'), findsWidgets);
      expect(find.textContaining('pas vous'), findsOneWidget);
    });
  });

  group('clinical sheet', () {
    testWidgets('usual cycles are shown within every range', (tester) async {
      final harness = Harness(tester);
      await harness.seed(
        days: [...periodFrom(CalendarDay(2025, 12, 6)), ...threePeriods()],
      );
      await harness.pumpApp();
      await openReview(tester);

      expect(find.text('Clinical sheet'), findsOneWidget);
      expect(
        find.text('Based on 3 complete cycles over the last 12 months.'),
        findsOneWidget,
      );
      expect(
        within('clinical-frequency', 'A cycle of 28 days on average'),
        findsOneWidget,
      );
      expect(
        within('clinical-frequency', 'Usual range: 24 to 38 days'),
        findsOneWidget,
      );
      expect(
        within('clinical-regularity', 'Cycles of 28 days, all the same length'),
        findsOneWidget,
      );
      expect(
        within('clinical-duration', '4 days on average, 4 at most'),
        findsOneWidget,
      );
      expect(
        within('clinical-volume', 'Moderate, as you logged it'),
        findsOneWidget,
      );
      expect(
        within(
          'clinical-phases',
          'Before ovulation: 12 to 18 days. After: about 13 days.',
        ),
        findsOneWidget,
      );
      expect(within('clinical-spotting', 'None logged'), findsOneWidget);
      expect(find.text('Within the usual range'), findsNWidgets(3));
      expect(find.text('Outside the usual range'), findsNothing);
      expect(find.byKey(const ValueKey('clinical-outside-note')), findsNothing);
    });

    testWidgets('unusual values are marked, without naming anything', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: unusualCycles());
      await harness.pumpApp(locale: 'fr');
      await openReview(tester);

      expect(
        within(
          'clinical-regularity',
          "Des cycles de 20 à 44 jours, soit 24 jours d'écart",
        ),
        findsOneWidget,
      );
      expect(
        within('clinical-regularity', 'Hors de la plage habituelle'),
        findsOneWidget,
      );
      expect(
        within('clinical-duration', '10 jours en moyenne, 10 au plus'),
        findsOneWidget,
      );
      expect(
        within('clinical-duration', 'Hors de la plage habituelle'),
        findsOneWidget,
      );
      // The average, 31 days, is within the range.
      expect(
        within('clinical-frequency', 'Dans la plage habituelle'),
        findsOneWidget,
      );
      expect(
        textOf(tester, 'clinical-outside-note'),
        "Une valeur hors de la plage habituelle n'est pas un diagnostic. "
        'Cette fiche mérite d\'être montrée à un médecin.',
      );
    });

    testWidgets('regularity waits for three cycles', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();
      await openReview(tester);

      expect(
        within(
          'clinical-regularity',
          'Three complete cycles are needed to tell.',
        ),
        findsOneWidget,
      );
      expect(find.text('Within the usual range'), findsNWidgets(2));
    });

    testWidgets('counts spotting between periods', (tester) async {
      final harness = Harness(tester);
      await harness.seed(
        days: [
          ...threePeriods(),
          DayEntry(day: CalendarDay(2026, 1, 17), flow: FlowIntensity.spotting),
          DayEntry(day: CalendarDay(2026, 2, 14), flow: FlowIntensity.spotting),
        ],
      );
      await harness.pumpApp();
      await openReview(tester);
      expect(within('clinical-spotting', '2 days logged'), findsOneWidget);
    });

    testWidgets('shows the reference ranges before a cycle has ended', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
      await harness.pumpApp();
      await openReview(tester);

      expect(find.textContaining('Shown for now: the reference'), findsOne);
      expect(
        within('clinical-frequency', 'Your figure will replace this line'),
        findsOneWidget,
      );
      expect(
        within('clinical-frequency', 'Usual range: 24 to 38 days'),
        findsOneWidget,
      );
      expect(
        within('clinical-duration', 'Usual: up to 8 days'),
        findsOneWidget,
      );
      expect(find.text('Within the usual range'), findsNothing);
    });
  });

  group('report for the doctor', () {
    testWidgets('opens in one tap from the home tab', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.read((store) => store.database.birthYear = 1990);
      await harness.pumpApp(locale: 'fr');

      await tapVisible(
        tester,
        find.byKey(const ValueKey('open-doctor-report')),
      );
      expect(find.text('Rapport pour le médecin'), findsOneWidget);
      expect(
        textOf(tester, 'doctor-report-intro'),
        'Établi le 20 mars 2026 à partir de vos saisies. Il décrit et '
        "compare ; ce n'est pas un diagnostic.",
      );
      expect(find.text('Âge : 36 ans'), findsOneWidget);
      expect(find.text('Fiche clinique'), findsOneWidget);
      expect(find.text('Ce cycle'), findsOneWidget);
      expect(find.text('Historique'), findsOneWidget);

      // And back to the home tab.
      await tapVisible(tester, find.byType(BackButton));
      expect(find.byKey(const ValueKey('cycle-day')), findsOneWidget);
    });

    testWidgets('says nothing of the age when it is not given', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();
      await tapVisible(
        tester,
        find.byKey(const ValueKey('open-doctor-report')),
      );
      expect(find.textContaining('Age:'), findsNothing);
      expect(find.text('Clinical sheet'), findsOneWidget);
    });
  });

  group('year of birth', () {
    testWidgets('given at first launch, it sets the reference cycle', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.pumpApp();
      await tapVisible(tester, find.byKey(const ValueKey('last-period-today')));
      await tester.ensureVisible(
        find.byKey(const ValueKey('birth-year-field')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('birth-year-field')),
        '2001',
      );
      await tester.pumpAndSettle();
      // The estimate shown before starting already uses it.
      expect(
        find.textContaining('Estimate based on a cycle of 30 days'),
        findsOneWidget,
      );
      await tapVisible(tester, find.text('Start'));

      expect(await harness.read((store) => store.database.birthYear), 2001);
      expect(within('figure-cycle', '30 days'), findsOneWidget);
      expect(
        within('figure-cycle', 'reference for your age, to adjust'),
        findsOneWidget,
      );
    });

    testWidgets('a year that makes no sense is refused', (tester) async {
      final harness = Harness(tester);
      await harness.pumpApp(locale: 'fr');
      await tapVisible(tester, find.byKey(const ValueKey('last-period-today')));
      await tester.ensureVisible(
        find.byKey(const ValueKey('birth-year-field')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('birth-year-field')),
        '2024',
      );
      await tapVisible(tester, find.text('Commencer'));

      expect(
        find.text('Saisissez une année entre 1956 et 2016.'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('birth-year-field')), findsOneWidget);
    });

    testWidgets('can be changed or forgotten in the settings', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: periodFrom(CalendarDay(2026, 3, 18)));
      await harness.pumpApp();
      await tapVisible(tester, find.byIcon(Icons.settings_outlined));
      expect(within('birth-year', 'Not given'), findsOneWidget);

      await tapVisible(tester, find.byKey(const ValueKey('birth-year')));
      await tester.enterText(dialogField(), '1981');
      await tapVisible(tester, find.text('Save'));
      expect(within('birth-year', '1981'), findsOneWidget);
      expect(await harness.read((store) => store.database.birthYear), 1981);

      // The reference follows: 27 days at 45.
      await openHome(tester);
      expect(within('figure-cycle', '27 days'), findsOneWidget);

      await tapVisible(tester, find.byIcon(Icons.settings_outlined));
      await tapVisible(tester, find.byKey(const ValueKey('birth-year')));
      await tester.enterText(dialogField(), '');
      await tapVisible(tester, find.text('Save'));
      expect(await harness.read((store) => store.database.birthYear), isNull);
    });

    testWidgets('her own cycles take over from the reference', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.read((store) => store.database.birthYear = 2001);
      await harness.pumpApp();

      expect(within('figure-cycle', '28 days'), findsOneWidget);
      expect(
        within('figure-cycle', 'from your entries\nreference: 30 days'),
        findsOneWidget,
      );
    });

    testWidgets('travels with a backup, and goes when everything is deleted', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.read((store) => store.database.birthYear = 1990);
      final store = await harness.openStore();
      addTearDown(store.close);
      final backup = await store.exportEncrypted('made-up password');
      store.database.birthYear = null;

      await store.importEncrypted(backup, 'made-up password');
      expect(store.database.birthYear, 1990);

      await store.deleteEverything();
      final fresh = await harness.openStore();
      addTearDown(fresh.close);
      expect(fresh.database.birthYear, isNull);
    });
  });

  for (final locale in ['en', 'fr']) {
    for (final scale in [1.0, 2.5]) {
      testWidgets('the sheet and the report hold from right to left, in dark '
          '($locale, × $scale)', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final harness = Harness(tester);
        if (scale > 1) {
          // A small phone.
          tester.view.physicalSize = const Size(320, 568);
        }
        await harness.seed(days: unusualCycles());
        await harness.read((store) => store.database.birthYear = 1990);
        await harness.pumpApp(
          locale: locale,
          themeMode: ThemeMode.dark,
          textDirection: TextDirection.rtl,
        );
        await tapVisible(tester, find.byKey(const ValueKey('open-sources')));
        await tapVisible(
          tester,
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(TextButton),
          ),
        );
        await tapVisible(
          tester,
          find.byKey(const ValueKey('open-doctor-report')),
        );
        await tester.drag(
          find.byType(SingleChildScrollView).last,
          const Offset(0, -8000),
        );
        await tester.pumpAndSettle();
      });
    }
  }
}
