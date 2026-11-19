import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../domain/cycle_overview.dart';
import '../domain/cycle_status.dart';
import '../domain/period_prediction.dart';
import '../l10n/app_localizations.dart';
import 'cycle_ring.dart';
import 'labels.dart';
import 'theme.dart';

/// The first thing seen, and almost the only one: the day of the cycle on a
/// ring, and the estimate for the next period, always as a range. Says,
/// without alarm, when the range is over. While no period is logged, one
/// button logs that it starts today.
class PredictionCard extends StatelessWidget {
  const PredictionCard({
    super.key,
    required this.status,
    required this.overview,
    this.fertileFromDay,
    this.fertileToDay,
    this.ovulationLine,
    this.onPeriodStartsToday,
  });

  final CycleStatus status;
  final CycleOverview overview;

  /// Days of the cycle covered by the estimated fertile window, when the
  /// user keeps that estimate on.
  final int? fertileFromDay;
  final int? fertileToDay;

  /// The estimated range of ovulation, already worded, when the user keeps
  /// that estimate on and enough cycles are logged.
  final String? ovulationLine;

  /// Logs that a period starts today. Offered while there is no estimate.
  final VoidCallback? onPeriodStartsToday;

  String _range(
    AppLocalizations l10n,
    PeriodPrediction prediction, {
    bool next = false,
  }) {
    final start = shortDate(l10n, prediction.earliestStart);
    final end = shortDate(l10n, prediction.latestStart);
    return next
        ? l10n.statusNextRange(start, end)
        : l10n.statusExpectedRange(start, end);
  }

  /// "Period in 5 to 11 days": the countdown is a range too.
  String _countdown(AppLocalizations l10n, int earliest) {
    final latest = overview.daysUntilLatest ?? earliest;
    return latest > earliest
        ? l10n.countdownRange(earliest, latest)
        : l10n.countdownDays(earliest);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = AccentColors.of(context);

    final String title;
    final lines = <String>[];
    var counting = true;
    var estimated = false;
    switch (status) {
      case NoEstimate():
        title = l10n.statusNoDataTitle;
        lines.add(l10n.statusNoDataBody);
        counting = false;
      case EstimateOutdated():
        title = l10n.statusOutdatedTitle;
        lines.add(l10n.statusOutdatedBody);
        counting = false;
      case PeriodOngoing(:final dayOfPeriod, :final next):
        title = l10n.statusOngoing(dayOfPeriod);
        lines.add(_range(l10n, next, next: true));
        estimated = true;
      case PeriodExpected(:final prediction, :final daysUntil):
        title = _countdown(l10n, daysUntil);
        lines.add(_range(l10n, prediction));
        estimated = true;
      case PeriodDue(:final prediction):
        title = l10n.countdownDue;
        lines.add(_range(l10n, prediction));
        estimated = true;
      case PeriodLate(:final prediction, :final daysLate):
        title = _range(l10n, prediction);
        lines
          ..add(l10n.statusLate(daysLate))
          ..add(l10n.statusLateNote);
        estimated = true;
    }
    final ovulation = ovulationLine;
    if (estimated && ovulation != null) {
      lines.add(ovulation);
    }

    final day = counting ? overview.dayOfCycle : null;
    final earliest = overview.daysUntilEarliest;
    final latest = overview.daysUntilLatest;
    final expectedFrom = day != null && earliest != null
        ? day + earliest
        : null;
    final expectedTo = day != null && latest != null ? day + latest : null;
    final ring = CycleRing(
      dayOfCycle: day,
      caption: l10n.cycleDayCaption,
      totalDays: [overview.cycleLength, ?day, ?expectedTo].reduce(math.max),
      periodDays: counting ? overview.periodLength : 0,
      expectedFromDay: expectedFrom,
      expectedToDay: expectedTo,
      fertileFromDay: fertileFromDay,
      fertileToDay: fertileToDay,
    );

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (day != null)
          Text(
            l10n.cycleDaySemantics(day),
            key: const ValueKey('cycle-day'),
            style: theme.textTheme.labelLarge?.copyWith(color: accent.onCard),
          ),
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(color: accent.onCard),
        ),
        for (final (index, line) in lines.indexed) ...[
          SizedBox(height: index == 0 ? 8 : 4),
          Text(
            line,
            style: theme.textTheme.bodyMedium?.copyWith(color: accent.onCard),
          ),
        ],
      ],
    );

    final start = onPeriodStartsToday;
    // Beside the ring on a normal phone, under it when the text is large.
    final stacked = MediaQuery.textScalerOf(context).scale(1) > 1.4;
    return Card.filled(
      margin: EdgeInsets.zero,
      color: accent.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MergeSemantics(
              child: stacked
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(child: ring),
                        const SizedBox(height: 16),
                        text,
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ring,
                        const SizedBox(width: 16),
                        Expanded(child: text),
                      ],
                    ),
            ),
            if (!counting && start != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                key: const ValueKey('period-starts-today'),
                onPressed: start,
                child: Text(l10n.periodStartsToday),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
