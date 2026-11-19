import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/sleep_quality.dart';
import 'package:fycle/domain/symptom.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Made-up log: periods on 3 January, 31 January and 28 February 2026 (two
/// complete cycles of 28 days), cramps on the second day of each period,
/// poor sleep a few days before the second and third periods, and fatigue
/// on three days of the second cycle.
List<DayEntry> logWithSigns() {
  final starts = [
    CalendarDay(2026, 1, 3),
    CalendarDay(2026, 1, 31),
    CalendarDay(2026, 2, 28),
  ];
  return [
    for (final start in starts) ...[
      DayEntry(day: start, flow: FlowIntensity.medium),
      DayEntry(
        day: start.addDays(1),
        flow: FlowIntensity.medium,
        symptoms: {Symptom.cramps},
      ),
      DayEntry(day: start.addDays(2), flow: FlowIntensity.light),
      DayEntry(day: start.addDays(3), flow: FlowIntensity.light),
    ],
    DayEntry(day: CalendarDay(2026, 1, 28), sleep: SleepQuality.poor),
    DayEntry(day: CalendarDay(2026, 2, 25), sleep: SleepQuality.poor),
    for (final day in [10, 11, 12])
      DayEntry(day: CalendarDay(2026, 2, day), symptoms: {Symptom.fatigue}),
  ];
}

Future<void> openInsights(WidgetTester tester) =>
    tapVisible(tester, find.byIcon(Icons.insights_outlined));

void main() {
  group('trends screen', () {
    testWidgets('with one period only, says what is still missing', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
      await harness.pumpApp();
      await openInsights(tester);

      expect(find.text('This cycle'), findsOneWidget);
      expect(find.byKey(const ValueKey('average-cycle')), findsNothing);
      expect(find.text('Average period: 4 days'), findsOneWidget);
      expect(
        find.text('Averages appear once a second period is logged.'),
        findsOneWidget,
      );
      expect(find.textContaining('Nothing to show yet'), findsOneWidget);
      expect(find.text('In progress since Feb 28, 2026'), findsOneWidget);
    });

    testWidgets('shows the averages, what comes back and the history', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: logWithSigns());
      await harness.pumpApp();
      await openInsights(tester);

      expect(find.text('Average cycle: 28 days'), findsOneWidget);
      expect(find.text('Average period: 4 days'), findsOneWidget);
      expect(
        find.text('Counted on your last 2 complete cycles.'),
        findsOneWidget,
      );

      expect(find.text('Cramps'), findsOneWidget);
      expect(
        find.text('During your period, in 2 of your last 2 cycles'),
        findsOneWidget,
      );
      expect(find.text('Sleep: Poor'), findsOneWidget);
      expect(
        find.text('In the week before your period, in 2 of your last 2 cycles'),
        findsOneWidget,
      );
      // Logged in one cycle only: not a trend.
      expect(find.byKey(const ValueKey('trend-fatigue')), findsNothing);
      expect(find.textContaining('not a medical interpretation'), findsOne);

      await tester.scrollUntilVisible(
        find.text('Jan 3, 2026 – Jan 30, 2026'),
        200,
      );
      expect(find.text('Jan 31, 2026 – Feb 27, 2026'), findsOneWidget);
      expect(find.text('28 days · period of 4 days'), findsNWidgets(2));
    });

    testWidgets('is shown in French', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: logWithSigns());
      await harness.pumpApp(locale: 'fr');
      await openInsights(tester);

      expect(find.text('Ce cycle'), findsWidgets);
      expect(find.text('Cycle moyen : 28 jours'), findsOneWidget);
      expect(find.text('Crampes'), findsOneWidget);
      expect(
        find.text('Pendant les règles, dans 2 de vos 2 derniers cycles'),
        findsOneWidget,
      );
      expect(find.text('Sommeil : Mauvais'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('En cours depuis le 28 févr. 2026'),
        200,
      );
      expect(find.text('28 jours · règles de 4 jours'), findsNWidgets(2));
      expect(find.text('En cours depuis le 28 févr. 2026'), findsOneWidget);
    });

    testWidgets('a cycle hiding a missed period is listed, and marked', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(
        days: [
          ...periodFrom(CalendarDay(2025, 9, 1)),
          ...periodFrom(CalendarDay(2026, 1, 3)),
          ...periodFrom(CalendarDay(2026, 1, 31)),
          ...periodFrom(CalendarDay(2026, 2, 28)),
        ],
      );
      await harness.pumpApp();
      await openInsights(tester);

      expect(find.text('Average cycle: 28 days'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Unusual length, left out of the averages.'),
        200,
      );
    });
  });

  group('end-of-cycle summary', () {
    testWidgets('appears when a new period starts, with plain facts', (
      tester,
    ) async {
      final harness = Harness(tester, today: CalendarDay(2026, 3, 2));
      await harness.seed(days: logWithSigns());
      await harness.pumpApp();

      expect(find.text('Your last cycle'), findsOneWidget);
      expect(find.text('It lasted 28 days.'), findsOneWidget);
      expect(find.text('The same as your cycles before.'), findsOneWidget);
      expect(find.text('Logged most: Fatigue, Cramps.'), findsOneWidget);
    });

    testWidgets('says how the length differs, in French', (tester) async {
      final harness = Harness(tester, today: CalendarDay(2026, 3, 5));
      await harness.seed(
        days: [
          ...periodFrom(CalendarDay(2026, 1, 3)),
          ...periodFrom(CalendarDay(2026, 1, 31)),
          ...periodFrom(CalendarDay(2026, 3, 3)),
        ],
      );
      await harness.pumpApp(locale: 'fr');

      expect(find.text('Votre dernier cycle'), findsOneWidget);
      expect(find.text('Il a duré 31 jours.'), findsOneWidget);
      expect(
        find.text('3 jours de plus que vos cycles précédents.'),
        findsOneWidget,
      );
      expect(find.textContaining('Le plus noté'), findsNothing);
    });

    testWidgets('once closed, it does not come back', (tester) async {
      final harness = Harness(tester, today: CalendarDay(2026, 3, 2));
      await harness.seed(days: logWithSigns());
      await harness.pumpApp();

      await tapVisible(tester, find.byTooltip('Close'));
      expect(find.text('Your last cycle'), findsNothing);

      // A new launch.
      await harness.pumpApp();
      expect(find.text('Your last cycle'), findsNothing);
    });

    testWidgets('leads to the trends', (tester) async {
      final harness = Harness(tester, today: CalendarDay(2026, 3, 2));
      await harness.seed(days: logWithSigns());
      await harness.pumpApp();

      await tapVisible(tester, find.text('See trends'));
      expect(find.text('What comes back'), findsOneWidget);
    });

    testWidgets('goes away by itself after a while', (tester) async {
      final harness = Harness(tester, today: CalendarDay(2026, 3, 20));
      await harness.seed(days: logWithSigns());
      await harness.pumpApp();
      expect(find.text('Your last cycle'), findsNothing);
    });

    testWidgets('there is none before a first cycle has ended', (tester) async {
      final harness = Harness(tester, today: CalendarDay(2026, 3, 1));
      await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
      await harness.pumpApp();
      expect(find.text('Your last cycle'), findsNothing);
    });
  });

  group('layout', () {
    for (final locale in ['en', 'fr']) {
      for (final scale in [1.0, 2.5]) {
        testWidgets(
          'trends and summary hold from right to left ($locale, × $scale)',
          (tester) async {
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );
            final harness = Harness(tester, today: CalendarDay(2026, 3, 2));
            if (scale > 1) {
              // A small phone.
              tester.view.physicalSize = const Size(320, 568);
            }
            await harness.seed(days: logWithSigns());
            await harness.pumpApp(
              locale: locale,
              textDirection: TextDirection.rtl,
            );
            expect(find.byIcon(Icons.close), findsOneWidget);

            await openInsights(tester);
            await tester.drag(
              find.byType(SingleChildScrollView).first,
              const Offset(0, -3000),
            );
            await tester.pumpAndSettle();
          },
        );
      }
    }

    testWidgets('the bar of a trend fills from the start of the line', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: logWithSigns());
      await harness.pumpApp(themeMode: ThemeMode.dark);
      await openInsights(tester);
      expect(find.byType(FractionallySizedBox), findsWidgets);
    });
  });
}
