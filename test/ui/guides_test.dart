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

    expect(
      tester.getTopLeft(key('guide-topic-pregnancy')).dy,
      lessThan(tester.getTopLeft(key('guide-topic-perimenopause')).dy),
    );
    await tapVisible(tester, key('guide-perimenopauseSeekAdvice'));
    expect(textOf(tester, 'guide-title'), 'When to see a doctor');
  });

  test('every guide has a text in both languages, and French says "tu"', () {
    for (final code in ['en', 'fr']) {
      final l10n = lookupAppLocalizations(Locale(code));
      for (final guide in Guide.values) {
        final text = guideText(l10n, guide);
        expect(text.title, isNotEmpty, reason: '$code ${guide.name}');
        expect(text.body.split('\n\n').length, greaterThan(2));
        expect(text.seek, isNotEmpty);
        // No treatment is named, no contraception advice is given.
        for (final word in ['HRT', 'THS', 'pilule', ' pill', 'préservatif']) {
          expect('${text.body} ${text.seek}', isNot(contains(word)));
        }
        if (code == 'fr') {
          expect(
            RegExp(r'(?<!rendez-)\b(vous|votre|vos)\b')
                .hasMatch('${text.title} ${text.body} ${text.seek}'),
            isFalse,
            reason: guide.name,
          );
        }
      }
    }
  });
}
