import 'package:flutter/foundation.dart';

import '../data/appearance.dart';
import '../data/local_store.dart';
import '../domain/calendar_day.dart';
import '../domain/cycle_history.dart';
import '../domain/day_entry.dart';
import '../domain/fertility_estimate.dart';
import '../domain/flow_intensity.dart';
import '../domain/period_prediction.dart';
import '../domain/period_predictor.dart';
import '../domain/period_starts.dart';
import '../domain/reminders.dart';

/// What the screens show, read from the local store and recomputed after
/// every change: the flow log, the days with any entry, the prediction, and
/// the settings of this phone (reminders, app lock, appearance).
class CycleModel extends ChangeNotifier {
  CycleModel(this.store) {
    _load();
  }

  final LocalStore store;

  Map<CalendarDay, FlowIntensity> _flowByDay = const {};
  Set<CalendarDay> _loggedDays = const {};
  List<DayEntry> _days = const [];
  List<LoggedCycle> _cycles = const [];
  CalendarDay? _dismissedSummaryStart;
  bool _fertilityEstimateEnabled = false;
  FertilityEstimate? _fertilityEstimate;
  List<FertilityEstimate> _pastFertilityEstimates = const [];
  PeriodPrediction? _prediction;
  int? _usualCycleLength;
  ReminderSettings _reminderSettings = ReminderSettings();
  bool _appLockEnabled = false;
  Appearance _appearance = Appearance.light;
  bool _onboardingDone = false;

  /// Flow intensity of each day with flow.
  Map<CalendarDay, FlowIntensity> get flowByDay => _flowByDay;

  /// Every day with something logged, flow or not.
  Set<CalendarDay> get loggedDays => _loggedDays;

  /// Everything logged, in chronological order.
  List<DayEntry> get days => _days;

  /// The logged cycles, oldest first. The last one is the current cycle.
  List<LoggedCycle> get cycles => _cycles;

  /// First day of the last cycle whose summary was closed on this phone.
  CalendarDay? get dismissedSummaryStart => _dismissedSummaryStart;

  /// Whether the user turned the ovulation estimate on.
  bool get fertilityEstimateEnabled => _fertilityEstimateEnabled;

  /// The ovulation estimate of the current cycle. Null while it is turned
  /// off, and while too few cycles are logged.
  FertilityEstimate? get fertilityEstimate => _fertilityEstimate;

  /// The estimates of the cycles that ended, looking back. Empty while
  /// the estimate is turned off.
  List<FertilityEstimate> get pastFertilityEstimates => _pastFertilityEstimates;

  /// The estimate for the next period, or null if no period was logged.
  PeriodPrediction? get prediction => _prediction;

  /// Usual cycle length declared by the user, if any.
  int? get usualCycleLength => _usualCycleLength;

  /// The reminders chosen on this phone.
  ReminderSettings get reminderSettings => _reminderSettings;

  /// Whether the app is locked when it opens.
  bool get appLockEnabled => _appLockEnabled;

  /// Light, dark, or like the phone.
  Appearance get appearance => _appearance;

  /// True while nothing is entered.
  bool get isEmpty => _loggedDays.isEmpty && _usualCycleLength == null;

  /// True once the first-launch screen was passed, even without an answer.
  bool get onboardingDone => _onboardingDone;

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

  void setReminderSettings(ReminderSettings settings) {
    store.database.reminderSettings = settings;
    reload();
  }

  void setAppLockEnabled(bool enabled) {
    store.database.appLockEnabled = enabled;
    reload();
  }

  void setAppearance(Appearance appearance) {
    store.database.appearance = appearance;
    reload();
  }

  void setFertilityEstimateEnabled(bool enabled) {
    store.database.fertilityEstimateEnabled = enabled;
    reload();
  }

  /// Closes the summary of the cycle that started on [start] for good.
  void dismissCycleSummary(CalendarDay start) {
    store.database.dismissedSummaryStart = start;
    reload();
  }

  /// Remembers that the first-launch screen was passed on this phone.
  void completeOnboarding() {
    store.database.onboardingDone = true;
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
    _days = List.unmodifiable(database.readDays());
    _loggedDays = {for (final entry in _days) entry.day};
    _cycles = List.unmodifiable(cycleHistory(_flowByDay));
    _dismissedSummaryStart = database.dismissedSummaryStart;
    _usualCycleLength = database.usualCycleLength;
    _reminderSettings = database.reminderSettings;
    _appLockEnabled = database.appLockEnabled;
    _appearance = database.appearance;
    _onboardingDone = database.onboardingDone;
    _prediction = const PeriodPredictor().predict(
      periodStarts: periodStartsFrom(_flowByDay),
      usualCycleLength: _usualCycleLength,
    );
    _fertilityEstimateEnabled = database.fertilityEstimateEnabled;
    final prediction = _prediction;
    _fertilityEstimate =
        _fertilityEstimateEnabled && prediction != null && _cycles.isNotEmpty
        ? fertilityEstimateFrom(prediction, lastPeriodStart: _cycles.last.start)
        : null;
    _pastFertilityEstimates = _fertilityEstimateEnabled
        ? List.unmodifiable([
            for (final cycle in _cycles) ?pastFertilityEstimate(cycle),
          ])
        : const [];
  }
}
