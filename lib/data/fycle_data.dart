import '../domain/day_entry.dart';
import '../domain/start_profile.dart';

/// Everything the user has entered: the content of the database, and of an
/// export file.
final class FycleData {
  FycleData({
    this.usualCycleLength,
    this.birthYear,
    this.usualPeriodLength,
    this.regularity,
    List<DayEntry> days = const [],
  }) : days = List.unmodifiable(days);

  /// Usual cycle length in days, as declared at first launch, if known.
  final int? usualCycleLength;

  /// Year of birth, if the user gave it.
  final int? birthYear;

  /// Usual period length in days, if the user gave it.
  final int? usualPeriodLength;

  /// Whether she calls her cycles regular, if she said.
  final CycleRegularity? regularity;

  /// Logged days, in chronological order.
  final List<DayEntry> days;
}
