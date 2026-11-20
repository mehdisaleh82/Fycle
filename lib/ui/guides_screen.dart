import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/further_reading.dart';
import '../domain/guide.dart';
import '../l10n/app_localizations.dart';
import 'art.dart';
import 'cycle_model.dart';
import 'home_cards.dart';
import 'links.dart';

String guideTopicLabel(AppLocalizations l10n, GuideTopic topic) =>
    switch (topic) {
      GuideTopic.perimenopause => l10n.guideTopicPerimenopause,
      GuideTopic.pregnancy => l10n.guideTopicPregnancy,
    };

Art guideTopicArt(GuideTopic topic) => switch (topic) {
  GuideTopic.perimenopause => Art.warmth,
  GuideTopic.pregnancy => Art.body,
};

String readingTopicLabel(AppLocalizations l10n, ReadingTopic topic) =>
    switch (topic) {
      ReadingTopic.cycle => l10n.readingTopicCycle,
      ReadingTopic.sexuality => l10n.readingTopicSexuality,
      ReadingTopic.contraception => l10n.readingTopicContraception,
      ReadingTopic.fertility => l10n.readingTopicFertility,
      ReadingTopic.perimenopause => l10n.guideTopicPerimenopause,
      ReadingTopic.pregnancy => l10n.guideTopicPregnancy,
    };

/// The outside pages of a topic, as the language of the interface lists
/// them: each language brings its own sources.
List<ReadingLink> readingLinks(AppLocalizations l10n, ReadingTopic topic) =>
    parseReadingLinks(switch (topic) {
      ReadingTopic.cycle => l10n.linksCycle,
      ReadingTopic.sexuality => l10n.linksSexuality,
      ReadingTopic.contraception => l10n.linksContraception,
      ReadingTopic.fertility => l10n.linksFertility,
      ReadingTopic.perimenopause => l10n.linksPerimenopause,
      ReadingTopic.pregnancy => l10n.linksPregnancy,
    });

ReadingTopic readingTopicOf(GuideTopic topic) => switch (topic) {
  GuideTopic.perimenopause => ReadingTopic.perimenopause,
  GuideTopic.pregnancy => ReadingTopic.pregnancy,
};

/// The outside pages of one topic, each opened in the browser of the
/// phone. Nothing when the language lists none.
class ReadingList extends StatelessWidget {
  const ReadingList({super.key, required this.topic});

  final ReadingTopic topic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final links = readingLinks(l10n, topic);
    if (links.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      key: ValueKey('links-${topic.name}'),
      child: Column(
        children: [
          for (final (index, link) in links.indexed)
            ListTile(
              key: ValueKey('link-${topic.name}-$index'),
              title: Text(link.title),
              subtitle: Text(link.source),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => openLink(link.address),
            ),
        ],
      ),
    );
  }
}

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
              Row(
                children: [
                  ArtImage(guideTopicArt(topic), size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        guideTopicLabel(l10n, topic),
                        key: ValueKey('guide-topic-${topic.name}'),
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                ],
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
            const SizedBox(height: 28),
            Semantics(
              header: true,
              child: Text(
                l10n.readingTitle,
                key: const ValueKey('reading-title'),
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 4),
            Text(l10n.readingNote, style: theme.textTheme.bodySmall),
            for (final topic in ReadingTopic.values)
              // Nothing about sex for the one who turned it off.
              if ((model.sexLifeVisible ||
                      (topic != ReadingTopic.sexuality &&
                          topic != ReadingTopic.contraception)) &&
                  readingLinks(l10n, topic).isNotEmpty) ...[
                const SizedBox(height: 16),
                Semantics(
                  header: true,
                  child: Text(
                    readingTopicLabel(l10n, topic),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                ReadingList(topic: topic),
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
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: ArtImage(guideTopicArt(guide.topic)),
              ),
              const SizedBox(height: 12),
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
              if (readingLinks(
                l10n,
                readingTopicOf(guide.topic),
              ).isNotEmpty) ...[
                const SizedBox(height: 24),
                Semantics(
                  header: true,
                  child: Text(
                    l10n.readingTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 4),
                Text(l10n.readingNote, style: muted),
                const SizedBox(height: 8),
                ReadingList(topic: readingTopicOf(guide.topic)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
