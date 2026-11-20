import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/cycle_status.dart';
import '../domain/desire_pattern.dart';
import '../domain/further_reading.dart';
import '../domain/guide.dart';
import '../domain/kiosk.dart';
import '../domain/start_profile.dart';
import '../l10n/app_localizations.dart';
import 'art.dart';
import 'cycle_model.dart';
import 'home_cards.dart';
import 'links.dart';

String guideTopicLabel(AppLocalizations l10n, GuideTopic topic) =>
    switch (topic) {
      GuideTopic.perimenopause => l10n.guideTopicPerimenopause,
      GuideTopic.pregnancy => l10n.guideTopicPregnancy,
      GuideTopic.intimacy => l10n.guideTopicIntimacy,
    };

Art guideTopicArt(GuideTopic topic) => switch (topic) {
  GuideTopic.perimenopause => Art.warmth,
  GuideTopic.pregnancy => Art.body,
  GuideTopic.intimacy => Art.woman,
};

/// The picture of a guide: its own when it has one, that of its topic
/// otherwise.
Art guideArt(Guide guide) => switch (guide) {
  Guide.intimacyNoOrgasm || Guide.intimacySolo => Art.lotus,
  Guide.intimacyPeriodSex || Guide.intimacyOnSchedule => Art.calendar,
  Guide.intimacyAnal || Guide.intimacyAfterBaby => Art.body,
  Guide.intimacyDesireCycle => Art.cycle,
  Guide.intimacyPain => Art.cramps,
  Guide.intimacyTears => Art.sleep,
  Guide.intimacySayIt => Art.journal,
  Guide.intimacyNoDesire || Guide.intimacyLube => Art.energy,
  Guide.intimacyMidlife => Art.warmth,
  _ => guideTopicArt(guide.topic),
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
  GuideTopic.intimacy => ReadingTopic.sexuality,
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
  GuideTopic.intimacy => l10n.guideSourcesIntimacy,
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
  Guide.intimacyOrgasm => (
    title: l10n.guideIntOrgasmTitle,
    body: l10n.guideIntOrgasmBody,
    seek: l10n.guideIntOrgasmKeep,
  ),
  Guide.intimacyNoOrgasm => (
    title: l10n.guideIntNoOrgasmTitle,
    body: l10n.guideIntNoOrgasmBody,
    seek: l10n.guideIntNoOrgasmKeep,
  ),
  Guide.intimacySolo => (
    title: l10n.guideIntSoloTitle,
    body: l10n.guideIntSoloBody,
    seek: l10n.guideIntSoloKeep,
  ),
  Guide.intimacyPeriodSex => (
    title: l10n.guideIntPeriodSexTitle,
    body: l10n.guideIntPeriodSexBody,
    seek: l10n.guideIntPeriodSexKeep,
  ),
  Guide.intimacyAnal => (
    title: l10n.guideIntAnalTitle,
    body: l10n.guideIntAnalBody,
    seek: l10n.guideIntAnalKeep,
  ),
  Guide.intimacyLube => (
    title: l10n.guideIntLubeTitle,
    body: l10n.guideIntLubeBody,
    seek: l10n.guideIntLubeKeep,
  ),
  Guide.intimacyDesireCycle => (
    title: l10n.guideIntDesireCycleTitle,
    body: l10n.guideIntDesireCycleBody,
    seek: l10n.guideIntDesireCycleKeep,
  ),
  Guide.intimacySquirting => (
    title: l10n.guideIntSquirtingTitle,
    body: l10n.guideIntSquirtingBody,
    seek: l10n.guideIntSquirtingKeep,
  ),
  Guide.intimacyPain => (
    title: l10n.guideIntPainTitle,
    body: l10n.guideIntPainBody,
    seek: l10n.guideIntPainKeep,
  ),
  Guide.intimacyTears => (
    title: l10n.guideIntTearsTitle,
    body: l10n.guideIntTearsBody,
    seek: l10n.guideIntTearsKeep,
  ),
  Guide.intimacySayIt => (
    title: l10n.guideIntSayItTitle,
    body: l10n.guideIntSayItBody,
    seek: l10n.guideIntSayItKeep,
  ),
  Guide.intimacyNoDesire => (
    title: l10n.guideIntNoDesireTitle,
    body: l10n.guideIntNoDesireBody,
    seek: l10n.guideIntNoDesireKeep,
  ),
  Guide.intimacyAfterBaby => (
    title: l10n.guideIntAfterBabyTitle,
    body: l10n.guideIntAfterBabyBody,
    seek: l10n.guideIntAfterBabyKeep,
  ),
  Guide.intimacyMidlife => (
    title: l10n.guideIntMidlifeTitle,
    body: l10n.guideIntMidlifeBody,
    seek: l10n.guideIntMidlifeKeep,
  ),
  Guide.intimacyOnSchedule => (
    title: l10n.guideIntOnScheduleTitle,
    body: l10n.guideIntOnScheduleBody,
    seek: l10n.guideIntOnScheduleKeep,
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

/// The way to the kiosk: recent articles from the press, on a web page
/// rebuilt every day and opened in the browser of the phone. The page
/// about intimacy is offered only to the one who is shown that topic.
class KioskCard extends StatelessWidget {
  const KioskCard({super.key, required this.intimacy});

  final bool intimacy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final language = Localizations.localeOf(context).languageCode;
    // The region the phone is set to: the app itself keeps no country.
    final country = View.of(context).platformDispatcher.locale.countryCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          key: const ValueKey('kiosk'),
          child: Column(
            children: [
              ListTile(
                key: const ValueKey('open-kiosk'),
                leading: const Icon(Icons.newspaper_outlined),
                title: Text(l10n.kioskTitle),
                subtitle: Text(l10n.kioskBody),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => openLink(
                  kioskAddress(
                    languageCode: language,
                    countryCode: country,
                    intimacy: false,
                  ),
                ),
              ),
              if (intimacy)
                ListTile(
                  key: const ValueKey('open-kiosk-intimacy'),
                  leading: const Icon(Icons.favorite_outline),
                  title: Text(l10n.kioskIntimacyTitle),
                  subtitle: Text(l10n.kioskIntimacyBody),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => openLink(
                    kioskAddress(
                      languageCode: language,
                      countryCode: country,
                      intimacy: true,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, top: 6, end: 4),
          child: Text(l10n.kioskNote, style: theme.textTheme.bodySmall),
        ),
      ],
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
      intimacy: showsIntimacy(
        sexLifeVisible: model.sexLifeVisible,
        age: model.age,
        profile: model.profile,
      ),
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
            const SizedBox(height: 12),
            KioskCard(intimacy: topics.contains(GuideTopic.intimacy)),
            for (final topic in ReadingTopic.values)
              // Nothing about sex for the one who turned it off, nor for
              // a minor.
              if ((topic == ReadingTopic.sexuality
                      ? topics.contains(GuideTopic.intimacy)
                      : model.sexLifeVisible ||
                            topic != ReadingTopic.contraception) &&
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
              for (final (index, paragraph)
                  in text.body.split('\n\n').indexed) ...[
                const SizedBox(height: 12),
                Text(
                  paragraph,
                  // A magazine opens on a line that stands out.
                  style: index == 0 && guide.topic == GuideTopic.intimacy
                      ? theme.textTheme.titleMedium
                      : theme.textTheme.bodyLarge,
                ),
              ],
              const SizedBox(height: 16),
              TitledCard(
                key: const ValueKey('guide-seek'),
                title: guide.topic == GuideTopic.intimacy
                    ? l10n.guideKeepTitle
                    : l10n.guideSeekTitle,
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

/// The guides on intimacy, as cards to swipe through on the home screen.
/// What fits where she is comes first, and the first card changes from one
/// day to the next. Nothing for a minor, nor once she turned it off.
class IntimacyCarousel extends StatelessWidget {
  const IntimacyCarousel({
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
    if (!showsIntimacy(
      sexLifeVisible: model.sexLifeVisible,
      age: model.age,
      profile: model.profile,
    )) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cycles = model.cycles;
    final window = cycles.isEmpty
        ? null
        : usualDesireWindow(cycles: cycles, days: model.days);
    final dayOfCycle = cycles.isEmpty
        ? null
        : today.daysSince(cycles.last.start) + 1;
    final guides = intimacyGuidesFor(
      profile: model.profile,
      followsCycleChanges: model.followsCycleChanges,
      wantsToConceive: model.goals.contains(Goal.conceive),
      periodOngoing: status is PeriodOngoing,
      desireDays:
          window != null &&
          dayOfCycle != null &&
          dayOfCycle >= window.fromDay &&
          dayOfCycle <= window.toDay,
      rotation: today.daysSince(CalendarDay(2020, 1, 1)),
    );
    // Room for three lines of title, whatever the size of the text.
    final height = 84 + MediaQuery.textScalerOf(context).scale(66);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.guideTopicIntimacy,
                  key: const ValueKey('intimacy-title'),
                  style: theme.textTheme.titleMedium,
                ),
              ),
              TextButton(
                key: const ValueKey('intimacy-all'),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => GuidesScreen(model: model),
                  ),
                ),
                child: Text(l10n.guideAll),
              ),
            ],
          ),
          SizedBox(
            height: height,
            child: ListView.separated(
              key: const ValueKey('intimacy-carousel'),
              scrollDirection: Axis.horizontal,
              itemCount: guides.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final guide = guides[index];
                return SizedBox(
                  width: 200,
                  child: Material(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      key: ValueKey('intimacy-card-${guide.name}'),
                      onTap: () => _open(context, guide),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ArtImage(guideArt(guide), size: 48),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                guideText(l10n, guide).title,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
