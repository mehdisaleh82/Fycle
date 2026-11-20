import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/coming_signs.dart';
import '../domain/cycle_status.dart';
import '../domain/life_stage.dart';
import '../domain/period_prediction.dart';
import '../l10n/app_localizations.dart';
import 'cycle_model.dart';
import 'home_cards.dart';
import 'labels.dart';

/// At most this many signs are listed.
const int maxComingSignsShown = 3;

/// What comes in the days before her period: the signs she logged cycle
/// after cycle, then the ones she named in the setup, and while nothing is
/// known of her, what is commonly reported. Each line says where it comes
/// from, so that a general benchmark never passes for something observed
/// about her.
///
/// A count and a reminder of what she said: no advice, no explanation
/// (CLAUDE.md, rule 7). When the days have come, one tap logs a sign for
/// today.
class ComingSignsCard extends StatelessWidget {
  const ComingSignsCard({
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
    // Nothing is said during a period, a pregnancy, or before periods are
    // back after a birth.
    final PeriodPrediction? prediction = switch (status) {
      PeriodExpected(:final prediction) => prediction,
      PeriodDue(:final prediction) => prediction,
      PeriodLate(:final prediction) => prediction,
      NoEstimate() || EstimateOutdated() => null,
      PeriodOngoing() => null,
    };
    if (status is PeriodOngoing || !followsACycle(model.profile)) {
      return const SizedBox.shrink();
    }
    final signs = signsBeforePeriod(
      cycles: model.cycles,
      days: model.days,
      declared: model.declaredBeforePeriod,
    );
    final common = signs.first.source == SignSource.common;
    if (common && prediction == null) {
      // Nothing of hers, and no date to tie a benchmark to.
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final daysUntil = prediction == null
        ? null
        : signsMayComeFrom(prediction, signs).daysSince(today);
    final later = daysUntil != null && daysUntil > 0;
    final when = daysUntil == null
        ? null
        : later
        ? l10n.comingIn(daysUntil)
        : l10n.comingNow;
    final entry = model.entryFor(today);

    // Side by side on a normal phone, one under the other with large text.
    final stacked = MediaQuery.textScalerOf(context).scale(1) > 1.4;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TitledCard(
        key: const ValueKey('coming-signs'),
        title: common ? l10n.comingTitleCommon : l10n.comingTitleHers,
        children: [
          if (when != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                when,
                key: const ValueKey('coming-when'),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          if (common) ...[
            Text(
              l10n.comingCommonBody(
                [for (final sign in signs) symptomLabel(l10n, sign.sign)]
                    .join(l10n.listSeparator),
              ),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(l10n.comingCommonHint, style: muted),
          ] else
            for (final sign in signs.take(maxComingSignsShown))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _line(
                  stacked: stacked,
                  text: MergeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          symptomLabel(l10n, sign.sign),
                          style: theme.textTheme.bodyLarge,
                        ),
                        Text(
                          _source(l10n, sign),
                          key: ValueKey('coming-${sign.sign.name}'),
                          style: muted,
                        ),
                      ],
                    ),
                  ),
                  action: later
                      ? null
                      : FilterChip(
                          key: ValueKey('coming-log-${sign.sign.name}'),
                          label: Text(l10n.comingLogToday),
                          tooltip: l10n.comingLogTooltip(
                            symptomLabel(l10n, sign.sign),
                          ),
                          selected: entry.symptoms.contains(sign.sign),
                          onSelected: (selected) {
                            // A light tick under the finger, as in the
                            // journal of the day.
                            HapticFeedback.selectionClick();
                            model.saveDay(
                              entry.withSymptoms({
                                for (final symptom in entry.symptoms)
                                  if (symptom != sign.sign) symptom,
                                if (selected) sign.sign,
                              }),
                            );
                          },
                        ),
                ),
              ),
        ],
      ),
    );
  }

  /// A sign and, when there is one, what to do about it today.
  Widget _line({
    required bool stacked,
    required Widget text,
    required Widget? action,
  }) {
    if (action == null) {
      return text;
    }
    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [text, const SizedBox(height: 4), action],
      );
    }
    return Row(
      children: [
        Expanded(child: text),
        const SizedBox(width: 8),
        action,
      ],
    );
  }

  /// Where the line comes from, always said.
  String _source(AppLocalizations l10n, SignBeforePeriod sign) {
    final farthest = sign.farthestDaysBefore;
    final nearest = sign.nearestDaysBefore;
    if (sign.source != SignSource.logged || farthest == null) {
      return l10n.comingDeclared;
    }
    return l10n.comingLoggedLine(
      nearest == null || nearest == farthest
          ? l10n.comingDaysBefore(farthest)
          : l10n.comingDaysRange(nearest, farthest),
      sign.cycles,
      sign.cyclesConsidered,
    );
  }
}
