import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../domain/cycle_overview.dart';
import '../domain/cycle_status.dart';
import '../domain/fertility_estimate.dart';
import '../domain/period_prediction.dart';
import '../l10n/app_localizations.dart';
import 'cycle_ring.dart';
import 'labels.dart';
import 'theme.dart';

/// The first thing seen: the day of the cycle on a ring, and the estimate
/// for the next period, always as a range, with what it is based on. Says,
/// without alarm, when the range is over.
class PredictionCard extends StatelessWidget {
  const PredictionCard({
    super.key,
    required this.status,
    required this.overview,
    required this.usualCycleLength,
    this.fertileFromDay,
    this.fertileToDay,
    this.ovulationLine,
    this.showReferenceFertility = false,
  });

  final CycleStatus status;
  final CycleOverview overview;

  /// The cycle length declared by the user, if any.
  final int? usualCycleLength;

  /// Days of the cycle covered by the estimated fertile window, when the
  /// user turned that estimate on.
  final int? fertileFromDay;
  final int? fertileToDay;

  /// The estimated range of ovulation, already worded, when the user keeps
  /// that estimate on and enough cycles are logged.
  final String? ovulationLine;

  /// Whether the reference cycle, drawn while nothing is logged, also
  /// carries the estimated fertile window: only when that estimate is on.
  final bool showReferenceFertility;

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

  String _basis(AppLocalizations l10n, PeriodPrediction prediction) {
    if (prediction.cyclesUsed > 0) {
      return l10n.estimateBasisCycles(prediction.cyclesUsed);
    }
    final declared = usualCycleLength;
    return declared != null
        ? l10n.estimateBasisDeclared(declared)
        : l10n.estimateBasisDefault(overview.cycleLength);
  }

  String _confidence(AppLocalizations l10n, PeriodPrediction prediction) =>
      switch (prediction.confidence) {
        PredictionConfidence.low => l10n.confidenceLow,
        PredictionConfidence.medium => l10n.confidenceMedium,
        PredictionConfidence.high => l10n.confidenceHigh,
      };

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
    PeriodPrediction? shown;
    var counting = true;
    var reference = false;
    switch (status) {
      case NoEstimate():
        title = l10n.statusNoDataTitle;
        lines
          ..add(l10n.statusNoDataBody)
          ..add(
            l10n.referenceLine(overview.cycleLength, overview.periodLength),
          );
        counting = false;
        reference = true;
      case EstimateOutdated():
        title = l10n.statusOutdatedTitle;
        lines.add(l10n.statusOutdatedBody);
        counting = false;
      case PeriodOngoing(:final dayOfPeriod, :final next):
        title = l10n.statusOngoing(dayOfPeriod);
        lines.add(_range(l10n, next, next: true));
        shown = next;
      case PeriodExpected(:final prediction, :final daysUntil):
        title = _countdown(l10n, daysUntil);
        lines.add(_range(l10n, prediction));
        shown = prediction;
      case PeriodDue(:final prediction):
        title = l10n.countdownDue;
        lines.add(_range(l10n, prediction));
        shown = prediction;
      case PeriodLate(:final prediction, :final daysLate):
        title = _range(l10n, prediction);
        lines
          ..add(l10n.statusLate(daysLate))
          ..add(l10n.statusLateNote);
        shown = prediction;
    }
    final ovulation = ovulationLine;
    if (shown != null && ovulation != null) {
      lines.add(ovulation);
    }
    if (shown != null) {
      lines
        ..add(_basis(l10n, shown))
        ..add(_confidence(l10n, shown));
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
      caption: reference ? l10n.referenceCaption : l10n.cycleDayCaption,
      centerText: reference ? '${overview.cycleLength}' : null,
      totalDays: [overview.cycleLength, ?day, ?expectedTo].reduce(math.max),
      periodDays: counting || reference ? overview.periodLength : 0,
      // Once a period is logged again, the range belongs to the next cycle:
      // it sits at the end of the ring.
      expectedFromDay: expectedFrom,
      expectedToDay: expectedTo,
      fertileFromDay: reference && showReferenceFertility
          ? overview.cycleLength -
                assumedDaysFromOvulationToPeriod -
                ovulationMarginDays -
                fertileDaysBeforeOvulation +
                1
          : fertileFromDay,
      fertileToDay: reference && showReferenceFertility
          ? overview.cycleLength -
                assumedDaysFromOvulationToPeriod +
                ovulationMarginDays +
                fertileDaysAfterOvulation +
                1
          : fertileToDay,
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
            style:
                (index == 0 || line == ovulation
                        ? theme.textTheme.titleSmall
                        : theme.textTheme.bodySmall)
                    ?.copyWith(color: accent.onCard),
          ),
        ],
      ],
    );

    // Beside the ring on a normal phone, under it when the text is large.
    final stacked = MediaQuery.textScalerOf(context).scale(1) > 1.4;
    return Card.filled(
      margin: EdgeInsets.zero,
      color: accent.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: MergeSemantics(
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
      ),
    );
  }
}
