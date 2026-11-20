import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/life_stage.dart';
import 'package:fycle/domain/partner_link.dart';
import 'package:fycle/domain/partner_snapshot.dart';

void main() {
  final full = PartnerSnapshot(
    madeOn: CalendarDay(2026, 3, 18),
    name: 'Zoé-Maëlle',
    profile: Profile.conceiving,
    cycleStart: CalendarDay(2026, 2, 28),
    periodLength: 5,
    cycleLength: 29,
    earliestNext: CalendarDay(2026, 3, 25),
    latestNext: CalendarDay(2026, 3, 31),
    fertileFrom: CalendarDay(2026, 3, 9),
    fertileTo: CalendarDay(2026, 3, 15),
  );

  test('a link gives back the picture it was made from', () {
    final read = partnerFromLink(partnerLinkOf(full))!;
    expect(read.toJson(), full.toJson());
  });

  test('a link is short enough for a code a phone reads easily', () {
    final link = partnerLinkOf(full);
    expect(link, startsWith('fycle://p/'));
    expect(link.length, lessThan(600));
    // Nothing a link cannot carry as it is.
    expect(Uri.parse(link).toString(), link);
  });

  test('anything else is not a partner link', () {
    for (final link in [
      '',
      'fycle://p/',
      'fycle://p/@@@',
      'fycle://other/abc',
      'https://example.com/p/abc',
      'fycle://p/e30',
      '${partnerLinkOf(full)}/more',
    ]) {
      expect(partnerFromLink(link), isNull, reason: link);
    }
  });

  group('past the range she shared', () {
    final snapshot = PartnerSnapshot(
      madeOn: CalendarDay(2026, 3, 18),
      cycleStart: CalendarDay(2026, 2, 28),
      periodLength: 4,
      cycleLength: 28,
      earliestNext: CalendarDay(2026, 3, 25),
      latestNext: CalendarDay(2026, 3, 31),
    );

    test('the period after is estimated, a day wider on each side', () {
      final status = partnerStatusOn(CalendarDay(2026, 4, 10), snapshot);
      expect(status.moment, PartnerMoment.beforePeriod);
      expect(status.earliest, CalendarDay(2026, 4, 21));
      expect(status.latest, CalendarDay(2026, 4, 29));
      expect(status.daysUntilEarliest, 11);
      // Which day of her cycle it is cannot be known any more.
      expect(status.dayOfCycle, isNull);
    });

    test('and the one after that, wider again', () {
      final status = partnerStatusOn(CalendarDay(2026, 5, 20), snapshot);
      expect(status.moment, PartnerMoment.periodExpected);
      expect(status.earliest, CalendarDay(2026, 5, 18));
      expect(status.latest, CalendarDay(2026, 5, 28));
    });

    test('then nothing more is said', () {
      expect(
        partnerStatusOn(CalendarDay(2026, 5, 29), snapshot).moment,
        PartnerMoment.outdated,
      );
    });

    test('without a cycle length, nothing is said past the first range', () {
      expect(
        partnerStatusOn(
          CalendarDay(2026, 4, 10),
          PartnerSnapshot(
            madeOn: CalendarDay(2026, 3, 18),
            cycleStart: CalendarDay(2026, 2, 28),
            periodLength: 4,
            earliestNext: CalendarDay(2026, 3, 25),
            latestNext: CalendarDay(2026, 3, 31),
          ),
        ).moment,
        PartnerMoment.outdated,
      );
    });
  });
}
