import 'package:material_ui/material_ui.dart';

import '../domain/cycle_overview.dart';
import '../l10n/app_localizations.dart';

/// A titled card, the common frame of the home screen.
class TitledCard extends StatelessWidget {
  const TitledCard({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
  });

  final String title;
  final List<Widget> children;

  /// Shown at the end of the title line, such as a short count.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(title, style: theme.textTheme.titleMedium),
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// A thin bar filled from the start of the line, up to [share] of its width.
class ShareBar extends StatelessWidget {
  const ShareBar({super.key, required this.share, this.color});

  final double share;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 8,
        child: ColoredBox(
          color: scheme.surfaceContainerHighest,
          child: FractionallySizedBox(
            alignment: AlignmentDirectional.centerStart,
            widthFactor: share.clamp(0, 1).toDouble(),
            child: ColoredBox(color: color ?? scheme.primary),
          ),
        ),
      ),
    );
  }
}

/// The key figures: length of the cycle, length of the period, days logged.
/// There is something to read from the first logged date, and each figure
/// says in a word where it comes from. The reference values behind an
/// estimate are not shown.
class KeyFiguresCard extends StatelessWidget {
  const KeyFiguresCard({super.key, required this.overview});

  final CycleOverview overview;

  String _source(AppLocalizations l10n, LengthSource? source) =>
      switch (source) {
        LengthSource.logged => l10n.sourceLogged,
        LengthSource.declared => l10n.sourceDeclared,
        LengthSource.assumed => l10n.sourceAssumed,
        LengthSource.current => l10n.sourceCurrent,
        null => '',
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final figures = [
      _Figure(
        key: const ValueKey('figure-cycle'),
        label: l10n.figureCycle,
        value: l10n.figureDays(overview.cycleLength),
        hint: _source(l10n, overview.cycleLengthSource),
      ),
      _Figure(
        key: const ValueKey('figure-period'),
        label: l10n.figurePeriod,
        value: l10n.figureDays(overview.periodLength),
        hint: _source(l10n, overview.periodLengthSource),
      ),
      _Figure(
        key: const ValueKey('figure-logged'),
        label: l10n.figureLogged,
        value: '${overview.daysLogged}',
        hint: l10n.sourceCycles(overview.completeCycles),
      ),
    ];
    // Side by side on a normal phone, one under the other with large text.
    final stacked = MediaQuery.textScalerOf(context).scale(1) > 1.4;
    return TitledCard(
      title: l10n.figuresTitle,
      children: [
        if (stacked)
          for (final figure in figures)
            Padding(padding: const EdgeInsets.only(bottom: 12), child: figure)
        else
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (index, figure) in figures.indexed) ...[
                  if (index > 0) const SizedBox(width: 12),
                  Expanded(child: figure),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    super.key,
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelLarge),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
          if (hint.isNotEmpty) Text(hint, style: muted),
        ],
      ),
    );
  }
}

/// "The more you log, the more you see": what the entries already give and
/// what the next ones will, with how far along each step is. Plain
/// information about the log: no points, no reward.
class UnlockCard extends StatelessWidget {
  const UnlockCard({super.key, required this.steps});

  final List<InsightStep> steps;

  (String, String) _texts(AppLocalizations l10n, Insight insight) =>
      switch (insight) {
        Insight.estimate => (l10n.unlockEstimate, l10n.unlockEstimateNeed),
        Insight.averages => (l10n.unlockAverages, l10n.unlockAveragesNeed),
        Insight.trends => (l10n.unlockTrends, l10n.unlockTrendsNeed),
        Insight.reliableEstimate => (
          l10n.unlockReliable,
          l10n.unlockReliableNeed,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final reached = steps.where((step) => step.reached).length;
    return TitledCard(
      key: const ValueKey('unlock-card'),
      title: l10n.unlockTitle,
      children: [
        Text(l10n.unlockIntro, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(child: ShareBar(share: reached / steps.length)),
              const SizedBox(height: 4),
              Text(
                l10n.unlockOverall(reached, steps.length),
                key: const ValueKey('unlock-overall'),
                style: muted,
              ),
            ],
          ),
        ),
        for (final step in steps) ...[
          const SizedBox(height: 12),
          MergeSemantics(
            child: Row(
              key: ValueKey('unlock-${step.insight.name}'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(
                  child: Icon(
                    step.reached
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: step.reached ? scheme.primary : scheme.outline,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _texts(l10n, step.insight).$1,
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        step.reached
                            ? l10n.unlockReached
                            : '${_texts(l10n, step.insight).$2} · '
                                  '${l10n.unlockProgress(step.have, step.need)}',
                        style: muted,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
