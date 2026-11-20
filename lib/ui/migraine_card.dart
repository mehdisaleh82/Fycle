import 'package:material_ui/material_ui.dart';

import '../domain/migraine.dart';
import '../l10n/app_localizations.dart';
import 'home_cards.dart';
import 'labels.dart';

/// The migraines of the last three months, counted and set against the
/// periods. It counts what was ticked; it says nothing of causes or of
/// treatments.
class MigraineCard extends StatelessWidget {
  const MigraineCard({super.key, required this.summary});

  final MigraineSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final intensity = summary.commonIntensity;
    return TitledCard(
      key: const ValueKey('migraine-card'),
      title: l10n.symptomMigraine,
      children: [
        Text(
          l10n.migraineSummaryDays(summary.days),
          key: const ValueKey('migraine-days'),
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.migraineSummaryPeriod(summary.duringPeriod),
          key: const ValueKey('migraine-period'),
          style: theme.textTheme.bodyMedium,
        ),
        if (summary.withMedication > 0) ...[
          const SizedBox(height: 4),
          Text(
            l10n.migraineSummaryMedication(summary.withMedication),
            style: theme.textTheme.bodyMedium,
          ),
        ],
        if (intensity != null) ...[
          const SizedBox(height: 4),
          Text(
            l10n.migraineSummaryIntensity(painLabel(l10n, intensity)),
            style: theme.textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: 8),
        Text(
          l10n.migraineSummaryNote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
