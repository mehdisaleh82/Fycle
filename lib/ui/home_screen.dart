import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/cycle_status.dart';
import '../domain/fertility_estimate.dart';
import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'cycle_model.dart';
import 'cycle_summary_card.dart';
import 'day_sheet.dart';
import 'disclaimer_card.dart';
import 'fertility_card.dart';
import 'insights_screen.dart';
import 'month_calendar.dart';
import 'prediction_card.dart';
import 'settings_screen.dart';
import 'today_card.dart';

/// Home: the estimate for the next period, today's period in one tap, the
/// calendar of the month, and one button to log the rest of the day.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.model,
    required this.environment,
    required this.onEraseEverything,
  });

  final CycleModel model;
  final AppEnvironment environment;

  /// Deletes all data and returns to the first-launch screen.
  final Future<void> Function() onEraseEverything;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late int _year;
  late int _month;

  @override
  void initState() {
    super.initState();
    final today = widget.environment.today();
    _year = today.year;
    _month = today.month;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The day may have changed while the app was in the background.
    if (state == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  void _moveMonth(int delta) {
    final moved = DateTime(_year, _month + delta);
    setState(() {
      _year = moved.year;
      _month = moved.month;
    });
  }

  void _openDay(CalendarDay day) {
    showDaySheet(context, model: widget.model, day: day);
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SettingsScreen(
          model: widget.model,
          environment: widget.environment,
          onEraseEverything: widget.onEraseEverything,
        ),
      ),
    );
  }

  void _openInsights() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => InsightsScreen(
          model: widget.model,
          environment: widget.environment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final model = widget.model;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.insightsTitle,
            icon: const Icon(Icons.insights_outlined),
            onPressed: _openInsights,
          ),
          IconButton(
            tooltip: l10n.settingsTooltip,
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettings,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openDay(widget.environment.today()),
        icon: const Icon(Icons.edit_outlined),
        label: Text(l10n.homeLogToday),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: model,
          builder: (context, _) {
            final today = widget.environment.today();
            final summary = cycleSummaryToShow(model, today);
            final status = cycleStatusOn(
              today,
              flowByDay: model.flowByDay,
              prediction: model.prediction,
            );
            final fertility = <FertilityEstimate>[
              ...model.pastFertilityEstimates,
              // Nothing is said of a cycle left aside for months.
              if (status is! EstimateOutdated) ?model.fertilityEstimate,
            ];
            return SingleChildScrollView(
              // Room at the bottom so the button never hides the notice.
              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 96),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PredictionCard(
                    status: status,
                    usualCycleLength: model.usualCycleLength,
                  ),
                  if (model.fertilityEstimateEnabled &&
                      status is! NoEstimate &&
                      status is! EstimateOutdated) ...[
                    const SizedBox(height: 16),
                    FertilityCard(estimate: model.fertilityEstimate),
                  ],
                  if (summary != null) ...[
                    const SizedBox(height: 16),
                    CycleSummaryCard(
                      summary: summary,
                      onClose: () =>
                          model.dismissCycleSummary(summary.cycle.start),
                      onSeeTrends: _openInsights,
                    ),
                  ],
                  const SizedBox(height: 16),
                  TodayCard(model: model, today: today),
                  const SizedBox(height: 16),
                  MonthCalendar(
                    year: _year,
                    month: _month,
                    today: today,
                    flowByDay: model.flowByDay,
                    loggedDays: model.loggedDays,
                    prediction: model.prediction,
                    fertility: fertility,
                    showFertility: model.fertilityEstimateEnabled,
                    onDayTap: _openDay,
                    onPreviousMonth: () => _moveMonth(-1),
                    onNextMonth: () => _moveMonth(1),
                  ),
                  const SizedBox(height: 16),
                  const DisclaimerCard(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
