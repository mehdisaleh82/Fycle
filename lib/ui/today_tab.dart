import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/catch_up.dart';
import '../domain/cycle_overview.dart';
import '../domain/cycle_status.dart';
import '../domain/day_entry.dart';
import '../domain/flow_intensity.dart';
import '../domain/life_stage.dart';
import '../domain/period_end_estimate.dart';
import '../domain/start_profile.dart';
import '../l10n/app_localizations.dart';
import 'ahead_card.dart';
import 'app_environment.dart';
import 'catch_up_card.dart';
import 'coming_signs_card.dart';
import 'cycle_model.dart';
import 'cycle_summary_card.dart';
import 'follow_card.dart';
import 'guides_screen.dart';
import 'home_screen.dart';
import 'insights_screen.dart';
import 'labels.dart';
import 'life_stage_cards.dart';
import 'phase_card.dart';
import 'prediction_card.dart';

/// The home tab: the cycle, as a ring to touch, and what it says of today.
/// The journal of the day is filled in the journal tab, one tap away. The summary of a cycle that just ended comes once,
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

  /// How long the period going on may still last, when her past periods
  /// or what she said allow an estimate.
  PeriodEndEstimate? _periodEndEstimate(CycleStatus status) =>
      status is PeriodOngoing
      ? periodEndEstimate(
          dayOfPeriod: status.dayOfPeriod,
          cycles: model.cycles,
          declaredPeriodLength: model.usualPeriodLength,
        )
      : null;

  /// The same, in words.
  String? _periodEnd(AppLocalizations l10n, PeriodEndEstimate? estimate) {
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
        final periodEnd = _periodEndEstimate(status);
        final summary = cycleSummaryToShow(model, today);
        final ask = catchUpOn(
          today,
          flowByDay: model.flowByDay,
          status: status,
          cycles: model.cycles,
          declaredPeriodLength: model.usualPeriodLength,
          notYetOn: model.periodNotYetOn,
          endedAfter: model.periodEndedAfter,
        );
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
                  (model.prediction == null || model.deliveryDate == null))
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
                  periodEndLine: _periodEnd(l10n, periodEnd),
                  // The ring shows, lighter, the days the period may still
                  // last: it is going on, not over after the days logged.
                  periodEstimatedDays:
                      status is PeriodOngoing &&
                          periodEnd != null &&
                          cycleStart != null
                      ? today.daysSince(cycleStart) +
                            1 +
                            periodEnd.latestDaysLeft
                      : null,
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
              if (ask != null)
                CatchUpCard(model: model, today: today, ask: ask),
              // The journal is filled in its own tab: the home only says how
              // far the day is, and leads there.
              gap,
              _JournalShortcut(
                model: model,
                today: today,
                onOpen: () => onOpenTab(HomeTab.journal),
              ),
              PhaseCard(model: model, today: today, status: status),
              ComingSignsCard(model: model, today: today, status: status),
              AheadCard(model: model, today: today, status: status),
              IntimacyCarousel(model: model, today: today, status: status),
              GuideCard(model: model, today: today),
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

/// How much of today's journal is filled in, and the way to the journal
/// tab, where it is written.
class _JournalShortcut extends StatelessWidget {
  const _JournalShortcut({
    required this.model,
    required this.today,
    required this.onOpen,
  });

  final CycleModel model;
  final CalendarDay today;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final filled = model.entryFor(today).filledGroups;
    return Card(
      key: const ValueKey('journal-shortcut'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.todayEntryTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.todayEntryProgress(filled, DayEntry.groupCount),
              key: const ValueKey('home-progress'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const ValueKey('open-journal-today'),
              onPressed: onOpen,
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.homeOpenJournal),
            ),
          ],
        ),
      ),
    );
  }
}
