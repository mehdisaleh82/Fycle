import '../domain/day_entry.dart';

/// Everything the user has entered: the content of the database, and of an
/// export file.
final class FycleData {
  FycleData({
    this.usualCycleLength,
    this.birthYear,
    List<DayEntry> days = const [],
  }) : days = List.unmodifiable(days);

  /// Usual cycle length in days, as declared at first launch, if known.
  final int? usualCycleLength;

  /// Year of birth, if the user gave it.
  final int? birthYear;

  /// Logged days, in chronological order.
  final List<DayEntry> days;
}
