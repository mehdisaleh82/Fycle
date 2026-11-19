import 'package:flutter/foundation.dart';

import '../data/local_store.dart';
import '../domain/calendar_day.dart';
import '../domain/day_entry.dart';
import '../domain/flow_intensity.dart';
import '../domain/period_prediction.dart';
import '../domain/period_predictor.dart';
import '../domain/period_starts.dart';

/// What the screens show, read from the local store and recomputed after
/// every change: the flow log, the days with any entry, and the prediction.
class CycleModel extends ChangeNotifier {
  CycleModel(this.store) {
    _load();
  }

  final LocalStore store;

  Map<CalendarDay, FlowIntensity> _flowByDay = const {};
  Set<CalendarDay> _loggedDays = const {};
  PeriodPrediction? _prediction;
  int? _usualCycleLength;

  /// Flow intensity of each day with flow.
  Map<CalendarDay, FlowIntensity> get flowByDay => _flowByDay;

  /// Every day with something logged, flow or not.
  Set<CalendarDay> get loggedDays => _loggedDays;

  /// The estimate for the next period, or null if no period was logged.
  PeriodPrediction? get prediction => _prediction;

  /// Usual cycle length declared by the user, if any.
  int? get usualCycleLength => _usualCycleLength;

  /// True until something is entered: the first-launch screen is shown.
  bool get isEmpty => _loggedDays.isEmpty && _usualCycleLength == null;

  /// What is logged for [day]; an empty entry if nothing is.
  DayEntry entryFor(CalendarDay day) =>
      store.database.readDay(day) ?? DayEntry(day: day);

  /// Saves [entry] and recomputes the prediction.
  void saveDay(DayEntry entry) {
    store.database.saveDay(entry);
    reload();
  }

  /// Stores the declared cycle length (null to forget it) and recomputes the
  /// prediction.
  void setUsualCycleLength(int? days) {
    store.database.usualCycleLength = days;
    reload();
  }

  /// Reads everything again, for example after an import.
  void reload() {
    _load();
    notifyListeners();
  }

  void _load() {
    final database = store.database;
    _flowByDay = database.flowByDay();
    _loggedDays = {for (final entry in database.readDays()) entry.day};
    _usualCycleLength = database.usualCycleLength;
    _prediction = const PeriodPredictor().predict(
      periodStarts: periodStartsFrom(_flowByDay),
      usualCycleLength: _usualCycleLength,
    );
  }
}
