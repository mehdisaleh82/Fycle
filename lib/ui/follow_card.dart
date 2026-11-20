import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/daily_figures.dart';
import '../domain/period_prediction.dart';
import '../domain/start_profile.dart';
import '../l10n/app_localizations.dart';
import 'cycle_model.dart';
import 'home_cards.dart';
import 'labels.dart';

/// What her journal holds lately, in plain counts: the last seven days row
/// by row, the month, the cycle going on next to the one before, and how
/// far the estimate can be trusted with what would raise it. It shows the
/// empty days as they are, without praise and without reproach.
class FollowCard extends StatelessWidget {
  const FollowCard({super.key, required this.model, required this.today});

  final CycleModel model;
  final CalendarDay today;

  /// The rows of the week, after the journal as a whole: what she said she
  /// follows, or pain and mood when she did not say.
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
    final figures = cycleFiguresOn(
      today,
      cycles: model.cycles,
      days: model.days,
    );
    final prediction = model.prediction;
    return TitledCard(
      key: const ValueKey('follow-card'),
      title: l10n.followTitle,
      children: [
        _WeekHeader(week: week),
        _WeekRow(
          name: 'journal',
          label: l10n.followJournal,
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
        if (figures != null) ...[
          const Divider(height: 28),
          Semantics(
            header: true,
            child: Text(
              l10n.followCycleTitle(figures.current.days),
              style: theme.textTheme.titleSmall,
            ),
          ),
          const SizedBox(height: 8),
          _Figures(current: figures.current, previous: figures.previous),
        ],
        const Divider(height: 28),
        _Reliability(prediction: prediction),
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
          const Expanded(flex: 4, child: SizedBox()),
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

/// One thing she follows over the last seven days: a full dot where it was
/// filled in, an empty one where it was not.
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
                flex: 4,
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
                            : Border.all(
                                color: scheme.outlineVariant,
                                width: 2,
                              ),
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

/// The cycle going on in a few figures, each next to the cycle before taken
/// at the same point.
class _Figures extends StatelessWidget {
  const _Figures({required this.current, required this.previous});

  final CycleFigures current;
  final CycleFigures? previous;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final previous = this.previous;
    final mood = current.commonMood;
    final libido = current.commonLibido;
    final previousMood = previous?.commonMood;
    final previousLibido = previous?.commonLibido;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Figure(
          name: 'logged',
          label: l10n.figureDaysLogged,
          value: l10n.figureOutOf(current.daysLogged, current.days),
          previous: previous == null
              ? null
              : l10n.figureOutOf(previous.daysLogged, previous.days),
        ),
        _Figure(
          name: 'good-nights',
          label: l10n.figureGoodNights,
          value: '${current.goodNights}',
          previous: previous == null ? null : '${previous.goodNights}',
        ),
        _Figure(
          name: 'pain-days',
          label: l10n.figurePainDays,
          value: '${current.painDays}',
          previous: previous == null ? null : '${previous.painDays}',
        ),
        if (mood != null)
          _Figure(
            name: 'mood',
            label: l10n.figureMood,
            value: moodLabel(l10n, mood),
            previous: previousMood == null
                ? null
                : moodLabel(l10n, previousMood),
          ),
        if (libido != null)
          _Figure(
            name: 'libido',
            label: l10n.figureLibido,
            value: libidoLabel(l10n, libido),
            previous: previousLibido == null
                ? null
                : libidoLabel(l10n, previousLibido),
          ),
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({
    required this.name,
    required this.label,
    required this.value,
    required this.previous,
  });

  final String name;
  final String label;
  final String value;

  /// The same figure for the cycle before, when there is one.
  final String? previous;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final previous = this.previous;
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.bodyMedium),
                  if (previous != null)
                    Text(
                      l10n.figurePrevious(previous),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // The value wraps rather than pushing the row out, with very
            // large text.
            Expanded(
              flex: 2,
              child: Text(
                value,
                key: ValueKey('figure-$name'),
                textAlign: TextAlign.end,
                style: theme.textTheme.titleMedium,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MergeSemantics(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.reliabilityTitle,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              if (step != null)
                Text(
                  switch (step.confidence) {
                    PredictionConfidence.low => l10n.reliabilityLow,
                    PredictionConfidence.medium => l10n.reliabilityMedium,
                    PredictionConfidence.high => l10n.reliabilityHigh,
                  },
                  key: const ValueKey('reliability-level'),
                  style: theme.textTheme.titleSmall,
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ExcludeSemantics(
          child: Row(
            children: [
              for (var i = 1; i <= PredictionConfidence.values.length; i++) ...[
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
    );
  }
}
