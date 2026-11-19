import 'package:material_ui/material_ui.dart';

import '../domain/cycle_history.dart';
import '../domain/cycle_trends.dart';
import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'cycle_model.dart';
import 'labels.dart';

/// Trends: the average lengths, what comes back at the same moment of the
/// cycle, and the list of logged cycles.
///
/// Everything here counts what was logged. Nothing is interpreted.
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({
    super.key,
    required this.model,
    required this.environment,
  });

  final CycleModel model;
  final AppEnvironment environment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.insightsTitle)),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: model,
          builder: (context, _) {
            final cycles = model.cycles;
            return ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
              children: [
                _AveragesCard(
                  averages: cycleAverages(cycles, today: environment.today()),
                ),
                const SizedBox(height: 16),
                _TrendsCard(
                  trends: cycleTrends(cycles: cycles, days: model.days),
                ),
                const SizedBox(height: 16),
                _HistoryCard(cycles: cycles),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _AveragesCard extends StatelessWidget {
  const _AveragesCard({required this.averages});

  final CycleAverages averages;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final cycle = averages.cycleLength;
    final period = averages.periodLength;
    return _CardBody(
      title: l10n.insightsCyclesTitle,
      children: [
        if (cycle != null)
          Text(
            l10n.insightsAverageCycle(dayCount(l10n, cycle)),
            key: const ValueKey('average-cycle'),
            style: theme.textTheme.bodyLarge,
          ),
        if (period != null) ...[
          if (cycle != null) const SizedBox(height: 4),
          Text(
            l10n.insightsAveragePeriod(dayCount(l10n, period)),
            key: const ValueKey('average-period'),
            style: theme.textTheme.bodyLarge,
          ),
        ],
        if (cycle != null) ...[
          const SizedBox(height: 8),
          Text(l10n.insightsAverageBasis(averages.cyclesCounted), style: muted),
        ] else ...[
          if (period != null) const SizedBox(height: 8),
          Text(l10n.insightsNoCycleYet, style: muted),
        ],
      ],
    );
  }
}

class _TrendsCard extends StatelessWidget {
  const _TrendsCard({required this.trends});

  final List<SignTrend> trends;

  String _sentence(AppLocalizations l10n, SignTrend trend) {
    final moment = trend.mainMoment;
    final count = trend.cyclesAt(moment);
    final total = trend.cyclesConsidered;
    return switch (moment) {
      CycleMoment.period => l10n.trendDuringPeriod(count, total),
      CycleMoment.beforeNextPeriod => l10n.trendBeforePeriod(count, total),
      CycleMoment.rest => l10n.trendRest(count, total),
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    return _CardBody(
      title: l10n.insightsTrendsTitle,
      children: [
        if (trends.isEmpty)
          Text(l10n.insightsTrendsEmpty, style: theme.textTheme.bodyMedium)
        else ...[
          for (final trend in trends)
            Padding(
              key: ValueKey('trend-${trend.sign.name}'),
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    signLabel(l10n, trend.sign),
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _sentence(l10n, trend),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  // The sentence above says the same thing in words.
                  ExcludeSemantics(
                    child: _ShareBar(
                      share:
                          trend.cyclesAt(trend.mainMoment) /
                          trend.cyclesConsidered,
                    ),
                  ),
                ],
              ),
            ),
          Text(l10n.insightsTrendsNote, style: muted),
        ],
      ],
    );
  }
}

/// A thin bar filled from the start of the line, up to [share] of its width.
class _ShareBar extends StatelessWidget {
  const _ShareBar({required this.share});

  final double share;

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
            child: ColoredBox(color: scheme.primary),
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.cycles});

  final List<LoggedCycle> cycles;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return _CardBody(
      title: l10n.insightsHistoryTitle,
      children: [
        if (cycles.isEmpty)
          Text(l10n.historyEmpty, style: theme.textTheme.bodyMedium),
        // Most recent first.
        for (final cycle in cycles.reversed)
          Padding(
            key: ValueKey('cycle-${cycle.start}'),
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cycle.isComplete
                      ? l10n.historyCycleRange(
                          mediumDate(l10n, cycle.start),
                          mediumDate(l10n, cycle.end!),
                        )
                      : l10n.historyCurrent(mediumDate(l10n, cycle.start)),
                  style: theme.textTheme.bodyLarge,
                ),
                if (cycle.isComplete)
                  Text(
                    l10n.historyCycleDetail(cycle.length!, cycle.periodLength),
                    style: theme.textTheme.bodyMedium,
                  ),
                if (cycle.isComplete && !cycle.isPlausible)
                  Text(l10n.historyUnusual, style: muted),
              ],
            ),
          ),
      ],
    );
  }
}
