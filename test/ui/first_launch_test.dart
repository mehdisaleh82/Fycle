import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/data/file_gateway.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/flow_intensity.dart';
import 'package:fycle/domain/life_stage.dart';
import 'package:fycle/domain/pain_level.dart';
import 'package:fycle/domain/start_profile.dart';
import 'package:fycle/domain/symptom.dart';
import 'package:material_ui/material_ui.dart';

import '../data/fakes.dart';
import 'harness.dart';

void main() {
  const next = ValueKey('onboarding-next');
  const skip = ValueKey('onboarding-step-skip');
  const finish = ValueKey('onboarding-finish');

  Future<void> tap(WidgetTester tester, Key key) =>
      tapVisible(tester, find.byKey(key));

  Future<void> to(WidgetTester tester, String title) => setupTo(tester, title);

  testWidgets('first launch welcomes, and shows the notice', (tester) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    expect(find.text('Welcome to Fycle'), findsOneWidget);
    expect(find.text('See your cycle clearly.'), findsOneWidget);
    expect(find.text("Let's go"), findsOneWidget);
    expect(find.text('Skip the setup'), findsOneWidget);
    expect(find.textContaining('not contraception'), findsOneWidget);
  });

  testWidgets('first launch is shown in French', (tester) async {
    final harness = Harness(tester);
    await harness.pumpApp(locale: 'fr');

    expect(find.text('Bienvenue dans Fycle'), findsOneWidget);
    expect(find.text("C'est parti"), findsOneWidget);
    expect(find.textContaining('ni contraception'), findsOneWidget);
    await tap(tester, next);
    expect(find.text('Tes données restent sur ton téléphone'), findsOneWidget);
    await tap(tester, next);
    expect(find.text('Quel est ton prénom ?'), findsOneWidget);
  });

  testWidgets('the setup asks one thing per screen, and keeps the answers', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await tap(tester, next);
    expect(find.text('Your data stays on your phone'), findsOneWidget);
    await tap(tester, next);
    await tester.enterText(find.byKey(const ValueKey('first-name')), 'Lina');
    await tap(tester, next);

    // A year is an answer only once the wheel was turned: ten years back
    // from the one in the middle.
    expect(find.text('What year were you born?'), findsOneWidget);
    expect(find.text('Welcome, Lina.'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byKey(next)).onPressed, isNull);
    await tester.drag(
      find.byKey(const ValueKey('birth-year-wheel')),
      const Offset(0, 56.0 * 10),
    );
    await tester.pumpAndSettle();
    await tap(tester, next);

    await tap(tester, const ValueKey('profile-tracking'));
    await tap(tester, next);
    await tap(tester, const ValueKey('wish-knowWhen'));
    await tap(tester, next);

    // One answer leads straight to the next question.
    await tap(tester, const ValueKey('regularity-regular'));
    expect(find.text('Your cycle and your period, in days'), findsOneWidget);
    expect(find.text('Not given'), findsNWidgets(2));
    // The cycle starts from the reference for her age: 28 days at 40.
    await tap(tester, const ValueKey('cycle-length-plus'));
    expect(find.text('28 days'), findsOneWidget);
    await tap(tester, const ValueKey('cycle-length-plus'));
    await tap(tester, const ValueKey('period-length-plus'));
    await tap(tester, const ValueKey('period-length-minus'));
    expect(find.text('29 days'), findsOneWidget);
    expect(find.text('4 days'), findsOneWidget);
    await tap(tester, next);

    await tap(tester, const ValueKey('usual-flow-heavy'));
    await tap(tester, const ValueKey('usual-pain-moderate'));
    await tap(tester, next);
    expect(find.text('Before your period, you often get…'), findsOneWidget);
    await tap(tester, const ValueKey('before-cravings'));
    await tap(tester, const ValueKey('before-bloating'));
    await tap(tester, next);
    await tap(tester, const ValueKey('contraception-none'));

    // At 40, the question about recent changes is asked.
    await tap(tester, const ValueKey('change-lessRegular'));
    await tap(tester, next);
    await tap(tester, const ValueKey('sign-hotFlashes'));
    await tap(tester, next);

    await tap(tester, const ValueKey('pick-2026-03-01'));
    expect(find.text('Sunday, March 1, 2026'), findsOneWidget);
    // 1 March + 29 days, 5 days on each side: a range, never a single date.
    expect(
      find.text('Next period expected between Mar 25 and Apr 4'),
      findsOneWidget,
    );
    // Nothing is saved before the end.
    expect(await harness.read((store) => store.database.readDays()), isEmpty);
    await tap(tester, next);

    // An earlier period, 28 days before: the estimate is hers already.
    expect(find.text('And the periods before?'), findsOneWidget);
    await tap(tester, const ValueKey('pick-2026-02-01'));
    expect(
      find.text('Next period expected between Mar 25 and Apr 2'),
      findsOneWidget,
    );
    await tap(tester, next);
    await tap(tester, const ValueKey('tracked-sleep'));
    await tap(tester, const ValueKey('tracked-libido'));
    await tap(tester, next);

    expect(find.text('Do you want reminders?'), findsOneWidget);
    await tap(tester, next);
    expect(find.text('For your eyes only'), findsOneWidget);
    await tap(tester, next);
    expect(find.text('All set, Lina'), findsOneWidget);
    expect(find.text('Your settings'), findsOneWidget);
    expect(find.text('A 28-day cycle, from your dates.'), findsOneWidget);
    expect(find.text('Your journal: Sleep, Libido.'), findsOneWidget);
    expect(find.text('Reminders on.'), findsOneWidget);
    await tap(tester, finish);

    expect(
      find.text('Period expected between Mar 25 and Apr 2'),
      findsOneWidget,
    );
    // The home offers in one tap what she said she follows.
    expect(find.byKey(const ValueKey('quick-sleep-good')), findsOneWidget);
    expect(find.byKey(const ValueKey('quick-libido-high')), findsOneWidget);
    expect(find.byKey(const ValueKey('quick-pain-mild')), findsNothing);
    final stored = await harness.read((store) {
      final database = store.database;
      return (
        database.flowByDay(),
        database.firstName,
        database.birthYear,
        database.goals,
        database.regularity,
        database.usualCycleLength,
        database.usualPeriodLength,
        database.recentChanges,
        database.fertilityEstimateEnabled,
        database.reminderSettings,
      );
    });
    // Each period, for as long as she says hers last, with the flow she
    // calls usual.
    expect(stored.$1, {
      for (final month in [2, 3])
        for (var day = 1; day <= stored.$7!; day++)
          CalendarDay(2026, month, day): FlowIntensity.heavy,
    });
    expect(stored.$2, 'Lina');
    expect(stored.$3, 1986);
    expect(stored.$4, {Goal.trackPeriods});
    expect(stored.$5, CycleRegularity.regular);
    expect(stored.$6, 29);
    expect(stored.$7, 4);
    expect(stored.$8, {RecentChange.lessRegular});
    // Only the dates of her periods were asked for: a plainer home.
    expect(stored.$9, isFalse);
    expect(stored.$10.periodEnabled, isTrue);
    expect(stored.$10.dailyEnabled, isTrue);
    expect(harness.reminders.permissionRequests, 1);
    final more = await harness.read((store) {
      final database = store.database;
      return (
        database.wishes,
        database.contraception,
        database.tracked,
        database.usualFlow,
        database.usualPain,
        database.startSigns,
      );
    });
    expect(more.$1, {Wish.knowWhen});
    expect(more.$2, Contraception.none);
    expect(more.$3, {Tracked.sleep, Tracked.libido});
    expect(more.$4, FlowIntensity.heavy);
    expect(more.$5, PainLevel.moderate);
    expect(more.$6, {Symptom.hotFlashes});
    expect(await harness.read((store) => store.database.signsBeforePeriod), {
      Symptom.cravings,
      Symptom.bloating,
    });
  });

  testWidgets('cycles she calls irregular start from a wider range', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await to(tester, 'Are your periods regular?');
    await tap(tester, const ValueKey('regularity-irregular'));
    await to(tester, 'When did your last period start?');
    await tap(tester, ValueKey('pick-${harness.today}'));

    // 20 March + 28 days, 10 days on each side.
    expect(
      find.text('Next period expected between Apr 7 and Apr 27'),
      findsOneWidget,
    );
  });

  testWidgets('without periods, neither lengths nor a date are asked', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await to(tester, 'Are your periods regular?');
    await tap(tester, const ValueKey('regularity-noPeriods'));

    expect(find.text('Do you use contraception?'), findsOneWidget);
    await to(tester, 'What do you want to log each day?');
    await tap(tester, next);
    expect(find.text('Do you want reminders?'), findsOneWidget);
  });

  testWidgets('the perimenopause brings the question about changes', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await to(tester, 'Where are you at?');
    await tap(tester, const ValueKey('profile-perimenopause'));
    // Passing a question forgets its answer: answers are confirmed.
    await tap(tester, next);
    await to(tester, 'Have your periods changed lately?');

    expect(find.text('Have your periods changed lately?'), findsOneWidget);
    // "Nothing" and a change do not go together.
    await tap(tester, const ValueKey('change-heavierFlow'));
    await tap(tester, const ValueKey('change-nothing'));
    await tap(tester, next);
    expect(
      find.text('Do you get these signs during your cycle?'),
      findsOneWidget,
    );
    await tap(tester, const ValueKey('sign-nightSweats'));
    await tap(tester, next);
    await to(tester, 'All set');
    expect(
      find.text('A review of changes from cycle to cycle.'),
      findsOneWidget,
    );
    await tap(tester, finish);

    final stored = await harness.read(
      (store) => (
        store.database.goals,
        store.database.recentChanges,
        store.database.startSigns,
      ),
    );
    expect(stored.$1, {Goal.perimenopause});
    expect(stored.$2, {RecentChange.nothing});
    expect(stored.$3, {Symptom.nightSweats});
  });

  testWidgets('without that goal and before 40, it is not asked', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await to(tester, 'Do you use contraception?');
    await tap(tester, skip);

    expect(find.text('When did your last period start?'), findsOneWidget);
  });

  testWidgets('wanting to conceive shows what the estimate is not', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await to(tester, 'Where are you at?');
    expect(find.byKey(const ValueKey('goal-conceive-warning')), findsNothing);
    await tap(tester, const ValueKey('profile-conceiving'));
    expect(
      find.textContaining('not a method of contraception'),
      findsOneWidget,
    );
    await tap(tester, next);
    await to(tester, 'All set');
    await tap(tester, finish);

    expect(
      await harness.read((store) => store.database.fertilityEstimateEnabled),
      isTrue,
    );
  });

  testWidgets('wanting to understand her body does not show it', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await to(tester, 'Where are you at?');
    await tap(tester, const ValueKey('profile-discovering'));
    await tap(tester, next);
    await to(tester, 'All set');
    expect(find.text('Fertile window hidden.'), findsOneWidget);
    await tap(tester, finish);

    expect(
      await harness.read((store) => store.database.fertilityEstimateEnabled),
      isFalse,
    );
  });

  testWidgets('an app set up before is aligned with her answers, once', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(
      days: periodFrom(CalendarDay(2026, 3, 1)),
      goals: {Goal.trackPeriods, Goal.understandBody},
    );
    // The estimate is on, as an earlier version left it.
    expect(
      await harness.read((store) => store.database.fertilityEstimateEnabled),
      isTrue,
    );
    await harness.pumpApp();
    expect(
      await harness.read((store) => store.database.fertilityEstimateEnabled),
      isFalse,
    );

    // What she turns on by hand afterwards stays on.
    await harness.read(
      (store) => store.database.fertilityEstimateEnabled = true,
    );
    await harness.pumpApp();
    expect(
      await harness.read((store) => store.database.fertilityEstimateEnabled),
      isTrue,
    );
  });

  testWidgets('without any answer, nothing is changed at launch', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: periodFrom(CalendarDay(2026, 3, 1)));
    await harness.pumpApp();

    expect(
      await harness.read((store) => store.database.fertilityEstimateEnabled),
      isTrue,
    );
  });

  testWidgets('reminders she passes stay off, and are not turned on behind', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await to(tester, 'All set');
    expect(find.text('Reminders off.'), findsOneWidget);
    await tap(tester, finish);
    // The next launch does not decide for her either.
    await harness.pumpApp();

    final reminders = await harness.read(
      (store) => store.database.reminderSettings,
    );
    expect(reminders.periodEnabled, isFalse);
    expect(reminders.dailyEnabled, isFalse);
    expect(harness.reminders.permissionRequests, 0);
  });

  testWidgets('the reminders she chooses are the ones turned on', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await to(tester, 'Do you want reminders?');
    await tap(tester, const ValueKey('setup-daily-reminder'));
    await tap(tester, const ValueKey('setup-days-before-3'));
    await tap(tester, next);

    final reminders = await harness.read(
      (store) => store.database.reminderSettings,
    );
    expect(reminders.periodEnabled, isTrue);
    expect(reminders.periodDaysBefore, 3);
    expect(reminders.dailyEnabled, isFalse);
  });

  testWidgets('notifications refused: no reminder, and she is told', (
    tester,
  ) async {
    final harness = Harness(tester)..reminders.allow = false;
    await harness.pumpApp();

    await to(tester, 'Do you want reminders?');
    await tap(tester, next);

    expect(find.text('Notifications are turned off'), findsOneWidget);
    await tapVisible(tester, find.text('OK'));
    expect(find.text('For your eyes only'), findsOneWidget);
    final reminders = await harness.read(
      (store) => store.database.reminderSettings,
    );
    expect(reminders.periodEnabled, isFalse);
    expect(reminders.dailyEnabled, isFalse);
  });

  testWidgets('the lock can be turned on from the setup', (tester) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await to(tester, 'For your eyes only');
    await tap(tester, const ValueKey('setup-lock'));

    expect(harness.deviceAuth.prompts, hasLength(1));
    expect(
      await harness.read((store) => store.database.appLockEnabled),
      isTrue,
    );
  });

  testWidgets('going back keeps what was answered', (tester) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await to(tester, 'What is your first name?');
    await tester.enterText(find.byKey(const ValueKey('first-name')), 'Lina');
    await tap(tester, next);
    await tap(tester, const ValueKey('onboarding-back'));

    expect(find.text('Lina'), findsOneWidget);
  });

  testWidgets('the length she gave says how long her period may last', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await to(tester, 'Your cycle and your period, in days');
    await tap(tester, const ValueKey('period-length-plus'));
    await tap(tester, next);
    await to(tester, 'When did your last period start?');
    await tap(tester, ValueKey('pick-${harness.today}'));
    await tap(tester, next);
    await to(tester, 'All set');
    await tap(tester, finish);

    expect(
      find.text('About 4 more days, going by what you said'),
      findsOneWidget,
    );
  });

  testWidgets('a past period is stored for as long as she says it lasts', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await to(tester, 'Your cycle and your period, in days');
    // The first touch gives the usual length, the second one day fewer.
    await tap(tester, const ValueKey('period-length-plus'));
    await tap(tester, const ValueKey('period-length-minus'));
    final length = int.parse(
      tester
          .widget<Text>(find.byKey(const ValueKey('period-length-value')))
          .data!
          .split(' ')
          .first,
    );
    await tap(tester, next);
    await to(tester, 'When did your last period start?');
    final start = harness.today.addDays(-10);
    await tap(tester, ValueKey('pick-$start'));
    await tap(tester, next);
    await to(tester, 'All set');
    await tap(tester, finish);

    final flow = await harness.read((store) => store.database.flowByDay());
    expect(flow.keys.toSet(), {
      for (var i = 0; i < length; i++) start.addDays(i),
    });
  });

  testWidgets('a period that started today is not stored into the future', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await to(tester, 'Your cycle and your period, in days');
    await tap(tester, const ValueKey('period-length-plus'));
    await tap(tester, next);
    await to(tester, 'When did your last period start?');
    await tap(tester, ValueKey('pick-${harness.today.addDays(-1)}'));
    await tap(tester, next);
    await to(tester, 'All set');
    await tap(tester, finish);

    final flow = await harness.read((store) => store.database.flowByDay());
    expect(flow.keys.toSet(), {harness.today.addDays(-1), harness.today});
  });

  testWidgets('several profiles can be chosen together', (tester) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await to(tester, 'Where are you at?');
    await tap(tester, const ValueKey('profile-tracking'));
    await tap(tester, const ValueKey('profile-conceiving'));
    await tap(tester, const ValueKey('profile-perimenopause'));
    await tap(tester, next);
    await to(tester, 'All set');
    await tap(tester, finish);

    expect(
      await harness.read((store) => store.database.profile),
      Profile.perimenopause,
    );
    expect(await harness.read((store) => store.database.goals), {
      Goal.trackPeriods,
      Goal.conceive,
      Goal.perimenopause,
    });
  });

  testWidgets('her answers can be changed from the settings', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: periodFrom(CalendarDay(2026, 3, 1)));
    await harness.pumpApp();

    await tapVisible(tester, find.byIcon(Icons.settings_outlined));
    await tap(tester, const ValueKey('edit-answers'));
    await tester.enterText(find.byKey(const ValueKey('first-name')), 'Maya');
    await tap(tester, next);
    await tap(tester, skip);
    await tap(tester, const ValueKey('profile-conceiving'));
    await tap(tester, next);
    await to(tester, 'Are your periods regular?');
    await tap(tester, const ValueKey('regularity-irregular'));
    await to(tester, 'Do you use contraception?');
    await tap(tester, const ValueKey('contraception-hormonal'));
    await to(tester, 'What do you want to log each day?');
    await tap(tester, const ValueKey('tracked-mood'));
    // The last question: the button saves.
    await tapVisible(tester, find.text('Save'));

    expect(find.byKey(const ValueKey('edit-answers')), findsOneWidget);
    final stored = await harness.read((store) {
      final database = store.database;
      return (
        database.firstName,
        database.goals,
        database.regularity,
        database.birthYear,
        database.readDays().length,
      );
    });
    expect(stored.$1, 'Maya');
    expect(stored.$2, {Goal.conceive});
    expect(stored.$3, CycleRegularity.irregular);
    expect(stored.$4, isNull);
    // Nothing she logged is touched.
    expect(stored.$5, greaterThan(0));
    // A hormonal contraception hides the ovulation estimate, whatever
    // the goal.
    expect(
      await harness.read((store) => store.database.fertilityEstimateEnabled),
      isFalse,
    );
  });

  testWidgets('the app can be entered without the setup, once and for all', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.pumpApp();

    await tester.tap(find.byKey(const ValueKey('onboarding-skip')));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Fycle'), findsNothing);
    expect(find.text('No estimate yet'), findsOneWidget);
    expect(find.text('Log today'), findsOneWidget);
    final days = await harness.read((store) => store.database.readDays());
    expect(days, isEmpty);

    // The setup is not shown again at the next launch.
    await harness.pumpApp();
    expect(find.text('Welcome to Fycle'), findsNothing);
    expect(find.text('No estimate yet'), findsOneWidget);
  });

  testWidgets('the home screen comes straight up once data exists', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: periodFrom(CalendarDay(2026, 3, 1)));
    await harness.pumpApp();

    expect(find.text('Welcome to Fycle'), findsNothing);
    expect(find.text('Log today'), findsOneWidget);
  });

  group('database whose key is gone', () {
    Future<Harness> unreadable(WidgetTester tester) async {
      final harness = Harness(tester);
      await harness.seed(days: periodFrom(CalendarDay(2026, 3, 1)));
      harness.keyStore.key = null; // As after restoring the phone.
      await harness.pumpApp();
      return harness;
    }

    testWidgets('is explained, with two ways out', (tester) async {
      await unreadable(tester);

      expect(find.text('Your data cannot be read'), findsOneWidget);
      expect(find.text('Start fresh'), findsOneWidget);
      expect(find.text('Restore from a backup file'), findsOneWidget);
    });

    testWidgets('nothing is erased without a confirmation', (tester) async {
      final harness = await unreadable(tester);

      await tester.tap(find.text('Start fresh'));
      await tester.pumpAndSettle();
      expect(find.text('Erase the unreadable data?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Your data cannot be read'), findsOneWidget);
      expect(harness.dir.listSync(), isNotEmpty);
    });

    testWidgets('starting fresh leads to the first-launch screen', (
      tester,
    ) async {
      await unreadable(tester);

      await tester.tap(find.text('Start fresh'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Erase'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome to Fycle'), findsOneWidget);
    });

    testWidgets('a backup file can be restored instead', (tester) async {
      final harness = await unreadable(tester);
      final backup = await tester.runAsync(
        () => fastCodec.encode(sampleData(), 'made-up password'),
      );
      harness.files.nextPick = PickedFile(name: 'old.fycle', bytes: backup!);

      await tester.tap(find.text('Restore from a backup file'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Erase'));
      await tester.pumpAndSettle();
      await tester.enterText(dialogField(), 'made-up password');
      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();

      expect(find.text('Log today'), findsOneWidget);
      final length = await harness.read(
        (store) => store.database.usualCycleLength,
      );
      expect(length, 29);
    });
  });
}
