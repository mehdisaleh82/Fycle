import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/further_reading.dart';
import 'package:fycle/l10n/app_localizations.dart';
import 'package:fycle/ui/guides_screen.dart';
import 'package:fycle/ui/links.dart';
import 'package:material_ui/material_ui.dart';

import 'harness.dart';

/// The public health sites the app may send her to. Never a competitor
/// (CLAUDE.md, rule 8), never a shop.
const allowedHosts = {
  'www.nhs.uk',
  'www.brook.org.uk',
  'www.who.int',
  'www.ameli.fr',
  'www.sante.fr',
  'www.procreation-medicale.fr',
  'questionsexualite.fr',
};

void main() {
  Finder key(String name) => find.byKey(ValueKey(name));

  test('a line that is not a secure address with a title is left out', () {
    final links = parseReadingLinks(
      'Periods|NHS|https://www.nhs.uk/conditions/periods/\n'
      'No address|NHS\n'
      'Not secure|NHS|http://www.nhs.uk/\n'
      '|NHS|https://www.nhs.uk/\n',
    );
    expect(links, hasLength(1));
    expect(links.single.title, 'Periods');
    expect(links.single.source, 'NHS');
    expect(links.single.address.host, 'www.nhs.uk');
    expect(parseReadingLinks(''), isEmpty);
  });

  test('every link goes to a public health site, in both languages', () {
    for (final code in ['en', 'fr']) {
      final l10n = lookupAppLocalizations(Locale(code));
      var count = 0;
      for (final topic in ReadingTopic.values) {
        for (final link in readingLinks(l10n, topic)) {
          count++;
          expect(
            allowedHosts,
            contains(link.address.host),
            reason: '$code ${topic.name} ${link.address}',
          );
          // Nothing of hers is carried in the address.
          expect(link.address.hasQuery, isFalse, reason: '${link.address}');
        }
      }
      expect(count, greaterThan(8), reason: code);
    }
  });

  testWidgets('a link is handed to the system, nothing more', (tester) async {
    final opened = <Uri>[];
    final before = openLink;
    openLink = (address) async => opened.add(address);
    addTearDown(() => openLink = before);

    final harness = Harness(tester);
    await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
    await harness.pumpApp();
    await openReview(tester);
    await tapVisible(tester, key('open-guides'));

    await tester.scrollUntilVisible(
      key('link-sexuality-2'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tapVisible(tester, key('link-sexuality-2'));
    expect(opened, [Uri.parse('https://www.brook.org.uk/your-life/anal-sex/')]);
  });

  testWidgets('nothing about sex is listed once she turned it off', (
    tester,
  ) async {
    final harness = Harness(tester);
    await harness.seed(days: periodFrom(CalendarDay(2026, 2, 28)));
    await harness.read((store) => store.database.sexLifeVisible = false);
    await harness.pumpApp();
    await openReview(tester);
    await tapVisible(tester, key('open-guides'));

    await tester.scrollUntilVisible(
      key('links-fertility'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(key('links-sexuality'), findsNothing);
    expect(key('links-contraception'), findsNothing);
  });
}
