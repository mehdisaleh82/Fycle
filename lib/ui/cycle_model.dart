import 'package:flutter/foundation.dart';

import '../data/appearance.dart';
import '../data/local_store.dart';
import '../domain/calendar_day.dart';
import '../domain/cycle_history.dart';
import '../domain/day_entry.dart';
import '../domain/fertility_estimate.dart';
import '../domain/flow_intensity.dart';
import '../domain/life_stage.dart';
import '../domain/pain_level.dart';
import '../domain/period_prediction.dart';
import '../domain/period_predictor.dart';
import '../domain/period_starts.dart';
import '../domain/reference_cycle.dart';
import '../domain/reminders.dart';
import '../domain/start_profile.dart';
import '../domain/start_profile.dart' as start_profile;
import '../domain/symptom.dart';

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
  Set<Wish> _wishes = const {};
  Contraception? _contraception;
  Set<Tracked> _tracked = const {};
  FlowIntensity? _usualFlow;
  PainLevel? _usualPain;
  Set<Symptom> _startSigns = const {};
  Set<Symptom> _declaredBeforePeriod = const {};
  Profile? _profile;
  CalendarDay? _pregnancyStart;
  CalendarDay? _deliveryDate;
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

  /// What she wants to know, in more detail.
  Set<Wish> get wishes => _wishes;

  /// The contraception she said she uses, if she said.
  Contraception? get contraception => _contraception;

  /// What she wants to follow day by day. Empty when she did not say.
  Set<Tracked> get tracked => _tracked;

  /// How heavy and how painful her periods usually are, as she said.
  FlowIntensity? get usualFlow => _usualFlow;
  PainLevel? get usualPain => _usualPain;

  /// The signs she said she had when the app was set up.
  Set<Symptom> get startSigns => _startSigns;

  /// The signs she said she often has before her period.
  Set<Symptom> get declaredBeforePeriod => _declaredBeforePeriod;

  /// Where she is in her life, as she said. Null when she did not say.
  Profile? get profile => _profile;

  /// First day of the last period before the pregnancy going on.
  CalendarDay? get pregnancyStart => _pregnancyStart;

  /// The day she gave birth.
  CalendarDay? get deliveryDate => _deliveryDate;

  /// Whether the estimate of periods is paused: during a pregnancy.
  bool get estimatePaused => _profile == Profile.pregnant;

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

  /// Logs flow on each of [days] that has none, as heavy as she said her
  /// periods usually are, and keeps whatever else is logged on them.
  void fillPeriodDays(Iterable<CalendarDay> days) {
    for (final day in days) {
      final entry = entryFor(day);
      if (entry.flow == null) {
        store.database.saveDay(
          entry.withFlow(_usualFlow ?? FlowIntensity.medium),
        );
      }
    }
    reload();
  }

  /// The day she last said her period had not started yet.
  CalendarDay? get periodNotYetOn => store.database.periodNotYetOn;

  /// The last flow day of the period she said was over.
  CalendarDay? get periodEndedAfter => store.database.periodEndedAfter;

  /// Does not ask again on [day] whether her period started.
  void answerPeriodNotYet(CalendarDay day) {
    store.database.periodNotYetOn = day;
    reload();
  }

  /// Does not ask again whether the period last logged on [lastFlowDay]
  /// goes on.
  void answerPeriodEnded(CalendarDay lastFlowDay) {
    store.database.periodEndedAfter = lastFlowDay;
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
    required Set<Wish> wishes,
    required Contraception? contraception,
    required Set<Tracked> tracked,
    required FlowIntensity? usualFlow,
    required PainLevel? usualPain,
    required Set<Symptom> startSigns,
    required Set<Symptom> beforePeriod,
  }) {
    final database = store.database;
    database.firstName = firstName;
    database.birthYear = birthYear;
    database.goals = goals;
    database.regularity = regularity;
    database.usualCycleLength = usualCycleLength;
    database.usualPeriodLength = usualPeriodLength;
    database.recentChanges = recentChanges;
    database.wishes = wishes;
    database.contraception = contraception;
    database.tracked = tracked;
    database.usualFlow = usualFlow;
    database.usualPain = usualPain;
    database.startSigns = startSigns;
    database.signsBeforePeriod = beforePeriod;
    reload();
  }

  /// Changes where she is in her life, with the date that goes with it
  /// when one is given. A date not given is kept as it was. [goals] are
  /// those of all the profiles she chose, when she chose several.
  void setProfile(
    Profile? profile, {
    Set<Goal>? goals,
    CalendarDay? pregnancyStart,
    CalendarDay? deliveryDate,
  }) {
    final database = store.database;
    database.profile = profile;
    if (pregnancyStart != null) {
      database.pregnancyStart = pregnancyStart;
    }
    if (deliveryDate != null) {
      database.deliveryDate = deliveryDate;
    }
    database.goals = goals ?? goalsOf(profile);
    if (!followsACycle(profile)) {
      // No fertile window is estimated during a pregnancy or before
      // periods are back.
      database.fertilityEstimateEnabled = false;
    }
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
    _wishes = database.wishes;
    _contraception = database.contraception;
    _tracked = database.tracked;
    _usualFlow = database.usualFlow;
    _usualPain = database.usualPain;
    _startSigns = database.startSigns;
    _declaredBeforePeriod = database.signsBeforePeriod;
    _profile = database.profile;
    _pregnancyStart = database.pregnancyStart;
    _deliveryDate = database.deliveryDate;
    _reminderSettings = database.reminderSettings;
    _appLockEnabled = database.appLockEnabled;
    _appearance = database.appearance;
    _onboardingDone = database.onboardingDone;
    // During a pregnancy nothing is estimated. After a birth, only the
    // periods that came back count, and the first cycles are expected to
    // vary.
    final delivery = _deliveryDate;
    final afterBirth = _profile == Profile.postpartum && delivery != null;
    final starts = afterBirth
        ? startsSinceBirth(periodStartsFrom(_flowByDay), delivery)
        : periodStartsFrom(_flowByDay).toList();
    _prediction = _profile == Profile.pregnant
        ? null
        : const PeriodPredictor().predict(
            periodStarts: starts,
            usualCycleLength: afterBirth ? null : _usualCycleLength,
            // Without a declared length, the reference for her age stands in.
            referenceCycleLength: age == null ? null : referenceCycleLength,
            irregular:
                _regularity == CycleRegularity.irregular ||
                (afterBirth && starts.length <= cyclesBeforeSettledAfterBirth),
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
