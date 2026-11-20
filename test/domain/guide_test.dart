import 'package:flutter_test/flutter_test.dart';
import 'package:fycle/domain/calendar_day.dart';
import 'package:fycle/domain/guide.dart';
import 'package:fycle/domain/life_stage.dart';

void main() {
  final today = CalendarDay(2026, 3, 20);

  Guide? featured(
    Profile? profile, {
    bool followsCycleChanges = false,
    CalendarDay? pregnancyStart,
  }) => featuredGuide(
    profile: profile,
    followsCycleChanges: followsCycleChanges,
    today: today,
    pregnancyStart: pregnancyStart,
  );

  group('the guide put forward', () {
    test('none when no guide is about her', () {
      expect(featured(null), isNull);
    });

    test('perimenopause when she follows a changing cycle', () {
      expect(
        featured(null, followsCycleChanges: true),
        Guide.perimenopauseWhat,
      );
    });

    test('the trimester she is in, counted from her last period', () {
      // Week 12 ends 84 days after the first day of the last period.
      expect(
        featured(Profile.pregnant, pregnancyStart: today.addDays(-83)),
        Guide.pregnancyFirstTrimester,
      );
      expect(
        featured(Profile.pregnant, pregnancyStart: today.addDays(-84)),
        Guide.pregnancySecondTrimester,
      );
      expect(
        featured(Profile.pregnant, pregnancyStart: today.addDays(-27 * 7)),
        Guide.pregnancyThirdTrimester,
      );
    });

    test('what care is for, while the pregnancy has no date', () {
      expect(featured(Profile.pregnant), Guide.pregnancyCare);
    });

    test('after a birth, bleeding and the return of periods', () {
      expect(featured(Profile.postpartum), Guide.pregnancyAfterBirth);
    });
  });

  test('her topic comes first in the list', () {
    expect(
      guideTopicsFor(profile: Profile.pregnant, followsCycleChanges: false),
      [GuideTopic.pregnancy, GuideTopic.perimenopause],
    );
    expect(guideTopicsFor(profile: null, followsCycleChanges: true), [
      GuideTopic.perimenopause,
      GuideTopic.pregnancy,
    ]);
    expect(guideTopicsFor(profile: null, followsCycleChanges: false), [
      GuideTopic.perimenopause,
      GuideTopic.pregnancy,
    ]);
  });

  test('every topic has guides', () {
    int count(GuideTopic topic) =>
        Guide.values.where((guide) => guide.topic == topic).length;
    expect(count(GuideTopic.perimenopause), 6);
    expect(count(GuideTopic.pregnancy), 6);
    expect(count(GuideTopic.intimacy), 15);
  });

  group('intimacy', () {
    test('is offered to adults, never to a minor, never once turned off', () {
      bool shown({bool visible = true, int? age, Profile? profile}) =>
          showsIntimacy(sexLifeVisible: visible, age: age, profile: profile);
      expect(shown(), isTrue);
      expect(shown(age: 34), isTrue);
      expect(shown(age: 16), isFalse);
      // The year she turns eighteen, she may still be seventeen.
      expect(shown(age: 18), isFalse);
      expect(shown(age: 19), isTrue);
      expect(shown(visible: false, age: 34), isFalse);
      // Discovering her cycle without an age: she may well be a minor.
      expect(shown(profile: Profile.discovering), isFalse);
      expect(shown(profile: Profile.discovering, age: 22), isTrue);
    });

    test('comes right after her own topic in the list', () {
      expect(
        guideTopicsFor(
          profile: Profile.pregnant,
          followsCycleChanges: false,
          intimacy: true,
        ),
        [GuideTopic.pregnancy, GuideTopic.intimacy, GuideTopic.perimenopause],
      );
    });

    List<Guide> cards({
      Profile? profile,
      bool followsCycleChanges = false,
      bool wantsToConceive = false,
      bool periodOngoing = false,
      bool desireDays = false,
      int rotation = 0,
    }) => intimacyGuidesFor(
      profile: profile,
      followsCycleChanges: followsCycleChanges,
      wantsToConceive: wantsToConceive,
      periodOngoing: periodOngoing,
      desireDays: desireDays,
      rotation: rotation,
    );

    test('what fits her moment comes first', () {
      expect(cards(periodOngoing: true).first, Guide.intimacyPeriodSex);
      expect(cards(desireDays: true).first, Guide.intimacyOrgasm);
      expect(cards(profile: Profile.postpartum).first, Guide.intimacyAfterBaby);
      expect(cards(followsCycleChanges: true).first, Guide.intimacyMidlife);
      expect(cards(wantsToConceive: true).first, Guide.intimacyOnSchedule);
    });

    test('what is about another moment of life is left for the list', () {
      final plain = cards();
      expect(plain, isNot(contains(Guide.intimacyAfterBaby)));
      expect(plain, isNot(contains(Guide.intimacyMidlife)));
      expect(plain, isNot(contains(Guide.intimacyOnSchedule)));
      final pregnant = cards(profile: Profile.pregnant, periodOngoing: true);
      expect(pregnant, isNot(contains(Guide.intimacyPeriodSex)));
      expect(pregnant, isNot(contains(Guide.intimacyDesireCycle)));
    });

    test('the first card changes from one day to the next', () {
      expect(cards().first, isNot(cards(rotation: 1).first));
      // Nothing is lost or repeated on the way.
      expect(cards(rotation: 5).toSet(), cards().toSet());
      expect(cards(rotation: 5), hasLength(cards().length));
    });
  });
}
