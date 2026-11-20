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
import '../domain/reference_cycle.dart';
import '../domain/reminders.dart';
import '../domain/start_profile.dart';
import '../domain/start_profile.dart' as start_profile;

/// What the screens show, read from the local store and recomputed after
/// every change: the flow log, the days with any entry, the prediction, and
/// the settings of this phone (reminders, app lock, appearance).
class CycleModel extends ChangeNotifier {
  CycleModel(this.store, {this.today}) {
    _load();
  }

  final LocalStore store;

  /// The current day, used to turn the year of birth into an age. Without
  /// it, the age stays unknown.
  final CalendarDay Function()? today;

  Map<CalendarDay, FlowIntensity> _flowByDay = const {};
  Set<CalendarDay> _loggedDays = const {};
  List<DayEntry> _days = const [];
  List<LoggedCycle> _cycles = const [];
  CalendarDay? _dismissedSummaryStart;
  bool _fertilityEstimateEnabled = true;
  bool _widgetEnabled = true;
  FertilityEstimate? _fertilityEstimate;
  List<FertilityEstimate> _pastFertilityEstimates = const [];
  PeriodPrediction? _prediction;
  int? _usualCycleLength;
  int? _birthYear;
  int? _usualPeriodLength;
  CycleRegularity? _regularity;
  String? _firstName;
  Set<Goal> _goals = const {};
  Set<RecentChange> _recentChanges = const {};
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

  /// Whether the home-screen widget is given something to show.
  bool get widgetEnabled => _widgetEnabled;

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

  /// Year of birth given by the user, if any.
  int? get birthYear => _birthYear;

  /// Usual period length she gave, if any.
  int? get usualPeriodLength => _usualPeriodLength;

  /// Whether she calls her cycles regular, if she said.
  CycleRegularity? get regularity => _regularity;

  /// The first name she gave, if any.
  String? get firstName => _firstName;

  /// Why she uses the app. Empty when she did not say.
  Set<Goal> get goals => _goals;

  /// The changes she noticed in her periods when the app was set up.
  Set<RecentChange> get recentChanges => _recentChanges;

  /// Whether the app follows what changes from one cycle to the next.
  bool get followsCycleChanges =>
      start_profile.followsCycleChanges(goals: _goals, age: age);

  /// Her age this year, or null when the year of birth is unknown.
  int? get age {
    final now = today;
    return now == null ? null : ageIn(now().year, _birthYear);
  }

  /// The reference cycle length she starts from: for her age when it is
  /// known, the common one otherwise.
  int get referenceCycleLength => referenceCycleLengthForAge(age);

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

  /// Stores the year of birth (null to forget it) and recomputes the
  /// prediction.
  void setBirthYear(int? year) {
    store.database.birthYear = year;
    reload();
  }

  /// Stores what she said of herself when the app was set up, in one go.
  void setStartProfile({
    required String? firstName,
    required int? birthYear,
    required Set<Goal> goals,
    required CycleRegularity? regularity,
    required int? usualCycleLength,
    required int? usualPeriodLength,
    required Set<RecentChange> recentChanges,
  }) {
    final database = store.database;
    database.firstName = firstName;
    database.birthYear = birthYear;
    database.goals = goals;
    database.regularity = regularity;
    database.usualCycleLength = usualCycleLength;
    database.usualPeriodLength = usualPeriodLength;
    database.recentChanges = recentChanges;
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

  void setWidgetEnabled(bool enabled) {
    store.database.widgetEnabled = enabled;
    reload();
  }

  void setFertilityEstimateEnabled(bool enabled) {
    store.database.fertilityEstimateEnabled = enabled;
    reload();
  }

  /// Whether the suggestion called [name] was already answered.
  bool suggestionDismissed(String name) =>
      store.database.suggestionDismissed(name);

  /// Never makes the suggestion called [name] again.
  void dismissSuggestion(String name) {
    store.database.dismissSuggestion(name);
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
    _birthYear = database.birthYear;
    _usualPeriodLength = database.usualPeriodLength;
    _regularity = database.regularity;
    _firstName = database.firstName;
    _goals = database.goals;
    _recentChanges = database.recentChanges;
    _reminderSettings = database.reminderSettings;
    _appLockEnabled = database.appLockEnabled;
    _appearance = database.appearance;
    _onboardingDone = database.onboardingDone;
    _prediction = const PeriodPredictor().predict(
      periodStarts: periodStartsFrom(_flowByDay),
      usualCycleLength: _usualCycleLength,
      // Without a declared length, the reference for her age stands in.
      referenceCycleLength: age == null ? null : referenceCycleLength,
      irregular: _regularity == CycleRegularity.irregular,
    );
    _fertilityEstimateEnabled = database.fertilityEstimateEnabled;
    _widgetEnabled = database.widgetEnabled;
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
