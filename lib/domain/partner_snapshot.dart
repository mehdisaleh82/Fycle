import 'calendar_day.dart';
import 'life_stage.dart';

/// What she chooses to hand to her partner: a picture of where she is, taken
/// on one day. It travels as an encrypted file from her phone to his, by
/// whatever way she picks; no server sees it (CLAUDE.md, rules 1 and 2).
///
/// It holds dates and estimates only: nothing of what she logs day by day.
final class PartnerSnapshot {
  const PartnerSnapshot({
    required this.madeOn,
    this.name,
    this.profile,
    this.cycleStart,
    this.periodLength = 0,
    this.earliestNext,
    this.latestNext,
    this.fertileFrom,
    this.fertileTo,
    this.pregnancyStart,
    this.deliveryDate,
  });

  /// The day the file was made.
  final CalendarDay madeOn;

  /// Her first name, if she chose to give it.
  final String? name;
  final Profile? profile;

  /// First day of the cycle going on, and how long her period lasts.
  final CalendarDay? cycleStart;
  final int periodLength;

  /// The range in which her next period is estimated.
  final CalendarDay? earliestNext;
  final CalendarDay? latestNext;

  /// Her estimated fertile window, if she chose to share it.
  final CalendarDay? fertileFrom;
  final CalendarDay? fertileTo;

  final CalendarDay? pregnancyStart;
  final CalendarDay? deliveryDate;

  static const String _kind = 'partner';
  static const int _version = 1;

  Map<String, Object?> toJson() => {
    'kind': _kind,
    'version': _version,
    'madeOn': '$madeOn',
    'name': ?name,
    'profile': ?profile?.name,
    'cycleStart': ?cycleStart?.toString(),
    'periodLength': periodLength,
    'earliestNext': ?earliestNext?.toString(),
    'latestNext': ?latestNext?.toString(),
    'fertileFrom': ?fertileFrom?.toString(),
    'fertileTo': ?fertileTo?.toString(),
    'pregnancyStart': ?pregnancyStart?.toString(),
    'deliveryDate': ?deliveryDate?.toString(),
  };

  /// Reads what [toJson] wrote. Throws a [FormatException] for anything
  /// else, a backup file included.
  static PartnerSnapshot fromJson(Object? json) {
    if (json is! Map<String, Object?> || json['kind'] != _kind) {
      throw const FormatException('Not a partner file');
    }
    final version = json['version'];
    if (version is! int || version < 1 || version > _version) {
      throw const FormatException('Unknown version');
    }
    CalendarDay? day(String key) {
      final value = json[key];
      return value is String ? CalendarDay.tryParse(value) : null;
    }

    final madeOn = day('madeOn');
    if (madeOn == null) {
      throw const FormatException('No date');
    }
    final name = json['name'];
    final length = json['periodLength'];
    Profile? profile;
    for (final value in Profile.values) {
      if (value.name == json['profile']) {
        profile = value;
      }
    }
    return PartnerSnapshot(
      madeOn: madeOn,
      name: name is String && name.trim().isNotEmpty ? name.trim() : null,
      profile: profile,
      cycleStart: day('cycleStart'),
      periodLength: length is int && length > 0 && length < 30 ? length : 0,
      earliestNext: day('earliestNext'),
      latestNext: day('latestNext'),
      fertileFrom: day('fertileFrom'),
      fertileTo: day('fertileTo'),
      pregnancyStart: day('pregnancyStart'),
      deliveryDate: day('deliveryDate'),
    );
  }
}

/// Where she is on a given day, going by the file.
enum PartnerMoment {
  /// Nothing to count from.
  unknown,
  pregnant,
  afterBirth,
  periodOngoing,

  /// Her next period is still to come.
  beforePeriod,

  /// Today is inside the range where her period is estimated.
  periodExpected,

  /// The range is behind: the file is too old to say anything.
  outdated,
}

final class PartnerStatus {
  const PartnerStatus({
    required this.moment,
    this.dayOfCycle,
    this.daysUntilEarliest,
    this.daysUntilLatest,
    this.inFertileWindow = false,
  });

  final PartnerMoment moment;
  final int? dayOfCycle;

  /// Days from today to each end of the range of her next period.
  final int? daysUntilEarliest;
  final int? daysUntilLatest;

  /// Whether today is inside the estimated fertile window she shared.
  final bool inFertileWindow;
}

/// Reads [snapshot] on [today]. An estimate made on one day stays one: past
/// its range, nothing more is said.
PartnerStatus partnerStatusOn(CalendarDay today, PartnerSnapshot snapshot) {
  if (snapshot.profile == Profile.pregnant) {
    return const PartnerStatus(moment: PartnerMoment.pregnant);
  }
  final start = snapshot.cycleStart;
  final earliest = snapshot.earliestNext;
  final latest = snapshot.latestNext;
  if (snapshot.profile == Profile.postpartum && earliest == null) {
    return const PartnerStatus(moment: PartnerMoment.afterBirth);
  }
  if (start == null || today.isBefore(start)) {
    return const PartnerStatus(moment: PartnerMoment.unknown);
  }
  final day = today.daysSince(start) + 1;
  final from = snapshot.fertileFrom;
  final to = snapshot.fertileTo;
  final fertile =
      from != null && to != null && !today.isBefore(from) && !today.isAfter(to);
  if (latest != null && today.isAfter(latest)) {
    return const PartnerStatus(moment: PartnerMoment.outdated);
  }
  if (day <= snapshot.periodLength) {
    return PartnerStatus(moment: PartnerMoment.periodOngoing, dayOfCycle: day);
  }
  if (earliest == null || latest == null) {
    return PartnerStatus(moment: PartnerMoment.unknown, dayOfCycle: day);
  }
  return PartnerStatus(
    moment: today.isBefore(earliest)
        ? PartnerMoment.beforePeriod
        : PartnerMoment.periodExpected,
    dayOfCycle: day,
    daysUntilEarliest: earliest.daysSince(today),
    daysUntilLatest: latest.daysSince(today),
    inFertileWindow: fertile,
  );
}
