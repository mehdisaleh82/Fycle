import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/libido_level.dart';
import 'package:fycle/domain/mood.dart';
import 'package:fycle/domain/pain_level.dart';
import 'package:fycle/domain/sleep_quality.dart';
import 'package:fycle/domain/symptom.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Three made-up periods, 28 days apart. Seen from 20 March 2026, the next
/// one is expected between 25 and 31 March.
List<DayEntry> threePeriods() => [
  ...periodFrom(CalendarDay(2026, 1, 3)),
  ...periodFrom(CalendarDay(2026, 1, 31)),
  ...periodFrom(CalendarDay(2026, 2, 28)),
];

void main() {
  testWidgets('the prediction is a range of dates, with its basis', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    expect(
      find.text('Period expected between Mar 25 and Mar 31'),
      findsOneWidget,
    );
    expect(find.text('This range starts in 5 days.'), findsOneWidget);
    expect(find.text('Estimate based on your last 2 cycles.'), findsOneWidget);
    expect(find.text('Confidence: medium'), findsOneWidget);
    expect(
      find.textContaining('not a method of contraception'),
      findsOneWidget,
    );
  });

  testWidgets('the prediction is shown in French', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp(locale: 'fr');

    expect(
      find.text('Règles prévues entre le 25 mars et le 31 mars'),
      findsOneWidget,
    );
    expect(find.text('Mars 2026'), findsOneWidget);
  });

  testWidgets('a period that has not come is reported without alarm', (
    tester,
  ) async {
    final harness = Harness(tester, today: CalendarDay(2026, 4, 5));
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    expect(
      find.text('Period expected between Mar 25 and Mar 31'),
      findsOneWidget,
    );
    expect(find.text('5 days past this range.'), findsOneWidget);
    expect(find.textContaining('only an estimate'), findsOneWidget);
  });

  testWidgets('a log left aside for months gives no day count', (tester) async {
    final harness = Harness(tester, today: CalendarDay(2026, 11, 19));
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    expect(find.text('No recent entry'), findsOneWidget);
    expect(find.textContaining('past this range'), findsNothing);
  });

  testWidgets('the calendar tells past and expected periods apart', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final harness = Harness(tester);
    await harness.seed(
      days: [
        ...threePeriods(),
        DayEntry(day: CalendarDay(2026, 3, 10), mood: Mood.calm),
      ],
    );
    await harness.pumpApp();

    expect(find.text('March 2026'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Sunday, March 1, period logged: Medium'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Wednesday, March 25, period expected, estimate'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Friday, March 20, today'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Tuesday, March 10, entry logged'),
      findsOneWidget,
    );
    expect(find.text('Expected period (estimate)'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    expect(find.text('February 2026'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Saturday, February 28, period logged: Medium'),
      findsOneWidget,
    );
    semantics.dispose();
  });

  testWidgets('logging today takes two gestures and updates the estimate', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    await tester.tap(find.text('Log today'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('flow-heavy')));
    await tester.pumpAndSettle();

    final entry = await harness.read(
      (store) => store.database.readDay(harness.today),
    );
    expect(entry?.flow, FlowIntensity.heavy);

    await tapVisible(tester, find.text('Done'));
    expect(find.text('Day 1 of your period'), findsOneWidget);
    expect(find.textContaining('Next period expected between'), findsOneWidget);
  });

  group('period of the day in one tap', () {
    /// Records the haptic feedback asked from the phone.
    List<Object?> recordHaptics(WidgetTester tester) {
      final haptics = <Object?>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add(call.arguments);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      return haptics;
    }

    bool chosen(WidgetTester tester, String key) =>
        tester.widget<ChoiceChip>(find.byKey(ValueKey(key))).selected;

    testWidgets('one tap logs it, with a tick, and updates the estimate', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();
      final haptics = recordHaptics(tester);

      expect(find.text('Period today'), findsOneWidget);
      await tapVisible(tester, find.byKey(const ValueKey('quick-flow-light')));

      final entry = await harness.read(
        (store) => store.database.readDay(harness.today),
      );
      expect(entry?.flow, FlowIntensity.light);
      expect(haptics, ['HapticFeedbackType.selectionClick']);
      expect(find.text('Day 1 of your period'), findsOneWidget);
      expect(chosen(tester, 'quick-flow-light'), isTrue);
    });

    testWidgets('a second tap takes it back', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();

      await tapVisible(tester, find.byKey(const ValueKey('quick-flow-heavy')));
      await tapVisible(tester, find.byKey(const ValueKey('quick-flow-heavy')));

      final entry = await harness.read(
        (store) => store.database.readDay(harness.today),
      );
      expect(entry, isNull);
      expect(
        find.text('Period expected between Mar 25 and Mar 31'),
        findsOneWidget,
      );
    });

    testWidgets('what else is logged for the day is kept', (tester) async {
      final harness = Harness(tester);
      await harness.seed(
        days: [
          ...threePeriods(),
          DayEntry(
            day: CalendarDay(2026, 3, 20),
            pain: PainLevel.mild,
            mood: Mood.calm,
            symptoms: {Symptom.fatigue},
            note: 'Made-up note',
          ),
        ],
      );
      await harness.pumpApp();

      await tapVisible(tester, find.byKey(const ValueKey('quick-flow-medium')));

      final entry = await harness.read(
        (store) => store.database.readDay(harness.today),
      );
      expect(
        entry,
        DayEntry(
          day: harness.today,
          flow: FlowIntensity.medium,
          pain: PainLevel.mild,
          mood: Mood.calm,
          symptoms: {Symptom.fatigue},
          note: 'Made-up note',
        ),
      );
    });

    testWidgets('the card follows what is chosen in the entry of the day', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: threePeriods());
      await harness.pumpApp();

      await tester.tap(find.text('Log today'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('flow-spotting')));
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Done'));

      expect(chosen(tester, 'quick-flow-spotting'), isTrue);
    });
  });

  group('days logged in a row', () {
    List<DayEntry> moodsBack(Iterable<int> offsets) => [
      for (final offset in offsets)
        DayEntry(
          day: CalendarDay(2026, 3, 20).addDays(-offset),
          mood: Mood.calm,
        ),
    ];

    testWidgets('are counted discreetly, from two days', (tester) async {
      final harness = Harness(tester);
      await harness.seed(
        days: [
          ...threePeriods(),
          ...moodsBack([1, 2, 3]),
        ],
      );
      await harness.pumpApp();

      // Today is not logged yet: the run is not broken.
      expect(find.text('Logged 3 days in a row'), findsOneWidget);

      await tapVisible(tester, find.byKey(const ValueKey('quick-flow-light')));
      expect(find.text('Logged 4 days in a row'), findsOneWidget);
    });

    testWidgets('are shown in French', (tester) async {
      final harness = Harness(tester);
      await harness.seed(
        days: [
          ...threePeriods(),
          ...moodsBack([0, 1]),
        ],
      );
      await harness.pumpApp(locale: 'fr');

      expect(find.text("Règles aujourd'hui"), findsOneWidget);
      expect(find.text('Saisie 2 jours de suite'), findsOneWidget);
    });

    testWidgets('nothing is said for a single day or after a gap', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(
        days: [
          ...threePeriods(),
          ...moodsBack([0, 2, 3]),
        ],
      );
      await harness.pumpApp();

      expect(find.byKey(const ValueKey('logging-streak')), findsNothing);
      expect(find.textContaining('in a row'), findsNothing);
    });
  });

  testWidgets('pain, mood, symptoms and a note are saved as they are set', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    await tester.tap(find.text('Log today'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Severe'));
    await tapVisible(tester, find.text('Calm'));
    await tapVisible(tester, find.text('Cramps'));
    await tapVisible(tester, find.text('Headache'));
    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'Made-up note');
    await tester.pumpAndSettle();

    final entry = await harness.read(
      (store) => store.database.readDay(harness.today),
    );
    expect(
      entry,
      DayEntry(
        day: harness.today,
        pain: PainLevel.severe,
        mood: Mood.calm,
        symptoms: {Symptom.cramps, Symptom.headache},
        note: 'Made-up note',
      ),
    );

    // Tapping a choice again takes it back.
    await tapVisible(tester, find.text('Calm'));
    final after = await harness.read(
      (store) => store.database.readDay(harness.today),
    );
    expect(after?.mood, isNull);
  });

  testWidgets('sleep and libido are saved as they are set', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    await tester.tap(find.text('Log today'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('sleep-poor')));
    await tapVisible(tester, find.byKey(const ValueKey('libido-high')));

    final entry = await harness.read(
      (store) => store.database.readDay(harness.today),
    );
    expect(
      entry,
      DayEntry(
        day: harness.today,
        sleep: SleepQuality.poor,
        libido: LibidoLevel.high,
      ),
    );

    // Tapping a choice again takes it back.
    await tapVisible(tester, find.byKey(const ValueKey('sleep-poor')));
    final after = await harness.read(
      (store) => store.database.readDay(harness.today),
    );
    expect(after?.sleep, isNull);
    expect(after?.libido, LibidoLevel.high);
  });

  testWidgets('a past day opens from the calendar, a day to come does not', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    await tapVisible(tester, find.byKey(const ValueKey('day-2026-03-27')));
    expect(find.text('Done'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('day-2026-03-02')));
    await tester.pumpAndSettle();
    expect(find.text('Monday, March 2, 2026'), findsOneWidget);
    // What was logged that day is shown.
    final chip = tester.widget<ChoiceChip>(
      find.byKey(const ValueKey('flow-medium')),
    );
    expect(chip.selected, isTrue);
  });
}
