import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/libido_level.dart';
import 'package:fycle/domain/start_profile.dart';
import 'package:fycle/domain/symptom.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Periods that open cycles of 28, 37, 28 and 28 days, the last one on
/// 2 March 2026. All made up.
List<DayEntry> changingCycles() => [
  ...periodFrom(CalendarDay(2025, 11, 1)),
  ...periodFrom(CalendarDay(2025, 11, 29)),
  ...periodFrom(CalendarDay(2026, 1, 5)),
  ...periodFrom(CalendarDay(2026, 2, 2)),
  ...periodFrom(CalendarDay(2026, 3, 2)),
];

/// Three periods, 28 days apart, the last one on 28 February 2026.
List<DayEntry> threePeriods() => [
  ...periodFrom(CalendarDay(2026, 1, 3)),
  ...periodFrom(CalendarDay(2026, 1, 31)),
  ...periodFrom(CalendarDay(2026, 2, 28)),
];

void main() {
  const card = ValueKey('change-card');

  testWidgets('the card is for those who follow a changing cycle', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: changingCycles());
    await harness.pumpApp();
    await openReview(tester);

    expect(find.byKey(card), findsNothing);
  });

  testWidgets('counts the differences that come back, and says who to tell', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(
      days: [
        ...changingCycles(),
        DayEntry(
          day: CalendarDay(2026, 3, 10),
          symptoms: const {Symptom.hotFlashes},
        ),
      ],
      goals: {Goal.perimenopause},
      recentChanges: {RecentChange.lessRegular, RecentChange.heavierFlow},
      startSigns: {Symptom.nightSweats, Symptom.jointPain},
    );
    await harness.pumpApp();
    await openReview(tester);
    await tester.ensureVisible(find.byKey(card));

    expect(find.text('What is changing'), findsOneWidget);
    expect(
      find.text(
        '2 times over your last 4 cycles, the length changed by 7 days or '
        'more from one cycle to the next.',
      ),
      findsOneWidget,
    );
    expect(
      find.text('In the last 90 days: Hot flashes (1 day).'),
      findsOneWidget,
    );
    expect(
      find.text(
        'When you set the app up, you said: heavier flow, less regular '
        'periods.',
      ),
      findsOneWidget,
    );
    expect(
      find.text(
        'Signs you named when you set the app up: Night sweats, Joint '
        'pain.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Worth telling a doctor'), findsOneWidget);
    // An observation: no stage, no condition is named.
    expect(find.textContaining('menopause'), findsNothing);
  });

  testWidgets('steady cycles are said to be steady, without alarm', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods(), birthYear: 1980);
    await harness.pumpApp(locale: 'fr');
    await openReview(tester);
    await tester.ensureVisible(find.byKey(card));

    expect(
      find.text(
        'Sur tes 2 derniers cycles, aucun ne diffère du précédent de 7 '
        'jours ou plus.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('À signaler'), findsNothing);
    expect(
      find.textContaining('Seul un professionnel de santé'),
      findsOneWidget,
    );
  });

  testWidgets('a long interval between two periods is reported', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(
      days: [
        ...periodFrom(CalendarDay(2025, 12, 1)),
        ...periodFrom(CalendarDay(2026, 2, 5)),
      ],
      goals: {Goal.perimenopause},
    );
    await harness.pumpApp();
    await openReview(tester);
    await tester.ensureVisible(find.byKey(card));

    expect(
      find.text(
        'One cycle lasted 66 days: 60 days or more between two periods.',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Worth telling a doctor'), findsOneWidget);
  });

  testWidgets('the report for the doctor carries it too', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: changingCycles(), goals: {Goal.perimenopause});
    await harness.pumpApp();
    await openReview(tester);
    await tapVisible(tester, find.byKey(const ValueKey('open-doctor-report')));

    expect(find.byKey(card), findsOneWidget);
  });

  group('what she follows', () {
    testWidgets('comes first in the entry of the day, after the flow', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(
        days: threePeriods(),
        tracked: {Tracked.libido, Tracked.sleep},
      );
      await harness.pumpApp();
      await tapVisible(tester, find.byKey(const ValueKey('log-today')));

      double top(String key) => tester.getTopLeft(find.byKey(ValueKey(key))).dy;
      expect(top('flow-medium'), lessThan(top('sleep-good')));
      expect(top('sleep-good'), lessThan(top('libido-low')));
      expect(top('libido-low'), lessThan(top('pain-mild')));
      expect(top('pain-mild'), lessThan(top('mood-calm')));
    });

    testWidgets('is one tap away on the home', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods(), tracked: {Tracked.libido});
      await harness.pumpApp();
      await tapVisible(tester, find.byKey(const ValueKey('quick-libido-high')));

      final entry = await harness.read(
        (store) => store.database.readDay(harness.today),
      );
      expect(entry?.libido, LibidoLevel.high);
      expect(find.byKey(const ValueKey('quick-mood-calm')), findsNothing);
    });

    testWidgets('pain and mood when she did not say', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();

      expect(find.byKey(const ValueKey('quick-pain-mild')), findsOneWidget);
      expect(find.byKey(const ValueKey('quick-mood-calm')), findsOneWidget);
      expect(find.byKey(const ValueKey('quick-sleep-good')), findsNothing);
    });
  });

  group('signs in the journal', () {
    const hotFlashes = ValueKey('symptom-hotFlashes');

    testWidgets('are offered to those who follow a changing cycle', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods(), goals: {Goal.perimenopause});
      await harness.pumpApp();
      await tapVisible(tester, find.byKey(const ValueKey('log-today')));
      await tapVisible(tester, find.byKey(hotFlashes));
      await tapVisible(tester, find.byKey(const ValueKey('day-done')));

      final entry = await harness.read(
        (store) => store.database.readDay(harness.today),
      );
      expect(entry?.symptoms, {Symptom.hotFlashes});
    });

    testWidgets('all six are there to tick', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods(), birthYear: 1980);
      await harness.pumpApp();
      await tapVisible(tester, find.byKey(const ValueKey('log-today')));

      for (final name in [
        'hotFlashes',
        'nightSweats',
        'vaginalDryness',
        'jointPain',
        'brainFog',
        'palpitations',
      ]) {
        expect(find.byKey(ValueKey('symptom-$name')), findsOneWidget);
      }
    });

    testWidgets('and not to the others', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();
      await tapVisible(tester, find.byKey(const ValueKey('log-today')));

      expect(find.byKey(const ValueKey('symptom-cramps')), findsOneWidget);
      expect(find.byKey(hotFlashes), findsNothing);
    });
  });
}
