import 'package:material_ui/material_ui.dart';

import '../domain/fertility_estimate.dart';
import '../domain/period_prediction.dart';
import '../l10n/app_localizations.dart';
import 'dialogs.dart';
import 'labels.dart';

/// The estimated fertile window of the current cycle, shown only when the
/// user turned it on: always two ranges of dates, called estimates, with a
/// way to read how they are calculated and what they are not.
class FertilityCard extends StatelessWidget {
  const FertilityCard({super.key, required this.estimate});

  /// Null while too few cycles are logged.
  final FertilityEstimate? estimate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final estimate = this.estimate;
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.fertilityCardTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (estimate == null)
                    Text(
                      l10n.fertilityNotEnough,
                      style: theme.textTheme.bodyMedium,
                    )
                  else ...[
                    Text(
                      l10n.fertilityWindowRange(
                        shortDate(l10n, estimate.windowStart),
                        shortDate(l10n, estimate.windowEnd),
                      ),
                      key: const ValueKey('fertile-window'),
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.fertilityOvulationRange(
                        shortDate(l10n, estimate.earliestOvulation),
                        shortDate(l10n, estimate.latestOvulation),
                      ),
                      key: const ValueKey('ovulation-range'),
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (estimate.confidence == PredictionConfidence.low) ...[
                      const SizedBox(height: 4),
                      Text(l10n.fertilityLowConfidence, style: muted),
                    ],
                  ],
                  const SizedBox(height: 8),
                  Text(
                    l10n.fertilityShortWarning,
                    key: const ValueKey('fertility-warning'),
                    style: muted,
                  ),
                ],
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsetsDirectional.only(end: 12),
                ),
                onPressed: () => showNotice(
                  context,
                  title: l10n.fertilityHow,
                  body: '${l10n.fertilityHowBody}\n\n${l10n.fertilityWarning}',
                ),
                child: Text(l10n.fertilityHow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
