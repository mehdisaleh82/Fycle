import 'calendar_day.dart';
import 'start_profile.dart';

/// Where she is in her life, as she says it when the app is set up. The
/// app shows and asks different things to each: every woman is different.
///
/// The names are stored on the phone: never rename a value, only add.
enum Profile {
  discovering,
  tracking,
  conceiving,
  pregnant,
  postpartum,
  perimenopause,
}

/// The goals a profile stands for, where the rest of the app reads goals.
Set<Goal> goalsOf(Profile? profile) => switch (profile) {
  Profile.discovering => {Goal.understandBody},
  Profile.tracking => {Goal.trackPeriods},
  Profile.conceiving => {Goal.conceive},
  Profile.perimenopause => {Goal.perimenopause},
  Profile.pregnant || Profile.postpartum || null => const {},
};

/// What becomes of [chosen] when she touches [tapped]: several profiles go
/// together, within what makes sense. A pregnancy stands alone, since no
/// period is expected then; discovering and tracking are two ways of saying
/// how far she is, so one replaces the other.
Set<Profile> toggledProfiles(Set<Profile> chosen, Profile tapped) {
  if (chosen.contains(tapped)) {
    return {...chosen}..remove(tapped);
  }
  if (tapped == Profile.pregnant) {
    return {tapped};
  }
  final next = {...chosen, tapped}..remove(Profile.pregnant);
  if (tapped == Profile.discovering) {
    next.remove(Profile.tracking);
  }
  if (tapped == Profile.tracking) {
    next.remove(Profile.discovering);
  }
  return next;
}

/// The profile that decides what the home screen shows, among [chosen]:
/// a pregnancy first, then a recent birth, then the rest.
Profile? mainProfile(Set<Profile> chosen) {
  for (final profile in const [
    Profile.pregnant,
    Profile.postpartum,
    Profile.perimenopause,
    Profile.conceiving,
    Profile.tracking,
    Profile.discovering,
  ]) {
    if (chosen.contains(profile)) {
      return profile;
    }
  }
  return null;
}

/// The goals all of [chosen] stand for, together.
Set<Goal> goalsOfAll(Set<Profile> chosen) => {
  for (final profile in chosen) ...goalsOf(profile),
};

/// The profiles she chose, read back from what is stored: the main one and
/// her goals.
Set<Profile> profilesFrom(Profile? main, Set<Goal> goals) => {
  ?main,
  if (main != Profile.pregnant)
    for (final profile in Profile.values)
      if (goalsOf(profile).isNotEmpty && goals.containsAll(goalsOf(profile)))
        profile,
};

/// Whether the profile is one where periods come cycle after cycle, so
/// that the usual questions about them make sense.
bool followsACycle(Profile? profile) =>
    profile != Profile.pregnant && profile != Profile.postpartum;

/// Pregnancy is dated from the first day of the last period, in completed
/// weeks and days ("weeks of amenorrhoea"). A birth is called at term from
/// 37 completed weeks to 42. These are the standard obstetric definitions;
/// the app only counts days from the date she gave. It dates nothing by
/// itself: only a dating scan does (CLAUDE.md, rule 7).
const int termFromWeeks = 37;
const int termToWeeks = 42;

final class PregnancyProgress {
  const PregnancyProgress({
    required this.weeks,
    required this.days,
    required this.termFrom,
    required this.termTo,
  });

  /// Completed weeks since the first day of the last period, and the days
  /// beyond them (0 to 6).
  final int weeks;
  final int days;

  /// The days between which a birth would be at term.
  final CalendarDay termFrom;
  final CalendarDay termTo;

  /// True once more weeks have gone by than a pregnancy lasts: the date is
  /// wrong, or the mode was left on.
  bool get pastTerm => weeks >= termToWeeks;
}

/// Counts from [lastPeriodStart] on [today]. Null when that day is still to
/// come.
PregnancyProgress? pregnancyProgressOn(
  CalendarDay today,
  CalendarDay lastPeriodStart,
) {
  final elapsed = today.daysSince(lastPeriodStart);
  if (elapsed < 0) {
    return null;
  }
  return PregnancyProgress(
    weeks: elapsed ~/ 7,
    days: elapsed % 7,
    termFrom: lastPeriodStart.addDays(termFromWeeks * 7),
    termTo: lastPeriodStart.addDays(termToWeeks * 7),
  );
}

/// Completed weeks since [date] on [today]. Null when that day is still to
/// come.
int? weeksSince(CalendarDay today, CalendarDay date) {
  final elapsed = today.daysSince(date);
  return elapsed < 0 ? null : elapsed ~/ 7;
}

/// After a birth, only the periods that came back count, and the first
/// cycles are expected to vary: the range stays wide until this many of
/// them are known.
const int cyclesBeforeSettledAfterBirth = 3;

/// The period starts the estimate rests on after a birth on [delivery]:
/// those that came on or after that day.
List<CalendarDay> startsSinceBirth(
  Iterable<CalendarDay> periodStarts,
  CalendarDay delivery,
) => [
  for (final start in periodStarts)
    if (!start.isBefore(delivery)) start,
];
