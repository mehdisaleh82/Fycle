import 'period_predictor.dart';

/// The reference cycle the user starts from, before her own dates replace
/// it. A point of comparison drawn from published averages: not a norm, and
/// not a goal to reach.
///
/// Source: Bull et al., "Real-world menstrual cycle characteristics of more
/// than 600,000 menstrual cycles", npj Digital Medicine, 2019. Mean cycle
/// length 29.3 days, shortening by about 0.18 day per year of age between
/// 25 and 45. See docs/DECISIONS.md for what is taken from the study and
/// what is assumed.

/// Mean cycle length found by the study, in days.
const double studyMeanCycleLength = 29.3;

/// Days by which the mean cycle shortens per year of age, in the range
/// below.
const double cycleDaysLostPerYear = 0.18;

/// The shortening was measured between these ages.
const int shorteningFromAge = 25;
const int shorteningToAge = 45;

/// The age at which the mean of the study is placed. An assumption of the
/// app, not a figure from the study.
const int meanAnchoredAtAge = 30;

/// A year of birth is accepted when it gives an age in this range.
const int minProfileAge = 10;
const int maxProfileAge = 70;

/// The age reached during [currentYear] by someone born in [birthYear], or
/// null when the year of birth is unknown or not plausible.
int? ageIn(int currentYear, int? birthYear) {
  if (birthYear == null) {
    return null;
  }
  final age = currentYear - birthYear;
  return age < minProfileAge || age > maxProfileAge ? null : age;
}

/// The reference cycle length in days for [age]: the common length when
/// the age is unknown, otherwise the mean of the study moved along its age
/// slope, held flat before 25 and after 45.
int referenceCycleLengthForAge(int? age) {
  if (age == null) {
    return PeriodPredictor.defaultCycleLength;
  }
  final within = age.clamp(shorteningFromAge, shorteningToAge);
  return (studyMeanCycleLength -
          cycleDaysLostPerYear * (within - meanAnchoredAtAge))
      .round();
}
