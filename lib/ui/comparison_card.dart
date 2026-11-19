import 'package:material_ui/material_ui.dart';

import '../domain/cycle_comparison.dart';
import '../l10n/app_localizations.dart';
import 'home_cards.dart';

/// This cycle next to the one before, at the same point: four counts side
/// by side, with an arrow for what moved. The arrow says "more" or "fewer",
/// never "better" or "worse".
class ComparisonCard extends StatelessWidget {
  const ComparisonCard({super.key, required this.comparison});

  final CycleComparison comparison;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final current = comparison.current;
    final previous = comparison.previous;
    final rows = [
      (
        'period',
        l10n.comparisonPeriod,
        current.periodDays,
        previous.periodDays,
      ),
      ('pain', l10n.comparisonPain, current.painDays, previous.painDays),
      (
        'sleep',
        l10n.comparisonSleep,
        current.poorSleepNights,
        previous.poorSleepNights,
      ),
      (
        'logged',
        l10n.comparisonLogged,
        current.daysLogged,
        previous.daysLogged,
      ),
    ];
    return TitledCard(
      key: const ValueKey('comparison-card'),
      title: l10n.comparisonTitle,
      children: [
        Text(
          l10n.comparisonIntro(comparison.dayOfCycle),
          key: const ValueKey('comparison-intro'),
          style: muted,
        ),
        const SizedBox(height: 12),
        // Column headers, read with each row by screen readers.
        ExcludeSemantics(
          child: Row(
            children: [
              const Expanded(flex: 5, child: SizedBox()),
              Expanded(
                flex: 3,
                child: Text(
                  l10n.reportTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  l10n.comparisonPrevious,
                  textAlign: TextAlign.center,
                  style: muted,
                ),
              ),
              const SizedBox(width: 24),
            ],
          ),
        ),
        for (final (name, label, now, before) in rows)
          Padding(
            key: ValueKey('comparison-$name'),
            padding: const EdgeInsets.only(top: 12),
            child: Semantics(
              container: true,
              label: l10n.comparisonRow(label, now, before),
              child: ExcludeSemantics(
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(label, style: theme.textTheme.bodyMedium),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        '$now',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        '$before',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 24,
                      child: Icon(
                        now > before
                            ? Icons.arrow_upward
                            : now < before
                            ? Icons.arrow_downward
                            : Icons.drag_handle,
                        size: 18,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
