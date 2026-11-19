import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/cycle_overview.dart';
import '../domain/cycle_status.dart';
import '../domain/flow_intensity.dart';
import '../domain/period_end_estimate.dart';
import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'cycle_model.dart';
import 'cycle_summary_card.dart';
import 'home_screen.dart';
import 'insights_screen.dart';
import 'labels.dart';
import 'prediction_card.dart';
import 'today_card.dart';

/// The home tab, kept to two things: the cycle, as a ring to touch, and the
/// journal of the day. The summary of a cycle that just ended comes once,
/// until it is closed. Everything else is in the review and the settings.
class TodayTab extends StatelessWidget {
  const TodayTab({
    super.key,
    required this.header,
    required this.model,
    required this.environment,
    required this.onOpenDay,
    required this.onOpenTab,
  });

  final CycleModel model;
  final AppEnvironment environment;
  final ValueChanged<CalendarDay> onOpenDay;
  final ValueChanged<HomeTab> onOpenTab;

  /// Shown first and scrolled with the rest.
  final Widget header;

  /// How long the period going on may still last, in words, when her past
  /// periods allow an estimate.
  String? _periodEnd(AppLocalizations l10n, CycleStatus status) {
    if (status is! PeriodOngoing) {
      return null;
    }
    final estimate = periodEndEstimate(
      dayOfPeriod: status.dayOfPeriod,
      cycles: model.cycles,
    );
    if (estimate == null) {
      return null;
    }
    final from = estimate.earliestDaysLeft;
    final to = estimate.latestDaysLeft;
    if (to == 0) {
      return l10n.periodEndToday;
    }
    return from == to ? l10n.periodEndDays(to) : l10n.periodEndRange(from, to);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        final today = environment.today();
        final status = cycleStatusOn(
          today,
          flowByDay: model.flowByDay,
          prediction: model.prediction,
        );
        final overview = cycleOverviewOn(
          today,
          cycles: model.cycles,
          prediction: model.prediction,
          usualCycleLength: model.usualCycleLength,
          daysLogged: model.loggedDays.length,
          referenceCycleLength: model.referenceCycleLength,
        );
        final current = status is NoEstimate || status is EstimateOutdated
            ? null
            : model.fertilityEstimate;
        final cycleStart = model.cycles.isEmpty
            ? null
            : model.cycles.last.start;
        final summary = cycleSummaryToShow(model, today);
        const gap = SizedBox(height: 16);
        return SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              PredictionCard(
                status: status,
                overview: overview,
                today: today,
                cycleStart: cycleStart,
                ovulationLine: current == null
                    ? null
                    : l10n.fertilityOvulationRange(
                        shortDate(l10n, current.earliestOvulation),
                        shortDate(l10n, current.latestOvulation),
                      ),
                periodEndLine: _periodEnd(l10n, status),
                fertileFromDay: current == null || cycleStart == null
                    ? null
                    : current.windowStart.daysSince(cycleStart) + 1,
                fertileToDay: current == null || cycleStart == null
                    ? null
                    : current.windowEnd.daysSince(cycleStart) + 1,
                usualSignsFor: (dayOfCycle) => usualSignsAround(
                  dayOfCycle,
                  cycles: model.cycles,
                  days: model.days,
                ),
                entryFor: model.entryFor,
                onOpenDay: onOpenDay,
                onPeriodStartsToday: () => model.saveDay(
                  model.entryFor(today).withFlow(FlowIntensity.medium),
                ),
              ),
              gap,
              TodayCard(
                model: model,
                today: today,
                onOpenDay: () => onOpenDay(today),
              ),
              if (summary != null) ...[
                gap,
                CycleSummaryCard(
                  summary: summary,
                  onClose: () => model.dismissCycleSummary(summary.cycle.start),
                  // Straight to the trends, which the review keeps one
                  // tap away.
                  onSeeTrends: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => ReviewDetailScreen(
                        model: model,
                        environment: environment,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
