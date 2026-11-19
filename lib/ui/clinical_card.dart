import 'package:material_ui/material_ui.dart';

import '../domain/clinical_review.dart';
import '../domain/fertility_estimate.dart';
import '../l10n/app_localizations.dart';
import 'home_cards.dart';
import 'labels.dart';

/// The log read with the parameters gynaecologists use: each line gives the
/// user's value, the published reference range, and where the value stands.
/// It describes and compares; it names no condition.
class ClinicalCard extends StatelessWidget {
  const ClinicalCard({super.key, required this.review});

  /// Null until a cycle has ended.
  final ClinicalReview? review;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final review = this.review;
    if (review == null) {
      return TitledCard(
        key: const ValueKey('clinical-card'),
        title: l10n.clinicalTitle,
        children: [
          Text(l10n.clinicalIntro, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(l10n.clinicalEmpty, style: muted),
          _Line(
            name: 'frequency',
            title: l10n.clinicalFrequency,
            value: l10n.clinicalToFill,
            reference: l10n.clinicalFrequencyRef,
          ),
          _Line(
            name: 'regularity',
            title: l10n.clinicalRegularity,
            value: l10n.clinicalToFill,
            reference: l10n.clinicalRegularityRefAny,
          ),
          _Line(
            name: 'duration',
            title: l10n.clinicalDuration,
            value: l10n.clinicalToFill,
            reference: l10n.clinicalDurationRef,
          ),
        ],
      );
    }
    final regular = review.regular;
    final volume = review.volume;
    final outside =
        review.frequency != RangePosition.within ||
        review.duration != RangePosition.within ||
        regular == false;
    return TitledCard(
      key: const ValueKey('clinical-card'),
      title: l10n.clinicalTitle,
      children: [
        Text(l10n.clinicalIntro, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(l10n.clinicalBasis(review.cyclesCounted), style: muted),
        _Line(
          name: 'frequency',
          title: l10n.clinicalFrequency,
          value: l10n.clinicalFrequencyValue(
            dayCount(l10n, review.meanCycleLength),
          ),
          reference: l10n.clinicalFrequencyRef,
          within: review.frequency == RangePosition.within,
        ),
        _Line(
          name: 'regularity',
          title: l10n.clinicalRegularity,
          value: l10n.clinicalRegularityValue(
            review.shortestCycle,
            review.longestCycle,
            review.variation,
          ),
          reference: regular == null
              ? l10n.clinicalRegularityTooFew
              : l10n.clinicalRegularityRef(review.regularVariationLimit),
          within: regular,
        ),
        _Line(
          name: 'duration',
          title: l10n.clinicalDuration,
          value: l10n.clinicalDurationValue(
            dayCount(l10n, review.meanPeriodLength),
            review.longestPeriod,
          ),
          reference: l10n.clinicalDurationRef,
          within: review.duration == RangePosition.within,
        ),
        if (volume != null)
          _Line(
            name: 'volume',
            title: l10n.clinicalVolume,
            value: switch (volume) {
              BleedingVolume.light => l10n.clinicalVolumeLight,
              BleedingVolume.moderate => l10n.clinicalVolumeModerate,
              BleedingVolume.heavy => l10n.clinicalVolumeHeavy,
            },
          ),
        _Line(
          name: 'phases',
          title: l10n.clinicalPhases,
          value: l10n.clinicalPhasesValue(
            review.follicularDaysEarliest,
            review.follicularDaysLatest,
            assumedDaysFromOvulationToPeriod,
          ),
        ),
        _Line(
          name: 'spotting',
          title: l10n.clinicalSpotting,
          value: l10n.clinicalSpottingValue(review.spottingDaysBetweenPeriods),
        ),
        if (outside) ...[
          const SizedBox(height: 16),
          Text(
            l10n.clinicalOutsideNote,
            key: const ValueKey('clinical-outside-note'),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}

/// One parameter: its name, the user's value, the reference range and,
/// when there is a range, whether the value is inside it.
class _Line extends StatelessWidget {
  const _Line({
    required this.name,
    required this.title,
    required this.value,
    this.reference,
    this.within,
  });

  final String name;
  final String title;
  final String value;
  final String? reference;

  /// Null when the value is not judged against a range.
  final bool? within;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final within = this.within;
    return Padding(
      key: ValueKey('clinical-$name'),
      padding: const EdgeInsets.only(top: 16),
      child: MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.labelLarge),
            const SizedBox(height: 2),
            Text(value, style: theme.textTheme.bodyLarge),
            if (reference != null) Text(reference!, style: muted),
            if (within != null) ...[
              const SizedBox(height: 6),
              // The words carry the meaning; the icon and the colour repeat it.
              Row(
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      within ? Icons.check_circle : Icons.error_outline,
                      size: 18,
                      color: within ? scheme.primary : scheme.error,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      within ? l10n.statusWithin : l10n.statusOutside,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: within ? scheme.primary : scheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
