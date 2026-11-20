import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/day_entry.dart';
import 'package:fycle/domain/life_stage.dart';
import 'package:fycle/ui/prediction_card.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// Three periods, 28 days apart, the last one on 28 February 2026.
List<DayEntry> threePeriods() => [
  ...periodFrom(CalendarDay(2026, 1, 3)),
  ...periodFrom(CalendarDay(2026, 1, 31)),
  ...periodFrom(CalendarDay(2026, 2, 28)),
];

void main() {
  Finder key(String name) => find.byKey(ValueKey(name));
  Future<void> tap(WidgetTester tester, String name) =>
      tapVisible(tester, key(name));

  group('the setup, for a pregnancy', () {
    testWidgets('asks nothing about cycles, and counts the weeks', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.pumpApp();

      await setupTo(tester, 'Where are you at?');
      await tap(tester, 'profile-pregnant');
      await tap(tester, 'onboarding-next');

      // Straight to the date the weeks are counted from.
      expect(find.text('Are your periods regular?'), findsNothing);
      expect(find.text('When did your last period start?'), findsOneWidget);
      await tap(tester, 'key-date-pick');
      await tester.tap(find.text('1'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Sunday, March 1, 2026'), findsOneWidget);
      await tap(tester, 'onboarding-next');

      await setupTo(tester, 'All set');
      expect(find.text('Pregnancy mode: weeks counted.'), findsOneWidget);
      await tap(tester, 'onboarding-finish');

      expect(key('pregnancy-card'), findsOneWidget);
      expect(find.text('2 weeks and 5 days'), findsOneWidget);
      expect(
        find.text(
          'A birth at term is estimated between Nov 15, 2026 and Dec 20, '
          '2026.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('An estimate: only a dating scan gives a reliable date.'),
        findsOneWidget,
      );
      expect(find.byType(PredictionCard), findsNothing);

      final stored = await harness.read(
        (store) => (
          store.database.profile,
          store.database.pregnancyStart,
          store.database.fertilityEstimateEnabled,
        ),
      );
      expect(stored.$1, Profile.pregnant);
      expect(stored.$2, CalendarDay(2026, 3, 1));
      expect(stored.$3, isFalse);
    });
  });

  group('during a pregnancy', () {
    testWidgets('no period is estimated, whatever was logged before', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(
        days: threePeriods(),
        profile: Profile.pregnant,
        pregnancyStart: CalendarDay(2026, 2, 28),
      );
      await harness.pumpApp(locale: 'fr');

      expect(find.text('Ta grossesse'), findsOneWidget);
      expect(find.text('2 semaines et 6 jours'), findsOneWidget);
      expect(find.byType(PredictionCard), findsNothing);
      expect(find.textContaining('Règles dans'), findsNothing);
      // Nothing to say of a reliability while nothing is estimated.
      expect(key('reliability-next'), findsNothing);
      // The journal of the day is still there.
      expect(key('log-today'), findsOneWidget);
    });

    testWidgets('without a date, asks for it', (tester) async {
      final harness = Harness(tester);
      await harness.seed(profile: Profile.pregnant);
      await harness.pumpApp();
      await tapVisible(tester, key('onboarding-skip'));

      expect(
        find.text('Give the first day of your last period to count the weeks.'),
        findsOneWidget,
      );
      await tap(tester, 'pregnancy-date');
      await tester.tap(find.text('6'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('2 weeks and 0 days'), findsOneWidget);
    });

    testWidgets('leaving asks where she is now, and nothing else', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(
        days: threePeriods(),
        profile: Profile.pregnant,
        pregnancyStart: CalendarDay(2026, 2, 28),
      );
      await harness.pumpApp();

      await tap(tester, 'pregnancy-leave');
      expect(find.text('Where are you at now?'), findsOneWidget);
      await tap(tester, 'leave-gave-birth');
      // The day of the birth: today, as proposed.
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(key('pregnancy-card'), findsNothing);
      expect(key('postpartum-card'), findsOneWidget);
      expect(
        find.text('Less than a week since you gave birth'),
        findsOneWidget,
      );
      final stored = await harness.read(
        (store) => (store.database.profile, store.database.deliveryDate),
      );
      expect(stored.$1, Profile.postpartum);
      expect(stored.$2, harness.today);
    });

    testWidgets('or goes back to the cycle as it was', (tester) async {
      final harness = Harness(tester);
      await harness.seed(
        days: threePeriods(),
        profile: Profile.pregnant,
        pregnancyStart: CalendarDay(2026, 2, 28),
      );
      await harness.pumpApp();

      await tap(tester, 'pregnancy-leave');
      await tap(tester, 'leave-back-to-cycle');

      expect(key('pregnancy-card'), findsNothing);
      expect(find.byType(PredictionCard), findsOneWidget);
      expect(find.text('Period in 5 to 11 days'), findsOneWidget);
    });
  });

  group('after a birth', () {
    testWidgets('nothing is estimated before periods are back', (tester) async {
      final harness = Harness(tester);
      await harness.seed(
        days: threePeriods(),
        profile: Profile.postpartum,
        deliveryDate: CalendarDay(2026, 3, 6),
      );
      await harness.pumpApp();

      expect(key('postpartum-card'), findsOneWidget);
      expect(find.text('2 weeks since you gave birth'), findsOneWidget);
      expect(find.byType(PredictionCard), findsNothing);
    });

    testWidgets('the estimate starts again from the first period, wide', (
      tester,
    ) async {
      final harness = Harness(tester);
      await harness.seed(
        days: threePeriods(),
        profile: Profile.postpartum,
        deliveryDate: CalendarDay(2026, 3, 6),
      );
      await harness.pumpApp();

      await tap(tester, 'quick-flow-medium');

      expect(key('postpartum-card'), findsNothing);
      expect(find.byType(PredictionCard), findsOneWidget);
      // 20 March + 28 days, 10 days on each side: the cycles before the
      // pregnancy do not count.
      expect(find.textContaining('between Apr 7 and Apr 27'), findsOneWidget);
    });
  });
}
