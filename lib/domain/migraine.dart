import 'calendar_day.dart';
import 'cycle_history.dart';
import 'day_entry.dart';
import 'pain_level.dart';
import 'symptom.dart';

/// How long a migraine lasted, in three steps she can tell apart without a
/// watch. The names are stored on disk: never rename a value, only add.
enum MigraineDuration { hours, day, longer }

/// What she notes of a migraine, besides ticking it: how strong, how long,
/// and whether she took something for it. Every field is optional.
///
/// The app records and counts. It says nothing of treatments
/// (CLAUDE.md, rule 7).
final class MigraineDetail {
  const MigraineDetail({this.intensity, this.duration, this.medication});

  /// Never [PainLevel.none]: a migraine without pain is not noted here.
  final PainLevel? intensity;
  final MigraineDuration? duration;

  /// Whether she took a medication for it. Null when she did not say.
  final bool? medication;

  bool get isEmpty =>
      intensity == null && duration == null && medication == null;

  MigraineDetail copyWith({
    PainLevel? Function()? intensity,
    MigraineDuration? Function()? duration,
    bool? Function()? medication,
  }) => MigraineDetail(
    intensity: intensity == null ? this.intensity : intensity(),
    duration: duration == null ? this.duration : duration(),
    medication: medication == null ? this.medication : medication(),
  );

  @override
  bool operator ==(Object other) =>
      other is MigraineDetail &&
      other.intensity == intensity &&
      other.duration == duration &&
      other.medication == medication;

  @override
  int get hashCode => Object.hash(intensity, duration, medication);

  @override
  String toString() =>
      'MigraineDetail(${intensity?.name}, ${duration?.name}, $medication)';
}

/// The migraines of the last days, counted and set against the periods.
final class MigraineSummary {
  const MigraineSummary({
    required this.days,
    required this.duringPeriod,
    required this.withMedication,
    required this.commonIntensity,
  });

  /// Days with a migraine ticked.
  final int days;

  /// Among them, days that fall during a period, or in the two days before
  /// one starts.
  final int duringPeriod;

  /// Among them, days where she noted a medication.
  final int withMedication;

  /// The intensity noted most often; on a tie, the stronger. Null when none
  /// was noted.
  final PainLevel? commonIntensity;
}

/// The window the summary looks at, and how many days before a period count
/// as "around" it.
const int migraineWindowDays = 90;
const int daysBeforePeriodCounted = 2;

/// Counts the migraines of the last [migraineWindowDays] days. Null when
/// there was none.
MigraineSummary? migraineSummaryOn(
  CalendarDay today, {
  required List<DayEntry> days,
  required List<LoggedCycle> cycles,
}) {
  bool aroundPeriod(CalendarDay day) {
    for (final cycle in cycles) {
      final from = cycle.start.addDays(-daysBeforePeriodCounted);
      if (!day.isBefore(from) && !day.isAfter(cycle.periodEnd)) {
        return true;
      }
    }
    return false;
  }

  var count = 0;
  var duringPeriod = 0;
  var withMedication = 0;
  final intensities = <PainLevel, int>{};
  for (final entry in days) {
    final ago = today.daysSince(entry.day);
    if (ago < 0 ||
        ago >= migraineWindowDays ||
        !entry.symptoms.contains(Symptom.migraine)) {
      continue;
    }
    count++;
    if (aroundPeriod(entry.day)) {
      duringPeriod++;
    }
    final detail = entry.migraine;
    if (detail?.medication == true) {
      withMedication++;
    }
    final intensity = detail?.intensity;
    if (intensity != null) {
      intensities[intensity] = (intensities[intensity] ?? 0) + 1;
    }
  }
  if (count == 0) {
    return null;
  }
  PainLevel? common;
  for (final level in PainLevel.values) {
    final seen = intensities[level] ?? 0;
    if (seen > 0 && (common == null || seen >= intensities[common]!)) {
      common = level;
    }
  }
  return MigraineSummary(
    days: count,
    duringPeriod: duringPeriod,
    withMedication: withMedication,
    commonIntensity: common,
  );
}
