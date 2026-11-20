import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../data/device_auth.dart';
import '../domain/calendar_day.dart';
import '../domain/cycle_change.dart';
import '../domain/day_entry.dart';
import '../domain/flow_intensity.dart';
import '../domain/life_stage.dart';
import '../domain/pain_level.dart';
import '../domain/period_prediction.dart';
import '../domain/period_predictor.dart';
import '../domain/reference_cycle.dart';
import '../domain/reminders.dart';
import '../domain/start_profile.dart';
import '../domain/symptom.dart';
import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'cycle_model.dart';
import 'dialogs.dart';
import 'disclaimer_card.dart';
import 'labels.dart';
import 'launch_animation.dart';
import 'life_stage_cards.dart';
import 'theme.dart';

/// Name under which the phone remembers that the reminders were decided
/// once: turned on by default, or chosen during the setup.
const String reminderDefaultSuggestion = 'reminders_default';

/// Turning the lock on or off asks who is holding the phone first: a lock
/// that cannot be opened is never turned on, and a passer-by cannot turn it
/// off.
Future<void> changeAppLock(
  BuildContext context, {
  required CycleModel model,
  required DeviceAuth auth,
  required bool enabled,
}) async {
  final l10n = AppLocalizations.of(context);
  var outcome = AuthOutcome.unavailable;
  if (await auth.isAvailable()) {
    outcome = await auth.authenticate(l10n.lockReason);
  }
  switch (outcome) {
    case AuthOutcome.success:
      model.setAppLockEnabled(enabled);
    case AuthOutcome.failed:
      break;
    case AuthOutcome.unavailable:
      if (!enabled) {
        // Nothing can check any more: the lock protects nothing.
        model.setAppLockEnabled(false);
      } else if (context.mounted) {
        await showNotice(
          context,
          title: l10n.lockUnavailableTitle,
          body: l10n.lockUnavailableBody,
        );
      }
  }
}

enum _Step {
  welcome,
  privacy,
  name,
  birthYear,
  goals,
  wishes,
  keyDate,
  regularity,
  lengths,
  usual,
  contraception,
  changes,
  signs,
  lastPeriod,
  earlier,
  tracked,
  reminders,
  lock,
  ready,
}

/// The setup, at first launch: a few questions, one per screen, each of
/// which can be passed. What she answers is where the first estimate starts
/// from, and what the app shows her; her own dates take over afterwards.
/// No account, and nothing leaves the phone.
///
/// With [editing], the same questions about her come back from the
/// settings, filled in with what she answered, without the welcome, the
/// date of the last period or the settings of the phone.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.model,
    required this.environment,
    required this.onDone,
    this.onRestore,
    this.editing = false,
  });

  final CycleModel model;
  final AppEnvironment environment;

  /// Called once the answers are saved, or when the setup is passed as a
  /// whole.
  final VoidCallback onDone;

  /// Called when the user would rather restore a backup file.
  final VoidCallback? onRestore;

  final bool editing;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  /// How many months back the last period may be picked, this one included.
  static const int _monthsShown = 3;

  /// Where the lengths start when she touches them for the first time.
  static const int _firstPeriodLength = 5;

  /// How many earlier periods may be given, and how close to the last one
  /// an earlier period may start.
  static const int _maxEarlier = 3;
  static const int _earlierMonthsShown = 4;

  late _Step _step = widget.editing ? _Step.name : _Step.welcome;

  late final TextEditingController _name = TextEditingController(
    text: widget.model.firstName ?? '',
  );
  late int? _birthYear = widget.model.birthYear;

  /// Whether the wheel shows a year she chose: one she gave before, or one
  /// she turned the wheel to. Until then, the year in the middle is nobody's.
  late bool _yearChosen = _birthYear != null;
  late final FixedExtentScrollController _yearWheel =
      FixedExtentScrollController(
        initialItem: (_birthYear ?? _thisYear - 30) - _firstYear,
      );
  late Set<Goal> _goals = {...widget.model.goals};
  late Profile? _profile = widget.model.profile;

  /// The date that goes with a pregnancy (first day of the last period)
  /// or with a birth.
  CalendarDay? _keyDate;
  late CycleRegularity? _regularity = widget.model.regularity;
  late int? _cycleLength = widget.model.usualCycleLength;
  late int? _periodLength = widget.model.usualPeriodLength;
  late Set<RecentChange> _changes = {...widget.model.recentChanges};
  late Set<Wish> _wishes = {...widget.model.wishes};
  late Contraception? _contraception = widget.model.contraception;
  late Set<Tracked> _tracked = {...widget.model.tracked};
  late FlowIntensity? _usualFlow = widget.model.usualFlow;
  late PainLevel? _usualPain = widget.model.usualPain;
  late Set<Symptom> _signs = {...widget.model.startSigns};
  CalendarDay? _lastPeriod;

  /// First days of earlier periods, three at most.
  final Set<CalendarDay> _earlier = {};
  late ReminderSettings _reminders = widget.model.reminderSettings.copyWith(
    periodEnabled: true,
    dailyEnabled: true,
  );

  int get _thisYear => widget.environment.today().year;
  int get _firstYear => _thisYear - maxProfileAge;
  int get _lastYear => _thisYear - minProfileAge;
  int? get _age => ageIn(_thisYear, _birthYear);

  /// The screens she goes through, which depend on what she answered.
  List<_Step> get _steps {
    final cycle = followsACycle(_profile);
    final periods = cycle && hasPeriods(_regularity);
    final changes = cycle && asksAboutRecentChanges(goals: _goals, age: _age);
    return [
      if (!widget.editing) ...[_Step.welcome, _Step.privacy],
      _Step.name,
      _Step.birthYear,
      // Where she is decides what is asked next.
      _Step.goals,
      if (cycle) ...[_Step.wishes, _Step.regularity],
      if (periods) ...[_Step.lengths, _Step.usual],
      if (_profile != Profile.pregnant) _Step.contraception,
      if (changes) ...[_Step.changes, _Step.signs],
      if (!widget.editing && !cycle) _Step.keyDate,
      if (!widget.editing && periods) ...[
        _Step.lastPeriod,
        if (_lastPeriod != null) _Step.earlier,
      ],
      _Step.tracked,
      if (!widget.editing) ...[_Step.reminders, _Step.lock, _Step.ready],
    ];
  }

  @override
  void dispose() {
    _name.dispose();
    _yearWheel.dispose();
    super.dispose();
  }

  /// The estimate the chosen date leads to, or null while there is nothing
  /// worth showing: no date, or a range that is already behind.
  PeriodPrediction? _preview() {
    final day = _lastPeriod;
    if (day == null) {
      return null;
    }
    final age = _age;
    final prediction = const PeriodPredictor().predict(
      periodStarts: [day, ..._earlier],
      usualCycleLength: _cycleLength,
      referenceCycleLength: age == null
          ? null
          : referenceCycleLengthForAge(age),
      irregular: _regularity == CycleRegularity.irregular,
    );
    if (prediction == null ||
        prediction.latestStart.isBefore(widget.environment.today())) {
      return null;
    }
    return prediction;
  }

  void _back() {
    final steps = _steps;
    final index = steps.indexOf(_step);
    if (index <= 0) {
      if (widget.editing) {
        Navigator.of(context).pop();
      }
      return;
    }
    setState(() => _step = steps[index - 1]);
  }

  /// Goes to the next screen, or saves everything after the last one.
  void _advance() {
    FocusManager.instance.primaryFocus?.unfocus();
    final steps = _steps;
    final index = steps.indexOf(_step);
    if (index == steps.length - 1) {
      _finish();
      return;
    }
    setState(() => _step = steps[index + 1]);
  }

  Future<void> _next() async {
    switch (_step) {
      case _Step.birthYear:
        // The year in the middle of the wheel is her answer.
        _birthYear = _firstYear + _yearWheel.selectedItem;
      case _Step.reminders:
        await _saveReminders(
          followsACycle(_profile)
              ? _reminders
              : _reminders.copyWith(periodEnabled: false),
        );
        if (!mounted) {
          return;
        }
      default:
        break;
    }
    _advance();
  }

  /// Leaves the question of this screen unanswered.
  Future<void> _skip() async {
    switch (_step) {
      case _Step.name:
        _name.clear();
      case _Step.birthYear:
        _birthYear = null;
        _yearChosen = false;
      case _Step.goals:
        _goals = {};
        _profile = null;
      case _Step.keyDate:
        _keyDate = null;
      case _Step.regularity:
        _regularity = null;
      case _Step.lengths:
        _cycleLength = null;
        _periodLength = null;
      case _Step.changes:
        _changes = {};
      case _Step.lastPeriod:
        _lastPeriod = null;
        _earlier.clear();
      case _Step.earlier:
        _earlier.clear();
      case _Step.wishes:
        _wishes = {};
      case _Step.usual:
        _usualFlow = null;
        _usualPain = null;
      case _Step.contraception:
        _contraception = null;
      case _Step.signs:
        _signs = {};
      case _Step.tracked:
        _tracked = {};
      case _Step.reminders:
        await _saveReminders(
          _reminders.copyWith(periodEnabled: false, dailyEnabled: false),
        );
        if (!mounted) {
          return;
        }
      case _Step.welcome || _Step.privacy || _Step.lock || _Step.ready:
        break;
    }
    _advance();
  }

  /// Stores the reminders she chose. The phone is asked for its permission
  /// only if she wants at least one; refused, none is turned on, and she is
  /// told where to allow them.
  Future<void> _saveReminders(ReminderSettings wanted) async {
    final model = widget.model;
    final asks = wanted.periodEnabled || wanted.dailyEnabled;
    var allowed = false;
    if (asks) {
      try {
        allowed = await widget.environment.reminders.requestPermission();
      } on Exception {
        allowed = false;
      }
    }
    // She chose: nothing is turned on by default behind her afterwards.
    if (!model.suggestionDismissed(reminderDefaultSuggestion)) {
      model.dismissSuggestion(reminderDefaultSuggestion);
    }
    model.setReminderSettings(
      allowed
          ? wanted
          : wanted.copyWith(periodEnabled: false, dailyEnabled: false),
    );
    if (asks && !allowed && mounted) {
      final l10n = AppLocalizations.of(context);
      await showNotice(
        context,
        title: l10n.reminderPermissionTitle,
        body: l10n.reminderPermissionBody,
      );
    }
  }

  /// Whether the estimate of the fertile window is shown, going by what
  /// she answered.
  bool get _showsFertility =>
      followsACycle(_profile) &&
      showsFertilityFor(_goals, wishes: _wishes, contraception: _contraception);

  bool _same<T>(Set<T> a, Set<T> b) => a.length == b.length && a.containsAll(b);

  void _finish() {
    final model = widget.model;
    final cycle = followsACycle(_profile);
    final periods = cycle && hasPeriods(_regularity);
    final follows = cycle && asksAboutRecentChanges(goals: _goals, age: _age);
    // In the settings, the estimate of the fertile window only follows the
    // answers that changed: what she set by hand since is hers.
    final fertilityAnswered =
        _profile != null ||
        _goals.isNotEmpty ||
        _wishes.isNotEmpty ||
        _contraception != null;
    final fertilityChanged =
        !widget.editing ||
        _profile != model.profile ||
        !_same(_goals, model.goals) ||
        !_same(_wishes, model.wishes) ||
        _contraception != model.contraception;
    model.setStartProfile(
      firstName: _name.text,
      birthYear: _birthYear,
      goals: _goals,
      regularity: _regularity,
      usualCycleLength: periods ? _cycleLength : null,
      usualPeriodLength: periods ? _periodLength : null,
      recentChanges: follows ? _changes : const {},
      wishes: _wishes,
      contraception: _contraception,
      tracked: _tracked,
      usualFlow: periods ? _usualFlow : null,
      usualPain: periods ? _usualPain : null,
      startSigns: follows ? _signs : const {},
    );
    if (fertilityAnswered && fertilityChanged) {
      model.setFertilityEstimateEnabled(_showsFertility);
    }
    if (_profile != model.profile || _keyDate != null) {
      // A pregnancy noted from the settings counts from the last period
      // logged, until she gives another date.
      final lastLogged = model.cycles.isEmpty ? null : model.cycles.last.start;
      model.setProfile(
        _profile,
        pregnancyStart: _profile == Profile.pregnant
            ? _keyDate ?? (model.pregnancyStart == null ? lastLogged : null)
            : null,
        deliveryDate: _profile == Profile.postpartum ? _keyDate : null,
      );
    }
    if (!model.suggestionDismissed(fertilityFromAnswers)) {
      model.dismissSuggestion(fertilityFromAnswers);
    }
    final day = _lastPeriod;
    if (day != null && periods && !widget.editing) {
      // Only first days are asked. Each is stored as one day of the flow
      // she calls usual, medium otherwise; the journal corrects it.
      for (final start in [..._earlier, day]) {
        model.saveDay(
          DayEntry(day: start, flow: _usualFlow ?? FlowIntensity.medium),
        );
      }
    }
    widget.onDone();
  }

  /// What her answers set, in plain sentences: shown before she starts.
  List<(IconData, String)> _recap(AppLocalizations l10n) {
    final model = widget.model;
    final prediction = _preview();
    final reminders = model.reminderSettings;
    return [
      if (_profile == Profile.pregnant)
        (Icons.pregnant_woman, l10n.recapPregnancy)
      else if (_profile == Profile.postpartum)
        (Icons.child_friendly_outlined, l10n.recapPostpartum)
      else if (prediction == null)
        (Icons.event_outlined, l10n.recapNoDate)
      else ...[
        (
          Icons.event_outlined,
          prediction.cyclesUsed > 0
              ? l10n.recapCycleOwn(prediction.estimatedCycleLength)
              : _cycleLength != null
              ? l10n.recapCycleDeclared(prediction.estimatedCycleLength)
              : _age != null
              ? l10n.recapCycleAge(prediction.estimatedCycleLength)
              : l10n.recapCycleDefault(prediction.estimatedCycleLength),
        ),
        (
          Icons.swap_horiz,
          l10n.recapRange(
            prediction.latestStart.daysSince(prediction.earliestStart) ~/ 2,
          ),
        ),
      ],
      if (followsACycle(_profile))
        (
          Icons.egg_outlined,
          _contraception == Contraception.hormonal
              ? l10n.recapFertilityHormonal
              : _showsFertility
              ? l10n.recapFertilityOn
              : l10n.recapFertilityOff,
        ),
      if (_tracked.isNotEmpty)
        (
          Icons.edit_note,
          l10n.recapJournal(
            [
              for (final kind in Tracked.values)
                if (_tracked.contains(kind)) trackedLabel(l10n, kind),
            ].join(l10n.listSeparator),
          ),
        ),
      if (asksAboutRecentChanges(goals: _goals, age: _age))
        (Icons.timeline, l10n.recapChanges),
      (
        Icons.notifications_outlined,
        reminders.periodEnabled || reminders.dailyEnabled
            ? l10n.recapRemindersOn
            : l10n.recapRemindersOff,
      ),
      if (model.appLockEnabled) (Icons.lock_outline, l10n.recapLockOn),
    ];
  }

  Future<void> _pickTime(
    ClockTime current,
    ValueChanged<ClockTime> onPicked,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
      // The system time picker has a fixed layout.
      builder: (context, child) =>
          MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3, child: child!),
    );
    if (picked != null && mounted) {
      setState(() => onPicked(ClockTime(picked.hour, picked.minute)));
    }
  }

  void _toggle<T>(Set<T> set, T value) => setState(() {
    if (!set.remove(value)) {
      set.add(value);
    }
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final steps = _steps;
    final index = steps.indexOf(_step);
    final last = index == steps.length - 1;
    final plain =
        _step == _Step.welcome ||
        _step == _Step.privacy ||
        _step == _Step.ready;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TopBar(
              step: index + 1,
              total: steps.length,
              onBack: index > 0 || widget.editing ? _back : null,
              closes: index == 0 && widget.editing,
              onSkip: plain ? null : _skip,
            ),
            Expanded(
              child: SingleChildScrollView(
                key: ValueKey(_step),
                padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 16),
                child: _body(context, l10n),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    key: ValueKey(
                      _step == _Step.ready
                          ? 'onboarding-finish'
                          : 'onboarding-next',
                    ),
                    // A year is an answer only once the wheel was turned.
                    onPressed: _step == _Step.birthYear && !_yearChosen
                        ? null
                        : _next,
                    child: Text(switch (_step) {
                      _Step.welcome => l10n.setupBegin,
                      _Step.ready => l10n.onboardingStart,
                      _ => last ? l10n.save : l10n.setupNext,
                    }),
                  ),
                  if (_step == _Step.welcome) ...[
                    const SizedBox(height: 8),
                    OutlinedButton(
                      key: const ValueKey('onboarding-skip'),
                      onPressed: widget.onDone,
                      child: Text(l10n.setupSkipAll),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    switch (_step) {
      case _Step.welcome:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: _MarkTile(size: 88),
            ),
            const SizedBox(height: 20),
            Semantics(
              header: true,
              child: Text(
                l10n.onboardingTitle,
                style: theme.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.privacyLine,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.setupWelcomeBody,
              key: const ValueKey('onboarding-months'),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            const DisclaimerCard(),
            if (widget.onRestore != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: widget.onRestore,
                child: Text(l10n.onboardingRestore),
              ),
            ],
          ],
        );
      case _Step.name:
        return _Question(
          title: l10n.setupNameTitle,
          hint: l10n.setupNameHint,
          child: TextField(
            key: const ValueKey('first-name'),
            controller: _name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            inputFormatters: [LengthLimitingTextInputFormatter(30)],
            onSubmitted: (_) => _next(),
            decoration: InputDecoration(labelText: l10n.setupNameLabel),
          ),
        );
      case _Step.birthYear:
        return _Question(
          lead: _name.text.trim().isEmpty
              ? null
              : l10n.setupGreeting(_name.text.trim()),
          title: l10n.setupBirthTitle,
          hint: l10n.setupBirthHint,
          child: _YearWheel(
            controller: _yearWheel,
            firstYear: _firstYear,
            lastYear: _lastYear,
            onChanged: () => setState(() => _yearChosen = true),
          ),
        );
      case _Step.goals:
        return _Question(
          title: l10n.setupProfileTitle,
          hint: l10n.setupProfileHint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (profile, icon, label, detail) in [
                (
                  Profile.discovering,
                  Icons.explore_outlined,
                  l10n.profileDiscovering,
                  l10n.profileDiscoveringDetail,
                ),
                (
                  Profile.tracking,
                  Icons.water_drop_outlined,
                  l10n.profileTracking,
                  l10n.profileTrackingDetail,
                ),
                (
                  Profile.conceiving,
                  Icons.favorite_border,
                  l10n.profileConceiving,
                  l10n.profileConceivingDetail,
                ),
                (
                  Profile.pregnant,
                  Icons.pregnant_woman,
                  l10n.profilePregnant,
                  l10n.profilePregnantDetail,
                ),
                (
                  Profile.postpartum,
                  Icons.child_friendly_outlined,
                  l10n.profilePostpartum,
                  l10n.profilePostpartumDetail,
                ),
                (
                  Profile.perimenopause,
                  Icons.timelapse,
                  l10n.profilePerimenopause,
                  l10n.profilePerimenopauseDetail,
                ),
              ])
                _Choice(
                  key: ValueKey('profile-${profile.name}'),
                  icon: icon,
                  label: label,
                  detail: detail,
                  selected: _profile == profile,
                  onTap: () => setState(() {
                    _profile = profile;
                    _goals = goalsOf(profile);
                  }),
                ),
              if (_profile == Profile.conceiving) ...[
                const SizedBox(height: 4),
                // The estimate of the fertile window comes with what it is
                // not (rule 7).
                Text(
                  l10n.fertilityWarning,
                  key: const ValueKey('goal-conceive-warning'),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        );
      case _Step.keyDate:
        final pregnant = _profile == Profile.pregnant;
        final date = _keyDate;
        return _Question(
          title: pregnant
              ? l10n.onboardingLastPeriodQuestion
              : l10n.setupBirthDateTitle,
          hint: pregnant
              ? l10n.setupPregnancyDateHint
              : l10n.setupBirthDateHint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (date != null) ...[
                Text(
                  fullDate(l10n, date),
                  key: const ValueKey('key-date'),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton.icon(
                key: const ValueKey('key-date-pick'),
                onPressed: () async {
                  final picked = await pickPastDay(
                    context,
                    today: widget.environment.today(),
                    daysBack: pregnant ? pregnancyDaysBack : birthDaysBack,
                    current: date,
                  );
                  if (picked != null && mounted) {
                    setState(() => _keyDate = picked);
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  date == null ? l10n.setupChooseDate : l10n.changeDate,
                ),
              ),
            ],
          ),
        );
      case _Step.regularity:
        return _Question(
          title: l10n.setupRegularTitle,
          hint: l10n.setupRegularHint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (value, label) in [
                (CycleRegularity.regular, l10n.regularYes),
                (CycleRegularity.irregular, l10n.regularNo),
                (CycleRegularity.unknown, l10n.regularUnknown),
                (CycleRegularity.noPeriods, l10n.regularNoPeriods),
              ])
                _Choice(
                  key: ValueKey('regularity-${value.name}'),
                  label: label,
                  selected: _regularity == value,
                  // One answer: it leads straight to the next question.
                  onTap: () {
                    _regularity = value;
                    if (_steps.last == _Step.regularity) {
                      // Nothing follows: the button below saves.
                      setState(() {});
                    } else {
                      _advance();
                    }
                  },
                ),
            ],
          ),
        );
      case _Step.lengths:
        return _Question(
          title: l10n.setupLengthsTitle,
          hint: l10n.setupLengthsHint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LengthStepper(
                name: 'cycle-length',
                label: l10n.setupCycleLength,
                helper: l10n.setupCycleLengthHelper,
                value: _cycleLength,
                min: PeriodPredictor.minCycleLength,
                max: PeriodPredictor.maxCycleLength,
                startAt: referenceCycleLengthForAge(_age),
                onChanged: (days) => setState(() => _cycleLength = days),
              ),
              const SizedBox(height: 12),
              _LengthStepper(
                name: 'period-length',
                label: l10n.setupPeriodLength,
                helper: l10n.setupPeriodLengthHelper,
                value: _periodLength,
                min: minPeriodLength,
                max: maxPeriodLength,
                startAt: _firstPeriodLength,
                onChanged: (days) => setState(() => _periodLength = days),
              ),
            ],
          ),
        );
      case _Step.changes:
        return _Question(
          title: l10n.setupChangesTitle,
          hint: l10n.setupChangesHint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final change in offeredChanges)
                _Choice(
                  key: ValueKey('change-${change.name}'),
                  label: recentChangeLabel(l10n, change),
                  selected: _changes.contains(change),
                  several: true,
                  onTap: () => setState(() {
                    if (_changes.remove(change)) {
                      return;
                    }
                    // "Nothing" goes with no change, and a change does not
                    // go with its opposite.
                    if (change == RecentChange.nothing) {
                      _changes = {change};
                    } else {
                      _changes
                        ..remove(RecentChange.nothing)
                        ..remove(RecentChange.lengthChanged)
                        ..remove(oppositeOf(change))
                        ..add(change);
                    }
                  }),
                ),
            ],
          ),
        );
      case _Step.lastPeriod:
        final today = widget.environment.today();
        final day = _lastPeriod;
        final preview = _preview();
        return _Question(
          title: l10n.onboardingLastPeriodQuestion,
          hint: l10n.setupLastHint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (day != null) ...[
                Text(
                  fullDate(l10n, day),
                  key: const ValueKey('last-period-date'),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
              ],
              if (preview != null) ...[
                _EstimatePreview(prediction: preview),
                const SizedBox(height: 8),
              ],
              for (var back = 0; back < _monthsShown; back++)
                _PickMonth(
                  year: DateTime(today.year, today.month - back).year,
                  month: DateTime(today.year, today.month - back).month,
                  today: today,
                  latest: today,
                  selected: {?day},
                  onPick: (picked) => setState(() {
                    _lastPeriod = picked;
                    // Earlier periods are earlier than this one.
                    _earlier.clear();
                  }),
                ),
            ],
          ),
        );
      case _Step.reminders:
        final reminders = _reminders;
        String timeText(ClockTime time) =>
            TimeOfDay(hour: time.hour, minute: time.minute).format(context);
        return _Question(
          title: l10n.setupRemindersTitle,
          hint: l10n.setupRemindersHint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (followsACycle(_profile))
                SwitchListTile(
                  key: const ValueKey('setup-period-reminder'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.setupPeriodReminder),
                  subtitle: Text(l10n.setupPeriodReminderHint),
                  value: reminders.periodEnabled,
                  onChanged: (on) => setState(
                    () => _reminders = reminders.copyWith(periodEnabled: on),
                  ),
                ),
              if (followsACycle(_profile) && reminders.periodEnabled) ...[
                Wrap(
                  spacing: 8,
                  children: [
                    for (final days in ReminderSettings.periodDaysBeforeChoices)
                      ChoiceChip(
                        key: ValueKey('setup-days-before-$days'),
                        label: Text(l10n.reminderDaysBefore(days)),
                        selected: reminders.periodDaysBefore == days,
                        onSelected: (_) => setState(
                          () => _reminders = reminders.copyWith(
                            periodDaysBefore: days,
                          ),
                        ),
                      ),
                  ],
                ),
                ListTile(
                  key: const ValueKey('setup-period-time'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule),
                  title: Text(l10n.reminderTime),
                  subtitle: Text(timeText(reminders.periodTime)),
                  onTap: () => _pickTime(
                    reminders.periodTime,
                    (time) =>
                        _reminders = _reminders.copyWith(periodTime: time),
                  ),
                ),
              ],
              if (followsACycle(_profile)) const Divider(),
              SwitchListTile(
                key: const ValueKey('setup-daily-reminder'),
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.setupDailyReminder),
                subtitle: Text(l10n.setupDailyReminderHint),
                value: reminders.dailyEnabled,
                onChanged: (on) => setState(
                  () => _reminders = reminders.copyWith(dailyEnabled: on),
                ),
              ),
              if (reminders.dailyEnabled)
                ListTile(
                  key: const ValueKey('setup-daily-time'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule),
                  title: Text(l10n.reminderTime),
                  subtitle: Text(timeText(reminders.dailyTime)),
                  onTap: () => _pickTime(
                    reminders.dailyTime,
                    (time) => _reminders = _reminders.copyWith(dailyTime: time),
                  ),
                ),
            ],
          ),
        );
      case _Step.lock:
        return _Question(
          title: l10n.setupLockTitle,
          hint: l10n.setupLockHint,
          child: ListenableBuilder(
            listenable: widget.model,
            builder: (context, _) => SwitchListTile(
              key: const ValueKey('setup-lock'),
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.fingerprint),
              title: Text(l10n.lockTitle),
              subtitle: Text(l10n.lockSubtitle),
              value: widget.model.appLockEnabled,
              onChanged: (on) => changeAppLock(
                context,
                model: widget.model,
                auth: widget.environment.deviceAuth,
                enabled: on,
              ),
            ),
          ),
        );
      case _Step.privacy:
        return _Question(
          title: l10n.setupPrivacyTitle,
          hint: l10n.setupPrivacyHint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (icon, text) in [
                (Icons.person_off_outlined, l10n.privacyNoAccount),
                (Icons.phonelink_lock, l10n.privacyOnPhone),
                (Icons.wifi_off, l10n.privacyBackup),
                (Icons.block, l10n.privacyNoAds),
              ])
                _Line(icon: icon, text: text),
            ],
          ),
        );
      case _Step.wishes:
        return _Question(
          title: l10n.setupWishesTitle,
          hint: l10n.setupWishesHint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (wish, label) in [
                (Wish.knowWhen, l10n.wishKnowWhen),
                (Wish.knowUsualRanges, l10n.wishKnowUsualRanges),
                (Wish.fertileWindow, l10n.wishFertileWindow),
                (Wish.afterContraception, l10n.wishAfterContraception),
                (Wish.whatComesBack, l10n.wishWhatComesBack),
              ])
                _Choice(
                  key: ValueKey('wish-${wish.name}'),
                  label: label,
                  selected: _wishes.contains(wish),
                  several: true,
                  onTap: () => _toggle(_wishes, wish),
                ),
              if (_wishes.contains(Wish.fertileWindow)) ...[
                const SizedBox(height: 4),
                Text(l10n.fertilityWarning, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        );
      case _Step.usual:
        return _Question(
          title: l10n.setupUsualTitle,
          hint: l10n.setupUsualHint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.setupUsualFlow, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final flow in [
                    FlowIntensity.light,
                    FlowIntensity.medium,
                    FlowIntensity.heavy,
                  ])
                    ChoiceChip(
                      key: ValueKey('usual-flow-${flow.name}'),
                      label: Text(flowLabel(l10n, flow)),
                      selected: _usualFlow == flow,
                      onSelected: (on) =>
                          setState(() => _usualFlow = on ? flow : null),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Text(l10n.setupUsualPain, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final pain in PainLevel.values)
                    ChoiceChip(
                      key: ValueKey('usual-pain-${pain.name}'),
                      label: Text(painLabel(l10n, pain)),
                      selected: _usualPain == pain,
                      onSelected: (on) =>
                          setState(() => _usualPain = on ? pain : null),
                    ),
                ],
              ),
            ],
          ),
        );
      case _Step.contraception:
        return _Question(
          title: l10n.setupContraceptionTitle,
          hint: l10n.setupContraceptionHint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (value, label) in [
                (Contraception.none, l10n.contraceptionNone),
                (Contraception.hormonal, l10n.contraceptionHormonal),
                (Contraception.nonHormonal, l10n.contraceptionNonHormonal),
              ])
                _Choice(
                  key: ValueKey('contraception-${value.name}'),
                  label: label,
                  selected: _contraception == value,
                  onTap: () {
                    _contraception = value;
                    _advance();
                  },
                ),
            ],
          ),
        );
      case _Step.signs:
        return _Question(
          title: l10n.setupSignsTitle,
          hint: l10n.setupSignsHint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final sign in changeSigns)
                _Choice(
                  key: ValueKey('sign-${sign.name}'),
                  label: symptomLabel(l10n, sign),
                  selected: _signs.contains(sign),
                  several: true,
                  onTap: () => _toggle(_signs, sign),
                ),
            ],
          ),
        );
      case _Step.earlier:
        final last = _lastPeriod!;
        final preview = _preview();
        // An earlier period starts at least a short cycle before.
        final latest = last.addDays(-PeriodPredictor.minCycleLength);
        return _Question(
          title: l10n.setupEarlierTitle,
          hint: l10n.setupEarlierHint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (preview != null) ...[
                _EstimatePreview(prediction: preview),
                const SizedBox(height: 8),
              ],
              for (var back = 0; back < _earlierMonthsShown; back++)
                _PickMonth(
                  year: DateTime(latest.year, latest.month - back).year,
                  month: DateTime(latest.year, latest.month - back).month,
                  today: widget.environment.today(),
                  latest: latest,
                  selected: _earlier,
                  onPick: (picked) => setState(() {
                    if (!_earlier.remove(picked) &&
                        _earlier.length < _maxEarlier) {
                      _earlier.add(picked);
                    }
                  }),
                ),
            ],
          ),
        );
      case _Step.tracked:
        return _Question(
          title: l10n.setupTrackedTitle,
          hint: l10n.setupTrackedHint,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (kind, icon) in [
                (Tracked.pain, Icons.healing_outlined),
                (Tracked.mood, Icons.mood),
                (Tracked.sleep, Icons.bedtime_outlined),
                (Tracked.libido, Icons.favorite_border),
                (Tracked.symptoms, Icons.checklist),
              ])
                _Choice(
                  key: ValueKey('tracked-${kind.name}'),
                  icon: icon,
                  label: trackedLabel(l10n, kind),
                  selected: _tracked.contains(kind),
                  several: true,
                  onTap: () => _toggle(_tracked, kind),
                ),
            ],
          ),
        );
      case _Step.ready:
        final name = _name.text.trim();
        final preview = _preview();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Center(child: _MarkTile(size: 104)),
            const SizedBox(height: 20),
            Semantics(
              header: true,
              child: Text(
                name.isEmpty
                    ? l10n.setupReadyTitle
                    : l10n.setupReadyTitleName(name),
                key: const ValueKey('setup-ready'),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.setupReadyBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (preview != null) ...[
              const SizedBox(height: 20),
              _EstimatePreview(prediction: preview),
            ],
            const SizedBox(height: 24),
            Semantics(
              header: true,
              child: Text(
                l10n.recapTitle,
                key: const ValueKey('setup-recap'),
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            for (final (icon, text) in _recap(l10n))
              _Line(icon: icon, text: text),
          ],
        );
    }
  }
}

/// The way back, how far she is, and the way past the question.
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.step,
    required this.total,
    required this.onBack,
    required this.closes,
    required this.onSkip,
  });

  final int step;
  final int total;
  final VoidCallback? onBack;

  /// Whether going back leaves the screen: a cross then, not an arrow.
  final bool closes;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onBack = this.onBack;
    final onSkip = this.onSkip;
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8, 4, 8, 0),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: onBack == null
                  ? null
                  : IconButton(
                      key: const ValueKey('onboarding-back'),
                      tooltip: closes
                          ? MaterialLocalizations.of(context).closeButtonTooltip
                          : l10n.setupBack,
                      onPressed: onBack,
                      icon: Icon(closes ? Icons.close : Icons.arrow_back),
                    ),
            ),
            Expanded(
              child: Semantics(
                label: l10n.setupProgress(step, total),
                child: ExcludeSemantics(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: step / total,
                      minHeight: 4,
                    ),
                  ),
                ),
              ),
            ),
            // The bar keeps its place whether or not the question can be
            // passed.
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48),
              child: onSkip == null
                  ? null
                  : MediaQuery.withClampedTextScaling(
                      maxScaleFactor: 1.3,
                      child: TextButton(
                        key: const ValueKey('onboarding-step-skip'),
                        onPressed: onSkip,
                        child: Text(l10n.setupSkip),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One question: what is asked, why, and the way to answer.
class _Question extends StatelessWidget {
  const _Question({
    this.lead,
    required this.title,
    required this.hint,
    required this.child,
  });

  /// A word said before the question, such as a greeting.
  final String? lead;
  final String title;
  final String hint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lead = this.lead;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        if (lead != null) ...[
          Text(
            lead,
            key: const ValueKey('setup-greeting'),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Semantics(
          header: true,
          child: Text(title, style: theme.textTheme.headlineSmall),
        ),
        const SizedBox(height: 8),
        Text(
          hint,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        child,
      ],
    );
  }
}

/// One plain statement, with its picture.
class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(child: Icon(icon, color: theme.colorScheme.primary)),
          const SizedBox(width: 14),
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

/// An answer to touch, as wide as the screen.
class _Choice extends StatelessWidget {
  const _Choice({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.detail,
    this.several = false,
  });

  final String label;

  /// A few words under the label, when the answer needs them.
  final String? detail;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  /// Whether several answers may be chosen together.
  final bool several;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final icon = this.icon;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: selected ? scheme.primary : scheme.outlineVariant,
        width: selected ? 2 : 1,
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Semantics(
        button: true,
        checked: several ? selected : null,
        selected: several ? null : selected,
        child: Material(
          // A chosen answer is filled in full: it cannot be missed.
          color: selected ? scheme.primary : scheme.surface,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 60),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 12, 12),
                child: Row(
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        color: selected ? scheme.onPrimary : scheme.primary,
                      ),
                      const SizedBox(width: 14),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: selected
                                  ? scheme.onPrimary
                                  : scheme.onSurface,
                            ),
                          ),
                          if (detail != null)
                            Text(
                              detail!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: selected
                                    ? scheme.onPrimary
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      selected
                          ? Icons.check_circle
                          : (several
                                ? Icons.add_circle_outline
                                : Icons.radio_button_unchecked),
                      color: selected ? scheme.onPrimary : scheme.outline,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The years to choose from, on a wheel: the one in the middle is hers.
class _YearWheel extends StatefulWidget {
  const _YearWheel({
    required this.controller,
    required this.firstYear,
    required this.lastYear,
    required this.onChanged,
  });

  final FixedExtentScrollController controller;
  final int firstYear;
  final int lastYear;

  /// Called each time the wheel stops on another year.
  final VoidCallback onChanged;

  @override
  State<_YearWheel> createState() => _YearWheelState();
}

class _YearWheelState extends State<_YearWheel> {
  late int _year = widget.firstYear + widget.controller.initialItem;

  void _move(int by) {
    final year = (_year + by).clamp(widget.firstYear, widget.lastYear);
    widget.controller.jumpToItem(year - widget.firstYear);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // A wheel has a fixed height: its years stop growing past a point.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: Semantics(
        key: const ValueKey('birth-year-wheel'),
        container: true,
        value: '$_year',
        increasedValue:
            '${(_year + 1).clamp(widget.firstYear, widget.lastYear)}',
        decreasedValue:
            '${(_year - 1).clamp(widget.firstYear, widget.lastYear)}',
        onIncrease: () => _move(1),
        onDecrease: () => _move(-1),
        child: ExcludeSemantics(
          child: SizedBox(
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // The band the chosen year sits in.
                Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                ListWheelScrollView.useDelegate(
                  controller: widget.controller,
                  itemExtent: 56,
                  diameterRatio: 1.6,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    HapticFeedback.selectionClick();
                    setState(() => _year = widget.firstYear + index);
                    widget.onChanged();
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: widget.lastYear - widget.firstYear + 1,
                    builder: (context, index) {
                      final year = widget.firstYear + index;
                      final chosen = year == _year;
                      return Center(
                        child: Text(
                          '$year',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: chosen
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: chosen
                                ? scheme.onPrimaryContainer
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A number of days, one more or one fewer at a time. Unknown until it is
/// touched.
class _LengthStepper extends StatelessWidget {
  const _LengthStepper({
    required this.name,
    required this.label,
    required this.helper,
    required this.value,
    required this.min,
    required this.max,
    required this.startAt,
    required this.onChanged,
  });

  /// Start of the keys of its buttons.
  final String name;
  final String label;
  final String helper;
  final int? value;
  final int min;
  final int max;

  /// The value it takes when touched for the first time.
  final int startAt;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final value = this.value;
    void move(int by) =>
        onChanged(value == null ? startAt : (value + by).clamp(min, max));
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(label, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              helper,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton.filledTonal(
                  key: ValueKey('$name-minus'),
                  tooltip: l10n.setupFewer,
                  onPressed: value == min ? null : () => move(-1),
                  icon: const Icon(Icons.remove),
                ),
                Expanded(
                  child: Text(
                    value == null ? l10n.setupNotGiven : l10n.setupDays(value),
                    key: ValueKey('$name-value'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton.filledTonal(
                  key: ValueKey('$name-plus'),
                  tooltip: l10n.setupMore,
                  onPressed: value == max ? null : () => move(1),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One month to pick first days of periods in. Days after [latest] cannot
/// be picked.
class _PickMonth extends StatelessWidget {
  const _PickMonth({
    required this.year,
    required this.month,
    required this.today,
    required this.latest,
    required this.selected,
    required this.onPick,
  });

  final int year;
  final int month;
  final CalendarDay today;

  /// The last day that can be picked.
  final CalendarDay latest;
  final Set<CalendarDay> selected;
  final ValueChanged<CalendarDay> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final material = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final firstWeekday = material.firstDayOfWeekIndex; // 0 is Sunday.
    final leading = (DateTime(year, month).weekday % 7 - firstWeekday + 7) % 7;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final rows = ((leading + daysInMonth) / 7).ceil();

    Widget cell(int slot) {
      final dayOfMonth = slot - leading + 1;
      if (dayOfMonth < 1 || dayOfMonth > daysInMonth) {
        return const SizedBox(height: 44);
      }
      final day = CalendarDay(year, month, dayOfMonth);
      final future = day.isAfter(latest);
      final chosen = selected.contains(day);
      final isToday = day == today;
      return Semantics(
        button: !future,
        selected: chosen,
        label: fullDate(l10n, day),
        excludeSemantics: true,
        child: InkResponse(
          key: ValueKey('pick-$day'),
          onTap: future ? null : () => onPick(day),
          radius: 24,
          child: SizedBox(
            height: 44,
            child: Center(
              child: Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: chosen ? PeriodColors.of(context).fill : null,
                  border: isToday && !chosen
                      ? Border.all(color: scheme.primary, width: 2)
                      : null,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    material.formatDecimal(dayOfMonth),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: chosen || isToday
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: chosen
                          ? PeriodColors.of(context).onFill
                          : future
                          ? scheme.onSurface.withValues(alpha: 0.32)
                          : scheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              toBeginningOfSentenceCase(
                monthTitle(l10n, year, month),
                l10n.localeName,
              ),
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 4),
          ExcludeSemantics(
            child: Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Center(
                      child: MediaQuery.withClampedTextScaling(
                        maxScaleFactor: 1.3,
                        child: Text(
                          material.narrowWeekdays[(firstWeekday + i) % 7],
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          for (var row = 0; row < rows; row++)
            Row(
              children: [
                for (var column = 0; column < 7; column++)
                  Expanded(child: cell(row * 7 + column)),
              ],
            ),
        ],
      ),
    );
  }
}

/// The mark of the app, as on its icon.
class _MarkTile extends StatelessWidget {
  const _MarkTile({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.14),
      decoration: BoxDecoration(
        color: launchNight,
        borderRadius: BorderRadius.circular(size * 0.24),
      ),
      child: const CycleMark(),
    ),
  );
}

/// The estimate, before anything is saved: a range of dates, as on the home
/// tab.
class _EstimatePreview extends StatelessWidget {
  const _EstimatePreview({required this.prediction});

  final PeriodPrediction prediction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = AccentColors.of(context);
    return DecoratedBox(
      key: const ValueKey('estimate-preview'),
      decoration: BoxDecoration(
        color: accent.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          l10n.statusNextRange(
            shortDate(l10n, prediction.earliestStart),
            shortDate(l10n, prediction.latestStart),
          ),
          style: theme.textTheme.titleMedium?.copyWith(color: accent.onCard),
        ),
      ),
    );
  }
}
