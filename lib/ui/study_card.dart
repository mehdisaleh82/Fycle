import 'package:material_ui/material_ui.dart';

import '../domain/clinical_review.dart';
import '../domain/fertility_estimate.dart';
import '../domain/study_facts.dart';
import '../l10n/app_localizations.dart';
import 'labels.dart';
import 'theme.dart';

String studyFactText(AppLocalizations l10n, StudyFact fact) => switch (fact) {
  StudyFact.exactly28 => l10n.factExactly28,
  StudyFact.variesMoreThan7 => l10n.factVariesMoreThan7,
  StudyFact.range22to36 => l10n.factRange22to36,
  StudyFact.shortensWithAge => l10n.factShortensWithAge,
  StudyFact.firstPartVaries => l10n.factFirstPartVaries,
  StudyFact.sixDayWindow => l10n.factSixDayWindow,
  StudyFact.figoRanges => l10n.factFigoRanges,
};

String studySourceText(AppLocalizations l10n, StudySource source) =>
    switch (source) {
      StudySource.bull2019 => l10n.sourceBull2019,
      StudySource.fehring2006 => l10n.sourceFehring2006,
      StudySource.wilcox1995 => l10n.sourceWilcox1995,
      StudySource.figo2018 => l10n.sourceFigo2018,
    };

/// Lists the published studies behind the reference figures.
Future<void> showSources(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final theme = Theme.of(context);
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      scrollable: true,
      title: Text(l10n.sourcesTitle),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.sourcesIntro, style: theme.textTheme.bodyMedium),
          for (final source in StudySource.values) ...[
            const SizedBox(height: 12),
            Text(
              studySourceText(l10n, source),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.ok),
        ),
      ],
    ),
  );
}

/// A finding of a published study, a new one each day, set against the
/// user's own figure: the first thing that changes when the app is opened.
class StudyCard extends StatelessWidget {
  const StudyCard({
    super.key,
    required this.fact,
    required this.review,
    required this.fertility,
    required this.age,
    required this.referenceCycleLength,
  });

  final StudyFact fact;

  /// Null until a cycle has ended.
  final ClinicalReview? review;

  /// Null when the estimate is off or not available yet.
  final FertilityEstimate? fertility;

  /// Null when the year of birth is unknown.
  final int? age;
  final int referenceCycleLength;

  /// Her own figure next to the finding, or what to do to get one.
  String _you(AppLocalizations l10n) {
    final review = this.review;
    switch (fact) {
      case StudyFact.shortensWithAge:
        final age = this.age;
        return age == null
            ? l10n.youAgeUnknown
            : l10n.youAgeReference(age, referenceCycleLength);
      case StudyFact.sixDayWindow:
        final fertility = this.fertility;
        return fertility == null
            ? l10n.youNotYet
            : l10n.youWindow(
                shortDate(l10n, fertility.windowStart),
                shortDate(l10n, fertility.windowEnd),
              );
      case StudyFact.exactly28 || StudyFact.range22to36:
        return review == null
            ? l10n.youNotYet
            : l10n.youMeanCycle(dayCount(l10n, review.meanCycleLength));
      case StudyFact.variesMoreThan7:
        return review == null || review.cyclesCounted < 2
            ? l10n.youNotYet
            : l10n.youVariation(review.variation);
      case StudyFact.firstPartVaries:
        return review == null
            ? l10n.youNotYet
            : l10n.youFollicular(
                review.follicularDaysEarliest,
                review.follicularDaysLatest,
              );
      case StudyFact.figoRanges:
        return review == null
            ? l10n.youNotYet
            : l10n.youFigo(
                dayCount(l10n, review.meanCycleLength),
                dayCount(l10n, review.meanPeriodLength),
              );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = AccentColors.of(context);
    return Card.filled(
      key: const ValueKey('study-card'),
      margin: EdgeInsets.zero,
      color: scheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MergeSemantics(
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.studyCardTitle,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: accent.todayHalo,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      studyFactText(l10n, fact),
                      key: const ValueKey('study-fact'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: scheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _you(l10n),
                      key: const ValueKey('study-you'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      studySourceText(l10n, fact.source),
                      key: const ValueKey('study-source'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                key: const ValueKey('open-sources'),
                style: TextButton.styleFrom(
                  foregroundColor: accent.todayHalo,
                  padding: const EdgeInsetsDirectional.only(end: 12),
                ),
                onPressed: () => showSources(context),
                child: Text(l10n.sourcesTitle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
