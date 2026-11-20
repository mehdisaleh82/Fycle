import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/guide.dart';
import '../l10n/app_localizations.dart';
import 'cycle_model.dart';
import 'home_cards.dart';

String guideTopicLabel(AppLocalizations l10n, GuideTopic topic) =>
    switch (topic) {
      GuideTopic.perimenopause => l10n.guideTopicPerimenopause,
      GuideTopic.pregnancy => l10n.guideTopicPregnancy,
    };

/// Where the text of a topic comes from.
String guideSources(AppLocalizations l10n, GuideTopic topic) => switch (topic) {
  GuideTopic.perimenopause => l10n.guideSourcesPerimenopause,
  GuideTopic.pregnancy => l10n.guideSourcesPregnancy,
};

/// The title, the text (paragraphs separated by an empty line) and when to
/// seek advice.
({String title, String body, String seek}) guideText(
  AppLocalizations l10n,
  Guide guide,
) => switch (guide) {
  Guide.perimenopauseWhat => (
    title: l10n.guidePeriWhatTitle,
    body: l10n.guidePeriWhatBody,
    seek: l10n.guidePeriWhatSeek,
  ),
  Guide.perimenopausePeriods => (
    title: l10n.guidePeriPeriodsTitle,
    body: l10n.guidePeriPeriodsBody,
    seek: l10n.guidePeriPeriodsSeek,
  ),
  Guide.perimenopauseHotFlushes => (
    title: l10n.guidePeriFlushesTitle,
    body: l10n.guidePeriFlushesBody,
    seek: l10n.guidePeriFlushesSeek,
  ),
  Guide.perimenopauseSleepMood => (
    title: l10n.guidePeriSleepTitle,
    body: l10n.guidePeriSleepBody,
    seek: l10n.guidePeriSleepSeek,
  ),
  Guide.perimenopauseSex => (
    title: l10n.guidePeriSexTitle,
    body: l10n.guidePeriSexBody,
    seek: l10n.guidePeriSexSeek,
  ),
  Guide.perimenopauseSeekAdvice => (
    title: l10n.guidePeriSeekTitle,
    body: l10n.guidePeriSeekBody,
    seek: l10n.guidePeriSeekSeek,
  ),
  Guide.pregnancyFirstTrimester => (
    title: l10n.guidePregFirstTitle,
    body: l10n.guidePregFirstBody,
    seek: l10n.guidePregFirstSeek,
  ),
  Guide.pregnancySecondTrimester => (
    title: l10n.guidePregSecondTitle,
    body: l10n.guidePregSecondBody,
    seek: l10n.guidePregSecondSeek,
  ),
  Guide.pregnancyThirdTrimester => (
    title: l10n.guidePregThirdTitle,
    body: l10n.guidePregThirdBody,
    seek: l10n.guidePregThirdSeek,
  ),
  Guide.pregnancyUrgentSigns => (
    title: l10n.guidePregUrgentTitle,
    body: l10n.guidePregUrgentBody,
    seek: l10n.guidePregUrgentSeek,
  ),
  Guide.pregnancyCare => (
    title: l10n.guidePregCareTitle,
    body: l10n.guidePregCareBody,
    seek: l10n.guidePregCareSeek,
  ),
  Guide.pregnancyAfterBirth => (
    title: l10n.guidePregAfterTitle,
    body: l10n.guidePregAfterBody,
    seek: l10n.guidePregAfterSeek,
  ),
};

void _open(BuildContext context, Guide guide) => Navigator.of(context).push(
  MaterialPageRoute<void>(builder: (context) => GuideScreen(guide: guide)),
);

/// The one guide put forward on the home screen, from where she is in her
/// life. Nothing when none is about her.
class GuideCard extends StatelessWidget {
  const GuideCard({super.key, required this.model, required this.today});

  final CycleModel model;
  final CalendarDay today;

  @override
  Widget build(BuildContext context) {
    final guide = featuredGuide(
      profile: model.profile,
      followsCycleChanges: model.followsCycleChanges,
      today: today,
      pregnancyStart: model.pregnancyStart,
    );
    if (guide == null) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TitledCard(
        key: const ValueKey('guide-card'),
        title: l10n.guideFeaturedTitle,
        children: [
          Text(
            guideText(l10n, guide).title,
            key: const ValueKey('guide-featured'),
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilledButton.tonal(
                key: const ValueKey('guide-read'),
                onPressed: () => _open(context, guide),
                child: Text(l10n.guideRead),
              ),
              TextButton(
                key: const ValueKey('guide-all'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => GuidesScreen(model: model),
                  ),
                ),
                child: Text(l10n.guideAll),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Every guide, by topic, hers first.
class GuidesScreen extends StatelessWidget {
  const GuidesScreen({super.key, required this.model});

  final CycleModel model;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final topics = guideTopicsFor(
      profile: model.profile,
      followsCycleChanges: model.followsCycleChanges,
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.guidesTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
          children: [
            Text(l10n.guidesIntro, style: theme.textTheme.bodyMedium),
            for (final topic in topics) ...[
              const SizedBox(height: 20),
              Semantics(
                header: true,
                child: Text(
                  guideTopicLabel(l10n, topic),
                  key: ValueKey('guide-topic-${topic.name}'),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    for (final guide in Guide.values)
                      if (guide.topic == topic)
                        ListTile(
                          key: ValueKey('guide-${guide.name}'),
                          title: Text(guideText(l10n, guide).title),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _open(context, guide),
                        ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One guide: its text, when to seek advice, and where it comes from.
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key, required this.guide});

  final Guide guide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final text = guideText(l10n, guide);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return Scaffold(
      appBar: AppBar(title: Text(guideTopicLabel(l10n, guide.topic))),
      body: SafeArea(
        // Short enough to be laid out whole.
        child: SingleChildScrollView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  text.title,
                  key: const ValueKey('guide-title'),
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 12),
              // Until a health professional has read it, it says so.
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    l10n.guidePendingReview,
                    key: const ValueKey('guide-pending-review'),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ),
              for (final paragraph in text.body.split('\n\n')) ...[
                const SizedBox(height: 12),
                Text(paragraph, style: theme.textTheme.bodyLarge),
              ],
              const SizedBox(height: 16),
              TitledCard(
                key: const ValueKey('guide-seek'),
                title: l10n.guideSeekTitle,
                children: [Text(text.seek, style: theme.textTheme.bodyLarge)],
              ),
              const SizedBox(height: 16),
              Text(l10n.guideNote, style: muted),
              const SizedBox(height: 8),
              Text(
                guideSources(l10n, guide.topic),
                key: const ValueKey('guide-sources'),
                style: muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
