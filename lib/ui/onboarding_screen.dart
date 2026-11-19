import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/day_entry.dart';
import '../domain/flow_intensity.dart';
import '../domain/period_prediction.dart';
import '../domain/period_predictor.dart';
import '../l10n/app_localizations.dart';
import 'cycle_length_field.dart';
import 'cycle_model.dart';
import 'disclaimer_card.dart';
import 'labels.dart';
import 'theme.dart';

/// First launch: the start of the last period, the usual cycle length if it
/// is known, and nothing else. No account. The estimate shows as soon as a
/// date is chosen, and the screen can be passed without one.
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
  CalendarDay? _lastPeriod;
  bool _lengthError = false;

  @override
  void dispose() {
    _length.dispose();
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
      setState(() => _lastPeriod = CalendarDay.fromDateTime(picked));
    }
  }

  void _choose(CalendarDay day) => setState(() => _lastPeriod = day);

  /// The estimate the chosen date leads to, or null while there is nothing
  /// worth showing: no date, or a range that is already behind.
  PeriodPrediction? _preview() {
    final day = _lastPeriod;
    if (day == null) {
      return null;
    }
    final length = readCycleLength(_length.text);
    final prediction = const PeriodPredictor().predict(
      periodStarts: [day],
      usualCycleLength: length.valid ? length.days : null,
    );
    if (prediction == null || prediction.latestStart.isBefore(widget.today())) {
      return null;
    }
    return prediction;
  }

  void _start() {
    final day = _lastPeriod;
    final length = readCycleLength(_length.text);
    setState(() => _lengthError = !length.valid);
    if (day == null || !length.valid) {
      return;
    }
    // Only the day is asked. It is stored as a day of medium flow, which can
    // be corrected from the calendar.
    widget.model
      ..setUsualCycleLength(length.days)
      ..saveDay(DayEntry(day: day, flow: FlowIntensity.medium));
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
                    const SizedBox(height: 20),
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
                          ],
                        ),
                      ),
                    ),
                    if (preview != null) ...[
                      const SizedBox(height: 16),
                      _EstimatePreview(
                        prediction: preview,
                        usualCycleLength: readCycleLength(_length.text).days,
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
  });

  final PeriodPrediction prediction;

  /// The cycle length typed so far, if it is a valid one.
  final int? usualCycleLength;

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
                    : l10n.estimateBasisDefault(
                        PeriodPredictor.defaultCycleLength,
                      ),
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
