import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/daily_figures.dart';
import '../domain/period_prediction.dart';
import '../domain/start_profile.dart';
import '../l10n/app_localizations.dart';
import 'cycle_model.dart';
import 'home_cards.dart';
import 'labels.dart';

/// A few figures to read at a glance, each in its own tile: one large
/// value, what it counts, and the cycle before when there is one. The
/// detail, day by day, is in the journal.
///
/// Plain counts, without praise and without reproach.
class FollowCard extends StatelessWidget {
  const FollowCard({super.key, required this.model, required this.today});

  final CycleModel model;
  final CalendarDay today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final byDay = {for (final entry in model.days) entry.day: entry};
    final week = lastSevenDays(today, (day) => byDay[day]);
    final weekLogged = week.where((day) => day.logged).length;
    final figures = cycleFiguresOn(
      today,
      cycles: model.cycles,
      days: model.days,
    );
    final current = figures?.current;
    final previous = figures?.previous;
    final mood = current?.commonMood;
    final libido = current?.commonLibido;
    // Each woman her own figures: those of what she chose to follow, or
    // pain and mood when she did not say.
    final follows = model.tracked.isEmpty
        ? const {Tracked.pain, Tracked.mood}
        : model.tracked;
    final tiles = [
      _Tile(
        name: 'week',
        icon: Icons.edit_calendar_outlined,
        label: l10n.kpiWeek,
        value: '$weekLogged',
        caption: l10n.kpiWeekCaption,
      ),
      if (current != null) ...[
        _Tile(
          name: 'cycle',
          icon: Icons.donut_large,
          label: l10n.kpiCycle,
          value: '${current.daysLogged}',
          caption: l10n.kpiCycleCaption(current.days),
        ),
        if (follows.contains(Tracked.sleep))
          _Tile(
            name: 'good-nights',
            icon: Icons.bedtime_outlined,
            label: l10n.figureGoodNights,
            value: '${current.goodNights}',
            caption: previous == null
                ? l10n.kpiThisCycle
                : l10n.kpiPrevious('${previous.goodNights}'),
          ),
        if (follows.contains(Tracked.pain))
          _Tile(
            name: 'pain-days',
            icon: Icons.healing_outlined,
            label: l10n.figurePainDays,
            value: '${current.painDays}',
            caption: previous == null
                ? l10n.kpiThisCycle
                : l10n.kpiPrevious('${previous.painDays}'),
          ),
        if (mood != null && follows.contains(Tracked.mood))
          _Tile(
            name: 'mood',
            icon: Icons.mood,
            label: l10n.dayMoodTitle,
            value: moodLabel(l10n, mood),
            caption: l10n.kpiMostFrequent,
          ),
        if (libido != null && follows.contains(Tracked.libido))
          _Tile(
            name: 'libido',
            icon: Icons.favorite_border,
            label: l10n.dayLibidoTitle,
            value: libidoLabel(l10n, libido),
            caption: l10n.kpiMostFrequent,
          ),
      ],
    ];
    return TitledCard(
      key: const ValueKey('follow-card'),
      title: l10n.followTitle,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // Two tiles side by side; one per line with very large text.
            final wide = MediaQuery.textScalerOf(context).scale(1) <= 1.4;
            const gap = 10.0;
            final width = wide
                ? (constraints.maxWidth - gap) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final tile in tiles) SizedBox(width: width, child: tile),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        _Reliability(prediction: model.prediction),
      ],
    );
  }
}

/// The header of a tile: a small picture and what the figure is.
class _TileHeader extends StatelessWidget {
  const _TileHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExcludeSemantics(child: Icon(icon, size: 18, color: scheme.primary)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary),
          ),
        ),
      ],
    );
  }
}

/// One figure: what it is, its value in large, and a word under it.
class _Tile extends StatelessWidget {
  const _Tile({
    required this.name,
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
  });

  final String name;
  final IconData icon;
  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return MergeSemantics(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TileHeader(icon: icon, label: label),
            const SizedBox(height: 8),
            Text(
              value,
              key: ValueKey('kpi-$name'),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              caption,
              key: ValueKey('kpi-$name-caption'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// How far the estimate can be trusted, on three steps, and what would
/// take it one step up. True to the rules of the predictor: when logging
/// more would change nothing, it says so.
class _Reliability extends StatelessWidget {
  const _Reliability({required this.prediction});

  final PeriodPrediction? prediction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final prediction = this.prediction;
    final step = prediction == null ? null : reliabilityStepOf(prediction);
    final level = step == null ? 0 : step.confidence.index + 1;
    final next = switch (step) {
      null => l10n.reliabilityNone,
      ReliabilityStep(confidence: PredictionConfidence.high) =>
        l10n.reliabilityAtTop,
      ReliabilityStep(heldByVariation: true) => l10n.reliabilityHeldByVariation,
      ReliabilityStep(confidence: PredictionConfidence.low) =>
        l10n.reliabilityToMedium(step.cyclesMissing),
      ReliabilityStep() => l10n.reliabilityToHigh(step.cyclesMissing),
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TileHeader(
            icon: Icons.verified_outlined,
            label: l10n.reliabilityTitle,
          ),
          if (step != null) ...[
            const SizedBox(height: 8),
            Text(
              switch (step.confidence) {
                PredictionConfidence.low => l10n.reliabilityLow,
                PredictionConfidence.medium => l10n.reliabilityMedium,
                PredictionConfidence.high => l10n.reliabilityHigh,
              },
              key: const ValueKey('reliability-level'),
              style: theme.textTheme.headlineMedium,
            ),
          ],
          const SizedBox(height: 8),
          ExcludeSemantics(
            child: Row(
              children: [
                for (
                  var i = 1;
                  i <= PredictionConfidence.values.length;
                  i++
                ) ...[
                  if (i > 1) const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: i <= level
                            ? scheme.primary
                            : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            next,
            key: const ValueKey('reliability-next'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// The last seven days, one line per thing she follows: a full dot where it
/// was filled in, an empty one where it was not. The detail behind the
/// figures of the home, kept in the journal.
class WeekCard extends StatelessWidget {
  const WeekCard({super.key, required this.model, required this.today});

  final CycleModel model;
  final CalendarDay today;

  /// The rows, after the day as a whole: what she said she follows, or
  /// pain and mood when she did not say.
  static List<Tracked> _rows(Set<Tracked> tracked) {
    final rows = [
      for (final kind in Tracked.values)
        if (tracked.contains(kind)) kind,
    ];
    return rows.isEmpty ? const [Tracked.pain, Tracked.mood] : rows;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final byDay = {for (final entry in model.days) entry.day: entry};
    final week = lastSevenDays(today, (day) => byDay[day]);
    final weekLogged = week.where((day) => day.logged).length;
    final month = monthLogged(today, model.loggedDays);
    return TitledCard(
      key: const ValueKey('week-card'),
      title: l10n.weekTitle,
      children: [
        Text(l10n.weekIntro, style: muted),
        const SizedBox(height: 8),
        _WeekHeader(week: week),
        _WeekRow(
          name: 'journal',
          label: l10n.weekAnyNote,
          filled: [for (final day in week) day.logged],
        ),
        for (final kind in _rows(model.tracked))
          _WeekRow(
            name: kind.name,
            label: trackedLabel(l10n, kind),
            filled: [for (final day in week) day.filled.contains(kind)],
          ),
        const SizedBox(height: 8),
        Text(
          l10n.followWeek(weekLogged),
          key: const ValueKey('follow-week'),
          style: muted,
        ),
        Text(
          l10n.followMonth(month.logged, month.elapsed),
          key: const ValueKey('follow-month'),
          style: muted,
        ),
      ],
    );
  }
}

/// The initials of the last seven days, today standing out.
class _WeekHeader extends StatelessWidget {
  const _WeekHeader({required this.week});

  final List<WeekDay> week;

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    return ExcludeSemantics(
      child: Row(
        children: [
          const Expanded(flex: 5, child: SizedBox()),
          for (var i = 0; i < week.length; i++)
            Expanded(
              flex: 2,
              child: Center(
                // A column of dots has a fixed width.
                child: MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1.3,
                  child: Text(
                    material.narrowWeekdays[DateTime(
                          week[i].day.year,
                          week[i].day.month,
                          week[i].day.day,
                        ).weekday %
                        7],
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: i == week.length - 1
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: i == week.length - 1
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeekRow extends StatelessWidget {
  const _WeekRow({
    required this.name,
    required this.label,
    required this.filled,
  });

  final String name;
  final String label;
  final List<bool> filled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final count = filled.where((on) => on).length;
    return Semantics(
      key: ValueKey('follow-row-$name'),
      // Each row is read on its own.
      container: true,
      label: l10n.followRow(label, count),
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              for (final on in filled)
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: on ? scheme.primary : null,
                        border: on
                            ? null
                            : Border.all(color: scheme.outline, width: 1.5),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
