import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/mood.dart';
import 'package:fycle/domain/pain_level.dart';
import 'package:fycle/domain/sleep_quality.dart';
import 'package:fycle/domain/start_profile.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Three periods 28 days apart, the last one on 28 February 2026, and two
/// days logged this week. All made up.
List<DayEntry> someTracking() => [
  ...periodFrom(CalendarDay(2026, 1, 3)),
  ...periodFrom(CalendarDay(2026, 1, 31)),
  ...periodFrom(CalendarDay(2026, 2, 28)),
  DayEntry(day: CalendarDay(2026, 3, 18), sleep: SleepQuality.good),
  DayEntry(
    day: CalendarDay(2026, 3, 19),
    pain: PainLevel.mild,
    mood: Mood.calm,
  ),
];

void main() {
  String text(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(ValueKey(key))).data!;

  testWidgets('counts the week, the month and the cycle going on', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: someTracking());
    await harness.pumpApp();
    await tester.ensureVisible(find.byKey(const ValueKey('follow-card')));

    expect(text(tester, 'follow-week'), '2 days logged out of the last 7');
    expect(text(tester, 'follow-month'), 'This month: 5 days logged out of 20');
    expect(find.text('This cycle, day 21'), findsOneWidget);
    expect(text(tester, 'figure-logged'), '6 of 21');
    expect(text(tester, 'figure-good-nights'), '1');
    expect(text(tester, 'figure-pain-days'), '1');
    expect(text(tester, 'figure-mood'), 'Calm');
    expect(
      find.text('Previous cycle, at the same point: 4 of 21'),
      findsOneWidget,
    );
    // Nothing was logged about libido: no line for it.
    expect(find.byKey(const ValueKey('figure-libido')), findsNothing);
  });

  testWidgets('says what would raise the reliability of the estimate', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: someTracking());
    await harness.pumpApp();
    await tester.ensureVisible(find.byKey(const ValueKey('reliability-next')));

    expect(text(tester, 'reliability-level'), 'Medium');
    expect(
      text(tester, 'reliability-next'),
      '2 more logged cycles before it can reach high.',
    );
  });

  testWidgets('shows a row for each thing she follows', (tester) async {
    final harness = Harness(tester);
    await harness.seed(
      days: someTracking(),
      tracked: {Tracked.sleep, Tracked.libido},
    );
    await harness.pumpApp(locale: 'fr');

    expect(find.byKey(const ValueKey('follow-row-journal')), findsOneWidget);
    expect(find.byKey(const ValueKey('follow-row-sleep')), findsOneWidget);
    expect(find.byKey(const ValueKey('follow-row-libido')), findsOneWidget);
    expect(find.byKey(const ValueKey('follow-row-pain')), findsNothing);
    expect(
      tester.getSemantics(find.byKey(const ValueKey('follow-row-sleep'))).label,
      'Sommeil : 1 jour sur les 7 derniers',
    );
  });

  testWidgets('before anything is logged, says where it starts', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.pumpApp();
    await tapVisible(tester, find.byKey(const ValueKey('onboarding-skip')));
    await tester.ensureVisible(find.byKey(const ValueKey('reliability-next')));

    expect(text(tester, 'follow-week'), 'No day logged out of the last 7');
    expect(
      text(tester, 'reliability-next'),
      'Log the first day of a period to get an estimate.',
    );
    expect(find.byKey(const ValueKey('reliability-level')), findsNothing);
    expect(find.byKey(const ValueKey('figure-logged')), findsNothing);
  });

  testWidgets('no points, no praise, no reproach', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: someTracking());
    await harness.pumpApp();

    for (final word in ['Bravo', 'Well done', 'score', 'points', 'missed']) {
      expect(find.textContaining(word), findsNothing, reason: word);
    }
  });
}
