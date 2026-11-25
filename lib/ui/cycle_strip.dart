import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'theme.dart';

/// The cycle as a line, read from its first day to its last in the writing
/// direction: the period, the estimated fertile window, then the range in
/// which the next period is expected, with a dot on today.
///
/// The same figures as the ring, laid flat: a line has a start and an end,
/// which a circle has not. A picture of what is written under it: hidden
/// from screen readers, which read the text instead.
class CycleStrip extends StatelessWidget {
  const CycleStrip({
    super.key,
    required this.dayOfCycle,
    required this.totalDays,
    required this.periodDays,
    required this.expectedFromDay,
    required this.expectedToDay,
    this.periodEstimatedDays,
    this.fertileFromDay,
    this.fertileToDay,
  });

  /// Height of the line itself.
  static const double thickness = 14;

  /// 1 on the first day of the period.
  final int dayOfCycle;

  /// Days the whole line stands for.
  final int totalDays;

  /// Days of the period, from day 1.
  final int periodDays;

  /// The day the period going on may last until, when it is estimated to
  /// go on after [periodDays].
  final int? periodEstimatedDays;

  /// First and last day of the cycle in the expected range, if any.
  final int? expectedFromDay;
  final int? expectedToDay;

  /// First and last day of the estimated fertile window, when it is shown.
  final int? fertileFromDay;
  final int? fertileToDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AccentColors.of(context);
    final total = math.max(totalDays, 1);
    final small = theme.textTheme.labelSmall?.copyWith(
      color: accent.onCard.withValues(alpha: 0.7),
    );
    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: thickness + 12,
            width: double.infinity,
            child: CustomPaint(
              painter: _StripPainter(
                dayOfCycle: dayOfCycle,
                totalDays: total,
                periodDays: periodDays,
                periodEstimatedDays: periodEstimatedDays,
                expectedFromDay: expectedFromDay,
                expectedToDay: expectedToDay,
                fertileFromDay: fertileFromDay,
                fertileToDay: fertileToDay,
                rightToLeft: Directionality.of(context) == TextDirection.rtl,
                track: accent.badge,
                period: PeriodColors.of(context).fill,
                expected: accent.mark,
                fertile: accent.onCard.withValues(alpha: 0.4),
                marker: accent.onCard,
              ),
            ),
          ),
          const SizedBox(height: 2),
          // The first and the last day of the line, as on a ruler.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1', style: small),
              Text('$total', style: small),
            ],
          ),
        ],
      ),
    );
  }
}

class _StripPainter extends CustomPainter {
  const _StripPainter({
    required this.dayOfCycle,
    required this.totalDays,
    required this.periodDays,
    required this.periodEstimatedDays,
    required this.expectedFromDay,
    required this.expectedToDay,
    required this.fertileFromDay,
    required this.fertileToDay,
    required this.rightToLeft,
    required this.track,
    required this.period,
    required this.expected,
    required this.fertile,
    required this.marker,
  });

  final int dayOfCycle;
  final int totalDays;
  final int periodDays;
  final int? periodEstimatedDays;
  final int? expectedFromDay;
  final int? expectedToDay;
  final int? fertileFromDay;
  final int? fertileToDay;
  final bool rightToLeft;
  final Color track;
  final Color period;
  final Color expected;
  final Color fertile;
  final Color marker;

  static const double _thickness = CycleStrip.thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final top = (size.height - _thickness) / 2;
    final line = Rect.fromLTWH(0, top, size.width, _thickness);
    final rounded = RRect.fromRectAndRadius(
      line,
      const Radius.circular(_thickness / 2),
    );
    canvas
      ..save()
      ..clipRRect(rounded)
      ..drawRect(line, Paint()..color = track);

    // Where day [day] starts, counted from the side the line starts on.
    double edge(num day) => size.width * (day - 1) / totalDays;
    void span(int? from, int? to, Color color, {double inset = 0}) {
      if (from == null || to == null) {
        return;
      }
      final first = from.clamp(1, totalDays);
      final last = to.clamp(1, totalDays);
      if (last < first) {
        return;
      }
      final start = edge(first);
      final end = edge(last + 1);
      canvas.drawRect(
        Rect.fromLTRB(
          rightToLeft ? size.width - end : start,
          top + inset,
          rightToLeft ? size.width - start : end,
          top + _thickness - inset,
        ),
        Paint()..color = color,
      );
    }

    // Thinner: the widest estimate, the least sure.
    span(fertileFromDay, fertileToDay, fertile, inset: 4);
    span(expectedFromDay, expectedToDay, expected);
    final estimated = periodEstimatedDays;
    if (estimated != null && estimated > periodDays) {
      span(periodDays + 1, estimated, period.withValues(alpha: 0.4));
    }
    if (periodDays > 0) {
      span(1, periodDays, period);
    }
    canvas.restore();

    // Today: a dot in the middle of its day.
    final middle = edge(dayOfCycle.clamp(1, totalDays) + 0.5);
    final position = Offset(
      rightToLeft ? size.width - middle : middle,
      size.height / 2,
    );
    canvas
      ..drawCircle(position, _thickness / 2 + 4, Paint()..color = track)
      ..drawCircle(position, _thickness / 2 + 1, Paint()..color = marker);
  }

  @override
  bool shouldRepaint(_StripPainter old) =>
      old.dayOfCycle != dayOfCycle ||
      old.totalDays != totalDays ||
      old.periodDays != periodDays ||
      old.periodEstimatedDays != periodEstimatedDays ||
      old.expectedFromDay != expectedFromDay ||
      old.expectedToDay != expectedToDay ||
      old.fertileFromDay != fertileFromDay ||
      old.fertileToDay != fertileToDay ||
      old.rightToLeft != rightToLeft ||
      old.track != track ||
      old.period != period ||
      old.expected != expected ||
      old.fertile != fertile ||
      old.marker != marker;
}
