import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/features/play/models/scribble.dart';

// The pad itself: a full-bleed surface that takes a finger and shows ink
// that is already leaving.
//
// The ink is this widget's own state. It exists nowhere else, goes nowhere,
// and dies with the screen -- the architecture's ephemeral-state rule and
// this feature's whole point happen to be the same thing here, so there is
// no viewmodel behind it and must never be one.
//
// One colour, one stroke weight, no undo. Anger wants discharge, and every
// control added to this surface is a decision put in front of it.
class ScribblePad extends StatefulWidget {
  const ScribblePad({super.key});

  @override
  State<ScribblePad> createState() => _ScribblePadState();
}

class _ScribblePadState extends State<ScribblePad>
    with SingleTickerProviderStateMixin {
  final Scribble _scribble = Scribble();

  // Repaints the fade. Runs only while there is ink on the pad: an idle pad
  // costs nothing, and the ticker stops itself the moment the last point
  // fades out.
  late final Ticker _ticker;

  // The moment of the latest tick, standing in for "now" for gestures and
  // painting both. The frame clock rather than a Stopwatch, so the ink ages
  // with the frames that show it -- not while the app is backgrounded, and
  // not on wall time a widget test cannot steer.
  Duration _now = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    setState(() {
      _now = elapsed;
      _scribble.prune(_now);
      if (_scribble.isEmpty) _ticker.stop();
    });
  }

  // onPanDown rather than onPanStart, so the ink appears on touch rather
  // than after the drag is recognised -- and a single stab of the finger
  // still leaves its dot.
  void _start(DragDownDetails details) {
    if (!_ticker.isActive) {
      // A restarted ticker counts elapsed from zero again, and the pad is
      // always empty while the ticker is off, so the clock restarts with it
      // and no surviving point can be older than "now".
      _now = Duration.zero;
      _ticker.start();
    }
    setState(() => _scribble.start(details.localPosition, _now));
  }

  void _extend(DragUpdateDetails details) {
    setState(() => _scribble.extend(details.localPosition, _now));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanDown: _start,
      onPanUpdate: _extend,
      child: ClipRect(
        child: CustomPaint(
          painter: _ScribblePainter(
            scribble: _scribble,
            now: _now,
            color: context.sk.ink,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _ScribblePainter extends CustomPainter {
  static const double strokeWidth = 7;

  final Scribble scribble;
  final Duration now;
  final Color color;

  const _ScribblePainter({
    required this.scribble,
    required this.now,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint ink = Paint()
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final ScribbleStroke stroke in scribble.strokes) {
      final List<ScribblePoint> points = stroke.points;

      // A stroke of one point is a stab of the finger: a dot.
      if (points.length == 1) {
        canvas.drawCircle(
          points.first.position,
          strokeWidth / 2,
          Paint()
            ..color = color.withValues(
                alpha: scribble.opacityOf(points.first, now)),
        );
        continue;
      }

      // Each segment takes the older end's strength, so the stroke thins
      // away from its tail first, the way it was drawn.
      for (int i = 1; i < points.length; i++) {
        ink.color = color.withValues(
            alpha: scribble.opacityOf(points[i - 1], now));
        canvas.drawLine(points[i - 1].position, points[i].position, ink);
      }
    }
  }

  @override
  bool shouldRepaint(_ScribblePainter oldDelegate) => true;
}
