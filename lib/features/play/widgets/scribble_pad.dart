import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// The pad itself: one finger, one colour, one stroke weight, and every mark
// fades away on its own.
//
// There is no undo, no colour picker and no save, and none of them is a
// missing feature. The screen is for discharge, and every control would be a
// decision put in front of somebody with no patience for one. The fade is
// the promise that makes scribbling hard safe: nothing is kept, so nothing
// can be judged or come back to be dwelt on.
//
// The strokes are throwaway widget state -- they never touch a service, load
// nothing and save nothing -- so there is no viewmodel. Same rule that gives
// AsyncButton its own in-flight flag.
class ScribblePad extends StatefulWidget {
  const ScribblePad({super.key, required this.color});

  // Handed in by the screen, because the right ink depends on the surface
  // the pad sits on.
  final Color color;

  // How long a finished stroke holds before it starts to go, and how long
  // the going takes. "A few seconds" from the wireframe: long enough to see
  // the mark land, short enough that the screen keeps its promise. An
  // instant vanish would read as broken.
  static const Duration hold = Duration(milliseconds: 1500);
  static const Duration fade = Duration(milliseconds: 3500);

  static const double strokeWidth = 5;

  @override
  State<ScribblePad> createState() => ScribblePadState();
}

// Public, like FormState, so a test can read how many strokes are alive --
// the count is not on screen anywhere, which is the point of the pad.
class ScribblePadState extends State<ScribblePad>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  // The pad's own clock, driven by the ticker rather than DateTime so widget
  // tests can move it with pump. The ticker only runs while there is
  // something to fade, and its elapsed restarts from zero each start, so the
  // clock accumulates across runs instead of reading elapsed directly.
  Duration _clock = Duration.zero;
  Duration _clockAtStart = Duration.zero;

  final List<_Stroke> _strokes = <_Stroke>[];

  // The painter listens to this instead of the widget rebuilding: a screen
  // repainting sixty times a second has no reason to rebuild its tree too.
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);

  // The pointer currently drawing, if any. One finger at a time: a second
  // finger joining mid-stroke would teleport the line, and a crayon does not
  // do that either.
  int? _activePointer;
  _Stroke? _activeStroke;

  int get strokeCount => _strokes.length;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    _clock = _clockAtStart + elapsed;

    _strokes.removeWhere(
      (_Stroke stroke) => _opacityOf(stroke) == 0,
    );

    // An empty pad has nothing to animate, and a ticker left running keeps
    // scheduling frames forever -- which also hangs every pumpAndSettle in a
    // widget test with this screen open.
    if (_strokes.isEmpty && _activePointer == null) {
      _ticker.stop();
      _clockAtStart = _clock;
    }

    _repaint.value++;
  }

  double _opacityOf(_Stroke stroke) {
    final Duration? endedAt = stroke.endedAt;

    // Still under the finger.
    if (endedAt == null) return 1;

    final Duration fading = _clock - endedAt - ScribblePad.hold;
    if (fading <= Duration.zero) return 1;

    final double t = fading.inMilliseconds / ScribblePad.fade.inMilliseconds;
    return (1 - t).clamp(0, 1).toDouble();
  }

  void _down(PointerDownEvent event) {
    if (_activePointer != null) return;

    if (!_ticker.isActive) {
      _clockAtStart = _clock;
      _ticker.start();
    }

    final _Stroke stroke = _Stroke(<Offset>[event.localPosition]);
    _activePointer = event.pointer;
    _activeStroke = stroke;
    _strokes.add(stroke);
    _repaint.value++;
  }

  // Points closer together than this are finger jitter, not drawing, and
  // keeping them is what puts kinks in a slow stroke.
  static const double _minPointDistance = 2;

  void _move(PointerMoveEvent event) {
    if (event.pointer != _activePointer) return;

    final _Stroke? stroke = _activeStroke;
    if (stroke == null) return;

    if ((event.localPosition - stroke.points.last).distance <
        _minPointDistance) {
      return;
    }

    stroke.points.add(event.localPosition);
    _repaint.value++;
  }

  // Up and cancel are the same thing here: the stroke is finished and its
  // fade clock starts. There is nothing to commit, so nothing to roll back.
  void _end(PointerEvent event) {
    if (event.pointer != _activePointer) return;
    _activeStroke?.endedAt = _clock;
    _activePointer = null;
    _activeStroke = null;
    _repaint.value++;
  }

  @override
  Widget build(BuildContext context) {
    // Raw pointer events rather than a GestureDetector: the pad has no
    // competing gestures, and a Listener catches the single tap that leaves
    // a dot without any pan-slop bookkeeping.
    return ClipRect(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _down,
        onPointerMove: _move,
        onPointerUp: _end,
        onPointerCancel: _end,
        child: SizedBox.expand(
          child: CustomPaint(
            painter: _ScribblePainter(
              strokes: _strokes,
              opacityOf: _opacityOf,
              color: widget.color,
              repaint: _repaint,
            ),
          ),
        ),
      ),
    );
  }
}

class _Stroke {
  _Stroke(this.points);

  final List<Offset> points;

  // Clock time when the finger lifted; null while it is still down. The
  // fade counts from here, so a mark never dissolves under the finger
  // making it.
  Duration? endedAt;
}

class _ScribblePainter extends CustomPainter {
  _ScribblePainter({
    required this.strokes,
    required this.opacityOf,
    required this.color,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final List<_Stroke> strokes;
  final double Function(_Stroke) opacityOf;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ScribblePad.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final _Stroke stroke in strokes) {
      final double opacity = opacityOf(stroke);
      if (opacity == 0) continue;

      paint.color = color.withValues(alpha: opacity);

      // A tap leaves a dot: a one-point path has no length to stroke, so it
      // is drawn as the round cap it would have had.
      if (stroke.points.length == 1) {
        canvas.drawCircle(
          stroke.points.first,
          ScribblePad.strokeWidth / 2,
          paint..style = PaintingStyle.fill,
        );
        paint.style = PaintingStyle.stroke;
        continue;
      }

      // Curves, not chords. Each sampled point becomes the control of a
      // quadratic bezier that lands on the midpoint to the next one, so the
      // line bends through the samples instead of cornering at them --
      // which is what made fast strokes look jagged.
      final List<Offset> points = stroke.points;
      final Path path = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length - 1; i++) {
        final Offset mid = (points[i] + points[i + 1]) / 2;
        path.quadraticBezierTo(points[i].dx, points[i].dy, mid.dx, mid.dy);
      }
      path.lineTo(points.last.dx, points.last.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_ScribblePainter oldDelegate) => true;
}
