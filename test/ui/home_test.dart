import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/mood.dart';
import 'package:fycle/domain/pain_level.dart';
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
    await tester.tap(find.text('Heavy'));
    await tester.pumpAndSettle();

    final entry = await harness.read(
      (store) => store.database.readDay(harness.today),
    );
    expect(entry?.flow, FlowIntensity.heavy);

    await tapVisible(tester, find.text('Done'));
    expect(find.text('Day 1 of your period'), findsOneWidget);
    expect(find.textContaining('Next period expected between'), findsOneWidget);
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

  testWidgets('a past day opens from the calendar, a day to come does not', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: threePeriods());
    await harness.pumpApp();

    await tester.tap(find.byKey(const ValueKey('day-2026-03-27')));
    await tester.pumpAndSettle();
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
