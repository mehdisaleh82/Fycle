import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// The colours of the launch: the same in light and in dark, as a signature.
const Color launchNight = Color(0xFF1B2A4A);
const Color _night = launchNight;
const Color _ringColor = Color(0xFFF6E6C2);
const Color _periodColor = Color(0xFFB04E64);
const Color _dotColor = Color(0xFFE3B45C);

/// The signature of the app, played once each time it is launched: the
/// cycle ring draws itself, its mark settles, and the ring opens onto the
/// app. A little over a second and a half; a tap skips it.
///
/// It covers [child] while it plays, so the app gets ready underneath. It
/// is not played again when the app comes back from the background, and not
/// at all when the phone asks for reduced motion.
class LaunchAnimation extends StatefulWidget {
  const LaunchAnimation({super.key, required this.child});

  final Widget child;

  /// How long it lasts.
  static const Duration duration = Duration(milliseconds: 1700);

  @override
  State<LaunchAnimation> createState() => _LaunchAnimationState();
}

class _LaunchAnimationState extends State<LaunchAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: LaunchAnimation.duration,
  );
  bool _done = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) {
      return;
    }
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _done = true;
      return;
    }
    _controller.forward().whenCompleteOrCancel(_finish);
  }

  void _finish() {
    if (mounted && !_done) {
      setState(() => _done = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return widget.child;
    }
    final leaving = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.8, 1, curve: Curves.easeIn),
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        // A picture only: screen readers go straight to the app underneath.
        ExcludeSemantics(
          child: GestureDetector(
            key: const ValueKey('launch-animation'),
            behavior: HitTestBehavior.opaque,
            onTap: _finish,
            child: FadeTransition(
              opacity: ReverseAnimation(leaving),
              child: ColoredBox(
                color: _night,
                child: Center(
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 1, end: 1.3).animate(leaving),
                    child: SizedBox.square(
                      dimension: 148,
                      child: CustomPaint(painter: _MarkPainter(_controller)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The mark once drawn, still, at the size it is given: the one of the
/// icon. Meant for a night-blue ground.
class CycleMark extends StatelessWidget {
  const CycleMark({super.key});

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1,
    child: CustomPaint(
      painter: _MarkPainter(const AlwaysStoppedAnimation<double>(1)),
    ),
  );
}

/// The ring, drawn clockwise from the top like the ring of the home tab:
/// the days of the period first, then the rest of the cycle, a mark leading
/// the way and settling where it ends.
class _MarkPainter extends CustomPainter {
  _MarkPainter(this.progress) : super(repaint: progress);

  final Animation<double> progress;

  /// Width of the line when the mark is [_designSize] wide; the rest
  /// follows in proportion.
  static const double _designStroke = 13;
  static const double _designSize = 148;

  /// Share of the ring drawn in the colour of the period.
  static const double _periodShare = 5 / 28;

  @override
  void paint(Canvas canvas, Size size) {
    final time = progress.value;
    final drawn = Curves.easeInOutCubic.transform((time / 0.6).clamp(0.0, 1.0));
    final unit = size.width / _designSize;
    final stroke = _designStroke * unit;
    final rect = (Offset.zero & size).deflate(stroke / 2 + 4 * unit);
    const top = -math.pi / 2;
    final sweep = 2 * math.pi * drawn;
    Paint line(Color color) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;

    if (drawn > 0) {
      canvas
        ..drawArc(rect, top, sweep, false, line(_ringColor))
        ..drawArc(
          rect,
          top,
          math.min(sweep, 2 * math.pi * _periodShare),
          false,
          line(_periodColor),
        );
    }

    // The mark leads the line, then settles with a small pulse.
    final pulse = ((time - 0.6) / 0.2).clamp(0.0, 1.0);
    final swell = math.sin(pulse * math.pi) * 3 * unit;
    // It stops a little before the top, where the period begins again.
    final angle = top + math.min(sweep, 2 * math.pi * 0.93);
    final radius = rect.width / 2;
    final position = Offset(
      rect.center.dx + radius * math.cos(angle),
      rect.center.dy + radius * math.sin(angle),
    );
    canvas
      ..drawCircle(
        position,
        stroke / 2 + 4 * unit + swell,
        Paint()..color = _night,
      )
      ..drawCircle(
        position,
        stroke / 2 + unit + swell,
        Paint()..color = _dotColor,
      );
  }

  @override
  bool shouldRepaint(_MarkPainter old) => old.progress != progress;
}
