import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/day_entry.dart';
import '../domain/flow_intensity.dart';
import '../domain/period_prediction.dart';
import '../domain/period_predictor.dart';
import '../l10n/app_localizations.dart';
import 'cycle_model.dart';
import 'disclaimer_card.dart';
import 'labels.dart';
import 'theme.dart';

/// First launch: one question, the start of the last period. It can be
/// answered now, or left for the day the period comes. No account, nothing
/// else to fill in: the rest can be set later, from the settings.
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

  /// Called once the answer is saved, or when the user goes on without
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

  CalendarDay? _lastPeriod;

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

  void _choose(CalendarDay day) => setState(() => _lastPeriod = day);

  /// The estimate the chosen date leads to, or null while there is nothing
  /// worth showing: no date, or a range that is already behind.
  PeriodPrediction? _preview() {
    final day = _lastPeriod;
    if (day == null) {
      return null;
    }
    final prediction = const PeriodPredictor().predict(periodStarts: [day]);
    if (prediction == null || prediction.latestStart.isBefore(widget.today())) {
      return null;
    }
    return prediction;
  }

  void _start() {
    final day = _lastPeriod;
    if (day == null) {
      return;
    }
    // Only the day is asked. It is stored as a day of medium flow, which can
    // be corrected from the journal.
    widget.model.saveDay(DayEntry(day: day, flow: FlowIntensity.medium));
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
                padding: const EdgeInsetsDirectional.fromSTEB(20, 24, 20, 8),
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
                    const SizedBox(height: 24),
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
                          ],
                        ),
                      ),
                    ),
                    if (preview != null) ...[
                      const SizedBox(height: 16),
                      _EstimatePreview(prediction: preview),
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
            // Always in reach, whatever the length of the page: start with
            // the date, or come in now and log the period the day it starts.
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: day == null ? null : _start,
                    child: Text(l10n.onboardingStart),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    key: const ValueKey('onboarding-skip'),
                    onPressed: widget.onDone,
                    child: Text(l10n.onboardingSkip),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
