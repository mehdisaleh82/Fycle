import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/cycle_overview.dart';
import '../domain/cycle_phase.dart';
import '../domain/cycle_status.dart';
import '../domain/daily_tip.dart';
import '../domain/life_stage.dart';
import '../domain/start_profile.dart';
import '../l10n/app_localizations.dart';
import 'art.dart';
import 'cycle_model.dart';
import 'labels.dart';

/// The texts of a phase: its name, what hormones do, what is often felt in
/// the head and in the body, and a few tips, one shown a day.
typedef PhaseText = ({
  String name,
  String hormones,
  String mood,
  String body,
  List<String> tips,
});

PhaseText phaseText(AppLocalizations l10n, CyclePhase phase) => switch (phase) {
  CyclePhase.period => (
    name: l10n.phasePeriodName,
    hormones: l10n.phasePeriodHormones,
    mood: l10n.phasePeriodMood,
    body: l10n.phasePeriodBody,
    tips: [l10n.phasePeriodTip1, l10n.phasePeriodTip2, l10n.phasePeriodTip3],
  ),
  CyclePhase.afterPeriod => (
    name: l10n.phaseAfterName,
    hormones: l10n.phaseAfterHormones,
    mood: l10n.phaseAfterMood,
    body: l10n.phaseAfterBody,
    tips: [l10n.phaseAfterTip1, l10n.phaseAfterTip2, l10n.phaseAfterTip3],
  ),
  CyclePhase.midCycle => (
    name: l10n.phaseMidName,
    hormones: l10n.phaseMidHormones,
    mood: l10n.phaseMidMood,
    body: l10n.phaseMidBody,
    tips: [l10n.phaseMidTip1, l10n.phaseMidTip2, l10n.phaseMidTip3],
  ),
  CyclePhase.secondPart => (
    name: l10n.phaseSecondName,
    hormones: l10n.phaseSecondHormones,
    mood: l10n.phaseSecondMood,
    body: l10n.phaseSecondBody,
    tips: [l10n.phaseSecondTip1, l10n.phaseSecondTip2, l10n.phaseSecondTip3],
  ),
  CyclePhase.beforePeriod => (
    name: l10n.phaseBeforeName,
    hormones: l10n.phaseBeforeHormones,
    mood: l10n.phaseBeforeMood,
    body: l10n.phaseBeforeBody,
    tips: [l10n.phaseBeforeTip1, l10n.phaseBeforeTip2, l10n.phaseBeforeTip3],
  ),
};

/// The tip that answers what she logged today.
String tipText(AppLocalizations l10n, TipTopic topic) => switch (topic) {
  TipTopic.pain => l10n.tipPain,
  TipTopic.headache => l10n.tipHeadache,
  TipTopic.nightSweats => l10n.tipNightSweats,
  TipTopic.poorSleep => l10n.tipPoorSleep,
  TipTopic.fatigue => l10n.tipFatigue,
  TipTopic.backPain => l10n.tipBackPain,
  TipTopic.bloating => l10n.tipBloating,
  TipTopic.nausea => l10n.tipNausea,
  TipTopic.breastTenderness => l10n.tipBreastTenderness,
  TipTopic.lowMood => l10n.tipLowMood,
};

/// Where she is in her cycle today: the phase, a tip that changes every
/// day, and, one tap away, what hormones, mood and body often do then.
/// When what she logged today calls for it (pain, a bad night, a heavy
/// mood), the tip answers that instead of the phase.
/// A line says what she herself logged around this day, and another what
/// her moment of life changes.
///
/// General benchmarks, said to be so, and an estimate whenever the phase
/// is not her period itself (CLAUDE.md, rule 7). Nothing during a
/// pregnancy, before periods are back, or with a hormonal contraception.
class PhaseCard extends StatefulWidget {
  const PhaseCard({
    super.key,
    required this.model,
    required this.today,
    required this.status,
  });

  final CycleModel model;
  final CalendarDay today;
  final CycleStatus status;

  @override
  State<PhaseCard> createState() => _PhaseCardState();
}

class _PhaseCardState extends State<PhaseCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    final today = widget.today;
    final cycleStart = model.cycles.isEmpty ? null : model.cycles.last.start;
    final phase = cyclePhaseOn(
      today,
      status: widget.status,
      cycleStart: cycleStart,
      fertility: model.fertilityEstimate,
      profile: model.profile,
      contraception: model.contraception,
    );
    if (phase == null) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final text = phaseText(l10n, phase);
    // What she logged today comes before the phase: a tip about energy
    // means little on a day of cramps.
    final topic = tipTopicFor(model.entryFor(today));
    final usual = cycleStart == null
        ? const <UsualSign>[]
        : usualSignsAround(
            today.daysSince(cycleStart) + 1,
            cycles: model.cycles,
            days: model.days,
          );
    final hers = switch (phase) {
      _ when model.followsCycleChanges => l10n.phasePerimenopause,
      CyclePhase.midCycle when model.goals.contains(Goal.conceive) =>
        l10n.phaseConceive,
      _ when model.profile == Profile.discovering => l10n.phaseDiscovering,
      _ => null,
    };

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        key: const ValueKey('phase-card'),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const ArtImage(Art.cycle, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.phaseTitle,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Semantics(
                          header: true,
                          child: Text(
                            phase == CyclePhase.period
                                ? text.name
                                : l10n.phaseEstimated(text.name),
                            key: const ValueKey('phase-name'),
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _Line(
                    icon: Icons.lightbulb_outline,
                    label: topic == null ? l10n.phaseTip : l10n.phaseTipYours,
                    text: topic == null
                        ? text.tips[tipIndexOn(today) % text.tips.length]
                        : tipText(l10n, topic),
                    textKey: const ValueKey('phase-tip'),
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              if (usual.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  l10n.phaseYours(
                    [
                      for (final sign in usual.take(3))
                        signLabel(l10n, sign.sign),
                    ].join(l10n.listSeparator),
                  ),
                  key: const ValueKey('phase-yours'),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              if (_open) ...[
                const SizedBox(height: 12),
                _Line(
                  icon: Icons.science_outlined,
                  label: l10n.phaseHormones,
                  text: text.hormones,
                  textKey: const ValueKey('phase-hormones'),
                ),
                const SizedBox(height: 12),
                _Line(
                  icon: Icons.mood_outlined,
                  label: l10n.phaseMood,
                  text: text.mood,
                  textKey: const ValueKey('phase-mood'),
                ),
                const SizedBox(height: 12),
                _Line(
                  icon: Icons.accessibility_new_outlined,
                  label: l10n.phaseBody,
                  text: text.body,
                  textKey: const ValueKey('phase-body'),
                ),
                if (hers != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    hers,
                    key: const ValueKey('phase-hers'),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  l10n.phaseNote,
                  key: const ValueKey('phase-note'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton.icon(
                  key: const ValueKey('phase-more'),
                  onPressed: () => setState(() => _open = !_open),
                  icon: Icon(_open ? Icons.expand_less : Icons.expand_more),
                  label: Text(_open ? l10n.phaseLess : l10n.phaseMore),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.icon,
    required this.label,
    required this.text,
    required this.textKey,
    this.color,
  });

  final IconData icon;
  final String label;
  final String text;
  final Key textKey;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color ?? theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color ?? theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                text,
                key: textKey,
                style: theme.textTheme.bodyMedium?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
