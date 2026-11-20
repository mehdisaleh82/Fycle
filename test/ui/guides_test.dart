import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/guide.dart';
import 'package:fycle/domain/life_stage.dart';
import 'package:fycle/l10n/app_localizations.dart';
import 'package:fycle/ui/guides_screen.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

void main() {
  Finder key(String name) => find.byKey(ValueKey(name));
  String textOf(WidgetTester tester, String name) =>
      tester.widget<Text>(key(name)).data!;

  testWidgets('a pregnancy puts the guide of its trimester forward', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(
      days: periodFrom(CalendarDay(2026, 1, 3)),
      profile: Profile.pregnant,
      // 20 March is in the 11th week.
      pregnancyStart: CalendarDay(2026, 1, 3),
    );
    await harness.pumpApp();

    expect(textOf(tester, 'guide-featured'), 'First trimester');
    await tapVisible(tester, key('guide-read'));

    expect(textOf(tester, 'guide-title'), 'First trimester');
    // Said on the page itself until a health professional has read it.
    expect(
      textOf(tester, 'guide-pending-review'),
      'Text awaiting review by a health professional.',
    );
    expect(key('guide-seek'), findsOneWidget);
    expect(textOf(tester, 'guide-sources'), contains('NHS'));
  });

  testWidgets('no guide is put forward when none is about her', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
    await harness.pumpApp();
    expect(key('guide-card'), findsNothing);
  });

  testWidgets('every guide is one tap away in the review, hers first', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(
      days: periodFrom(CalendarDay(2026, 1, 3)),
      profile: Profile.postpartum,
      deliveryDate: CalendarDay(2026, 2, 1),
    );
    await harness.pumpApp();

    await openReview(tester);
    await tapVisible(tester, key('open-guides'));

    // Her topic is at the top, intimacy next, the other one further down.
    expect(key('guide-topic-pregnancy'), findsOneWidget);
    expect(key('guide-topic-perimenopause'), findsNothing);
    await tester.scrollUntilVisible(
      key('guide-perimenopauseSeekAdvice'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tapVisible(tester, key('guide-perimenopauseSeekAdvice'));
    expect(textOf(tester, 'guide-title'), 'When to see a doctor');
  });

  testWidgets('intimacy is a row of cards on the home screen', (tester) async {
    // 1 March: the second day of a period.
    final harness = Harness(tester, today: CalendarDay(2026, 3, 1));
    await harness.seed(
      days: [
        ...periodFrom(CalendarDay(2026, 1, 3)),
        ...periodFrom(CalendarDay(2026, 1, 31)),
        ...periodFrom(CalendarDay(2026, 2, 28)),
      ],
    );
    await harness.pumpApp();

    // During her period, what is about it comes first.
    final first = key('intimacy-card-intimacyPeriodSex');
    await tester.scrollUntilVisible(
      first,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      tester.getTopLeft(first).dx,
      tester.getTopLeft(key('intimacy-carousel')).dx,
    );

    await tapVisible(tester, first);
    expect(
      textOf(tester, 'guide-title'),
      'Sex on your period: yes, and here is how',
    );
    expect(key('guide-seek'), findsNothing);
    // Still said to be awaiting review.
    expect(key('guide-pending-review'), findsOneWidget);
  });

  testWidgets('nothing about intimacy for a minor, nor once turned off', (
    tester,
  ) async {
    final minor = Harness(tester);
    await minor.seed(
      days: periodFrom(CalendarDay(2026, 2, 28)),
      birthYear: 2011,
    );
    await minor.pumpApp();
    expect(key('intimacy-title'), findsNothing);
    await openReview(tester);
    await tapVisible(tester, key('open-guides'));
    expect(key('guide-topic-intimacy'), findsNothing);
  });

  testWidgets('nothing about intimacy once she turned it off', (tester) async {
    final harness = Harness(tester);
    await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
    await harness.read((store) => store.database.sexLifeVisible = false);
    await harness.pumpApp();
    expect(key('intimacy-title'), findsNothing);
  });

  test('every guide has a text in both languages, and French says "tu"', () {
    for (final code in ['en', 'fr']) {
      final l10n = lookupAppLocalizations(Locale(code));
      for (final guide in Guide.values) {
        final text = guideText(l10n, guide);
        expect(text.title, isNotEmpty, reason: '$code ${guide.name}');
        expect(text.body.split('\n\n').length, greaterThan(2));
        // The guides about intimacy have no closing box.
        final seek = text.seek ?? '';
        expect(seek.isEmpty, guide.topic == GuideTopic.intimacy);
        // No treatment is named, no contraception advice is given.
        if (guide.topic != GuideTopic.intimacy) {
          for (final word in ['HRT', 'THS', 'pilule', ' pill', 'préservatif']) {
            expect('${text.body} $seek', isNot(contains(word)));
          }
        }
        if (code == 'fr') {
          expect(
            RegExp(r'(?<!rendez-)\b(vous|votre|vos)\b')
                .hasMatch('${text.title} ${text.body} $seek'),
            isFalse,
            reason: guide.name,
          );
        }
      }
    }
  });
}
