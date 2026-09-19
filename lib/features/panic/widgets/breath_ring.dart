import 'package:flutter/widgets.dart';

import 'package:sidekick/app/widgets/sk_character.dart';

// The sidekick, with a ring that opens out on the in-breath and folds back on
// the out.
//
// **It fades as well as folds.** The ring is at full strength only at the top
// of the in-breath and is gone by the bottom of the out, so the out-breath
// ends on an empty scene and the next breath blooms out of nothing. Two
// readings -- how wide, how bright -- carried by one object, which is the only
// way this screen is allowed to say two things at once. The fade also hides
// the corner the width could not fix: the folded ring grazes her ears and her
// feet, and by the time it is that close to her it is too faint for the two
// outlines to read as one tangled shape.
//
// **It brightens as it opens, and not the other way round.** Fading *out* as
// it grows is the ordinary ripple, and it is wrong here: the ring would die
// at the top of the in-breath and leave the out-breath -- 6.1 seconds of the
// 10, and the half that does the settling -- with nothing at all to follow.
// A pacer that goes out while somebody is still breathing is telling them to
// stop.
//
// **Why this exists, and why it is a line rather than a glow.** Her body is
// the pacer, and on its own it was reported as not obvious. Three filled
// versions followed -- a dark flower, a pale one, a pale one with her cut out
// of the middle -- and every one was reported as not working. They shared one
// fault, and it was never the colour:
//
// - **A soft wash has no edge**, so there is nothing for the eye to fix on.
//   A stroked line at full alpha has one, and a line one pixel wide can be
//   as strong as it likes without washing out anything behind it. That is
//   also what ends the contrast problem in `sk_colors.dart`: a line does not
//   have to beat a character, because there is almost nothing of it.
// - **Growth on its own cannot be measured.** A circle that gets bigger and
//   then smaller says only that something is moving. The fixed outer ring is
//   the reference that turns it into a reading: the gap between the two is
//   the breath, and it visibly closes.
//
// **One circle, not a flower.** Six stroked circles pushing apart was tried
// first, because the filled version had been a flower: open, their outlines
// crossed into a scribble of a dozen arcs, which is an agitating thing to put
// in front of somebody mid-panic. Whatever this screen shows has to be
// quieter the closer it is looked at, and a single line is.
//
// **The pace is not decided here.** It ramps between the `inhale` and
// `exhale` events the artboard reports, and every event re-anchors the ramp,
// so the ring cannot slide out of step with her body however long the screen
// is open.
//
// **It learns the pace rather than holding a second copy of it.** The gap
// between two events *is* the length of the phase that just ended, so each
// one is measured and used for the next ramp of that kind. The two seeds
// below are used for the first breath only, and a change to the Rive
// timeline is followed from the second breath with no edit here. This is the
// shape `_docs/handoff-shaders-2026-09-19.md` recommended for any continuous
// breath value in Dart.
class BreathRing extends StatefulWidget {
  const BreathRing({
    super.key,
    required this.skin,
    required this.startBreathing,
    required this.color,
    required this.glowColor,
    required this.glowStrength,
    required this.builder,
    this.onInhale,
    this.onExhale,
  });

  // Passed straight through to SkCharacter: 0 is the girl, 1 is the cat.
  final double skin;

  // Starts her breath cycle, and fades the rings in. False through the
  // lead-in, where she idles and there is nothing yet to pace.
  final bool startBreathing;

  // The line colour, before alpha.
  //
  // `onScene` is the right slot now that this is a line: it is the one tuned
  // to read against the scene gradient in every palette and both modes, and
  // it needs no branch on brightness. The filled versions could not use it --
  // a dark wash behind her made her the hole in it -- but a stroke crosses
  // only a couple of pixels of her and is drawn under her anyway.
  final Color color;

  // The colour of the light around the line, before alpha.
  //
  // **It is a separate colour from `color` because a glow has to be pale and
  // a line has to be readable, and no one slot is both.** `onScene` is the
  // dark end of the palette in light mode, and a blur in a dark colour is a
  // smudge rather than a shine. The crisp line keeps `onScene` so the signal
  // is never in doubt; the light behind it goes pale in both modes, where it
  // can only ever add and never obscure.
  final Color glowColor;

  // Scales the glow's strength, because the two ends of the palette do not
  // need the same amount of it.
  //
  // A dark scene gives a glow the whole range between itself and white, so a
  // little goes a long way and more reads as a blown-out lamp. A light scene
  // gives it almost none, and the same setting there reads as nothing at all.
  // The numbers in the painter are sized for the light end, and this turns
  // them down for the dark one. It is set from the scene's own lightness in
  // `BreathingView`, next to the colour it belongs with.
  final double glowStrength;

  // Forwarded after the rings have been moved, so the cue line still comes
  // from the artboard and not from anything here.
  final VoidCallback? onInhale;
  final VoidCallback? onExhale;

  // Builds everything that sits in front of the rings, and is handed the
  // sidekick to place wherever the screen wants her.
  //
  // **This is a builder rather than a plain child because the rings have to
  // be wider than the band she stands in.** Her head is near the top of that
  // band, so a ring centred on her head could only be about as wide as her
  // head before it started covering the line above. Painting under the whole
  // screen lifts that cap; the target ring passes behind the words at the
  // top, which a hairline can do without making them harder to read.
  final Widget Function(BuildContext context, Widget sidekick) builder;

  // The first breath only. Everything after is measured. These match the
  // `Breathe` timeline as it stands -- 480 frames at 48fps, `exhale` keyed at
  // frame 186 -- but they are a starting guess, not a source of truth.
  static const Duration inhaleSeed = Duration(milliseconds: 3875);
  static const Duration exhaleSeed = Duration(milliseconds: 6125);

  @override
  State<BreathRing> createState() => _BreathRingState();
}

class _BreathRingState extends State<BreathRing>
    with SingleTickerProviderStateMixin {
  // 0 is folded in, 1 is touching the target ring. Nothing outside this
  // widget reads it.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: BreathRing.inhaleSeed,
  );

  // Runs from one event to the next. Its reading at an event is the length of
  // the phase that has just ended.
  final Stopwatch _sinceLastEvent = Stopwatch();

  Duration _inhale = BreathRing.inhaleSeed;
  Duration _exhale = BreathRing.exhaleSeed;

  // A measurement outside these bounds is a dropped frame, a backgrounded app
  // or a paused engine, not a breath. It is thrown away and the last good
  // value is kept, so one hiccup cannot leave the ring crawling or snapping
  // for the rest of the session.
  static const Duration _minPhase = Duration(milliseconds: 500);
  static const Duration _maxPhase = Duration(seconds: 30);

  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final bool reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce == _reduceMotion) return;

    _reduceMotion = reduce;
    if (reduce) {
      // Held half open: a still ring rather than one folded shut, which would
      // now be invisible as well as closed and read as missing rather than as
      // deliberately not moving. Half open is also half strength, which is
      // what keeps it on screen at all.
      _controller
        ..stop()
        ..value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The reading is only meaningful once a first event has started the clock.
  Duration? _measure() {
    if (!_sinceLastEvent.isRunning) return null;

    final Duration elapsed = _sinceLastEvent.elapsed;
    if (elapsed < _minPhase || elapsed > _maxPhase) return null;

    return elapsed;
  }

  void _restartClock() {
    _sinceLastEvent
      ..reset()
      ..start();
  }

  void _handleInhale() {
    // The gap that has just closed is an out-breath.
    final Duration? measured = _measure();
    if (measured != null) _exhale = measured;
    _restartClock();

    if (!_reduceMotion) {
      _controller.animateTo(1, duration: _inhale, curve: Curves.easeInOut);
    }

    widget.onInhale?.call();
  }

  void _handleExhale() {
    // And this one is an in-breath.
    final Duration? measured = _measure();
    if (measured != null) _inhale = measured;
    _restartClock();

    if (!_reduceMotion) {
      _controller.animateBack(0, duration: _exhale, curve: Curves.easeInOut);
    }

    widget.onExhale?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Behind everything, and slow to arrive: the rings belong to the
        // pacing, so they are not on screen during the lead-in where there is
        // no breath for them to show. The fade is long enough not to read as
        // a flash.
        AnimatedOpacity(
          opacity: widget.startBreathing ? 1 : 0,
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOut,
          child: CustomPaint(
            painter: _BreathRingPainter(
              phase: _controller,
              color: widget.color,
              glowColor: widget.glowColor,
              glowStrength: widget.glowStrength,
            ),
          ),
        ),
        widget.builder(
          context,
          SkCharacter(
            skin: widget.skin,
            startBreathing: widget.startBreathing,
            onInhale: _handleInhale,
            onExhale: _handleExhale,
          ),
        ),
      ],
    );
  }
}

// One stroked circle that opens out on the in-breath and folds back on the
// out, brightening as it opens and going out as it closes.
//
// **There used to be a second, fixed ring for it to measure against**, because
// growth on its own says only that something is moving. The fade replaced it.
// Brightness is the reading now -- full strength *is* the top of the breath --
// so the reference was no longer carrying anything, and it was the one thing
// on a screen meant to be quiet that never moved and never dimmed. Putting it
// back means one `drawCircle` at `_fullExtent`, not a rethink.
//
// The painter is handed the controller as its `repaint`, so a breath repaints
// this line and rebuilds nothing -- the character above is untouched by
// sixty frames a second. Nothing here uses `saveLayer`, so nothing is clipped
// to the panel's padding: an earlier filled version was cut off in two
// straight lines down the sides for exactly that reason.
class _BreathRingPainter extends CustomPainter {
  _BreathRingPainter({
    required this.phase,
    required this.color,
    required this.glowColor,
    required this.glowStrength,
  }) : super(repaint: phase);

  final Animation<double> phase;
  final Color color;
  final Color glowColor;
  final double glowStrength;

  // Both are fractions of half the screen width, so the ring is the same
  // shape on every phone.
  //
  // **`_restExtent` has to clear her silhouette.** She is drawn on top, so a
  // ring narrower than her shoulders is simply hidden and the fold-in looks
  // like the screen going blank. She is roughly 0.64 of this half at her
  // widest.
  //
  // **`_fullExtent` has to stay inside the screen and clear of the words.**
  // It is the top of the in-breath, and the top of the in-breath is where the
  // ring is at its brightest, so a line running off the edge there is the one
  // moment that cannot be missed going wrong.
  // **`_restExtent` clears her whole silhouette, not just her shoulders.** At
  // 0.72 the folded ring cut through her ears and her feet, so the line kept
  // meeting her outline and the two read as one tangled shape. She is about
  // 0.64 of this half wide and rather taller than that, so the ring has to be
  // sized off her height.
  //
  // **The cost is travel, and there is no way round it.** Every point the
  // folded ring gains is a point the breath does not move, and the open ring
  // cannot make it up: `_fullExtent` is already at the screen's own edge.
  // That is why the glow carries brightness as well -- the width alone no
  // longer has the room to say everything.
  // **`_fullExtent` is set by the gap it has to leave at the phone's edge,
  // and the gap is measured from the glow rather than from the line.** The
  // blur reaches about `_glowBlur` beyond the stroke, so the visible edge of
  // the open ring is that much wider than this number says: 1.04 was picked
  // to leave 17 points and left 8. This box is already inset 24 points each
  // side by `SkScenePanel`, so 1.00 of its half is 171 points on a 390-point
  // screen, the glow reaches 179, and 16 are left to the glass. Changing
  // either `SkScenePanel`'s padding or `_glowBlur` changes that sum.
  //
  // **`_restExtent` is a three-way squeeze and 0.84 is a compromise.** The
  // ring has to clear her, stay off the edge, and still visibly travel, and
  // there are only about 33 points between her silhouette and the edge to
  // do all three in. At 0.84 it clears her sides comfortably and grazes her
  // ears and feet, which is the corner that gives most cheaply.
  static const double _restExtent = 0.80;
  static const double _fullExtent = 0.97;

  // How far down the screen both rings are centred.
  //
  // **On her body, not her head.** A ring is not a fill: centred on her
  // middle it encircles the whole of her, which is the shape every breathing
  // app uses, and it keeps the top of the ring clear of the line above. The
  // filled versions had to sit on her head instead, because a fill centred on
  // her middle read as a belt.
  //
  // **Measured off the running screen, not calculated.** Everything above her
  // is a fixed height and the band she stands in takes the rest. Moving any
  // band means looking at this again.
  static const double _centreY = 0.53;

  // Hairlines, both of them.
  //
  // **The line still has to be crisp, but it does not have to be loud.** A
  // hard edge is what makes the ring measurable -- that is the whole reason
  // this replaced a soft wash -- so the width never goes to nothing. What
  // came down is the weight: at 2.5 points and nearly opaque it read as a
  // drawn circle sitting on top of the scene, which is louder than anything
  // else on a screen meant to be quiet. Thin and half-strength keeps the
  // edge and hands the presence to the glow.
  // **`_ringAlpha` is the top of the in-breath, not a constant.** It is
  // multiplied by the phase, so the line is at half strength only where the
  // ring is fully open and has gone to nothing by the time it is folded in.
  static const double _ringWidth = 1.25;
  static const double _ringAlpha = 0.5;

  // The light around the line. It is a fat, blurred copy of the same circle
  // drawn underneath, so it can never move independently of the thing it is
  // lighting.
  //
  // **Its strength rises with the breath**, from nothing folded in to
  // `_glowFull` at the top of the in-breath. It used to rest at 0.18 rather
  // than at nothing, so something was always alight around her. That floor is
  // gone: the ring now goes out with the out-breath and comes back with the
  // in, and a glow left burning under a line that is not there would be the
  // one thing on screen still saying "breathe in".
  // `_glowFull` is sized for a light scene, where a glow has almost no
  // headroom. `glowStrength` turns it down for a dark one.
  static const double _glowWidth = 7;
  static const double _glowBlur = 6;
  static const double _glowFull = 0.7;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final double half = size.width / 2;
    final Offset centre = Offset(half, size.height * _centreY);

    final double p = phase.value;
    final double extent =
        (_restExtent + (_fullExtent - _restExtent) * p) * half;

    // The fade is the phase itself, straight, with no curve of its own on top.
    // The controller is already eased in time, so a second curve here would
    // compound into a ring that is faint for most of the breath and bright for
    // an instant. Linear in `p` means the line is exactly as strong as the
    // breath is far along, which is the reading the ring is for.
    final double fade = p.clamp(0.0, 1.0);
    if (fade <= 0) return;

    canvas.drawCircle(
      centre,
      extent,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _glowWidth
        ..color = glowColor.withValues(
          alpha: (_glowFull * fade * glowStrength).clamp(0.0, 1.0),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _glowBlur)
        ..isAntiAlias = true,
    );

    canvas.drawCircle(
      centre,
      extent,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _ringWidth
        ..color = color.withValues(alpha: _ringAlpha * fade)
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(_BreathRingPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.glowColor != glowColor ||
      oldDelegate.phase != phase;
}
