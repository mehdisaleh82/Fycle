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
    expect(
      guideTopicsFor(profile: null, followsCycleChanges: false),
      GuideTopic.values,
    );
  });

  test('every topic has guides', () {
    for (final topic in GuideTopic.values) {
      expect(Guide.values.where((guide) => guide.topic == topic), hasLength(6));
    }
  });
}
