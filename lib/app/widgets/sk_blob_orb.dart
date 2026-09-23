import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
// Material for `Theme` alone. The orb is a widgets-layer painter and stays
// one; it needs the app's resolved brightness and that lives on ThemeData,
// so the import is narrowed to the one name rather than the library. Same
// shape as the `show ThemeMode` in theme_service.dart.
import 'package:flutter/material.dart' show Theme;
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:sidekick/app/core/shader_cache.dart';

// An orb of soft drifting petals that moves on its own and quickens when
// [level] rises.
//
// **This is not SkBreathHalo and it is not a pacer.** The halo's one rule is
// that its size is the breath phase and nothing else, so it can never drift
// from the sidekick's belly. This widget has the opposite job: it must look
// alive with no input at all, so it runs its own clocks and moves whether or
// not anything is driving it. Do not put one behind the sidekick on the
// breathing screen -- two things moving on two clocks is exactly what the
// halo's rule exists to prevent.
//
// What it is for: a screen where the orb IS the thing being watched. A voice
// speaking, a meditation playing, a moment with nothing else on the page.
//
// ## Five things to give it, and nothing else
//
// **Two colours, a level, a seed, and a box.** That is the whole surface, and
// it is deliberately this small.
//
// The orb had sliders for its shape for one afternoon on 20 September 2026 --
// wobble, softness, crispness, swirl, rings, grain, radius, speed -- and they
// were taken out the same day. The reference this is built from exposes two
// colours, a seed and a volume, and every other number is settled inside. A
// knob for each lets any screen quietly invent a different orb, and a set of
// numbers that were tuned together is not a set anybody should be recombining
// one at a time. The constants and the reasons live in
// `shaders/blob_orb.frag`.
//
// **Size is the box's job.** The orb fills the box it is given, a little
// under the short side. Want a smaller orb, give it a smaller box.
//
// ## The level
//
// [level] is one number, 0 to 1. Feed it audio loudness, or a breath ramp, or
// leave it out and the orb idles at [restingLevel].
//
// **Level moves two things: how much of the disc is coloured, and how fast the
// field flows.** A higher level lengthens the petals and lifts a floor under
// the grey field, so more of the circle lands in the coloured middle of the
// ramp and less of it stays white; it also raises the flow clock's rate, so
// the orb moves faster. **At 1.0 the disc is completely coloured**, which is
// what a screen asking for a held squeeze needs it to do.
//
// **The disc's size is not one of them.** The circle is the same circle at
// every level -- only what is inside it changes. Size is the box's job, as
// above.
//
// **The petals used to shorten as the level rose, and that was backwards.**
// It came from the reference, where a louder orb is a busier one. On a screen
// asking somebody to tighten, the rising level made the orb whiter and
// thinner at the exact moment the colour was meant to fill. Changed on 20
// September 2026, pivoted on [defaultRestingLevel] so an orb with no level
// attached looks exactly as it did. The one number is in
// `shaders/blob_orb.frag`, on `b`.
//
// **Smooth the level before handing it over.** Raw audio amplitude jumps frame
// to frame and the orb then looks like it is vibrating, not speaking.
// [SkBlobOrbLevel] does the smoothing if you have nothing else doing it.
//
// ## The look
//
// Built on 20 September 2026 from the ElevenLabs UI orb
// (https://ui.elevenlabs.io/docs/components/orb), which is MIT licensed. The
// reasoning lives in the shader; the short version is that the orb is composed
// flat, in grey, in polar space, and coloured once at the end through a
// four-stop ramp that runs black -> [edge] -> [core] -> white.
//
// It repaints without rebuilding: [level] and the internal clocks are the
// painter's `repaint` listenable, so a moving orb costs one paint of one rect
// and no widget rebuild anywhere.
//
// **Give it a box.** The shader reads noise about twenty times per pixel,
// which is affordable in a 300pt square and not affordable across a whole
// phone screen.
class SkBlobOrb extends StatefulWidget {
  const SkBlobOrb({
    super.key,
    required this.core,
    required this.edge,
    this.level,
    this.inverted,
    this.seed = defaultSeed,
    this.restingLevel = defaultRestingLevel,
  });

  // Where the petals start. Two orbs on one screen with the same seed drift in
  // step, which reads as one thing cut in half. In radians; anything in 0..2pi
  // is as good as anything else.
  static const double defaultSeed = 0.0;

  // What the orb shows at with no [level] attached. Not zero: the flow clock's
  // rate is a function of the level, and at zero the orb nearly stops.
  static const double defaultRestingLevel = 0.30;

  // What the orb shows at when the system is set to reduce motion: a still orb
  // at a middling level, with both clocks stopped. The composition is frozen,
  // not hidden -- the screen would otherwise be empty.
  static const double reducedMotionLevel = 0.45;

  // The ramp's two middle stops, each carrying its own alpha. [edge] is the
  // darker of the two and [core] the lighter; the ramp runs black, [edge],
  // [core], white.
  //
  // **The two ends are black and white and are not settable.** They are what
  // let one grey field reach real shadow and real highlight. A third theme
  // colour in the middle was tried and removed: it squeezes the ends, and the
  // ends are doing most of the work.
  final Color core;
  final Color edge;

  // 0 resting, 1 loudest. Null means idle at [restingLevel] for good.
  final ValueListenable<double>? level;

  // Flip the grey field, so the ramp is read from the other end. Left null it
  // follows `Theme.of(context).brightness` -- the app's resolved brightness,
  // not the phone's -- which is almost always right: the same two colours then
  // read correctly on a dark ground without a second palette existing
  // anywhere. Pass it only when the orb sits on a ground that disagrees with
  // the theme, which on this widget means a backdrop the screen painted itself.
  //
  // **Getting this wrong is loud, not subtle.** The ramp's two ends are opaque
  // black and opaque white, so an orb inverted against its ground fills its
  // whole circle with one of them. A black disc on a pale page is this flag
  // pointing the wrong way, every time.
  final bool? inverted;

  final double seed;
  final double restingLevel;

  @override
  State<SkBlobOrb> createState() => _SkBlobOrbState();
}

class _SkBlobOrbState extends State<SkBlobOrb>
    with SingleTickerProviderStateMixin {
  ui.FragmentShader? _shader;

  // **Two clocks, and they do different jobs.** [_time] is steady and owns the
  // petal drift, so the composition keeps its own slow pace whatever the level
  // does. [_anim] owns the flow and runs at a rate that follows the level, so
  // a loud moment makes the orb move faster. Collapsing them would mean a
  // quiet moment freezing the whole picture.
  final ValueNotifier<double> _time = ValueNotifier<double>(0);
  final ValueNotifier<double> _anim = ValueNotifier<double>(0);

  // Fades in over about half a second. An orb that appears at full strength on
  // the frame the screen opens reads as a pop; this is the one moment where
  // the widget is allowed to do something that is not the composition.
  final ValueNotifier<double> _opacity = ValueNotifier<double>(0);

  // The smoothed rate of the flow clock. Smoothed rather than read straight
  // off the level, because a rate that jumps is a speed change the eye sees as
  // a stutter even when the level itself was smooth.
  double _flowRate = _minFlowRate;

  // At rest the flow still moves, slowly. Zero would be a stopped picture,
  // which reads as the app having hung.
  static const double _minFlowRate = 0.1;

  // Stands in when no level is supplied, and again when the system asks for
  // reduced motion. Constant, so the painter's repaint listener never fires
  // for it.
  late final ValueNotifier<double> _idleLevel =
      ValueNotifier<double>(widget.restingLevel);
  final ValueNotifier<double> _frozenLevel =
      ValueNotifier<double>(SkBlobOrb.reducedMotionLevel);

  Ticker? _ticker;
  Duration _last = Duration.zero;
  bool _reduceMotion = false;
  bool _ambientDark = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // **The app's brightness, not the phone's.** This read was
    // `MediaQuery.platformBrightnessOf` until 20 September 2026, and that is
    // the phone's system setting: an app forced to Light on a phone set to
    // Dark inverted the orb against a pale page, which floods the whole disc
    // with the ramp's opaque black end and looks like a black circle. The Me
    // tab offers Light, Dark and System, so the two disagree whenever the user
    // has chosen. `Theme.of(context).brightness` is the resolved answer, and
    // it is what every screen deciding a pale slot already reads.
    _ambientDark = Theme.of(context).brightness == Brightness.dark;

    // Read here rather than in build: it decides whether a Ticker runs, and
    // starting or stopping one from build is not allowed.
    final bool reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce != _reduceMotion) {
      _reduceMotion = reduce;
      _syncTicker();
    }
  }

  @override
  void didUpdateWidget(SkBlobOrb oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.restingLevel != oldWidget.restingLevel) {
      _idleLevel.value = widget.restingLevel;
    }
  }

  Future<void> _load() async {
    final ui.FragmentProgram? program =
        await ShaderCache.load('shaders/blob_orb.frag');

    // The screen can close while a shader compiles.
    if (!mounted) return;

    setState(() => _shader = program?.fragmentShader());
    _syncTicker();
  }

  // The clocks run whenever motion is allowed. Unlike the halo there is no
  // "off" setting: a still orb is not what this widget is for.
  void _syncTicker() {
    if (!_reduceMotion && _ticker == null) {
      _last = Duration.zero;
      _ticker = createTicker(_tick)..start();
      return;
    }

    if (_reduceMotion && _ticker != null) {
      _ticker!.dispose();
      _ticker = null;
      _time.value = 0;
      _anim.value = 0;

      // Frozen, but not invisible: reduced motion asks for stillness, not for
      // an empty screen.
      _opacity.value = 1;
    }
  }

  void _tick(Duration elapsed) {
    // Frame delta rather than total elapsed, because the flow clock advances
    // at a rate that changes: it cannot be recovered from a total.
    final double dt =
        (elapsed - _last).inMicroseconds / Duration.microsecondsPerSecond;
    _last = elapsed;

    // A long first frame, or a frame after the app was in the background,
    // would otherwise jump the flow forward by seconds in one step.
    final double step = dt.clamp(0.0, 1.0 / 20.0);

    if (_opacity.value < 1) {
      _opacity.value = math.min(1.0, _opacity.value + step * 2.0);
    }

    final double level = _currentLevel.value.clamp(0.0, 1.0);

    // Half a second per second, so "one unit of uTime" is a comfortable period
    // for the slow sines in the shader to be written against.
    _time.value += step * 0.5;

    // Fast in the middle of the range and easing off at both ends, so the
    // orb's response to getting louder is strongest where most speech lives.
    final double target =
        _minFlowRate + (1.0 - math.pow(level - 1.0, 2).toDouble()) * 0.9;
    _flowRate += (target - _flowRate) * 0.12;

    _anim.value += step * _flowRate;
  }

  ValueListenable<double> get _currentLevel =>
      _reduceMotion ? _frozenLevel : (widget.level ?? _idleLevel);

  @override
  void dispose() {
    _ticker?.dispose();
    _shader?.dispose();
    _time.dispose();
    _anim.dispose();
    _opacity.dispose();
    _idleLevel.dispose();
    _frozenLevel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ValueListenable<double> level = _currentLevel;
    final ui.FragmentShader? shader = _shader;
    final bool inverted = widget.inverted ?? _ambientDark;

    // A plain radial gradient while the shader compiles, and for good if it
    // never does. Same circle, no petals, so a device whose driver rejects the
    // shader sees a breathing disc rather than an empty screen.
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: shader == null
            ? _FallbackOrbPainter(
                level: level,
                time: _time,
                opacity: _opacity,
                core: widget.core,
                edge: widget.edge,
                inverted: inverted,
              )
            : _BlobOrbPainter(
                shader: shader,
                level: level,
                time: _time,
                anim: _anim,
                opacity: _opacity,
                core: widget.core,
                edge: widget.edge,
                inverted: inverted,
                seed: widget.seed,
              ),
      ),
    );
  }
}

// The uniform indices, written out once so the shader file and this painter
// cannot drift apart silently. setFloat takes a position, not a name, so a
// shader that gains a uniform in the middle breaks every one after it.
abstract final class _U {
  static const int width = 0;
  static const int height = 1;
  static const int time = 2;
  static const int anim = 3;
  static const int level = 4;
  static const int inverted = 5;
  static const int seed = 6;
  static const int opacity = 7;
  static const int coreR = 8;
  static const int edgeR = 12;
}

class _BlobOrbPainter extends CustomPainter {
  _BlobOrbPainter({
    required this.shader,
    required this.level,
    required this.time,
    required this.anim,
    required this.opacity,
    required this.core,
    required this.edge,
    required this.inverted,
    required this.seed,
  }) : super(
          repaint: Listenable.merge(<Listenable>[level, time, anim, opacity]),
        );

  final ui.FragmentShader shader;
  final ValueListenable<double> level;
  final ValueListenable<double> time;
  final ValueListenable<double> anim;
  final ValueListenable<double> opacity;
  final Color core;
  final Color edge;
  final bool inverted;
  final double seed;

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(_U.width, size.width)
      ..setFloat(_U.height, size.height)
      ..setFloat(_U.time, time.value)
      ..setFloat(_U.anim, anim.value)
      ..setFloat(_U.level, level.value.clamp(0.0, 1.0))
      ..setFloat(_U.inverted, inverted ? 1.0 : 0.0)
      ..setFloat(_U.seed, seed)
      ..setFloat(_U.opacity, opacity.value.clamp(0.0, 1.0));

    _setColor(shader, _U.coreR, core);
    _setColor(shader, _U.edgeR, edge);

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  // Straight alpha, not premultiplied. The shader premultiplies on the way
  // out, which is what Flutter expects from a fragment shader; doing it twice
  // shows as an orb darker in the middle than at its edge.
  static void _setColor(ui.FragmentShader shader, int at, Color color) {
    shader
      ..setFloat(at, color.r)
      ..setFloat(at + 1, color.g)
      ..setFloat(at + 2, color.b)
      ..setFloat(at + 3, color.a);
  }

  @override
  bool shouldRepaint(_BlobOrbPainter old) {
    // Level and the clocks repaint through the listenable above, so they are
    // not tested here. These are the ones a rebuild can change.
    return old.shader != shader ||
        old.core != core ||
        old.edge != edge ||
        old.inverted != inverted ||
        old.seed != seed;
  }
}

// The same orb without a shader: a radial gradient disc that drifts slowly
// with the clock. No petals -- reproducing a polar composition on the CPU is
// not worth a path in a fallback. The ramp's two fixed ends are kept, because
// they are what make the colours read.
class _FallbackOrbPainter extends CustomPainter {
  _FallbackOrbPainter({
    required this.level,
    required this.time,
    required this.opacity,
    required this.core,
    required this.edge,
    required this.inverted,
  }) : super(repaint: Listenable.merge(<Listenable>[level, time, opacity]));

  final ValueListenable<double> level;
  final ValueListenable<double> time;
  final ValueListenable<double> opacity;
  final Color core;
  final Color edge;
  final bool inverted;

  // The same share of the box the shader fills, so a device that falls back
  // does not also change the layout it sits in.
  static const double _fill = 0.46;

  @override
  void paint(Canvas canvas, Size size) {
    final double short = size.shortestSide;
    if (short <= 0) return;

    final double a = opacity.value.clamp(0.0, 1.0);
    if (a <= 0) return;

    // One slow sine so the fallback is not dead still.
    final double drift = 1.0 + math.sin(time.value * 1.8) * 0.02;
    final double r = _fill * drift * short;

    // The centre is the bright end of the ramp in light mode and the dark end
    // in dark mode, which is what the shader's inversion does.
    final Color inner = inverted ? edge : core;
    final Color outer = inverted ? core : edge;

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.radial(
          size.center(Offset.zero),
          math.max(r, 0.001),
          <Color>[
            inner.withValues(alpha: inner.a * a),
            outer.withValues(alpha: outer.a * a),
            outer.withValues(alpha: 0.0),
          ],
          const <double>[0.0, 0.97, 1.0],
        ),
    );
  }

  @override
  bool shouldRepaint(_FallbackOrbPainter old) {
    return old.core != core || old.edge != edge || old.inverted != inverted;
  }
}

// Turns a jumpy signal into one the orb can be driven by.
//
// Audio loudness arrives as a new number every frame and those numbers jump.
// Fed straight in, the orb judders. This blends each new value a little way
// into the old one, so the orb lags the sound by a few frames and reads as
// following it rather than reacting to it.
//
// [attack] is how fast it rises, [release] how fast it falls. Rise is quicker
// than fall on purpose: a voice starting should be caught, a voice stopping
// should ease off rather than snap shut.
//
// Nothing drives this automatically. Call [push] from wherever the numbers
// come from -- an audio meter, a stream, a timer -- and dispose it with the
// widget that owns it.
class SkBlobOrbLevel extends ValueNotifier<double> {
  SkBlobOrbLevel({
    double initial = SkBlobOrb.defaultRestingLevel,
    this.attack = 0.35,
    this.release = 0.12,
  }) : super(initial);

  final double attack;
  final double release;

  void push(double raw) {
    final double target = raw.clamp(0.0, 1.0);
    final double rate = target > value ? attack : release;
    value = value + (target - value) * rate;
  }
}
