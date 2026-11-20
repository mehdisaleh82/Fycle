import 'calendar_day.dart';
import 'life_stage.dart';

/// What a guide is about.
enum GuideTopic { perimenopause, pregnancy, intimacy }

/// A short page written for the app.
///
/// The guides on perimenopause and pregnancy are general information drawn
/// from public health sources: they describe and say when to seek advice,
/// and give no treatment, no contraception advice and no diagnosis
/// (CLAUDE.md, rule 7). The guides on intimacy are written like a magazine,
/// about practices and what is lived; what they say of safety is kept to
/// the basics. Every text is reviewed before any release on a store.
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
  pregnancyAfterBirth(GuideTopic.pregnancy),
  intimacyOrgasm(GuideTopic.intimacy),
  intimacyNoOrgasm(GuideTopic.intimacy),
  intimacySolo(GuideTopic.intimacy),
  intimacyPeriodSex(GuideTopic.intimacy),
  intimacyAnal(GuideTopic.intimacy),
  intimacyLube(GuideTopic.intimacy),
  intimacyDesireCycle(GuideTopic.intimacy),
  intimacySquirting(GuideTopic.intimacy),
  intimacyPain(GuideTopic.intimacy),
  intimacyTears(GuideTopic.intimacy),
  intimacySayIt(GuideTopic.intimacy),
  intimacyNoDesire(GuideTopic.intimacy),
  intimacyAfterBaby(GuideTopic.intimacy),
  intimacyMidlife(GuideTopic.intimacy),
  intimacyOnSchedule(GuideTopic.intimacy);

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

/// Below this age, nothing about sex is put forward.
const int intimacyFromAge = 18;

/// Whether the guides on intimacy are offered: never once she turned them
/// off, never to a minor, and not to someone who is discovering her cycle
/// and did not give her age, who may well be one.
bool showsIntimacy({
  required bool sexLifeVisible,
  required int? age,
  required Profile? profile,
}) {
  if (!sexLifeVisible) {
    return false;
  }
  if (age != null) {
    // Her age is known from her year of birth alone: the year she turns
    // eighteen, she may still be seventeen. One more year makes it sure.
    return age > intimacyFromAge;
  }
  return profile != Profile.discovering;
}

/// The topics in the order she sees them: hers first, then intimacy when
/// it is offered.
List<GuideTopic> guideTopicsFor({
  required Profile? profile,
  required bool followsCycleChanges,
  bool intimacy = false,
}) {
  final first = profile == Profile.pregnant || profile == Profile.postpartum
      ? GuideTopic.pregnancy
      : followsCycleChanges
      ? GuideTopic.perimenopause
      : null;
  return [
    ?first,
    if (intimacy) GuideTopic.intimacy,
    for (final topic in GuideTopic.values)
      if (topic != first && topic != GuideTopic.intimacy) topic,
  ];
}

/// The guides on intimacy put forward on the home screen, in order.
///
/// What fits where she is comes first: her period, her days of higher
/// desire, a birth, a changing cycle, a wish to conceive. The guides that
/// are about another moment of life are left for the full list. The rest
/// turns by one place each day ([rotation], a count of days), so that the
/// first card is not the same day after day.
List<Guide> intimacyGuidesFor({
  required Profile? profile,
  required bool followsCycleChanges,
  required bool wantsToConceive,
  required bool periodOngoing,
  required bool desireDays,
  required int rotation,
}) {
  final pregnant = profile == Profile.pregnant;
  final afterBirth = profile == Profile.postpartum;
  final left = <Guide>{
    if (!afterBirth) Guide.intimacyAfterBaby,
    if (!followsCycleChanges) Guide.intimacyMidlife,
    if (!wantsToConceive || pregnant || afterBirth) Guide.intimacyOnSchedule,
    // Nothing follows a cycle during a pregnancy.
    if (pregnant) ...[Guide.intimacyPeriodSex, Guide.intimacyDesireCycle],
  };
  final first = <Guide>[
    if (periodOngoing && !pregnant) Guide.intimacyPeriodSex,
    if (desireDays && !pregnant) Guide.intimacyOrgasm,
    if (afterBirth) Guide.intimacyAfterBaby,
    if (followsCycleChanges) Guide.intimacyMidlife,
    if (wantsToConceive && !pregnant && !afterBirth) Guide.intimacyOnSchedule,
  ];
  final rest = [
    for (final guide in Guide.values)
      if (guide.topic == GuideTopic.intimacy &&
          !left.contains(guide) &&
          !first.contains(guide))
        guide,
  ];
  final turn = rest.isEmpty ? 0 : rotation % rest.length;
  return [...first, ...rest.sublist(turn), ...rest.sublist(0, turn)];
}
