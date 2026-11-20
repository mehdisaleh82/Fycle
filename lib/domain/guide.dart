import 'calendar_day.dart';
import 'life_stage.dart';

/// What a guide is about.
enum GuideTopic { perimenopause, pregnancy }

/// A short page of general information, written from public health
/// sources. A guide describes and says when to seek advice; it gives no
/// treatment, no contraception advice and no diagnosis (CLAUDE.md, rule 7).
/// Its text is reviewed by a health professional before any release on a
/// store.
enum Guide {
  perimenopauseWhat(GuideTopic.perimenopause),
  perimenopausePeriods(GuideTopic.perimenopause),
  perimenopauseHotFlushes(GuideTopic.perimenopause),
  perimenopauseSleepMood(GuideTopic.perimenopause),
  perimenopauseSex(GuideTopic.perimenopause),
  perimenopauseSeekAdvice(GuideTopic.perimenopause),
  pregnancyFirstTrimester(GuideTopic.pregnancy),
  pregnancySecondTrimester(GuideTopic.pregnancy),
  pregnancyThirdTrimester(GuideTopic.pregnancy),
  pregnancyUrgentSigns(GuideTopic.pregnancy),
  pregnancyCare(GuideTopic.pregnancy),
  pregnancyAfterBirth(GuideTopic.pregnancy);

  const Guide(this.topic);

  final GuideTopic topic;
}

/// The second trimester starts with this week, and the third with that
/// one, counted from the first day of the last period.
const int secondTrimesterFromWeek = 13;
const int thirdTrimesterFromWeek = 28;

/// The guide of the trimester a pregnancy dated from [pregnancyStart] is
/// in on [today].
Guide trimesterGuide(CalendarDay pregnancyStart, CalendarDay today) {
  // Week 1 is the week that starts on the first day of the last period.
  final week = today.daysSince(pregnancyStart) ~/ 7 + 1;
  if (week >= thirdTrimesterFromWeek) {
    return Guide.pregnancyThirdTrimester;
  }
  return week >= secondTrimesterFromWeek
      ? Guide.pregnancySecondTrimester
      : Guide.pregnancyFirstTrimester;
}

/// The one guide put forward on the home screen, from where she is in her
/// life. Null when none of the guides is about her.
Guide? featuredGuide({
  required Profile? profile,
  required bool followsCycleChanges,
  required CalendarDay today,
  CalendarDay? pregnancyStart,
}) {
  if (profile == Profile.pregnant) {
    return pregnancyStart == null || pregnancyStart.isAfter(today)
        ? Guide.pregnancyCare
        : trimesterGuide(pregnancyStart, today);
  }
  if (profile == Profile.postpartum) {
    return Guide.pregnancyAfterBirth;
  }
  return followsCycleChanges ? Guide.perimenopauseWhat : null;
}

/// The topics in the order she sees them: hers first.
List<GuideTopic> guideTopicsFor({
  required Profile? profile,
  required bool followsCycleChanges,
}) {
  final first = profile == Profile.pregnant || profile == Profile.postpartum
      ? GuideTopic.pregnancy
      : followsCycleChanges
      ? GuideTopic.perimenopause
      : null;
  return [
    ?first,
    for (final topic in GuideTopic.values)
      if (topic != first) topic,
  ];
}
