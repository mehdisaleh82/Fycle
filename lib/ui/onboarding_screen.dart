import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/day_entry.dart';
import '../domain/flow_intensity.dart';
import '../domain/period_prediction.dart';
import '../domain/period_predictor.dart';
import '../domain/reference_cycle.dart';
import '../l10n/app_localizations.dart';
import 'birth_year_field.dart';
import 'cycle_length_field.dart';
import 'cycle_model.dart';
import 'disclaimer_card.dart';
import 'labels.dart';
import 'theme.dart';

/// First launch: what the app does in three lines, then the start of the
/// last period, the usual cycle length if it is known and, for whoever
/// wants figures at once, the start of earlier periods. No account. The
/// estimate shows as soon as a date is chosen, and the screen can be passed
/// without one.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.model,
    required this.today,
    required this.onDone,
    required this.onRestore,
  });

  final CycleModel model;
  final CalendarDay Function() today;

  /// Called once the answers are saved, or when the user goes on without
  /// giving a date.
  final VoidCallback onDone;

  /// Called when the user would rather restore a backup file.
  final VoidCallback onRestore;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  /// How far back the last period may be picked, in days.
  static const int _maxDaysBack = 366;

  final _length = TextEditingController();
  final _birthYear = TextEditingController();
  bool _birthYearError = false;
  CalendarDay? _lastPeriod;
  bool _lengthError = false;

  /// First days of earlier periods, most recent first.
  final List<CalendarDay> _earlier = [];

  /// Two period starts are at least this far apart.
  static const int _minDaysBetweenPeriods = 15;

  @override
  void dispose() {
    _length.dispose();
    _birthYear.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = widget.today();
    final last = DateTime(today.year, today.month, today.day);
    final current = _lastPeriod;
    final picked = await showDatePicker(
      context: context,
      initialDate: current == null
          ? last
          : DateTime(current.year, current.month, current.day),
      firstDate: last.subtract(const Duration(days: _maxDaysBack)),
      lastDate: last,
      // The system date picker has a fixed layout: beyond this size its
      // header no longer fits on a small phone.
      builder: (context, child) =>
          MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3, child: child!),
    );
    if (picked != null && mounted) {
      _choose(CalendarDay.fromDateTime(picked));
    }
  }

  /// Earlier periods are counted back from the last one: changing it
  /// starts them over.
  void _choose(CalendarDay day) => setState(() {
    if (day != _lastPeriod) {
      _earlier.clear();
    }
    _lastPeriod = day;
  });

  Future<void> _addEarlier() async {
    final from = _earlier.isEmpty ? _lastPeriod : _earlier.last;
    if (from == null) {
      return;
    }
    final latest = from.addDays(-_minDaysBetweenPeriods);
    final last = DateTime(latest.year, latest.month, latest.day);
    final suggested = from.addDays(-PeriodPredictor.defaultCycleLength);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(suggested.year, suggested.month, suggested.day),
      firstDate: last.subtract(const Duration(days: _maxDaysBack)),
      lastDate: last,
      builder: (context, child) =>
          MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3, child: child!),
    );
    if (picked != null && mounted) {
      setState(() => _earlier.add(CalendarDay.fromDateTime(picked)));
    }
  }

  /// The estimate the chosen date leads to, or null while there is nothing
  /// worth showing: no date, or a range that is already behind.
  PeriodPrediction? _preview() {
    final day = _lastPeriod;
    if (day == null) {
      return null;
    }
    final length = readCycleLength(_length.text);
    final prediction = const PeriodPredictor().predict(
      periodStarts: [day, ..._earlier],
      usualCycleLength: (length.valid ? length.days : null) ?? _ageReference(),
    );
    if (prediction == null || prediction.latestStart.isBefore(widget.today())) {
      return null;
    }
    return prediction;
  }

  /// The reference cycle length for the year of birth typed so far, or
  /// null when none is given.
  int? _ageReference() {
    final year = readBirthYear(_birthYear.text, widget.today().year);
    final age = ageIn(widget.today().year, year.year);
    return age == null ? null : referenceCycleLengthForAge(age);
  }

  void _start() {
    final day = _lastPeriod;
    final length = readCycleLength(_length.text);
    final birthYear = readBirthYear(_birthYear.text, widget.today().year);
    setState(() {
      _lengthError = !length.valid;
      _birthYearError = !birthYear.valid;
    });
    if (day == null || !length.valid || !birthYear.valid) {
      return;
    }
    widget.model.setBirthYear(birthYear.year);
    // Only the day is asked. It is stored as a day of medium flow, which can
    // be corrected from the calendar.
    widget.model
      ..setUsualCycleLength(length.days)
      ..saveDay(DayEntry(day: day, flow: FlowIntensity.medium));
    for (final earlier in _earlier) {
      widget.model.saveDay(DayEntry(day: earlier, flow: FlowIntensity.medium));
    }
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final day = _lastPeriod;
    final today = widget.today();
    final yesterday = today.addDays(-1);
    final preview = _preview();
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                    const SizedBox(height: 16),
                    for (final (icon, line) in [
                      (Icons.edit_outlined, l10n.onboardingIntro1),
                      (Icons.donut_large_outlined, l10n.onboardingIntro2),
                      (Icons.trending_up, l10n.onboardingIntro3),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ExcludeSemantics(
                              child: Icon(
                                icon,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                line,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.onboardingLastPeriodQuestion,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.onboardingLastPeriodHint,
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ChoiceChip(
                                  key: const ValueKey('last-period-today'),
                                  label: Text(l10n.onboardingToday),
                                  selected: day == today,
                                  onSelected: (_) => _choose(today),
                                ),
                                ChoiceChip(
                                  key: const ValueKey('last-period-yesterday'),
                                  label: Text(l10n.onboardingYesterday),
                                  selected: day == yesterday,
                                  onSelected: (_) => _choose(yesterday),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: _pickDate,
                              icon: const Icon(Icons.calendar_today),
                              label: Text(
                                day == null
                                    ? l10n.onboardingChooseDate
                                    : fullDate(l10n, day),
                              ),
                            ),
                            // Next to the question it answers: the app can
                            // be entered without a date.
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: TextButton(
                                key: const ValueKey('onboarding-skip'),
                                onPressed: widget.onDone,
                                child: Text(l10n.onboardingSkip),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.onboardingCycleLengthQuestion,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            CycleLengthField(
                              controller: _length,
                              showError: _lengthError,
                              // The estimate below follows what is typed.
                              onChanged: (_) =>
                                  setState(() => _lengthError = false),
                            ),
                            const SizedBox(height: 20),
                            BirthYearField(
                              controller: _birthYear,
                              currentYear: today.year,
                              showError: _birthYearError,
                              // The estimate below follows what is typed.
                              onChanged: (_) =>
                                  setState(() => _birthYearError = false),
                            ),
                            if (day != null) ...[
                              const SizedBox(height: 20),
                              Text(
                                l10n.onboardingEarlierTitle,
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.onboardingEarlierHint,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final earlier in _earlier)
                                    InputChip(
                                      key: ValueKey('earlier-$earlier'),
                                      label: Text(mediumDate(l10n, earlier)),
                                      deleteButtonTooltipMessage: l10n
                                          .onboardingRemoveDate(
                                            mediumDate(l10n, earlier),
                                          ),
                                      // Only the oldest can go: the others
                                      // are counted from one another.
                                      onDeleted: earlier == _earlier.last
                                          ? () => setState(_earlier.removeLast)
                                          : null,
                                    ),
                                ],
                              ),
                              OutlinedButton.icon(
                                key: const ValueKey('add-earlier-period'),
                                onPressed: _addEarlier,
                                icon: const Icon(Icons.add),
                                label: Text(l10n.onboardingAddEarlier),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (preview != null) ...[
                      const SizedBox(height: 16),
                      _EstimatePreview(
                        prediction: preview,
                        usualCycleLength: readCycleLength(_length.text).days,
                        referenceCycleLength:
                            _ageReference() ??
                            PeriodPredictor.defaultCycleLength,
                      ),
                    ],
                    const SizedBox(height: 16),
                    const DisclaimerCard(),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: widget.onRestore,
                      child: Text(l10n.onboardingRestore),
                    ),
                  ],
                ),
              ),
            ),
            // Always in reach, whatever the length of the page and above
            // the keyboard.
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 16),
              child: FilledButton(
                onPressed: day == null ? null : _start,
                child: Text(l10n.onboardingStart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The estimate, before anything is saved: a range of dates and what it is
/// based on, as on the home screen.
class _EstimatePreview extends StatelessWidget {
  const _EstimatePreview({
    required this.prediction,
    required this.usualCycleLength,
    required this.referenceCycleLength,
  });

  final PeriodPrediction prediction;

  /// The cycle length typed so far, if it is a valid one.
  final int? usualCycleLength;

  /// The reference length used when none is typed.
  final int referenceCycleLength;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = AccentColors.of(context);
    final declared = usualCycleLength;
    return DecoratedBox(
      key: const ValueKey('estimate-preview'),
      decoration: BoxDecoration(
        color: accent.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.statusNextRange(
                  shortDate(l10n, prediction.earliestStart),
                  shortDate(l10n, prediction.latestStart),
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: accent.onCard,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                declared != null
                    ? l10n.estimateBasisDeclared(declared)
                    : l10n.estimateBasisDefault(referenceCycleLength),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: accent.onCard,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
