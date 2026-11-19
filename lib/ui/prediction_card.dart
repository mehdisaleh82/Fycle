import 'package:material_ui/material_ui.dart';

import '../domain/cycle_status.dart';
import '../domain/period_prediction.dart';
import '../domain/period_predictor.dart';
import '../l10n/app_localizations.dart';
import 'labels.dart';
import 'theme.dart';

/// The estimate for the next period: always a range of dates, with what it
/// is based on. Says, without alarm, when the range is over.
class PredictionCard extends StatelessWidget {
  const PredictionCard({
    super.key,
    required this.status,
    required this.usualCycleLength,
  });

  final CycleStatus status;

  /// The cycle length declared by the user, if any.
  final int? usualCycleLength;

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
        : l10n.estimateBasisDefault(PeriodPredictor.defaultCycleLength);
  }

  String _confidence(AppLocalizations l10n, PeriodPrediction prediction) =>
      switch (prediction.confidence) {
        PredictionConfidence.low => l10n.confidenceLow,
        PredictionConfidence.medium => l10n.confidenceMedium,
        PredictionConfidence.high => l10n.confidenceHigh,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = AccentColors.of(context);

    final String title;
    final lines = <String>[];
    PeriodPrediction? shown;
    switch (status) {
      case NoEstimate():
        title = l10n.statusNoDataTitle;
        lines.add(l10n.statusNoDataBody);
      case EstimateOutdated():
        title = l10n.statusOutdatedTitle;
        lines.add(l10n.statusOutdatedBody);
      case PeriodOngoing(:final dayOfPeriod, :final next):
        title = l10n.statusOngoing(dayOfPeriod);
        lines.add(_range(l10n, next, next: true));
        shown = next;
      case PeriodExpected(:final prediction, :final daysUntil):
        title = _range(l10n, prediction);
        lines.add(l10n.statusExpectedIn(daysUntil));
        shown = prediction;
      case PeriodDue(:final prediction):
        title = _range(l10n, prediction);
        lines.add(l10n.statusDue);
        shown = prediction;
      case PeriodLate(:final prediction, :final daysLate):
        title = _range(l10n, prediction);
        lines
          ..add(l10n.statusLate(daysLate))
          ..add(l10n.statusLateNote);
        shown = prediction;
    }
    if (shown != null) {
      lines
        ..add(_basis(l10n, shown))
        ..add(_confidence(l10n, shown));
    }

    return Card.filled(
      margin: EdgeInsets.zero,
      color: accent.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: accent.onCard,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Decoration only.
                  ExcludeSemantics(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: accent.badge,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.water_drop_outlined,
                          size: 22,
                          color: accent.mark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              for (final (index, line) in lines.indexed) ...[
                SizedBox(height: index == 0 ? 8 : 4),
                Text(
                  line,
                  style:
                      (index == 0
                              ? theme.textTheme.titleMedium
                              : theme.textTheme.bodyMedium)
                          ?.copyWith(color: accent.onCard),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
