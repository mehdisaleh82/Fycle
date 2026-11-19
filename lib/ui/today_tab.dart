import 'package:material_ui/material_ui.dart';

import '../data/device_auth.dart';
import '../domain/calendar_day.dart';
import '../domain/cycle_overview.dart';
import '../domain/cycle_status.dart';
import '../domain/flow_intensity.dart';
import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'cycle_model.dart';
import 'cycle_summary_card.dart';
import 'dialogs.dart';
import 'home_cards.dart';
import 'home_screen.dart';
import 'labels.dart';
import 'prediction_card.dart';
import 'today_card.dart';

/// Names of the suggestions made once on the home tab.
const String reminderSuggestion = 'reminders';
const String lockSuggestion = 'lock';

/// The home tab, kept to the essential: where today falls in the cycle and
/// the journal of the day. What changes with each day or each entry may
/// follow (the summary of a cycle that ended, what usually comes around this
/// day, one suggestion); everything else is in the review.
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

  /// One line saying what the tab is for, shown first and scrolled with
  /// the rest.
  final Widget header;

  /// Turns both reminders on, if the phone allows notifications.
  Future<void> _turnRemindersOn(BuildContext context) async {
    bool allowed;
    try {
      allowed = await environment.reminders.requestPermission();
    } on Exception {
      allowed = false;
    }
    if (allowed) {
      model.setReminderSettings(
        model.reminderSettings.copyWith(
          periodEnabled: true,
          dailyEnabled: true,
        ),
      );
    } else if (context.mounted) {
      final l10n = AppLocalizations.of(context);
      await showNotice(
        context,
        title: l10n.reminderPermissionTitle,
        body: l10n.reminderPermissionBody,
      );
    }
    model.dismissSuggestion(reminderSuggestion);
  }

  /// Turns the lock on, after checking who is holding the phone.
  Future<void> _turnLockOn(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final auth = environment.deviceAuth;
    var outcome = AuthOutcome.unavailable;
    if (await auth.isAvailable()) {
      outcome = await auth.authenticate(l10n.lockReason);
    }
    switch (outcome) {
      case AuthOutcome.success:
        model.setAppLockEnabled(true);
      case AuthOutcome.failed:
        // Nothing changes: the question stays for another time.
        return;
      case AuthOutcome.unavailable:
        if (context.mounted) {
          await showNotice(
            context,
            title: l10n.lockUnavailableTitle,
            body: l10n.lockUnavailableBody,
          );
        }
    }
    model.dismissSuggestion(lockSuggestion);
  }

  Widget? _suggestion(BuildContext context, AppLocalizations l10n) {
    final reminders = model.reminderSettings;
    if (!reminders.periodEnabled &&
        !reminders.dailyEnabled &&
        !model.suggestionDismissed(reminderSuggestion)) {
      return SuggestionCard(
        key: const ValueKey('suggest-reminders'),
        title: l10n.suggestReminderTitle,
        body: l10n.suggestReminderBody,
        accept: l10n.fertilityTurnOn,
        onAccept: () => _turnRemindersOn(context),
        onDismiss: () => model.dismissSuggestion(reminderSuggestion),
      );
    }
    if (!model.appLockEnabled && !model.suggestionDismissed(lockSuggestion)) {
      return SuggestionCard(
        key: const ValueKey('suggest-lock'),
        title: l10n.suggestLockTitle,
        body: l10n.suggestLockBody,
        accept: l10n.fertilityTurnOn,
        onAccept: () => _turnLockOn(context),
        onDismiss: () => model.dismissSuggestion(lockSuggestion),
      );
    }
    return null;
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
        final dayOfCycle = status is EstimateOutdated
            ? null
            : overview.dayOfCycle;
        final usual = dayOfCycle == null
            ? const <UsualSign>[]
            : usualSignsAround(
                dayOfCycle,
                cycles: model.cycles,
                days: model.days,
              );
        final summary = cycleSummaryToShow(model, today);
        final suggestion = _suggestion(context, l10n);
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
                ovulationLine: current == null
                    ? null
                    : l10n.fertilityOvulationRange(
                        shortDate(l10n, current.earliestOvulation),
                        shortDate(l10n, current.latestOvulation),
                      ),
                fertileFromDay: current == null || cycleStart == null
                    ? null
                    : current.windowStart.daysSince(cycleStart) + 1,
                fertileToDay: current == null || cycleStart == null
                    ? null
                    : current.windowEnd.daysSince(cycleStart) + 1,
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
                  onSeeTrends: () => onOpenTab(HomeTab.review),
                ),
              ],
              if (usual.isNotEmpty) ...[gap, UsualSignsCard(signs: usual)],
              if (suggestion != null) ...[gap, suggestion],
            ],
          ),
        );
      },
    );
  }
}
