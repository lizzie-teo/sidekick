import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:sidekick/app/core/shader_cache.dart';

// Which halo shader to draw with. All three take the same uniforms in the
// same order, so this is a swap and nothing else -- see the table at the top
// of shaders/halo_soft.frag.
enum SkHaloStyle {
  // One feathered circle. The baseline.
  soft('shaders/halo_soft.frag'),

  // A warm bright centre inside the fade, so the light has a source.
  warm('shaders/halo_warm.frag'),

  // A second, much wider and fainter wash behind the first, so the halo has
  // no findable edge at all.
  mist('shaders/halo_mist.frag');

  const SkHaloStyle(this.asset);

  final String asset;
}

// A soft pool of light that grows on the in-breath and shrinks on the out.
//
// **This is a rhythm cue, not a contrast fix.** There used to be an
// `SkCharacterGlow` behind the sidekick whose job was to separate her from
// the scene. It could not: the girl and the cat span nearly the whole range
// from white to black, so no single pool serves both, and the note in
// sk_colors.dart records the measurements. Nothing here revisits that. This
// halo exists so the breath can be seen from the corner of an eye, by
// somebody who is not reading the screen, and it is kept faint enough that
// it is never the thing she is standing out against.
//
// **Size is [phase] and nothing else.** No curve is applied on top. The pacer
// -- the Rive timeline, by way of the events it fires -- already shapes the
// ramp, so an ease here would put the halo ahead of or behind her belly, and
// later, ahead of or behind a voice track. The only clock in this widget
// drives the edge wobble, which is off by default and never touches size.
//
// It repaints without rebuilding. [phase] is handed to the painter as its
// `repaint` listenable, so a moving breath costs one paint of one rect and
// no widget rebuild anywhere. The breathing screen rebuilds a handful of
// times per session; this moves every frame, and the two must not be joined.
//
// It is a backdrop: it takes the box it is given and lays out nothing. Put it
// behind the sidekick in a Stack and she is positioned exactly as before.
class SkBreathHalo extends StatefulWidget {
  const SkBreathHalo({
    super.key,
    required this.phase,
    required this.inner,
    required this.outer,
    this.style = SkHaloStyle.soft,
    this.minRadius = defaultMinRadius,
    this.maxRadius = defaultMaxRadius,
    this.softness = defaultSoftness,
    this.wobble = defaultWobble,
  });

  // Start faint and small. The brief was "too subtle rather than too much",
  // and these are the numbers to raise, not lower.
  //
  // Radii are fractions of the SHORT side of the box, measured from the
  // centre. 0.5 reaches the nearest edge exactly, so anything above it is
  // still part-opaque where the paint stops -- which shows as a rectangle.
  // Keep maxRadius at or below 0.46 and the fade lands inside the box.
  static const double defaultMinRadius = 0.30;
  static const double defaultMaxRadius = 0.44;

  // How much of the radius is spent fading, as a fraction of it. Near 0 is a
  // hard disc; 1.0 is a fade that starts at the centre.
  static const double defaultSoftness = 0.60;

  // Off. A true circle until somebody turns it on.
  static const double defaultWobble = 0.0;

  // What the halo shows at when the system is set to reduce motion: the
  // middle of the range, held still. Not the minimum -- a halo frozen at its
  // smallest reads as something that failed to start.
  static const double reducedMotionPhase = 0.5;

  // 0 at the bottom of an out-breath, 1 at the top of an in-breath.
  //
  // A listenable rather than a double so this widget can repaint on its own.
  // Values outside 0..1 are clamped in the shader.
  final ValueListenable<double> phase;

  final SkHaloStyle style;

  // The centre colour and the edge colour. Both carry their own alpha, and
  // the edge one is normally fully transparent -- it is the colour the halo
  // fades *to*, not a rim.
  final Color inner;
  final Color outer;

  final double minRadius;
  final double maxRadius;
  final double softness;
  final double wobble;

  @override
  State<SkBreathHalo> createState() => _SkBreathHaloState();
}

class _SkBreathHaloState extends State<SkBreathHalo>
    with SingleTickerProviderStateMixin {
  ui.FragmentShader? _shader;

  // Seconds since the wobble started. Its own notifier so it can drive a
  // repaint without touching the phase, and so it can stay frozen at zero
  // when the wobble is off.
  final ValueNotifier<double> _time = ValueNotifier<double>(0);

  // Stands in for the real phase when the system asks for reduced motion.
  // Constant, so the painter's repaint listener simply never fires.
  final ValueNotifier<double> _frozenPhase =
      ValueNotifier<double>(SkBreathHalo.reducedMotionPhase);

  Ticker? _ticker;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Read here rather than in build: it decides whether a Ticker runs, and
    // starting or stopping one from build is not allowed.
    final bool reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce != _reduceMotion) {
      _reduceMotion = reduce;
    }

    _syncTicker();
  }

  @override
  void didUpdateWidget(SkBreathHalo oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.style != oldWidget.style) {
      _shader?.dispose();
      _shader = null;
      _load();
    }

    // Turning the wobble on and off is the only thing that starts or stops
    // the clock. A halo with no wobble has nothing to animate between
    // breaths, so it must not hold a Ticker open.
    if (widget.wobble != oldWidget.wobble) {
      _syncTicker();
    }
  }

  Future<void> _load() async {
    final SkHaloStyle style = widget.style;

    final ui.FragmentProgram? program = await ShaderCache.load(style.asset);

    // Both guards matter: the screen can close while a shader compiles, and
    // the style can change under a load that is still in flight.
    if (!mounted || style != widget.style) return;

    setState(() => _shader = program?.fragmentShader());
  }

  void _syncTicker() {
    final bool wants = widget.wobble > 0 && !_reduceMotion;

    if (wants && _ticker == null) {
      _ticker = createTicker((Duration elapsed) {
        _time.value = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
      })
        ..start();
      return;
    }

    if (!wants && _ticker != null) {
      _ticker!.dispose();
      _ticker = null;
      _time.value = 0;
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    _shader?.dispose();
    _time.dispose();
    _frozenPhase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ValueListenable<double> phase =
        _reduceMotion ? _frozenPhase : widget.phase;

    final ui.FragmentShader? shader = _shader;

    // A plain radial gradient while the shader compiles, and for good if it
    // never does. It is the same shape drawn a duller way, so a device whose
    // driver rejects the shader still sees the breath rather than nothing.
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: shader == null
            ? _FallbackHaloPainter(
                phase: phase,
                inner: widget.inner,
                outer: widget.outer,
                minRadius: widget.minRadius,
                maxRadius: widget.maxRadius,
                softness: widget.softness,
              )
            : _HaloPainter(
                shader: shader,
                phase: phase,
                time: _time,
                inner: widget.inner,
                outer: widget.outer,
                minRadius: widget.minRadius,
                maxRadius: widget.maxRadius,
                softness: widget.softness,
                wobble: widget.wobble,
              ),
      ),
    );
  }
}

// The uniform indices, written out once so the shader files and this painter
// cannot drift apart silently. setFloat takes a position, not a name, so a
// shader that gains a uniform in the middle breaks every one after it.
abstract final class _U {
  static const int width = 0;
  static const int height = 1;
  static const int phase = 2;
  static const int minRadius = 3;
  static const int maxRadius = 4;
  static const int softness = 5;
  static const int wobble = 6;
  static const int time = 7;
  static const int innerR = 8;
  static const int outerR = 12;
}

class _HaloPainter extends CustomPainter {
  _HaloPainter({
    required this.shader,
    required this.phase,
    required this.time,
    required this.inner,
    required this.outer,
    required this.minRadius,
    required this.maxRadius,
    required this.softness,
    required this.wobble,
  }) : super(repaint: Listenable.merge(<Listenable>[phase, time]));

  final ui.FragmentShader shader;
  final ValueListenable<double> phase;
  final ValueListenable<double> time;
  final Color inner;
  final Color outer;
  final double minRadius;
  final double maxRadius;
  final double softness;
  final double wobble;

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(_U.width, size.width)
      ..setFloat(_U.height, size.height)
      ..setFloat(_U.phase, phase.value.clamp(0.0, 1.0))
      ..setFloat(_U.minRadius, minRadius)
      ..setFloat(_U.maxRadius, maxRadius)
      ..setFloat(_U.softness, softness)
      ..setFloat(_U.wobble, wobble)
      ..setFloat(_U.time, time.value);

    _setColor(shader, _U.innerR, inner);
    _setColor(shader, _U.outerR, outer);

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  // Straight alpha, not premultiplied. The shader premultiplies on the way
  // out, which is what Flutter expects from a fragment shader; doing it twice
  // shows as a halo that is darker in the middle than at its edge.
  static void _setColor(ui.FragmentShader shader, int at, Color color) {
    shader
      ..setFloat(at, color.r)
      ..setFloat(at + 1, color.g)
      ..setFloat(at + 2, color.b)
      ..setFloat(at + 3, color.a);
  }

  @override
  bool shouldRepaint(_HaloPainter old) {
    // Phase and time repaint through the listenable above, so they are not
    // tested here. These are the ones a rebuild can change.
    return old.shader != shader ||
        old.inner != inner ||
        old.outer != outer ||
        old.minRadius != minRadius ||
        old.maxRadius != maxRadius ||
        old.softness != softness ||
        old.wobble != wobble;
  }
}

// The same halo without a shader: a radial gradient with the fade split into
// four stops so it rolls off rather than ramping straight. No wobble -- an
// edge ripple is not worth a path in a fallback.
class _FallbackHaloPainter extends CustomPainter {
  _FallbackHaloPainter({
    required this.phase,
    required this.inner,
    required this.outer,
    required this.minRadius,
    required this.maxRadius,
    required this.softness,
  }) : super(repaint: phase);

  final ValueListenable<double> phase;
  final Color inner;
  final Color outer;
  final double minRadius;
  final double maxRadius;
  final double softness;

  @override
  void paint(Canvas canvas, Size size) {
    final double short = size.shortestSide;
    if (short <= 0) return;

    final double t = phase.value.clamp(0.0, 1.0);
    final double radius =
        (minRadius + (maxRadius - minRadius) * t) * short * (1 + softness);

    final Offset centre = size.center(Offset.zero);

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.radial(
          centre,
          radius,
          <Color>[
            inner,
            Color.lerp(inner, outer, 0.45)!,
            Color.lerp(inner, outer, 0.85)!,
            outer,
          ],
          <double>[0.0, 0.45, 0.75, 1.0],
        ),
    );
  }

  @override
  bool shouldRepaint(_FallbackHaloPainter old) {
    return old.inner != inner ||
        old.outer != outer ||
        old.minRadius != minRadius ||
        old.maxRadius != maxRadius ||
        old.softness != softness;
  }
}
