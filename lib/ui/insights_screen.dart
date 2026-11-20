import 'package:material_ui/material_ui.dart';

import '../domain/clinical_review.dart';
import '../domain/cycle_change.dart';
import '../domain/cycle_comparison.dart';
import '../domain/cycle_history.dart';
import '../domain/cycle_overview.dart';
import '../domain/cycle_status.dart';
import '../domain/cycle_trends.dart';
import '../domain/migraine.dart';
import '../l10n/app_localizations.dart';
import 'app_environment.dart';
import 'change_card.dart';
import 'clinical_card.dart';
import 'comparison_card.dart';
import 'cycle_model.dart';
import 'devices_screen.dart';
import 'disclaimer_card.dart';
import 'doctor_pdf.dart';
import 'fertility_card.dart';
import 'guides_screen.dart';
import 'home_cards.dart';
import 'labels.dart';
import 'migraine_card.dart';

/// Trends: the average lengths, what comes back at the same moment of the
/// cycle, and the list of logged cycles.
///
/// Everything here counts what was logged. Nothing is interpreted.
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({
    super.key,
    required this.header,
    required this.model,
    required this.environment,
  });

  final CycleModel model;
  final AppEnvironment environment;

  /// One line saying what the tab is for, shown first and scrolled with
  /// the rest.
  final Widget header;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: model,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final theme = Theme.of(context);
        final prediction = model.prediction;
        final comparison = compareWithPreviousCycle(
          cycles: model.cycles,
          days: model.days,
          today: environment.today(),
        );
        final cycles = model.cycles;
        final today = environment.today();
        final status = cycleStatusOn(
          today,
          flowByDay: model.flowByDay,
          prediction: model.prediction,
        );
        final showFertility =
            model.fertilityEstimateEnabled &&
            status is! NoEstimate &&
            status is! EstimateOutdated;
        return SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              // What a doctor would look at, one tap away.
              FilledButton.tonalIcon(
                key: const ValueKey('open-doctor-report'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => DoctorReportScreen(
                      model: model,
                      environment: environment,
                    ),
                  ),
                ),
                icon: const Icon(Icons.assignment_outlined),
                label: Text(l10n.doctorReportTitle),
              ),
              const SizedBox(height: 16),
              KeyFiguresCard(
                overview: cycleOverviewOn(
                  today,
                  cycles: cycles,
                  prediction: prediction,
                  usualCycleLength: model.usualCycleLength,
                  daysLogged: model.loggedDays.length,
                  referenceCycleLength: model.referenceCycleLength,
                ),
              ),
              if (prediction != null && status is! EstimateOutdated)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
                  child: Text(
                    '${estimateBasis(l10n, prediction, declaredLength: model.usualCycleLength, assumedLength: model.referenceCycleLength)} '
                    '${confidenceLabel(l10n, prediction)}',
                    key: const ValueKey('estimate-basis'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              if (comparison != null) ...[
                const SizedBox(height: 16),
                ComparisonCard(comparison: comparison),
              ],
              if (model.followsCycleChanges) ...[
                const SizedBox(height: 16),
                ChangeCard(
                  change: cycleChangeOn(
                    today,
                    cycles: cycles,
                    days: model.days,
                  ),
                  saidAtSetup: model.recentChanges,
                  signsAtSetup: model.startSigns,
                ),
              ],
              if (showFertility) ...[
                const SizedBox(height: 16),
                FertilityCard(estimate: model.fertilityEstimate),
              ],
              const SizedBox(height: 16),
              // The clinical sheet, the trends and the history: one tap
              // away, for the days she wants to dig.
              OutlinedButton.icon(
                key: const ValueKey('open-review-detail'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => ReviewDetailScreen(
                      model: model,
                      environment: environment,
                    ),
                  ),
                ),
                icon: const Icon(Icons.expand_circle_down_outlined),
                label: Text(l10n.reviewSeeDetail),
              ),
              const SizedBox(height: 8),
              // General information, hers first.
              OutlinedButton.icon(
                key: const ValueKey('open-guides'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => GuidesScreen(model: model),
                  ),
                ),
                icon: const Icon(Icons.article_outlined),
                label: Text(l10n.guidesTitle),
              ),
              const SizedBox(height: 8),
              // What her watch measured, read when she asks.
              OutlinedButton.icon(
                key: const ValueKey('open-devices'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        DevicesScreen(model: model, environment: environment),
                  ),
                ),
                icon: const Icon(Icons.watch_outlined),
                label: Text(l10n.devicesTitle),
              ),
              const SizedBox(height: 16),
              const DisclaimerCard(),
            ],
          ),
        );
      },
    );
  }
}

/// What the review keeps one tap away: the current cycle in detail, the
/// clinical sheet, the averages, what comes back, the list of cycles and
/// what the next entries will bring.
///
/// Everything here counts what was logged. Nothing is interpreted.
class ReviewDetailScreen extends StatelessWidget {
  const ReviewDetailScreen({
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
      appBar: AppBar(title: Text(l10n.reviewDetailTitle)),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: model,
          builder: (context, _) {
            final cycles = model.cycles;
            final today = environment.today();
            final steps = insightSteps(
              cycles: cycles,
              prediction: model.prediction,
            );
            return SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ReportCard(
                    report: currentCycleReport(
                      cycles: cycles,
                      days: model.days,
                      today: today,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClinicalCard(
                    review: clinicalReview(
                      cycles: cycles,
                      flowByDay: model.flowByDay,
                      today: today,
                      age: model.age,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AveragesCard(
                    averages: cycleAverages(cycles, today: environment.today()),
                  ),
                  const SizedBox(height: 16),
                  _TrendsCard(
                    trends: cycleTrends(cycles: cycles, days: model.days),
                  ),
                  const SizedBox(height: 16),
                  if (migraineSummaryOn(today, days: model.days, cycles: cycles)
                      case final migraines?) ...[
                    MigraineCard(summary: migraines),
                    const SizedBox(height: 16),
                  ],
                  _HistoryCard(cycles: cycles),
                  const SizedBox(height: 16),
                  UnlockCard(steps: steps),
                  const SizedBox(height: 16),
                  const DisclaimerCard(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The current cycle at a glance, readable at any time.
class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  /// Null when no period was logged.
  final CycleReport? report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final report = this.report;
    final symptoms = report?.mostLoggedSymptoms ?? const [];
    return _CardBody(
      key: const ValueKey('cycle-report'),
      title: l10n.reportTitle,
      children: [
        if (report == null)
          Text(l10n.reportEmpty, style: theme.textTheme.bodyMedium)
        else
          for (final line in [
            l10n.cycleDaySemantics(report.dayOfCycle),
            l10n.reportStarted(mediumDate(l10n, report.cycle.start)),
            l10n.reportPeriod(report.cycle.periodLength),
            l10n.reportLogged(report.daysLogged),
            if (report.painDays > 0) l10n.reportPainDays(report.painDays),
            if (report.poorSleepNights > 0)
              l10n.reportPoorSleep(report.poorSleepNights),
            if (symptoms.isNotEmpty)
              l10n.summaryMostLogged(
                [for (final symptom in symptoms) symptomLabel(l10n, symptom)]
                    .join(l10n.listSeparator),
              ),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(line, style: theme.textTheme.bodyMedium),
            ),
      ],
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({super.key, required this.title, required this.children});

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

/// Everything a doctor would look at, on one page to show on the phone: the
/// clinical sheet, the current cycle, the averages, what comes back and the
/// history. It describes and compares; it is no diagnosis.
class DoctorReportScreen extends StatelessWidget {
  const DoctorReportScreen({
    super.key,
    required this.model,
    required this.environment,
  });

  final CycleModel model;
  final AppEnvironment environment;

  /// Makes the PDF on the phone and hands it to the file dialog of the
  /// system: she keeps it where she wants.
  Future<void> _savePdf(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final today = environment.today();
    var saved = false;
    try {
      final bytes = await buildDoctorPdf(
        l10n,
        today: today,
        cycles: model.cycles,
        days: model.days,
        followsChanges: model.followsCycleChanges,
        age: model.age,
      );
      saved = await environment.files.save(
        fileName: 'fycle-report-$today.pdf',
        bytes: bytes,
      );
    } on Exception {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      return;
    }
    if (saved) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.pdfSaved)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.doctorReportTitle),
        actions: [
          IconButton(
            key: const ValueKey('doctor-pdf'),
            tooltip: l10n.pdfSave,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () => _savePdf(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: model,
          builder: (context, _) {
            final cycles = model.cycles;
            final today = environment.today();
            final age = model.age;
            final comparison = compareWithPreviousCycle(
              cycles: cycles,
              days: model.days,
              today: today,
            );
            const gap = SizedBox(height: 16);
            return SingleChildScrollView(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.doctorReportIntro(mediumDate(l10n, today)),
                          key: const ValueKey('doctor-report-intro'),
                          style: theme.textTheme.bodyMedium,
                        ),
                        if (age != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            l10n.doctorReportAge(age),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                  ClinicalCard(
                    review: clinicalReview(
                      cycles: cycles,
                      flowByDay: model.flowByDay,
                      today: today,
                      age: age,
                    ),
                  ),
                  gap,
                  _ReportCard(
                    report: currentCycleReport(
                      cycles: cycles,
                      days: model.days,
                      today: today,
                    ),
                  ),
                  if (comparison != null) ...[
                    gap,
                    ComparisonCard(comparison: comparison),
                  ],
                  if (model.followsCycleChanges) ...[
                    gap,
                    ChangeCard(
                      change: cycleChangeOn(
                        today,
                        cycles: cycles,
                        days: model.days,
                      ),
                      saidAtSetup: model.recentChanges,
                      signsAtSetup: model.startSigns,
                    ),
                  ],
                  gap,
                  _AveragesCard(averages: cycleAverages(cycles, today: today)),
                  gap,
                  _TrendsCard(
                    trends: cycleTrends(cycles: cycles, days: model.days),
                  ),
                  gap,
                  if (migraineSummaryOn(today, days: model.days, cycles: cycles)
                      case final migraines?) ...[
                    MigraineCard(summary: migraines),
                    gap,
                  ],
                  _HistoryCard(cycles: cycles),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
