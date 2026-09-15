import 'dart:ui';

// The ink on the scribble pad, and the rule that makes it disappear.
//
// Every point remembers the moment it landed. A point holds full strength
// for [holdFor], fades to nothing across [fadeFor], and is then gone -- so a
// long stroke dies from its tail while its head is still being drawn. Time
// comes in as an argument rather than from a clock, which is what lets a
// plain unit test walk the rule forward without pumping frames.
//
// There is deliberately no undo, no colour choice, no stroke weight and no
// way to read the ink back out once it has faded. Nothing here is saved,
// which is the point of the screen it draws on.
class Scribble {
  // How long a point stays at full strength.
  static const Duration holdFor = Duration(milliseconds: 2500);

  // How long the fade to nothing takes once the hold is over.
  static const Duration fadeFor = Duration(milliseconds: 1500);

  final List<ScribbleStroke> strokes = <ScribbleStroke>[];

  bool get isEmpty => strokes.isEmpty;

  // A finger lands: a new stroke, holding its first point.
  void start(Offset position, Duration now) {
    final ScribbleStroke stroke = ScribbleStroke();
    stroke.points.add(ScribblePoint(position, now));
    strokes.add(stroke);
  }

  // The finger moves. If there is no stroke to extend -- the pad pruned
  // itself empty mid-drag -- the point opens a fresh one rather than being
  // dropped.
  void extend(Offset position, Duration now) {
    if (strokes.isEmpty) {
      start(position, now);
    } else {
      strokes.last.points.add(ScribblePoint(position, now));
    }
  }

  // 1.0 through the hold, then easing down to 0.0 across the fade.
  double opacityOf(ScribblePoint point, Duration now) {
    final Duration age = now - point.bornAt;
    if (age <= holdFor) return 1.0;
    final double faded =
        (age - holdFor).inMicroseconds / fadeFor.inMicroseconds;
    return (1.0 - faded).clamp(0.0, 1.0);
  }

  // Drop every point that has fully faded, and every stroke left with
  // nothing in it. The pad stops ticking when this leaves it empty.
  void prune(Duration now) {
    for (final ScribbleStroke stroke in strokes) {
      stroke.points
          .removeWhere((ScribblePoint point) => opacityOf(point, now) <= 0.0);
    }
    strokes.removeWhere((ScribbleStroke stroke) => stroke.points.isEmpty);
  }
}

// One unbroken drag of the finger.
class ScribbleStroke {
  final List<ScribblePoint> points = <ScribblePoint>[];
}

// One touch position and the moment it landed.
class ScribblePoint {
  final Offset position;
  final Duration bornAt;

  const ScribblePoint(this.position, this.bornAt);
}
