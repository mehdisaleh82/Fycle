import 'calendar_day.dart';

/// The published studies the app draws its reference figures from. The full
/// references are listed in docs/DECISIONS.md and in the app.
enum StudySource {
  /// Bull et al., npj Digital Medicine, 2019: 612,613 cycles.
  bull2019,

  /// Fehring, Schneider and Raviele, 2006: 1,060 cycles.
  fehring2006,

  /// Wilcox, Weinberg and Baird, New England Journal of Medicine, 1995.
  wilcox1995,

  /// Munro, Critchley and Fraser for FIGO, Int J Gynecol Obstet, 2018.
  figo2018,
}

/// A finding of one of those studies, shown on the home tab next to the
/// user's own figure. One a day, in turn.
enum StudyFact {
  /// Only about 13% of cycles last exactly 28 days.
  exactly28(StudySource.bull2019),

  /// In about 4 women out of 10, cycle length varies by more than 7 days.
  variesMoreThan7(StudySource.fehring2006),

  /// 95% of the cycles measured lasted between 22 and 36 days.
  range22to36(StudySource.fehring2006),

  /// Cycles shorten by about 0.18 day per year of age between 25 and 45.
  shortensWithAge(StudySource.bull2019),

  /// The first part of the cycle varies most; the second hardly moves.
  firstPartVaries(StudySource.fehring2006),

  /// Conception was observed only in the six days ending on ovulation day.
  sixDayWindow(StudySource.wilcox1995),

  /// A cycle of 24 to 38 days and a period of up to 8 days are within the
  /// usual range.
  figoRanges(StudySource.figo2018);

  const StudyFact(this.source);

  final StudySource source;
}

/// The fact shown on [day]: they follow one another, a new one each day,
/// the same for the whole day.
StudyFact studyFactOn(CalendarDay day) {
  final sinceEpoch = day.daysSince(CalendarDay(2026, 1, 1));
  final count = StudyFact.values.length;
  return StudyFact.values[((sinceEpoch % count) + count) % count];
}
