import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/cycle_history.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/mood.dart';
import 'package:fycle/domain/period_predictor.dart';
import 'package:fycle/domain/period_starts.dart';
import 'package:fycle/domain/widget_snapshot.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Three made-up periods, 28 days apart. Seen from 20 March 2026, the next
/// one is expected between 25 and 31 March.
List<DayEntry> threePeriods() => [
  ...periodFrom(CalendarDay(2026, 1, 3)),
  ...periodFrom(CalendarDay(2026, 1, 31)),
  ...periodFrom(CalendarDay(2026, 2, 28)),
];

WidgetSnapshot? snapshot(List<DayEntry> days, CalendarDay today) {
  final flow = {
    for (final entry in days)
      if (entry.flow != null) entry.day: entry.flow!,
  };
  return widgetSnapshotOn(
    today,
    cycles: cycleHistory(flow),
    flowByDay: flow,
    prediction: const PeriodPredictor().predict(
      periodStarts: periodStartsFrom(flow),
    ),
  );
}

void main() {
  group('widgetSnapshotOn', () {
    test('gives the start of the cycle, its lengths and the expected '
        'range', () {
      expect(
        snapshot(threePeriods(), CalendarDay(2026, 3, 20)),
        WidgetSnapshot(
          cycleStart: CalendarDay(2026, 2, 28),
          cycleLength: 28,
          periodLength: 4,
          nextEarliest: CalendarDay(2026, 3, 25),
          nextLatest: CalendarDay(2026, 3, 31),
        ),
      );
    });

    test('there is nothing to show before a period is logged', () {
      expect(snapshot(const [], CalendarDay(2026, 3, 20)), isNull);
    });

    test('nor for a log left aside for months', () {
      expect(snapshot(threePeriods(), CalendarDay(2026, 11, 19)), isNull);
    });

    test('it stays the same from one day to the next: the widget counts', () {
      expect(
        snapshot(threePeriods(), CalendarDay(2026, 3, 21)),
        snapshot(threePeriods(), CalendarDay(2026, 3, 20)),
      );
    });
  });

  group('in the app', () {
    testWidgets('the widget is given what to show as the app opens', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();

      expect(harness.widgets.current?.cycleStart, CalendarDay(2026, 2, 28));
      expect(harness.widgets.current?.nextEarliest, CalendarDay(2026, 3, 25));
    });

    testWidgets('it follows what is logged', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();

      // A period logged today starts a new cycle.
      await openJournal(tester);
      await tapVisible(tester, find.byKey(const ValueKey('quick-flow-medium')));
      expect(harness.widgets.current?.cycleStart, harness.today);
    });

    testWidgets('an entry that changes nothing for it is not handed again', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();
      final handed = harness.widgets.handed.length;

      await openJournal(tester);
      await tapVisible(tester, find.byKey(const ValueKey('quick-mood-calm')));
      expect(harness.widgets.handed, hasLength(handed));
    });

    testWidgets('nothing private goes to it: dates and lengths only', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(
        days: [
          ...threePeriods(),
          DayEntry(
            day: CalendarDay(2026, 3, 18),
            mood: Mood.sad,
            note: 'Made-up note',
          ),
        ],
      );
      await harness.pumpApp();

      expect('${harness.widgets.current}', isNot(contains('Made-up')));
      expect('${harness.widgets.current}', isNot(contains('sad')));
    });

    testWidgets('with nothing logged, it is given nothing', (tester) async {
      final harness = Harness(tester);
      await harness.pumpApp();
      await tapVisible(tester, find.byKey(const ValueKey('onboarding-skip')));

      expect(harness.widgets.current, isNull);
    });

    testWidgets('it can be turned off, which empties it', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp(locale: 'fr');
      expect(harness.widgets.current, isNotNull);

      await tapVisible(tester, find.byIcon(Icons.settings_outlined));
      expect(find.text("Widget d'écran d'accueil"), findsOneWidget);
      await tapVisible(tester, find.byKey(const ValueKey('widget-enabled')));

      expect(harness.widgets.current, isNull);
      expect(
        await harness.read((store) => store.database.widgetEnabled),
        isFalse,
      );

      // It stays off, and empty, at the next launch.
      await harness.pumpApp();
      expect(harness.widgets.current, isNull);

      // Turned back on, it is filled again.
      await tapVisible(tester, find.byIcon(Icons.settings_outlined));
      await tapVisible(tester, find.byKey(const ValueKey('widget-enabled')));
      expect(harness.widgets.current, isNotNull);
    });

    testWidgets('deleting everything empties it', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();
      expect(harness.widgets.current, isNotNull);

      await tapVisible(tester, find.byIcon(Icons.settings_outlined));
      await tapVisible(tester, find.text('Delete everything'));
      await tapVisible(tester, find.text('Delete everything').last);

      expect(harness.widgets.current, isNull);
      expect(
        (await harness.read((store) => store.database.flowByDay())),
        <CalendarDay, FlowIntensity>{},
      );
    });
  });
}
