import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/libido_level.dart';
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
  DayEntry(
    day: CalendarDay(2026, 3, 18),
    sleep: SleepQuality.good,
    libido: LibidoLevel.high,
  ),
  DayEntry(
    day: CalendarDay(2026, 3, 19),
    pain: PainLevel.mild,
    mood: Mood.calm,
  ),
];

void main() {
  String text(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(ValueKey(key))).data!;

  Finder key(String name) => find.byKey(ValueKey(name));

  group('the figures of the home', () {
    testWidgets('are few, each in its tile, with one large value', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: someTracking());
      await harness.pumpApp();
      await tester.ensureVisible(key('follow-card'));

      expect(text(tester, 'kpi-week'), '2');
      expect(text(tester, 'kpi-week-caption'), 'days logged');
      expect(text(tester, 'kpi-cycle'), '6');
      expect(text(tester, 'kpi-cycle-caption'), 'days logged out of 21');
      // The detail of the week is not on the home any more.
      expect(key('follow-row-journal'), findsNothing);
    });

    testWidgets('follow what she did not say: pain and mood', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: someTracking());
      await harness.pumpApp();

      expect(text(tester, 'kpi-pain-days'), '1');
      expect(text(tester, 'kpi-pain-days-caption'), 'previous cycle: 0');
      expect(text(tester, 'kpi-mood'), 'Calm');
      expect(key('kpi-good-nights'), findsNothing);
      expect(key('kpi-libido'), findsNothing);
    });

    testWidgets('follow what she chose: each woman has her own', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(
        days: someTracking(),
        tracked: {Tracked.sleep, Tracked.libido},
      );
      await harness.pumpApp();

      expect(text(tester, 'kpi-good-nights'), '1');
      expect(text(tester, 'kpi-libido'), 'High');
      expect(key('kpi-pain-days'), findsNothing);
      expect(key('kpi-mood'), findsNothing);
    });

    testWidgets('say what would raise the reliability of the estimate', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(days: someTracking());
      await harness.pumpApp();
      await tester.ensureVisible(key('reliability-next'));

      expect(text(tester, 'reliability-level'), 'Medium');
      expect(
        text(tester, 'reliability-next'),
        '2 more logged cycles before it can reach high.',
      );
    });

    testWidgets('before anything is logged, say where it starts', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.pumpApp();
      await tapVisible(tester, key('onboarding-skip'));
      await tester.ensureVisible(key('reliability-next'));

      expect(text(tester, 'kpi-week'), '0');
      expect(
        text(tester, 'reliability-next'),
        'Log the first day of a period to get an estimate.',
      );
      expect(key('reliability-level'), findsNothing);
      expect(key('kpi-cycle'), findsNothing);
    });

    testWidgets('no points, no praise, no reproach', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: someTracking());
      await harness.pumpApp();

      for (final word in ['Bravo', 'Well done', 'score', 'points', 'missed']) {
        expect(find.textContaining(word), findsNothing, reason: word);
      }
    });
  });

  group('the last seven days, in the journal', () {
    testWidgets('show a row for each thing she follows', (tester) async {
      final harness = Harness(tester);
      await harness.seed(
        days: someTracking(),
        tracked: {Tracked.sleep, Tracked.libido},
      );
      await harness.pumpApp(locale: 'fr');
      await openJournal(tester);
      await tester.ensureVisible(key('week-card'));

      expect(find.text('Tes 7 derniers jours'), findsOneWidget);
      expect(find.text('La journée'), findsOneWidget);
      expect(key('follow-row-sleep'), findsOneWidget);
      expect(key('follow-row-libido'), findsOneWidget);
      expect(key('follow-row-pain'), findsNothing);
      expect(
        tester.getSemantics(key('follow-row-sleep')).label,
        'Sommeil : 1 jour sur les 7 derniers',
      );
    });

    testWidgets('count the week and the month', (tester) async {
      final harness = Harness(tester);
      await harness.seed(days: someTracking());
      await harness.pumpApp();
      await openJournal(tester);
      await tester.ensureVisible(key('week-card'));

      expect(text(tester, 'follow-week'), '2 days logged out of the last 7');
      expect(
        text(tester, 'follow-month'),
        'This month: 5 days logged out of 20',
      );
    });
  });
}
