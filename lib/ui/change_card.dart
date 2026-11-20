import 'package:material_ui/material_ui.dart';

import '../domain/cycle_change.dart';
import '../domain/start_profile.dart';
import '../domain/symptom.dart';
import '../l10n/app_localizations.dart';
import 'home_cards.dart';
import 'labels.dart';

/// What her dates show from one cycle to the next: differences that come
/// back, long intervals, and the signs she logged. It counts and reports;
/// it names no stage and no condition, and sends her to a health
/// professional for what it means.
class ChangeCard extends StatelessWidget {
  const ChangeCard({
    super.key,
    required this.change,
    required this.saidAtSetup,
    this.signsAtSetup = const {},
  });

  final CycleChange change;

  /// The changes she named when the app was set up.
  final Set<RecentChange> saidAtSetup;

  /// The signs she said she had when the app was set up.
  final Set<Symptom> signsAtSetup;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final change = this.change;
    // Each cycle is compared with the one before: one more cycle than
    // comparisons.
    final compared = change.cyclesCompared;
    final interval = change.longestInterval;
    final sinceLast = change.daysSinceLastPeriod;
    final said = [
      for (final value in RecentChange.values)
        if (value != RecentChange.nothing && saidAtSetup.contains(value))
          switch (value) {
            RecentChange.heavierFlow => l10n.changeSaidHeavier,
            RecentChange.lighterFlow => l10n.changeSaidLighter,
            RecentChange.lessRegular => l10n.changeSaidLessRegular,
            RecentChange.lengthChanged => l10n.changeSaidLength,
            RecentChange.nothing => '',
          },
    ];
    // What is worth telling a professional about.
    final toReport =
        change.differenceComesBack || interval != null || sinceLast != null;
    return TitledCard(
      key: const ValueKey('change-card'),
      title: l10n.changeTitle,
      children: [
        Text(l10n.changeIntro, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        _Fact(
          name: 'difference',
          icon: Icons.swap_vert,
          text: compared == 0
              ? l10n.changeTooFew
              : change.markedDifferences == 0
              ? l10n.changeNoDifference(compared + 1)
              : l10n.changeDifferences(change.markedDifferences, compared + 1),
          strong: change.differenceComesBack,
        ),
        if (interval != null)
          _Fact(
            name: 'interval',
            icon: Icons.more_time,
            text: l10n.changeLongInterval(interval),
            strong: true,
          ),
        if (sinceLast != null)
          _Fact(
            name: 'since-last',
            icon: Icons.hourglass_bottom,
            text: l10n.changeSinceLast(sinceLast),
            strong: true,
          ),
        _Fact(
          name: 'signs',
          icon: Icons.thermostat,
          text: change.signDays.isEmpty
              ? l10n.changeNoSigns
              : l10n.changeSignsList(
                  [
                    for (final sign in changeSigns)
                      if (change.signDays[sign] case final days?)
                        l10n.changeSignDays(symptomLabel(l10n, sign), days),
                  ].join(l10n.listSeparator),
                ),
        ),
        if (said.isNotEmpty)
          _Fact(
            name: 'said',
            icon: Icons.format_quote,
            text: l10n.changeSaid(said.join(l10n.listSeparator)),
          ),
        if (signsAtSetup.isNotEmpty)
          _Fact(
            name: 'start-signs',
            icon: Icons.flag_outlined,
            text: l10n.changeStartSigns(
              [
                for (final sign in changeSigns)
                  if (signsAtSetup.contains(sign)) symptomLabel(l10n, sign),
              ].join(l10n.listSeparator),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          toReport ? l10n.changeToReport : l10n.changeFooter,
          key: const ValueKey('change-footer'),
          style: toReport ? theme.textTheme.bodyMedium : muted,
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({
    required this.name,
    required this.icon,
    required this.text,
    this.strong = false,
  });

  final String name;
  final IconData icon;
  final String text;

  /// Whether the fact passes a published threshold.
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Icon(icon, size: 20, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              key: ValueKey('change-$name'),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: strong ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
