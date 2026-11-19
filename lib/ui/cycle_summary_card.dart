import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/cycle_trends.dart';
import '../l10n/app_localizations.dart';
import 'cycle_model.dart';
import 'labels.dart';

/// The summary stays on the home screen for this many days after the new
/// period started, unless it is closed before.
const int daysSummaryStaysShown = 10;

/// The summary to show on [today], or null: there is one for a short while
/// after a new period is logged, until it is closed.
CycleSummary? cycleSummaryToShow(CycleModel model, CalendarDay today) {
  final summary = lastCycleSummary(cycles: model.cycles, days: model.days);
  if (summary == null || model.dismissedSummaryStart == summary.cycle.start) {
    return null;
  }
  final sinceNewPeriod = today.daysSince(model.cycles.last.start);
  return sinceNewPeriod >= 0 && sinceNewPeriod <= daysSummaryStaysShown
      ? summary
      : null;
}

/// A cycle has just ended: how long it lasted next to the ones before, and
/// what was logged most. Plain facts, no praise, closed in one tap.
class CycleSummaryCard extends StatelessWidget {
  const CycleSummaryCard({
    super.key,
    required this.summary,
    required this.onClose,
    required this.onSeeTrends,
  });

  final CycleSummary summary;
  final VoidCallback onClose;
  final VoidCallback onSeeTrends;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final difference = summary.differenceWithPrevious;
    final symptoms = summary.mostLoggedSymptoms;
    final lines = [
      l10n.summaryLength(summary.cycle.length!),
      if (difference != null)
        if (difference > 0)
          l10n.summaryLonger(difference)
        else if (difference < 0)
          l10n.summaryShorter(-difference)
        else
          l10n.summarySame,
      if (symptoms.isNotEmpty)
        l10n.summaryMostLogged(
          [for (final symptom in symptoms) symptomLabel(l10n, symptom)]
              .join(l10n.listSeparator),
        ),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 4, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.summaryTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.summaryClose,
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
            for (final line in lines)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 12, bottom: 4),
                child: Text(line, style: theme.textTheme.bodyMedium),
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                ),
                onPressed: onSeeTrends,
                child: Text(l10n.summarySeeTrends),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
