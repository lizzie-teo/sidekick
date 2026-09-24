import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';

// A single fall of confetti over whatever is under it, played once.
//
// **It is on the dial because the user asked for it, over a raised concern,
// and the concern is worth writing down rather than arguing again.** This is
// the panic path. A burst fired at somebody who dragged too far is a startle
// on the one screen that must never startle, and the dial's standing rule is
// that crossing a stop says exactly one thing -- her face. Confetti is a
// second thing moving that the reader did not ask for.
//
// So the answer is not to soften it into nothing. It is to make the burst
// short, make it fall rather than explode, and make it obey the phone's own
// "reduce motion" switch. All three are below, and each is the reason the
// concern is met rather than ignored.
//
// **It is not a second clock.** The standing ban is on something that keeps
// its own time *while the reader is working* -- a loop, a pacer, an idle. This
// runs once, for [duration], and stops. Nothing on the screen is waiting for
// it and nothing reads it back.
//
// **No package.** `flutter_animate` runs an effect on a widget; this holds
// eighteen positions over time, which is the job the repository gives to a
// plain `AnimationController`.
class FeelingConfetti extends StatefulWidget {
  const FeelingConfetti({
    super.key,
    required this.trigger,
    required this.child,
  });

  // Bump this to play. Any change to a non-null value starts a fall; the very
  // first build never does, so a restored route does not open on a party.
  //
  // It is an `Object?` rather than a `bool` so a second burst can be asked for
  // while the reader is still on the screen -- dragging away from the stop and
  // back is a second arrival, and a flag would already be true.
  final Object? trigger;

  // What the confetti falls in front of.
  final Widget child;

  // **Short, and shorter than it wants to be.** Long enough to be seen and
  // read as celebration, over before it is something to sit through. The
  // reader came here to answer a question.
  static const Duration duration = Duration(milliseconds: 1400);

  // How many pieces. Enough to read as a handful thrown, few enough that no
  // single frame is busy.
  static const int pieceCount = 18;

  @override
  State<FeelingConfetti> createState() => FeelingConfettiState();
}

// Public only so a test can ask whether it is running.
//
// **The guard worth testing is the reduce-motion one**, and it cannot be seen
// from outside: a widget that decided not to play looks exactly like one that
// has finished. `test/support/pump_app.dart` sets `disableAnimations: true`
// for every screen test in this repository, so the picker's own tests would
// pass whether the guard existed or not.
class FeelingConfettiState extends State<FeelingConfetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: FeelingConfetti.duration,
  );

  // Rebuilt on every trigger, so two falls in a row are not the same fall
  // twice. Seeded from the trigger rather than from the clock, so a test that
  // pumps the same trigger gets the same picture.
  List<_Piece> _pieces = const <_Piece>[];

  @override
  void didUpdateWidget(FeelingConfetti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger == oldWidget.trigger || widget.trigger == null) return;

    // The phone's own switch, not a setting of ours. Somebody who has asked
    // their device for less movement has already answered this question, and
    // a celebration is the first thing that should listen.
    if (MediaQuery.disableAnimationsOf(context)) return;

    setState(() {
      _pieces = _Piece.spread(widget.trigger.hashCode);
    });
    _controller.forward(from: 0);
  }

  // Whether a fall is in the air right now.
  @visibleForTesting
  bool get isPlaying => _controller.isAnimating;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    // **Confetti in the reader's own palette, moved the smallest amount that
    // makes it show.** The scene stops are the palette's own three colours and
    // they are drawn to sit under white text on a gradient, so on the page
    // ground some of them are nearly the page. `readable` keeps each hue and
    // lifts it to the 3:1 a non-text mark needs.
    //
    // The status tones are deliberately not here. Green means *right* and red
    // means *wrong* everywhere in this app, and neither is a claim confetti
    // may make about a feeling.
    final List<Color> colours = <Color>[
      sk.action,
      sk.scene.first,
      sk.scene.last,
      sk.ink,
    ]
        .map((Color colour) => SkContrast.readable(
              colour,
              sk.canvas,
              minRatio: SkContrast.nonText,
            ))
        .toList();

    return Stack(
      children: <Widget>[
        widget.child,
        // Decoration, in both senses: no finger may land on it and no screen
        // reader is told it happened. A reader on VoiceOver picked a feeling;
        // announcing paper falling is noise between them and the button.
        Positioned.fill(
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (BuildContext context, Widget? child) {
                    return CustomPaint(
                      painter: _ConfettiPainter(
                        pieces: _pieces,
                        progress: _controller.value,
                        colours: colours,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// One piece of paper, in fractions of the box it falls through, so the same
// numbers work on an SE and on a tablet.
class _Piece {
  const _Piece({
    required this.x,
    required this.drift,
    required this.delay,
    required this.spin,
    required this.tilt,
    required this.speed,
    required this.size,
    required this.colour,
    required this.round,
  });

  // Where it starts across the width, 0 to 1.
  final double x;

  // How far it slides sideways on the way down, as a fraction of the width.
  final double drift;

  // How much of the fall has passed before this piece starts, 0 to 0.35. It is
  // what makes it a handful thrown rather than a curtain dropped.
  final double delay;

  // Turns over the whole fall.
  final double spin;

  // The angle it is already lying at when it appears. Without it every
  // rectangle starts flat and the first frame is a row of level dashes.
  final double tilt;

  // How far it falls relative to its neighbours, around 1. Pieces that all
  // travel the same distance in the same time read as a sheet coming down
  // rather than as loose paper.
  final double speed;

  // The long side, in points.
  final double size;

  // An index into the caller's colour list, so the palette is resolved at
  // paint time and a theme change mid-fall is not a stale colour.
  final int colour;

  // Whether this one is a disc rather than a rectangle. Two shapes read as
  // paper; one shape reads as a pattern.
  final bool round;

  // **Every piece differs from its neighbour in seven ways, and one of those
  // is deliberately not free.** Colour, shape, size, spin, tilt, fall speed
  // and start delay are all drawn at random; the position across the width is
  // not. Each piece gets a slot and wanders a slot or so either side, so
  // neighbours cross and the spacing is uneven -- but nothing collapses into a
  // clump with a bare gap beside it, which is what pure random produces often
  // enough to be seen, and which reads as a bug rather than as paper.
  static List<_Piece> spread(int seed) {
    final math.Random random = math.Random(seed);
    const int count = FeelingConfetti.pieceCount;

    return List<_Piece>.generate(count, (int index) {
      return _Piece(
        x: (index + 0.5) / count + (random.nextDouble() - 0.5) * 2.2 / count,
        drift: (random.nextDouble() - 0.5) * 0.42,
        delay: random.nextDouble() * 0.5,
        spin: 0.4 + random.nextDouble() * 2.6,
        tilt: random.nextDouble() * 2 * math.pi,
        speed: 0.82 + random.nextDouble() * 0.36,
        size: 6 + random.nextDouble() * 8,
        colour: random.nextInt(4),
        round: random.nextDouble() < 0.45,
      );
    });
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({
    required this.pieces,
    required this.progress,
    required this.colours,
  });

  final List<_Piece> pieces;
  final double progress;
  final List<Color> colours;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1) return;

    final Paint paint = Paint();

    for (final _Piece piece in pieces) {
      // Its own progress: nothing until its delay has passed, then 0 to 1 over
      // what is left.
      final double own = (progress - piece.delay) / (1 - piece.delay);
      if (own <= 0) continue;

      // **It falls rather than bursts.** A piece eased out of the top and
      // slowed on the way down is paper; one fired from a point is a firework,
      // and a firework on the panic path is the startle this widget's header
      // is about.
      final double fall = Curves.easeInOut.transform(own.clamp(0.0, 1.0));

      // Gone before it lands, so nothing collects at the bottom of the screen
      // and no piece is ever mid-air when the fall ends.
      final double fade = own > 0.7 ? 1 - (own - 0.7) / 0.3 : 1.0;

      final double x = (piece.x + piece.drift * fall) * size.width;
      // Starts a little above the box so it arrives from off the top, and
      // travels its own distance rather than everybody's.
      final double y = (fall * 1.15 * piece.speed - 0.12) * size.height;

      paint.color = colours[piece.colour % colours.length]
          .withValues(alpha: fade.clamp(0.0, 1.0));

      canvas.save();
      canvas.translate(x, y);

      if (piece.round) {
        canvas.drawCircle(Offset.zero, piece.size / 2, paint);
      } else {
        canvas.rotate(piece.tilt + piece.spin * fall * 2 * math.pi);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: piece.size,
              height: piece.size * 0.55,
            ),
            const Radius.circular(1.5),
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) =>
      old.progress != progress ||
      old.pieces != pieces ||
      !listEquals(old.colours, colours);
}
