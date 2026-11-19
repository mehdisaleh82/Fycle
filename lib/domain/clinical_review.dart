import 'calendar_day.dart';
import 'cycle_history.dart';
import 'fertility_estimate.dart';
import 'flow_intensity.dart';

/// The log read with the parameters a gynaecologist uses to describe
/// menstrual bleeding: frequency, regularity, duration and volume.
///
/// Source of the reference ranges: Munro, Critchley and Fraser for the FIGO
/// Menstrual Disorders Committee, "The two FIGO systems for normal and
/// abnormal uterine bleeding symptoms and classification of causes of
/// abnormal uterine bleeding in the reproductive years: 2018 revisions",
/// International Journal of Gynecology & Obstetrics, 2018.
///
/// This describes what was logged and sets it against published ranges. It
/// names no condition and is no diagnosis (CLAUDE.md, rule 7).

/// Shortest and longest cycle length, in days, inside the usual range.
const int figoMinCycleLength = 24;
const int figoMaxCycleLength = 38;

/// Longest period, in days, inside the usual range.
const int figoMaxPeriodLength = 8;

/// Largest difference, in days, between the shortest and the longest cycle
/// for cycles to be called regular. The revision gives 7 to 9 days; the
/// stricter value applies from 26 to 41 years of age, the wider one before
/// and after, and when the age is unknown.
const int figoRegularVariationStrict = 7;
const int figoRegularVariationWide = 9;
const int strictVariationFromAge = 26;
const int strictVariationToAge = 41;

/// Cycles that started within this many days are looked at.
const int reviewWindowDays = 365;

/// Regularity is not judged on fewer cycles than this.
const int minCyclesForRegularity = 3;

/// Where a value stands against its reference range.
enum RangePosition { below, within, above }

/// How heavy the periods are, from the intensities the user chose: the
/// heaviest day of each period, most often.
enum BleedingVolume { light, moderate, heavy }

final class ClinicalReview {
  const ClinicalReview({
    required this.cyclesCounted,
    required this.meanCycleLength,
    required this.frequency,
    required this.shortestCycle,
    required this.longestCycle,
    required this.regularVariationLimit,
    required this.regular,
    required this.meanPeriodLength,
    required this.longestPeriod,
    required this.duration,
    required this.volume,
    required this.follicularDaysEarliest,
    required this.follicularDaysLatest,
    required this.spottingDaysBetweenPeriods,
  });

  /// Complete, plausible cycles the review rests on.
  final int cyclesCounted;

  final double meanCycleLength;

  /// The mean cycle length against 24 to 38 days: below is called frequent,
  /// above infrequent.
  final RangePosition frequency;

  final int shortestCycle;
  final int longestCycle;

  /// Days between the shortest and the longest cycle.
  int get variation => longestCycle - shortestCycle;

  /// The limit [variation] is compared with, which depends on age.
  final int regularVariationLimit;

  /// Null below [minCyclesForRegularity] cycles: too few to tell.
  final bool? regular;

  final double meanPeriodLength;
  final int longestPeriod;

  /// The usual period length against 8 days: above is called prolonged.
  final RangePosition duration;

  /// Null when no period has a logged intensity.
  final BleedingVolume? volume;

  /// Estimated length of the first part of the cycle, before ovulation: the
  /// mean cycle length minus the assumed second part, as a range.
  final int follicularDaysEarliest;
  final int follicularDaysLatest;

  /// Days of spotting logged outside periods, in the cycles looked at.
  final int spottingDaysBetweenPeriods;
}

/// The limit on cycle variation that applies at [age].
int regularVariationLimitFor(int? age) =>
    age != null && age >= strictVariationFromAge && age <= strictVariationToAge
    ? figoRegularVariationStrict
    : figoRegularVariationWide;

/// Reads the last year of [cycles] (as returned by [cycleHistory]) against
/// the reference ranges. Returns null when no complete, plausible cycle
/// started in that year.
ClinicalReview? clinicalReview({
  required List<LoggedCycle> cycles,
  required Map<CalendarDay, FlowIntensity> flowByDay,
  required CalendarDay today,
  int? age,
}) {
  final counted = [
    for (final cycle in cycles)
      if (cycle.isPlausible &&
          today.daysSince(cycle.start) <= reviewWindowDays &&
          !cycle.start.isAfter(today))
        cycle,
  ];
  if (counted.isEmpty) {
    return null;
  }

  final lengths = [for (final cycle in counted) cycle.length!];
  final mean = lengths.reduce((a, b) => a + b) / lengths.length;
  final shortest = lengths.reduce((a, b) => a < b ? a : b);
  final longest = lengths.reduce((a, b) => a > b ? a : b);
  final limit = regularVariationLimitFor(age);

  final periods = [for (final cycle in counted) cycle.periodLength];
  final meanPeriod = periods.reduce((a, b) => a + b) / periods.length;
  final longestPeriod = periods.reduce((a, b) => a > b ? a : b);

  // The heaviest day of each period, then the most common of those.
  final peaks = <BleedingVolume, int>{};
  var spotting = 0;
  for (final cycle in counted) {
    FlowIntensity? peak;
    for (
      var day = cycle.start;
      !day.isAfter(cycle.end!);
      day = day.addDays(1)
    ) {
      final flow = flowByDay[day];
      if (flow == null) {
        continue;
      }
      if (flow == FlowIntensity.spotting) {
        if (day.isAfter(cycle.periodEnd)) {
          spotting++;
        }
        continue;
      }
      if (!day.isAfter(cycle.periodEnd) &&
          (peak == null || flow.index > peak.index)) {
        peak = flow;
      }
    }
    final volume = switch (peak) {
      FlowIntensity.light => BleedingVolume.light,
      FlowIntensity.medium => BleedingVolume.moderate,
      FlowIntensity.heavy => BleedingVolume.heavy,
      FlowIntensity.spotting || null => null,
    };
    if (volume != null) {
      peaks[volume] = (peaks[volume] ?? 0) + 1;
    }
  }
  BleedingVolume? volume;
  for (final candidate in BleedingVolume.values) {
    // On a tie, the heavier description is kept.
    if ((peaks[candidate] ?? 0) > 0 &&
        (volume == null || peaks[candidate]! >= peaks[volume]!)) {
      volume = candidate;
    }
  }

  final rounded = mean.round();
  int atLeastOne(int days) => days < 1 ? 1 : days;
  return ClinicalReview(
    cyclesCounted: counted.length,
    meanCycleLength: mean,
    frequency: rounded < figoMinCycleLength
        ? RangePosition.below
        : rounded > figoMaxCycleLength
        ? RangePosition.above
        : RangePosition.within,
    shortestCycle: shortest,
    longestCycle: longest,
    regularVariationLimit: limit,
    regular: counted.length < minCyclesForRegularity
        ? null
        : longest - shortest <= limit,
    meanPeriodLength: meanPeriod,
    longestPeriod: longestPeriod,
    duration: meanPeriod.round() > figoMaxPeriodLength
        ? RangePosition.above
        : RangePosition.within,
    volume: volume,
    follicularDaysEarliest: atLeastOne(
      rounded - assumedDaysFromOvulationToPeriod - ovulationMarginDays,
    ),
    follicularDaysLatest: atLeastOne(
      rounded - assumedDaysFromOvulationToPeriod + ovulationMarginDays,
    ),
    spottingDaysBetweenPeriods: spotting,
  );
}
