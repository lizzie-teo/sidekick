import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';

// A semicircle dial with the sidekick standing inside it.
//
// The arc sweeps under her and rises past her waist on both sides, so the
// control reads as something she is sitting in rather than a slider parked
// underneath her. Dragging the knob along it moves her between the
// moods; the mood is reported the instant the knob crosses a stop, so she
// changes under the reader's own thumb rather than after they let go.
//
// **The knob is decoration as far as a screen reader is concerned.** A drag
// along a curve is not a gesture anybody can make with VoiceOver on, so the
// stops are real buttons sitting on top of the arc, each 48 points, each
// announcing its own name and whether it is the one picked. Dragging is the
// nice way in, not the only way in.
//
// **At 200% text the dial is not used at all.** The caller falls back to a
// column of cards -- see `FeelingPickerView`. A fixed-size arc is the one
// shape on this screen that cannot grow with the reader's font, so rather
// than shrink the words inside it the screen changes shape.
class FeelingDial extends StatefulWidget {
  const FeelingDial({
    super.key,
    required this.stops,
    required this.selected,
    required this.onChanged,
    required this.activeColor,
    required this.character,
  });

  // One label per stop, left to right. They are what a screen reader reads;
  // the dial itself draws no words.
  final List<String> stops;

  // The stop currently picked, or null when nothing is.
  //
  // **Null is the state the screen opens in and it is not a gap to be filled
  // with a default.** A dial that starts on an answer has answered the
  // question for the reader, and their first move is then a correction.
  final int? selected;

  // Fires while the knob is dragged, every time it crosses into a new stop,
  // as well as on a tap. The caller treats it as "this is the mood now".
  final ValueChanged<int> onChanged;

  // The colour of the filled part of the arc and of the knob. Handed in
  // because the leftmost stop is the panic door and wears the panic colour,
  // and the dial should not be the thing that knows that.
  final Color activeColor;

  // The sidekick, built at the size that fits inside the bowl.
  final Widget Function(BuildContext context, double size) character;

  // Half the arc's sweep. 80 degrees each side of straight down, so the ends
  // finish just above her waist: a full half-circle would put them level with
  // her head, where they read as two horns rather than as the ends of a line.
  //
  // It was 75 for an afternoon on 24 September 2026 and the bowl came out
  // shallow -- a saucer under a small head, with the page's empty middle
  // showing through it. Five degrees deepens the bowl by about a tenth of its
  // own height, which is the difference between her standing in it and her
  // hovering over it.
  static const double halfSweep = 80 * math.pi / 180;

  // The widest the dial is ever drawn. Without it a tablet hands one control
  // the whole page.
  static const double maxWidth = 420;

  @override
  State<FeelingDial> createState() => _FeelingDialState();
}

class _FeelingDialState extends State<FeelingDial>
    with SingleTickerProviderStateMixin {
  // The knob's position along the arc, 0 at the left-hand end and 1 at the
  // right. It is the controller's own value rather than a field beside it, so
  // the snap after a drag is one `animateTo` and not a tween to manage.
  late final AnimationController _knob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
    value: _positionOf(widget.selected) ?? 0.5,
  );

  bool _dragging = false;

  // Worked out in build from the incoming width, and read again by the
  // gesture handlers, which run between builds.
  _DialGeometry? _geometry;

  @override
  void didUpdateWidget(FeelingDial oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Somebody else moved the selection -- the fallback list, or a restored
    // route. Carry the knob there rather than leaving it behind the answer.
    if (widget.selected != oldWidget.selected && !_dragging) {
      final double? target = _positionOf(widget.selected);
      if (target != null) _settle(target);
    }
  }

  @override
  void dispose() {
    _knob.dispose();
    super.dispose();
  }

  double? _positionOf(int? stop) {
    if (stop == null) return null;
    final int last = widget.stops.length - 1;
    return last <= 0 ? 0 : stop / last;
  }

  int _stopNear(double position) =>
      (position * (widget.stops.length - 1)).round();

  void _settle(double target) {
    // Reduced motion means no travel, not a slower one: the knob still has to
    // end up where the answer is.
    if (MediaQuery.disableAnimationsOf(context)) {
      _knob.value = target;
      return;
    }
    _knob.animateTo(target, curve: Curves.easeOutCubic);
  }

  // Where along the arc a touch at [local] falls, or null when it is nowhere
  // near the line.
  double? _positionAt(Offset local) {
    final _DialGeometry? geometry = _geometry;
    if (geometry == null) return null;

    final Offset fromCentre = local - geometry.centre;
    final double distance = fromCentre.distance;

    // A band around the line rather than the whole box. The middle of the
    // bowl is where the sidekick stands, and a drag that starts on her should
    // not fling the knob to whichever end her shoulder happens to point at.
    if ((distance - geometry.radius).abs() > _DialGeometry.grabBand) {
      return null;
    }

    // Every point on the arc is below the circle's centre -- the sweep stops
    // 15 degrees short of the horizontal on both sides -- so a touch above it
    // is not on the line however close to the radius it lands.
    //
    // **It is a correctness guard, not tidiness.** `atan2` wraps from +pi to
    // -pi straight above the centre, and without this a finger drifting up
    // past the left-hand end came back as a position at the *right-hand* end:
    // the knob jumped the whole arc, and the mood with it.
    if (fromCentre.dy <= 0) return null;

    final double angle = math.atan2(fromCentre.dy, fromCentre.dx);
    final double position =
        (_DialGeometry.startAngle - angle) / (FeelingDial.halfSweep * 2);

    return position.clamp(0.0, 1.0);
  }

  void _handle(Offset local, {required bool ending}) {
    final double? position = _positionAt(local);
    if (position == null) return;

    _dragging = !ending;
    _knob.value = position;

    final int stop = _stopNear(position);
    if (stop != widget.selected) widget.onChanged(stop);

    if (ending) _settle(_positionOf(stop)!);
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = math.min(
          constraints.maxWidth,
          FeelingDial.maxWidth,
        );

        final _DialGeometry geometry = _DialGeometry(width);
        _geometry = geometry;

        return SizedBox(
          width: width,
          height: geometry.height,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanStart: (DragStartDetails d) =>
                _handle(d.localPosition, ending: false),
            onPanUpdate: (DragUpdateDetails d) {
              if (_dragging) _handle(d.localPosition, ending: false);
            },
            onPanEnd: (DragEndDetails d) {
              if (!_dragging) return;
              _dragging = false;
              final int stop = _stopNear(_knob.value);
              _settle(_positionOf(stop)!);
            },
            child: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                // Under everything, so the arc's ends cross in front of her
                // feet and the bowl reads as holding her.
                //
                // She takes no touches: a tap reaction here would compete with
                // the knob for the same finger, and the knob is what the
                // screen is asking for.
                Positioned(
                  top: 0,
                  child: IgnorePointer(
                    child: widget.character(context, geometry.characterSize),
                  ),
                ),

                // Decoration. Every word and every state it shows is also on
                // the stop buttons above it and in the label under the dial.
                Positioned.fill(
                  child: ExcludeSemantics(
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _knob,
                        builder: (BuildContext context, Widget? child) {
                          return CustomPaint(
                            painter: _DialPainter(
                              geometry: geometry,
                              position: _knob.value,
                              stops: widget.stops.length,
                              picked: widget.selected != null,
                              active: widget.activeColor,
                              track: sk.border,
                              stop: SkContrast.captionOn(sk.canvas),
                              knobRing: sk.surface,
                              shadow: sk.ink,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // The real controls. One per stop, on top of everything, so a
                // reader who cannot drag still has a plain button per stop.
                for (int index = 0; index < widget.stops.length; index++)
                  _stopButton(context, geometry, index),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _stopButton(BuildContext context, _DialGeometry geometry, int index) {
    final Offset centre = geometry.pointAt(index / (widget.stops.length - 1));
    const double target = SkLayout.tapTarget;

    return Positioned(
      left: centre.dx - target / 2,
      top: centre.dy - target / 2,
      width: target,
      height: target,
      child: Semantics(
        button: true,
        selected: widget.selected == index,
        label: widget.stops[index],
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _settle(index / (widget.stops.length - 1));
            if (index != widget.selected) widget.onChanged(index);
          },
          // Nothing drawn: the dot under it is the picture, and a second one
          // here would sit a hair off it at some text sizes.
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

// Every number the dial is drawn and touched with, worked out once from the
// width it was given.
class _DialGeometry {
  // How close to the line a finger has to land for a drag to take hold.
  static const double grabBand = 56;

  // Room outside the arc for the knob, its lift, and half a tap target.
  //
  // **Half a tap target is the binding one.** The stop buttons are 48 points
  // centred on their dots, and the outermost dots sit exactly this far from
  // the edge -- so anything under 24 pushes the leftmost and rightmost
  // buttons past the side of the box, where a `Stack` clips them and the two
  // ends of the dial stop answering a tap at all.
  static const double edge = 26;

  // How far the arc's ends climb past the sidekick's feet. It is what makes
  // the bowl read as holding her rather than sitting under her.
  static const double overlap = 46;

  final double width;

  _DialGeometry(this.width);

  // The arc is at its widest at its two ends, which stand `halfSweep` either
  // side of straight down -- so their distance from the middle is the *sine*
  // of that angle, not its cosine. Getting the two the wrong way round put
  // the radius at nearly four times its right value, which threw both ends of
  // the dial off the side of the box, where a `Stack` clipped them and
  // neither end answered a tap.
  late final double radius =
      (width / 2 - edge) / math.sin(FeelingDial.halfSweep);

  // How tall the band of arc is: from its ends down to its lowest point.
  late final double band = radius * (1 - math.cos(FeelingDial.halfSweep));

  // She is a little over half the dial's width.
  //
  // **0.46 was too small and it was the first thing wrong on the running
  // app.** The screen is her and one control, so she has to be the thing the
  // eye lands on; at 0.46 she was a small head floating over a wide saucer
  // with the page showing between the two. Much past 0.60 and her shoulders
  // reach the arc where it is still climbing, and the bowl looks too small
  // for her.
  late final double characterSize = width * 0.58;

  late final double height = characterSize + band - overlap + edge;

  late final Offset centre = Offset(width / 2, height - edge - radius);

  // The left-hand end, in canvas angles: 0 is three o'clock and the angle
  // grows clockwise, so straight down is a quarter turn and the left end is
  // the sweep beyond it.
  static final double startAngle = math.pi / 2 + FeelingDial.halfSweep;

  double angleAt(double position) =>
      startAngle - position * FeelingDial.halfSweep * 2;

  Offset pointAt(double position) {
    final double angle = angleAt(position);
    return centre + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
  }
}

class _DialPainter extends CustomPainter {
  final _DialGeometry geometry;
  final double position;
  final int stops;
  final bool picked;
  final Color active;
  final Color track;
  final Color stop;
  final Color knobRing;
  final Color shadow;

  const _DialPainter({
    required this.geometry,
    required this.position,
    required this.stops,
    required this.picked,
    required this.active,
    required this.track,
    required this.stop,
    required this.knobRing,
    required this.shadow,
  });

  // How many marks sit along the whole arc. Enough to read as a scale, few
  // enough that they do not turn into a solid band on a small phone.
  static const int _ticks = 41;

  static const double _trackWidth = 3;
  static const double _knobRadius = 15;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect circle = Rect.fromCircle(
      center: geometry.centre,
      radius: geometry.radius,
    );

    const double sweep = FeelingDial.halfSweep * 2;

    // The whole line, quiet.
    canvas.drawArc(
      circle,
      _DialGeometry.startAngle,
      -sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _trackWidth
        ..strokeCap = StrokeCap.round
        ..color = track,
    );

    // The part behind the knob, in the live colour. It is drawn only once
    // something is picked: a filled arc under an untouched dial would say the
    // reader had already answered.
    if (picked) {
      canvas.drawArc(
        circle,
        _DialGeometry.startAngle,
        -sweep * position,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _trackWidth
          ..strokeCap = StrokeCap.round
          ..color = active,
      );
    }

    _paintTicks(canvas);
    _paintStops(canvas);
    _paintKnob(canvas);
  }

  // Marks inside the line, pointing at the sidekick. Outside they would sit on
  // the very edge of the screen on a small phone and get clipped by the
  // gutter.
  void _paintTicks(Canvas canvas) {
    final Paint paint = Paint()
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int index = 0; index < _ticks; index++) {
      final double at = index / (_ticks - 1);
      final double angle = geometry.angleAt(at);
      final Offset direction = Offset(math.cos(angle), math.sin(angle));

      // The marks nearest the knob stand a little taller and take its colour,
      // so the knob has a shadow of itself on the scale and the eye can tell
      // where it is without following the line back to the end.
      final double near = (1 - (at - position).abs() * 9).clamp(0.0, 1.0);
      final double length = 7 + near * 5;

      paint.color = picked ? Color.lerp(track, active, near)! : track;

      canvas.drawLine(
        geometry.centre + direction * (geometry.radius - 9),
        geometry.centre + direction * (geometry.radius - 9 - length),
        paint,
      );
    }
  }

  // The answers. They are the one part of the picture that carries
  // meaning, so they are the part held to a text-grade contrast.
  void _paintStops(Canvas canvas) {
    final Paint paint = Paint()..color = stop;

    for (int index = 0; index < stops; index++) {
      final double at = index / (stops - 1);
      canvas.drawCircle(geometry.pointAt(at), 3.5, paint);
    }
  }

  void _paintKnob(Canvas canvas) {
    final Offset centre = geometry.pointAt(position);

    canvas.drawCircle(
      centre.translate(0, 3),
      _knobRadius,
      Paint()
        ..color = shadow.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    canvas.drawCircle(centre, _knobRadius, Paint()..color = knobRing);

    canvas.drawCircle(
      centre,
      _knobRadius - 4,
      // Untouched, the knob is the same quiet grey as the line it sits on. It
      // takes the live colour the moment there is an answer under it.
      Paint()..color = picked ? active : track,
    );
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.position != position ||
      old.picked != picked ||
      old.active != active ||
      old.track != track ||
      old.stop != stop ||
      old.geometry.width != geometry.width;
}
