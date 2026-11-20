import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/day_entry.dart';
import '../domain/flow_intensity.dart';
import '../domain/libido_level.dart';
import '../domain/logging_streak.dart';
import '../domain/mood.dart';
import '../domain/pain_level.dart';
import '../domain/sleep_quality.dart';
import '../domain/start_profile.dart';
import '../l10n/app_localizations.dart';
import 'cycle_model.dart';
import 'home_cards.dart';
import 'labels.dart';

/// Logging today from the home screen, one tap at a time: period, pain and
/// mood. A tap saves, a second tap takes it back, and whatever else is
/// logged for the day is kept. A bar shows how much of the day is filled
/// in, and a button opens the full entry.
///
/// Also shows, discreetly, how many days in a row were logged: a plain
/// count, without praise, and nothing at all when the run stops.
class TodayCard extends StatelessWidget {
  const TodayCard({
    super.key,
    required this.model,
    required this.today,
    required this.onOpenDay,
  });

  final CycleModel model;
  final CalendarDay today;

  /// Opens the full entry of today.
  final VoidCallback onOpenDay;

  /// The rows offered in one tap, after the flow: what she follows among
  /// pain, mood, sleep and libido, or pain and mood when she did not say.
  /// Symptoms are too many for a row: they stay in the full entry.
  static List<Tracked> _quickRows(Set<Tracked> tracked) {
    final rows = [
      for (final kind in Tracked.values)
        if (kind != Tracked.symptoms && tracked.contains(kind)) kind,
    ];
    return rows.isEmpty ? const [Tracked.pain, Tracked.mood] : rows;
  }

  void _save(DayEntry entry) {
    // A light tick under the finger: the tap was taken into account.
    HapticFeedback.selectionClick();
    model.saveDay(entry);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final entry = model.entryFor(today);
    final streak = loggingStreak(model.loggedDays, today);
    final filled = entry.filledGroups;
    return TitledCard(
      title: l10n.todayEntryTitle,
      children: [
        _Group(
          title: l10n.todayCardTitle,
          children: [
            for (final flow in FlowIntensity.values)
              ChoiceChip(
                key: ValueKey('quick-flow-${flow.name}'),
                label: Text(flowLabel(l10n, flow)),
                selected: entry.flow == flow,
                onSelected: (selected) =>
                    _save(entry.withFlow(selected ? flow : null)),
              ),
          ],
        ),
        // What she said she wants to follow; pain and mood otherwise.
        for (final kind in _quickRows(model.tracked))
          switch (kind) {
            Tracked.pain => _Group(
              title: l10n.dayPainTitle,
              children: [
                for (final pain in PainLevel.values)
                  ChoiceChip(
                    key: ValueKey('quick-pain-${pain.name}'),
                    label: Text(painLabel(l10n, pain)),
                    selected: entry.pain == pain,
                    onSelected: (selected) =>
                        _save(entry.withPain(selected ? pain : null)),
                  ),
              ],
            ),
            Tracked.mood => _Group(
              title: l10n.dayMoodTitle,
              children: [
                for (final mood in Mood.values)
                  ChoiceChip(
                    key: ValueKey('quick-mood-${mood.name}'),
                    label: Text(moodLabel(l10n, mood)),
                    selected: entry.mood == mood,
                    onSelected: (selected) =>
                        _save(entry.withMood(selected ? mood : null)),
                  ),
              ],
            ),
            Tracked.sleep => _Group(
              title: l10n.daySleepTitle,
              children: [
                for (final sleep in SleepQuality.values)
                  ChoiceChip(
                    key: ValueKey('quick-sleep-${sleep.name}'),
                    label: Text(sleepLabel(l10n, sleep)),
                    selected: entry.sleep == sleep,
                    onSelected: (selected) =>
                        _save(entry.withSleep(selected ? sleep : null)),
                  ),
              ],
            ),
            Tracked.libido => _Group(
              title: l10n.dayLibidoTitle,
              children: [
                for (final libido in LibidoLevel.values)
                  ChoiceChip(
                    key: ValueKey('quick-libido-${libido.name}'),
                    label: Text(libidoLabel(l10n, libido)),
                    selected: entry.libido == libido,
                    onSelected: (selected) =>
                        _save(entry.withLibido(selected ? libido : null)),
                  ),
              ],
            ),
            Tracked.symptoms => const SizedBox.shrink(),
          },
        MergeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: ShareBar(share: filled / DayEntry.groupCount),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.todayEntryProgress(filled, DayEntry.groupCount),
                key: const ValueKey('today-progress'),
                style: muted,
              ),
            ],
          ),
        ),
        if (streak >= minStreakShown) ...[
          const SizedBox(height: 4),
          Text(
            l10n.loggingStreak(streak),
            key: const ValueKey('logging-streak'),
            style: muted,
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            key: const ValueKey('log-today'),
            onPressed: onOpenDay,
            icon: const Icon(Icons.edit_outlined),
            label: Text(l10n.homeLogToday),
          ),
        ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(spacing: 8, children: children),
        ],
      ),
    );
  }
}
