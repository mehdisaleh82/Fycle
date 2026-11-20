import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/life_stage.dart';
import 'package:fycle/domain/start_profile.dart';

void main() {
  test('each profile stands for the goals the app reads', () {
    expect(goalsOf(Profile.discovering), {Goal.understandBody});
    expect(goalsOf(Profile.tracking), {Goal.trackPeriods});
    expect(goalsOf(Profile.conceiving), {Goal.conceive});
    expect(goalsOf(Profile.perimenopause), {Goal.perimenopause});
    expect(goalsOf(Profile.pregnant), isEmpty);
    expect(goalsOf(Profile.postpartum), isEmpty);
    expect(goalsOf(null), isEmpty);
  });

  group('several profiles together', () {
    test('a birth and a wish to conceive go together', () {
      final chosen = toggledProfiles({Profile.postpartum}, Profile.conceiving);
      expect(chosen, {Profile.postpartum, Profile.conceiving});
      expect(mainProfile(chosen), Profile.postpartum);
      expect(goalsOfAll(chosen), {Goal.conceive});
    });

    test('a pregnancy stands alone, both ways', () {
      expect(
        toggledProfiles({
          Profile.tracking,
          Profile.conceiving,
        }, Profile.pregnant),
        {Profile.pregnant},
      );
      expect(toggledProfiles({Profile.pregnant}, Profile.tracking), {
        Profile.tracking,
      });
    });

    test('discovering and tracking replace each other', () {
      expect(
        toggledProfiles({
          Profile.discovering,
          Profile.perimenopause,
        }, Profile.tracking),
        {Profile.tracking, Profile.perimenopause},
      );
      expect(toggledProfiles({Profile.tracking}, Profile.discovering), {
        Profile.discovering,
      });
    });

    test('touching a chosen profile takes it away', () {
      expect(
        toggledProfiles({
          Profile.tracking,
          Profile.conceiving,
        }, Profile.conceiving),
        {Profile.tracking},
      );
    });

    test('the main profile is the one the home screen follows', () {
      expect(mainProfile({}), isNull);
      expect(
        mainProfile({Profile.discovering, Profile.conceiving}),
        Profile.conceiving,
      );
      expect(
        mainProfile({Profile.perimenopause, Profile.conceiving}),
        Profile.perimenopause,
      );
    });

    test('what is stored gives back what she chose', () {
      for (final chosen in [
        {Profile.pregnant},
        {Profile.postpartum, Profile.conceiving},
        {Profile.tracking, Profile.perimenopause},
        {Profile.discovering},
        <Profile>{},
      ]) {
        expect(
          profilesFrom(mainProfile(chosen), goalsOfAll(chosen)),
          chosen,
          reason: '$chosen',
        );
      }
    });
  });

  test('a pregnancy and the weeks after a birth do not follow a cycle', () {
    expect(followsACycle(null), isTrue);
    expect(followsACycle(Profile.tracking), isTrue);
    expect(followsACycle(Profile.perimenopause), isTrue);
    expect(followsACycle(Profile.pregnant), isFalse);
    expect(followsACycle(Profile.postpartum), isFalse);
  });

  group('a pregnancy', () {
    final start = CalendarDay(2026, 3, 1);

    test('is counted in completed weeks and days from the last period', () {
      final first = pregnancyProgressOn(start, start)!;
      expect((first.weeks, first.days), (0, 0));

      final later = pregnancyProgressOn(CalendarDay(2026, 3, 20), start)!;
      expect((later.weeks, later.days), (2, 5));

      final weeks = pregnancyProgressOn(start.addDays(70), start)!;
      expect((weeks.weeks, weeks.days), (10, 0));
    });

    test('is at term from 37 completed weeks to 42', () {
      final progress = pregnancyProgressOn(start, start)!;
      expect(progress.termFrom, start.addDays(259));
      expect(progress.termTo, start.addDays(294));
      expect(progress.pastTerm, isFalse);
      expect(pregnancyProgressOn(start.addDays(293), start)!.pastTerm, isFalse);
      expect(pregnancyProgressOn(start.addDays(294), start)!.pastTerm, isTrue);
    });

    test('cannot start on a day to come', () {
      expect(pregnancyProgressOn(start.addDays(-1), start), isNull);
    });
  });

  test('weeks since a birth are completed weeks', () {
    final birth = CalendarDay(2026, 3, 1);
    expect(weeksSince(birth, birth), 0);
    expect(weeksSince(birth.addDays(6), birth), 0);
    expect(weeksSince(birth.addDays(7), birth), 1);
    expect(weeksSince(birth.addDays(-1), birth), isNull);
  });

  test('after a birth, only the periods that came back count', () {
    final birth = CalendarDay(2026, 3, 1);
    expect(
      startsSinceBirth([
        CalendarDay(2025, 5, 1),
        CalendarDay(2025, 5, 29),
        birth,
        CalendarDay(2026, 4, 20),
      ], birth),
      [birth, CalendarDay(2026, 4, 20)],
    );
  });
}
