import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/cycle_overview.dart';
import '../domain/cycle_status.dart';
import '../domain/flow_intensity.dart';
import '../domain/life_stage.dart';
import '../domain/period_end_estimate.dart';
import '../domain/start_profile.dart';
import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'coming_signs_card.dart';
import 'cycle_model.dart';
import 'cycle_summary_card.dart';
import 'follow_card.dart';
import 'home_screen.dart';
import 'insights_screen.dart';
import 'labels.dart';
import 'life_stage_cards.dart';
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
      declaredPeriodLength: model.usualPeriodLength,
    );
    if (estimate == null) {
      return null;
    }
    final from = estimate.earliestDaysLeft;
    final to = estimate.latestDaysLeft;
    if (estimate.periodsUsed == 0) {
      // From what she said, not from what she logged.
      return to == 0
          ? l10n.periodEndDeclaredToday
          : l10n.periodEndDeclaredDays(to);
    }
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
              if (model.profile == Profile.pregnant)
                PregnancyCard(model: model, today: today)
              else if (model.profile == Profile.postpartum &&
                  model.prediction == null)
                PostpartumCard(model: model, today: today)
              else
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
              ComingSignsCard(model: model, today: today, status: status),
              gap,
              TodayCard(
                model: model,
                today: today,
                onOpenDay: () => onOpenDay(today),
              ),
              if (model.profile == Profile.discovering ||
                  (model.goals.contains(Goal.understandBody) &&
                      followsACycle(model.profile))) ...[
                gap,
                const LearnCard(),
              ],
              gap,
              FollowCard(model: model, today: today),
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
