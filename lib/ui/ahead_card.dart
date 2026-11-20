import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/coming_signs.dart';
import '../domain/cycle_status.dart';
import '../domain/desire_pattern.dart';
import '../domain/period_prediction.dart';
import '../l10n/app_localizations.dart';
import 'cycle_model.dart';
import 'home_cards.dart';
import 'labels.dart';

/// Nothing further ahead than this many days is listed.
const int aheadHorizonDays = 42;

/// What the coming weeks may hold, in order of date, to plan around: the
/// estimated period, the days her signs usually come back, the estimated
/// fertile window when she keeps it on, and the days she most often logged
/// a high desire. Every line is an estimate or a count of what she logged,
/// said as such (CLAUDE.md, rule 7).
class AheadCard extends StatelessWidget {
  const AheadCard({
    super.key,
    required this.model,
    required this.today,
    required this.status,
  });

  final CycleModel model;
  final CalendarDay today;
  final CycleStatus status;

  @override
  Widget build(BuildContext context) {
    final PeriodPrediction? prediction = switch (status) {
      PeriodExpected(:final prediction) => prediction,
      PeriodOngoing(:final next) => next,
      PeriodDue() || PeriodLate() => null,
      NoEstimate() || EstimateOutdated() => null,
    };
    final estimated = status is! NoEstimate && status is! EstimateOutdated;
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    final lines =
        <({String name, CalendarDay from, CalendarDay to, String text})>[];
    void add(String name, CalendarDay from, CalendarDay to, String text) {
      if (!to.isBefore(today) &&
          from.daysSince(today) <= aheadHorizonDays &&
          !to.isBefore(from)) {
        lines.add((name: name, from: from, to: to, text: text));
      }
    }

    if (prediction != null) {
      add(
        'period',
        prediction.earliestStart,
        prediction.latestStart,
        l10n.aheadPeriod,
      );
      final signs = [
        for (final sign in signsBeforePeriod(
          cycles: model.cycles,
          days: model.days,
          declared: model.declaredBeforePeriod,
        ))
          if (sign.source != SignSource.common) sign,
      ];
      if (signs.isNotEmpty) {
        add(
          'signs',
          signsMayComeFrom(prediction, signs),
          prediction.earliestStart.addDays(-1),
          l10n.aheadSigns(
            [for (final sign in signs.take(3)) symptomLabel(l10n, sign.sign)]
                .join(l10n.listSeparator),
          ),
        );
      }
    }
    final fertile = estimated ? model.fertilityEstimate : null;
    if (fertile != null) {
      add('fertile', fertile.windowStart, fertile.windowEnd, l10n.aheadFertile);
    }
    final window = model.sexLifeVisible && model.cycles.isNotEmpty
        ? usualDesireWindow(cycles: model.cycles, days: model.days)
        : null;
    if (window != null && estimated) {
      final dates = desireDatesAhead(
        window,
        cycleStart: model.cycles.last.start,
        today: today,
        prediction: model.prediction,
      );
      if (dates != null) {
        add(
          'desire',
          dates.from,
          dates.to,
          l10n.aheadDesire(window.cycles, window.cyclesConsidered),
        );
      }
    }
    if (lines.isEmpty) {
      return const SizedBox.shrink();
    }
    lines.sort((a, b) => a.from.compareTo(b.from));

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TitledCard(
        key: const ValueKey('ahead'),
        title: l10n.aheadTitle,
        children: [
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MergeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.from == line.to
                          ? shortDate(l10n, line.from)
                          : l10n.aheadDates(
                              shortDate(l10n, line.from),
                              shortDate(l10n, line.to),
                            ),
                      key: ValueKey('ahead-${line.name}-dates'),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      line.text,
                      key: ValueKey('ahead-${line.name}'),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
          Text(l10n.aheadHint, style: muted),
          if (model.sexLifeVisible && window == null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.aheadDesireGeneral,
              key: const ValueKey('ahead-desire-general'),
              style: muted,
            ),
          ],
        ],
      ),
    );
  }
}
