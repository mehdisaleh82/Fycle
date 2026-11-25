import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/calendar_day.dart';
import '../domain/cycle_overview.dart';
import '../domain/cycle_status.dart';
import '../domain/day_entry.dart';
import '../domain/period_prediction.dart';
import '../l10n/app_localizations.dart';
import 'cycle_ring.dart';
import 'cycle_strip.dart';
import 'labels.dart';
import 'theme.dart';

/// What the middle of the ring and the text under it show.
enum _View {
  /// The day of the cycle and the estimate for the next period.
  day,

  /// The cycle laid flat, as a line, with its steps and their dates.
  timeline,

  /// What she logged around this day in her past cycles.
  usual,
}

/// The first thing seen, and almost the only one: the cycle as a ring, the
/// day of the cycle in its middle, and the estimate for the next period,
/// always as a range. Says, without alarm, when the range is over.
///
/// The card is meant to be touched. A tap anywhere goes to the next view
/// (the cycle as a line with its steps, then what usually comes around this
/// day), and dots under the ring show how many views there are. A finger sliding around the ring
/// goes through the cycle day by day: the date, what is estimated for it,
/// what was logged on it and what usually comes around it. While no period
/// is logged, one button logs that it starts today.
class PredictionCard extends StatefulWidget {
  const PredictionCard({
    super.key,
    required this.status,
    required this.overview,
    required this.today,
    this.cycleStart,
    this.fertileFromDay,
    this.fertileToDay,
    this.periodEstimatedDays,
    this.ovulationLine,
    this.periodEndLine,
    this.usualSignsFor,
    this.entryFor,
    this.onOpenDay,
    this.onPeriodStartsToday,
  });

  final CycleStatus status;
  final CycleOverview overview;
  final CalendarDay today;

  /// First day of the current cycle. Without it, the ring cannot be gone
  /// through: its days have no date.
  final CalendarDay? cycleStart;

  /// Days of the cycle covered by the estimated fertile window, when the
  /// user keeps that estimate on.
  final int? fertileFromDay;
  final int? fertileToDay;

  /// The day of the cycle the period going on may last until, when her
  /// past periods allow an estimate.
  final int? periodEstimatedDays;

  /// The estimated range of ovulation, already worded, when the user keeps
  /// that estimate on and enough cycles are logged.
  final String? ovulationLine;

  /// How long the period going on may still last, already worded, when her
  /// past periods allow an estimate.
  final String? periodEndLine;

  /// What she logged around a given day of the cycle in her past cycles.
  final List<UsualSign> Function(int dayOfCycle)? usualSignsFor;

  /// What is logged for a given day; an empty entry when nothing is.
  final DayEntry Function(CalendarDay day)? entryFor;

  /// Opens the journal page of a day.
  final ValueChanged<CalendarDay>? onOpenDay;

  /// Logs that a period starts today. Offered while there is no estimate.
  final VoidCallback? onPeriodStartsToday;

  @override
  State<PredictionCard> createState() => _PredictionCardState();
}

class _PredictionCardState extends State<PredictionCard> {
  static const double _ringSize = 168;

  /// Which view is shown, counted in taps.
  int _view = 0;

  /// The day of the cycle being looked at, while a finger went around the
  /// ring. Null when the card shows today.
  int? _explored;

  /// The finger that is going around the ring, if any.
  int? _pointer;

  CycleStatus get status => widget.status;
  CycleOverview get overview => widget.overview;

  String _range(
    AppLocalizations l10n,
    PeriodPrediction prediction, {
    bool next = false,
  }) {
    final start = shortDate(l10n, prediction.earliestStart);
    final end = shortDate(l10n, prediction.latestStart);
    return next
        ? l10n.statusNextRange(start, end)
        : l10n.statusExpectedRange(start, end);
  }

  /// "Period in 5 to 11 days": the countdown is a range too.
  String _countdown(AppLocalizations l10n, int earliest) {
    final latest = overview.daysUntilLatest ?? earliest;
    return latest > earliest
        ? l10n.countdownRange(earliest, latest)
        : l10n.countdownDays(earliest);
  }

  void _explore(int day) {
    if (day == _explored) {
      return;
    }
    // A light tick at each day passed.
    HapticFeedback.selectionClick();
    setState(() => _explored = day);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = AccentColors.of(context);
    final onCard = accent.onCard;

    final String title;
    final lines = <String>[];
    var counting = true;
    var estimated = false;
    PeriodPrediction? shown;
    switch (status) {
      case NoEstimate():
        title = l10n.statusNoDataTitle;
        lines.add(l10n.statusNoDataBody);
        counting = false;
      case EstimateOutdated():
        title = l10n.statusOutdatedTitle;
        lines.add(l10n.statusOutdatedBody);
        counting = false;
      case PeriodOngoing(:final dayOfPeriod, :final next):
        title = l10n.statusOngoing(dayOfPeriod);
        final end = widget.periodEndLine;
        if (end != null) {
          lines.add(end);
        }
        lines.add(_range(l10n, next, next: true));
        estimated = true;
        shown = next;
      case PeriodExpected(:final prediction, :final daysUntil):
        title = _countdown(l10n, daysUntil);
        // Where she is, in plain words, before the dates.
        lines
          ..add(
            (overview.dayOfCycle ?? 1) * 2 <= overview.cycleLength
                ? l10n.cycleFirstHalf
                : l10n.cycleSecondHalf,
          )
          ..add(_range(l10n, prediction));
        estimated = true;
        shown = prediction;
      case PeriodDue(:final prediction):
        title = l10n.countdownDue;
        lines.add(_range(l10n, prediction));
        estimated = true;
        shown = prediction;
      case PeriodLate(:final prediction, :final daysLate):
        title = _range(l10n, prediction);
        lines
          ..add(l10n.statusLate(daysLate))
          ..add(l10n.statusLateNote);
        estimated = true;
    }
    final ovulation = widget.ovulationLine;
    if (estimated && ovulation != null) {
      lines.add(ovulation);
    }

    final day = counting ? overview.dayOfCycle : null;
    final earliest = overview.daysUntilEarliest;
    final latest = overview.daysUntilLatest;
    final expectedFrom = day != null && earliest != null
        ? day + earliest
        : null;
    final expectedTo = day != null && latest != null ? day + latest : null;
    final totalDays = [
      overview.cycleLength,
      ?day,
      ?expectedTo,
    ].reduce(math.max);

    // The line shows what is ahead: offered while the range is not behind,
    // before it, inside it, and during a period, for the one after.
    final canCount =
        day != null && earliest != null && latest != null && latest >= 0;
    final usualFor = widget.usualSignsFor;
    final usualToday = day == null || usualFor == null
        ? const <UsualSign>[]
        : usualFor(day);
    final views = [
      _View.day,
      if (canCount) _View.timeline,
      if (usualToday.isNotEmpty) _View.usual,
    ];
    final view = views[_view % views.length];
    final nextView = views[(_view + 1) % views.length];

    final cycleStart = widget.cycleStart;
    final flat = view == _View.timeline && day != null;
    // The ring is gone through with a finger; the line is only read.
    final canExplore = day != null && cycleStart != null && !flat;
    final explored = canExplore ? _explored?.clamp(1, totalDays) : null;
    final canTap = views.length > 1 || explored != null;

    void onTap() {
      // A light tick under the finger.
      HapticFeedback.selectionClick();
      setState(() {
        if (_explored != null) {
          _explored = null;
        } else {
          _view = (_view + 1) % views.length;
        }
      });
    }

    final periodDays = counting ? overview.periodLength : 0;
    final Widget drawing = flat
        ? CycleStrip(
            key: const ValueKey('cycle-strip'),
            dayOfCycle: day,
            totalDays: totalDays,
            periodDays: periodDays,
            periodEstimatedDays: widget.periodEstimatedDays,
            expectedFromDay: expectedFrom,
            expectedToDay: expectedTo,
            fertileFromDay: widget.fertileFromDay,
            fertileToDay: widget.fertileToDay,
          )
        : CycleRing(
            size: _ringSize,
            dayOfCycle: day,
            selectedDay: explored,
            caption: l10n.cycleDayCaption,
            centerText: explored == null ? null : '$explored',
            totalDays: totalDays,
            periodDays: periodDays,
            periodEstimatedDays: widget.periodEstimatedDays,
            expectedFromDay: expectedFrom,
            expectedToDay: expectedTo,
            fertileFromDay: widget.fertileFromDay,
            fertileToDay: widget.fertileToDay,
          );

    Widget ring = drawing;
    if (canExplore) {
      void exploreAt(Offset position) =>
          _explore(CycleRing.dayAt(position, _ringSize, totalDays));
      // A finger put on the line of the ring is for the ring alone: the
      // page does not scroll under it. Anywhere else, nothing changes.
      ring = RawGestureDetector(
        gestures: {
          _RingBandRecognizer:
              GestureRecognizerFactoryWithHandlers<_RingBandRecognizer>(
                _RingBandRecognizer.new,
                (recognizer) => recognizer.ringSize = _ringSize,
              ),
        },
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (event) {
            if (CycleRing.isOnBand(event.localPosition, _ringSize)) {
              _pointer = event.pointer;
              exploreAt(event.localPosition);
            }
          },
          onPointerMove: (event) {
            if (event.pointer == _pointer) {
              exploreAt(event.localPosition);
            }
          },
          onPointerUp: (event) {
            if (event.pointer == _pointer) {
              _pointer = null;
            }
          },
          onPointerCancel: (event) {
            if (event.pointer == _pointer) {
              _pointer = null;
            }
          },
          child: drawing,
        ),
      );
    }

    if (canTap || canExplore) {
      final shown = explored ?? day;
      final String label;
      if (explored != null) {
        label = l10n.exploreBack;
      } else if (views.length > 1) {
        label = switch (nextView) {
          _View.day => l10n.ringShowDay,
          _View.timeline => l10n.ringShowTimeline,
          _View.usual => l10n.ringShowUsual,
        };
      } else {
        label = l10n.cycleDayCaption;
      }
      final canIncrease = canExplore && shown != null && shown < totalDays;
      final canDecrease = canExplore && shown != null && shown > 1;
      String? valueOf(int? day) => canExplore && day != null
          ? l10n.ringExploreValue(
              day,
              weekdayDate(l10n, cycleStart.addDays(day - 1)),
            )
          : null;
      ring = Semantics(
        key: const ValueKey('cycle-ring'),
        // A node of its own in both views: the line under it has nothing
        // for a screen reader, the steps say it in words.
        container: true,
        button: canTap,
        label: label,
        // For a screen reader, the ring is gone through like a slider.
        value: valueOf(shown),
        increasedValue: canIncrease ? valueOf(shown + 1) : null,
        decreasedValue: canDecrease ? valueOf(shown - 1) : null,
        onTap: canTap ? onTap : null,
        onIncrease: canIncrease ? () => _explore(shown + 1) : null,
        onDecrease: canDecrease ? () => _explore(shown - 1) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ring,
            if (views.length > 1) ...[
              const SizedBox(height: 10),
              // Dots, as under pages that can be swiped: there are other
              // views, and which one is shown.
              ExcludeSemantics(
                child: Row(
                  key: const ValueKey('ring-dots'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final other in views)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: SizedBox.square(
                          dimension: 7,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: other == view && explored == null
                                  ? onCard
                                  : onCard.withValues(alpha: 0.25),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (day != null && !flat) {
      // Under the ring, outside what answers to the finger: what its
      // colours stand for. The line says it in its steps.
      ring = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ring,
          const SizedBox(height: 10),
          _RingLegend(
            expected: expectedFrom != null,
            fertile: widget.fertileFromDay != null,
          ),
        ],
      );
    }

    final labelStyle = theme.textTheme.labelLarge?.copyWith(color: onCard);
    final titleStyle = theme.textTheme.headlineSmall?.copyWith(color: onCard);
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(color: onCard);

    Widget block({
      Key? key,
      required String? label,
      Key? labelKey,
      required String title,
      required List<String> lines,
    }) => Column(
      key: key,
      children: [
        if (label != null)
          Text(
            label,
            key: labelKey,
            textAlign: TextAlign.center,
            style: labelStyle,
          ),
        Text(title, textAlign: TextAlign.center, style: titleStyle),
        for (final (index, line) in lines.indexed) ...[
          SizedBox(height: index == 0 ? 8 : 4),
          Text(line, textAlign: TextAlign.center, style: bodyStyle),
        ],
      ],
    );

    Widget text;
    Widget? actions;
    if (explored != null && cycleStart != null) {
      final date = cycleStart.addDays(explored - 1);
      final future = date.isAfter(widget.today);
      final dateText = weekdayDate(l10n, date);
      final about = <String>[];
      final entryFor = widget.entryFor;
      if (!future && entryFor != null) {
        final facts = entryFacts(l10n, entryFor(date));
        about.add(
          facts.isEmpty
              ? l10n.exploreNothingLogged
              : l10n.exploreLogged(facts.join(' · ')),
        );
      }
      if (!date.isBefore(widget.today) &&
          expectedFrom != null &&
          expectedTo != null &&
          explored >= expectedFrom &&
          explored <= expectedTo) {
        about.add(l10n.exploreExpected);
      }
      final fertileFrom = widget.fertileFromDay;
      final fertileTo = widget.fertileToDay;
      if (fertileFrom != null &&
          fertileTo != null &&
          explored >= fertileFrom &&
          explored <= fertileTo) {
        about.add(l10n.exploreFertile);
      }
      final usual = usualFor == null ? const <UsualSign>[] : usualFor(explored);
      if (usual.isNotEmpty) {
        about.add(
          l10n.exploreUsual(
            [for (final sign in usual.take(3)) signLabel(l10n, sign.sign)]
                .join(l10n.listSeparator),
          ),
        );
      } else if (about.isEmpty) {
        about.add(l10n.exploreNothing);
      }
      text = block(
        key: const ValueKey('explore-panel'),
        label: date == widget.today ? l10n.exploreToday(dateText) : dateText,
        title: l10n.cycleDaySemantics(explored),
        lines: about,
      );
      final open = widget.onOpenDay;
      actions = Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        children: [
          if (!future && open != null)
            FilledButton.tonal(
              key: const ValueKey('explore-open'),
              onPressed: () => open(date),
              child: Text(l10n.exploreOpen),
            ),
          TextButton(
            key: const ValueKey('explore-back'),
            onPressed: onTap,
            child: Text(l10n.exploreBack),
          ),
        ],
      );
    } else if (view == _View.usual) {
      text = block(
        key: const ValueKey('usual-signs'),
        label: day == null ? null : l10n.cycleDaySemantics(day),
        labelKey: const ValueKey('cycle-day'),
        title: l10n.usualTitle,
        lines: [
          for (final sign in usualToday.take(3))
            l10n.usualLine(
              signLabel(l10n, sign.sign),
              sign.cycles,
              sign.cyclesConsidered,
            ),
        ],
      );
    } else {
      text = block(
        label: day == null ? null : l10n.cycleDaySemantics(day),
        labelKey: const ValueKey('cycle-day'),
        title: title,
        lines: lines,
      );
    }

    if (flat && explored == null) {
      // Under the line, its steps in the order they come, each with its
      // dates: what the colours stand for, and when.
      final fertileFrom = widget.fertileFromDay;
      final fertileTo = widget.fertileToDay;
      final ongoing = status is PeriodOngoing;
      final next = shown;
      text = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          block(
            label: l10n.cycleDaySemantics(day),
            labelKey: const ValueKey('cycle-day'),
            title: title,
            lines: const [],
          ),
          const SizedBox(height: 14),
          Column(
            key: const ValueKey('cycle-steps'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (cycleStart != null)
                _Step(
                  color: PeriodColors.of(context).fill,
                  title: l10n.stepPeriodStarted(shortDate(l10n, cycleStart)),
                  detail: ongoing ? widget.periodEndLine : null,
                ),
              if (cycleStart != null &&
                  fertileFrom != null &&
                  fertileTo != null)
                _Step(
                  color: onCard.withValues(alpha: 0.4),
                  title: l10n.stepFertile(
                    shortDate(l10n, cycleStart.addDays(fertileFrom - 1)),
                    shortDate(l10n, cycleStart.addDays(fertileTo - 1)),
                  ),
                ),
              if (next != null)
                _Step(
                  color: accent.mark,
                  title: _range(l10n, next, next: ongoing),
                  // During a period, the title counts its days: the days
                  // left before the next one are said here.
                  detail: ongoing && earliest != null
                      ? _countdown(l10n, math.max(earliest, 0))
                      : null,
                ),
            ],
          ),
        ],
      );
    }

    final start = widget.onPeriodStartsToday;
    return Card.filled(
      margin: EdgeInsets.zero,
      color: accent.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      // The whole card answers a tap, not only the ring. Screen readers get
      // one button, the ring, which says what it does.
      child: InkWell(
        key: const ValueKey('cycle-card'),
        onTap: canTap ? onTap : null,
        excludeFromSemantics: true,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: ring),
              if (canExplore && explored == null) ...[
                const SizedBox(height: 8),
                // Said by the slider actions of the ring for screen readers.
                ExcludeSemantics(
                  child: Text(
                    l10n.ringHint,
                    key: const ValueKey('ring-hint'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: onCard.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              flat ? text : MergeSemantics(child: text),
              if (actions != null) ...[const SizedBox(height: 12), actions],
              if (!counting && start != null) ...[
                const SizedBox(height: 16),
                FilledButton(
                  key: const ValueKey('period-starts-today'),
                  onPressed: start,
                  child: Text(l10n.periodStartsToday),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Takes for the ring alone a finger put on its line, so that the page does
/// not scroll while the finger goes around. A finger put anywhere else is
/// left to the card and to the page.
class _RingBandRecognizer extends EagerGestureRecognizer {
  double ringSize = 0;

  @override
  bool isPointerAllowed(PointerDownEvent event) =>
      CycleRing.isOnBand(event.localPosition, ringSize) &&
      super.isPointerAllowed(event);
}

/// What the colours of the ring stand for, in a line under it.
class _RingLegend extends StatelessWidget {
  const _RingLegend({required this.expected, required this.fertile});

  /// Whether the ring shows days of an expected period, and of an estimated
  /// fertile window.
  final bool expected;
  final bool fertile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = AccentColors.of(context);
    Widget item(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: accent.onCard),
          ),
        ),
      ],
    );
    // The same words are read from the ring itself.
    return ExcludeSemantics(
      child: Wrap(
        key: const ValueKey('ring-legend'),
        alignment: WrapAlignment.center,
        spacing: 14,
        runSpacing: 4,
        children: [
          item(PeriodColors.of(context).fill, l10n.legendPeriod),
          if (expected) item(accent.mark, l10n.legendExpected),
          if (fertile)
            item(accent.onCard.withValues(alpha: 0.4), l10n.legendFertile),
          item(accent.onCard, l10n.legendToday),
        ],
      ),
    );
  }
}

/// One step of the cycle under the line: a dot of its colour, what it is
/// and when, and a detail when there is one.
class _Step extends StatelessWidget {
  const _Step({required this.color, required this.title, this.detail});

  final Color color;
  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onCard = AccentColors.of(context).onCard;
    final detail = this.detail;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.only(top: 5, end: 10),
              child: ExcludeSemantics(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onCard,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (detail != null)
                    Text(
                      detail,
                      style: theme.textTheme.bodySmall?.copyWith(color: onCard),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
