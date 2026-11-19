import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/day_entry.dart';
import '../domain/flow_intensity.dart';
import '../l10n/app_localizations.dart';
import 'cycle_length_field.dart';
import 'cycle_model.dart';
import 'disclaimer_card.dart';
import 'labels.dart';

/// First launch: the start of the last period, the usual cycle length if it
/// is known, and nothing else. No account.
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

  /// Called once the answers are saved.
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
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
              Text(l10n.privacyLine, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 32),
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
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  day == null ? l10n.onboardingChooseDate : fullDate(l10n, day),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                l10n.onboardingCycleLengthQuestion,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              CycleLengthField(
                controller: _length,
                showError: _lengthError,
                onChanged: (_) {
                  if (_lengthError) {
                    setState(() => _lengthError = false);
                  }
                },
              ),
              const SizedBox(height: 32),
              const DisclaimerCard(),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: day == null ? null : _start,
                child: Text(l10n.onboardingStart),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: widget.onRestore,
                child: Text(l10n.onboardingRestore),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
