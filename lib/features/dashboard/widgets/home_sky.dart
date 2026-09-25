import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:sidekick/features/dashboard/models/day_phase.dart';

// Home's scene: a sky for the time of day, a sun or a moon with its glow,
// two layers of hills, and her standing on the nearer one. Built 25
// September 2026, at the user's request, and recoloured the same evening
// from six illustrated references the user brought.
//
// **What the references taught, and what this file does with it:**
//
// | Lesson | Here |
// | --- | --- |
// | Each time of day owns a hue: a yellow-to-pink morning, a blue day, a violet-to-pink evening, a navy night | `_scenes` |
// | The land is never green. It is the sky's own hue, a step deeper or lighter | `farHill`, `land` |
// | Layers are what separate land from sky: far hills close to the sky, the near land a step on | Two hill paths in `_StagePainter` |
// | A sun or moon is a disc with a soft glow around it, not a flat dot | `glow` |
// | Mountains are a few big simple shapes, each with a lit side and a shaded side, a paler row behind a darker one | `_backMountains`, `_frontMountains` |
// | The moon is a warm gold, lit from one side, with faint darker seas on it | `_paintMoon` |
// | Alto's Odyssey: big layered mountains with haze at the foot of each layer, tall slim pines far bigger than her, one long slope with a crest under her feet. Still fireflies and butterflies | `_StagePainter` |
// | Every layer further back is paler, in both modes | `distantHill`, `farHill`, `land`, `grass` |
//
// **Dark mode used to run the land the other way**, lighter in front, so the
// nearest hill glowed and the distance came forward. It was turned round on
// 25 September 2026 with the valley, and the lower sky was lifted to give the
// ranges something to be darker than. The words sit in the top of the sky,
// which did not move.
// **The palette does not reach the scene, and that is deliberate.** The
// time of day is a fact about the world: a dawn that went coral in Coral
// diorama and teal in Dusk terrarium would not read as dawn. The palette
// keeps the rest of the page -- the panel under the scene and the
// tiles. The first version mixed the sky from the canvas and made the land
// the canvas; at night in dark mode the land measured 1.02:1 against the
// sky, and in light mode it was a cream hill on a cream sky. Both were
// reported the day they shipped.
//
// **The mode still picks the brightness.** Light mode runs a pale version of
// each scene and dark mode a deep one, so a dark phone at noon gets a deep
// blue day and not a lamp. Night is the exception in light mode: a pale
// night is not a night, so it is a mid blue with white words on it.
//
// **The words on the sky are near-black or near-white, whichever that sky
// carries.** A palette's `ink` was picked against a cream page, not against
// violet. `test/home_sky_test.dart` holds `onSky` to 4.5:1 across the top of
// every sky, which is where the date and the quote sit.
class HomeSkyColors {
  final Color top;
  final Color bottom;

  // The far hills, close to the sky. The near land she stands on is a step
  // further from it.
  final Color farHill;
  final Color land;

  // The sun or the moon, and the soft halo around it.
  final Color body;
  final Color glow;

  // Night only.
  final Color star;

  // The date, the quote and the name under it.
  final Color onSky;

  const HomeSkyColors({
    required this.top,
    required this.bottom,
    required this.farHill,
    required this.land,
    required this.body,
    required this.glow,
    required this.star,
    required this.onSky,
  });

  static const Color _darkText = Color(0xFF221D33);
  static const Color _lightText = Color(0xFFFBF8F2);
  static const Color _starlight = Color(0xFFFFFFFF);

  // How far down the sky the quote can reach on an ordinary phone. The text
  // test measures every sky between its top and this point.
  static const double textZone = 0.45;

  // Where the far hills meet the sky, as a share of the gradient.
  static const double horizonAt = 0.6;

  // Where the sky meets the land.
  Color get horizon => Color.lerp(top, bottom, horizonAt)!;

  // The range furthest back: the far hills taken halfway into the sky, so
  // it is the palest land in the picture.
  Color get distantHill => Color.lerp(farHill, horizon, 0.5)!;

  // The trees nearest to her. On a dark sky, the land lifted part of the
  // way towards the hills; on a pale one, the land taken a little deeper.
  // One rule for both failed both ways: the darkest tint read as two black
  // walls at the edges of a night screen, and the land's own colour melted
  // into the mountains on a pale morning.
  Color get nearTree => top.computeLuminance() < 0.2
      ? Color.lerp(land, farHill, 0.45)!
      : Color.lerp(land, grass, 0.3)!;

  // The foot of the ground she stands on, where it meets the panel below.
  // The panel's rounded corners show this colour, so it has to be the one
  // the ground fades to.
  Color get ground => Color.lerp(land, grass, 0.5)!;

  // The nearest trees: the land taken darker still, because they are the
  // nearest thing in the picture, and quieter, because darkening alone left
  // a pale pink land as a hot pink. Named for the grass it was first made
  // for.
  Color get grass {
    final HSLColor hsl = HSLColor.fromColor(land);
    return hsl
        .withLightness(hsl.lightness * 0.72)
        .withSaturation(hsl.saturation * 0.6)
        .toColor();
  }

  static HomeSkyColors of(DayPhase phase, Brightness brightness) =>
      _scenes[(phase, brightness)]!;

  static const Map<(DayPhase, Brightness), HomeSkyColors> _scenes =
      <(DayPhase, Brightness), HomeSkyColors>{
    // Light mode: the pale version of each scene.
    (DayPhase.morning, Brightness.light): HomeSkyColors(
      top: Color(0xFFFBE7A1),
      bottom: Color(0xFFF7CFD3),
      farHill: Color(0xFFEBA9C0),
      land: Color(0xFFD98AAB),
      body: Color(0xFFFFF4D2),
      glow: Color(0xFFFFFBEA),
      star: _starlight,
      onSky: _darkText,
    ),
    // **A soft blue running down into pink, with periwinkle ranges.** From
    // a reference the user brought on 25 September 2026, after two rounds on
    // this sky. The first blue was greyed and read as dull; a saturated cyan
    // with cartoon clouds and a rainbow followed, and was called ugly. What
    // the night scene had and the day did not was a palette that holds
    // together -- one family from the sky to the land -- so the day now
    // takes the same scene and a family of its own. No clouds, no rainbow.
    (DayPhase.day, Brightness.light): HomeSkyColors(
      top: Color(0xFF78B8E8),
      bottom: Color(0xFFFBC3D3),
      farHill: Color(0xFF8E9BD6),
      land: Color(0xFF6674BE),
      body: Color(0xFFFFE9B8),
      glow: Color(0xFFFFFFFF),
      star: _starlight,
      onSky: _darkText,
    ),
    (DayPhase.evening, Brightness.light): HomeSkyColors(
      top: Color(0xFF9C79D6),
      bottom: Color(0xFFF2A7B4),
      farHill: Color(0xFFA36CB6),
      land: Color(0xFF7E4F9C),
      body: Color(0xFFFFD9A3),
      glow: Color(0xFFFFC98C),
      star: _starlight,
      onSky: _darkText,
    ),
    (DayPhase.night, Brightness.light): HomeSkyColors(
      top: Color(0xFF3F4A92),
      bottom: Color(0xFF7683C7),
      farHill: Color(0xFF3A4585),
      land: Color(0xFF2B336B),
      body: Color(0xFFF6CD8C),
      glow: Color(0xFFF2B77A),
      star: _starlight,
      onSky: _lightText,
    ),

    // Dark mode: the deep version.
    (DayPhase.morning, Brightness.dark): HomeSkyColors(
      top: Color(0xFF2E2848),
      bottom: Color(0xFF9C7494),
      farHill: Color(0xFF5A4264),
      land: Color(0xFF3B2B4A),
      body: Color(0xFFE8C98A),
      glow: Color(0xFFD9A77A),
      star: _starlight,
      onSky: _lightText,
    ),
    (DayPhase.day, Brightness.dark): HomeSkyColors(
      top: Color(0xFF17304F),
      bottom: Color(0xFF5A8CBC),
      farHill: Color(0xFF2E5378),
      land: Color(0xFF1D3754),
      body: Color(0xFFE8C66A),
      glow: Color(0xFFB9A060),
      star: _starlight,
      onSky: _lightText,
    ),
    (DayPhase.evening, Brightness.dark): HomeSkyColors(
      top: Color(0xFF241B44),
      bottom: Color(0xFFA65E90),
      farHill: Color(0xFF552D5C),
      land: Color(0xFF361C41),
      body: Color(0xFFE9A36F),
      glow: Color(0xFFC0706A),
      star: _starlight,
      onSky: _lightText,
    ),
    (DayPhase.night, Brightness.dark): HomeSkyColors(
      top: Color(0xFF0E1330),
      bottom: Color(0xFF5260A8),
      farHill: Color(0xFF222A5C),
      land: Color(0xFF121636),
      body: Color(0xFFF1C27F),
      glow: Color(0xFFD9955E),
      star: _starlight,
      onSky: _lightText,
    ),
  };
}

// The gradient behind the whole page.
class HomeSky extends StatelessWidget {
  final DayPhase phase;

  const HomeSky({super.key, required this.phase});

  @override
  Widget build(BuildContext context) {
    final HomeSkyColors colours =
        HomeSkyColors.of(phase, Theme.of(context).brightness);

    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[colours.top, colours.bottom],
          ),
        ),
      ),
    );
  }
}

// Her band: the sun or moon, the far hills, the near land, and her on it.
//
// A fixed height, so nothing that grows elsewhere on the page -- the quote at
// 200% text -- can move her inside it. The near land's crown sits `hillRise`
// above the band's foot, so her feet and legs stand on it.
class HomeStage extends StatefulWidget {
  final DayPhase phase;
  final double height;
  final Widget child;

  // How far above the foot of the band the crown of the near land sits.
  static const double hillRise = 72;

  // One loop of the fireflies and butterflies. Every movement in it repeats
  // a whole number of times per loop, so the end meets the start and there
  // is no jump.
  static const Duration lifeLoop = Duration(seconds: 24);

  const HomeStage({
    super.key,
    required this.phase,
    required this.height,
    required this.child,
  });

  @override
  State<HomeStage> createState() => _HomeStageState();
}

// **The fireflies and butterflies move, and that is the user's decision.**
// Made 25 September 2026, knowing the Motion rule in `CLAUDE.md` -- nothing
// decorative moves under somebody reading -- because Home's quote sits above
// the band, not on it. So the movement is kept slow and small: a drift of a
// few points, a glow that swells over seconds, a wingbeat twice a second.
// Nothing crosses her or the words.
//
// **Reduce Motion stops it.** With the system setting on, every creature
// stands still where the loop starts, which is the scene as it was before.
class _HomeStageState extends State<HomeStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _life =
      AnimationController(vsync: this, duration: HomeStage.lifeLoop);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _life
        ..stop()
        ..value = 0;
    } else if (!_life.isAnimating) {
      _life.repeat();
    }
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HomeSkyColors colours =
        HomeSkyColors.of(widget.phase, Theme.of(context).brightness);

    // Clipped at the foot only, because the near trees are sunk below it and
    // a scroll view paints its first slivers over the later ones: unclipped,
    // the bottoms of the trees were drawn over the cream panel. The top is
    // left open, so the moon's glow fades into the sky above instead of
    // stopping at a straight line.
    return SizedBox(
      height: widget.height,
      child: ClipRect(
        clipper: const _FootClipper(),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ExcludeSemantics(
              child: CustomPaint(
                painter: _StagePainter(phase: widget.phase, colours: colours),
              ),
            ),
            // Its own layer, so the scene under it is not repainted on every
            // frame of a wingbeat.
            ExcludeSemantics(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _LifePainter(
                    phase: widget.phase,
                    colours: colours,
                    clock: _life,
                    moving: !MediaQuery.disableAnimationsOf(context),
                  ),
                ),
              ),
            ),
            Align(alignment: Alignment.bottomCenter, child: widget.child),
          ],
        ),
      ),
    );
  }
}

// Cuts off whatever is painted below the foot of the band, and nothing else.
class _FootClipper extends CustomClipper<Rect> {
  const _FootClipper();

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(-size.width, -size.height, size.width * 2, size.height);

  @override
  bool shouldReclip(_FootClipper old) => false;
}

class _StagePainter extends CustomPainter {
  final DayPhase phase;
  final HomeSkyColors colours;

  const _StagePainter({required this.phase, required this.colours});

  // Where the stars sit, as fractions of the band, with a radius each.
  // Fixed, so the sky is the same every night rather than a new scatter on
  // every rebuild. None of them sits in the moon's glow.
  static const List<(double, double, double)> _stars =
      <(double, double, double)>[
    (0.06, 0.12, 1.6),
    (0.14, 0.34, 1.2),
    (0.24, 0.08, 1.4),
    (0.36, 0.22, 1.0),
    (0.58, 0.06, 1.2),
    (0.64, 0.30, 1.0),
    (0.95, 0.40, 1.2),
    (0.97, 0.08, 1.0),
  ];

  // The mountains, as (share of the width of the peak, height above the
  // foot of the band, reach to the left, reach to the right, both as shares
  // of the width), in two rows. The row behind is paler than the row in
  // front.
  //
  // **Alto's Odyssey is the reference**, at the user's request, 25
  // September 2026. Three things make that look and all three are here:
  // mountains far bigger than the figure, long slopes that steepen towards
  // a sharp top, and a haze gathering at the foot of every layer so each
  // one floats off the one in front. The haze is what `_hazed` paints.
  //
  // **Tall at the sides and low in the middle,** so the peaks frame her,
  // and **tallest round the moon**: one peak either side of it, rising to
  // the top of the band, so the moon sits in a notch between two mountains.
  // Every slope directly under it is still lower than its foot; the first
  // version put a peak through the middle of the moon.
  //
  // Earlier the same evening this was a river valley, then a row of sharp
  // ridges, then triangles with a lit face. The river ran behind her legs;
  // the ridges read as broken glass on the left.
  static const List<(double, double, double, double)> _backMountains =
      <(double, double, double, double)>[
    (0.06, 262, 0.45, 0.40),
    (0.40, 170, 0.30, 0.24),
    (0.64, 232, 0.18, 0.20),
    (0.99, 264, 0.22, 0.30),
  ];

  static const List<(double, double, double, double)> _frontMountains =
      <(double, double, double, double)>[
    (0.16, 210, 0.34, 0.30),
    (0.64, 150, 0.30, 0.30),
    (0.95, 196, 0.26, 0.32),
  ];

  // Pines, as (share of the width, base height, tree height). Tall and slim,
  // the way Alto draws them, and far bigger than her so the scale reads as
  // a landscape rather than a stage set. The hazy ones stand between the
  // mountain rows; the dark ones on the slopes at the edges, nearest of all.
  // None in the middle third, which is hers, and the tallest on the right
  // keep their tops below the moon.
  static const List<(double, double, double)> _farPines =
      <(double, double, double)>[
    (0.22, 60, 96),
    (0.27, 58, 70),
    (0.74, 64, 88),
    (0.79, 62, 64),
  ];

  static const List<(double, double, double)> _nearPines =
      <(double, double, double)>[
    (0.03, 6, 214),
    (0.10, 14, 164),
    (0.17, 20, 118),
    (0.98, 14, 176),
    (0.91, 22, 134),
    (0.85, 30, 96),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint paint = Paint()..isAntiAlias = true;

    // The sun or moon first. All four sit in open sky, clear of every peak
    // and to the side of her head: morning on the left, the rest on the
    // right. Morning and evening sit lower than day and night.
    final (Offset centre, double radius) = switch (phase) {
      DayPhase.morning => (Offset(w * 0.24, h * 0.26), 28.0),
      DayPhase.day => (Offset(w * 0.80, h * 0.18), 28.0),
      DayPhase.evening => (Offset(w * 0.79, h * 0.34), 34.0),
      DayPhase.night => (Offset(w * 0.79, h * 0.26), 36.0),
    };

    if (phase == DayPhase.night) {
      paint.color = colours.star.withValues(alpha: 0.8);
      for (final (double x, double y, double r) in _stars) {
        canvas.drawCircle(Offset(w * x, h * y), r, paint);
      }
      _paintMoon(canvas, centre, radius);
    } else {
      // The glow: three soft rings, each wider and fainter than the last.
      for (final (double scale, double alpha) in <(double, double)>[
        (3.0, 0.10),
        (2.2, 0.16),
        (1.5, 0.26),
      ]) {
        paint.color = colours.glow.withValues(alpha: alpha);
        canvas.drawCircle(centre, radius * scale, paint);
      }
      paint.color = colours.body;
      canvas.drawCircle(centre, radius, paint);
    }

    // The row behind, palest because it is furthest away.
    canvas.drawPath(_mountains(_backMountains, w, h),
        _hazed(colours.distantHill, h - 262, h, 0.3));

    canvas.drawPath(_mountains(_frontMountains, w, h),
        _hazed(colours.farHill, h - 212, h, 0.22));

    for (final (double x, double base, double tall) in _farPines) {
      canvas.drawPath(_pine(Offset(w * x, h - base), tall),
          _hazed(colours.farHill, h - base - tall, h - base, 0.25));
    }

    // The near trees go down before the ground, sunk into it, so the slope
    // covers their feet and they grow out of the hill. Painted after it,
    // their lowest tier stopped in mid-air.
    //
    paint.color = colours.nearTree;
    for (final (double x, double base, double tall) in _nearPines) {
      canvas.drawPath(_pine(Offset(w * x, h - base + 14), tall), paint);
    }

    // The ground she stands on: one long slope, not a dome. It rises from
    // low on the left to a gentle crest under her feet, then falls away more
    // slowly to the right, the way a real ridge does -- a symmetrical mound
    // read as a stage. Darker towards the foot, because that is nearest.
    final double crest = h - HomeStage.hillRise;
    final Path ground = Path()
      ..moveTo(0, h - 26)
      ..cubicTo(w * 0.2, h - 34, w * 0.34, crest, w * 0.5, crest)
      ..cubicTo(w * 0.66, crest, w * 0.82, h - 58, w, h - 44)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      ground,
      Paint()
        ..isAntiAlias = true
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[colours.land, colours.ground],
        ).createShader(Rect.fromLTRB(0, crest, w, h)),
    );
  }

  // A layer's colour at its top, fading towards the horizon's colour at its
  // foot by `haze`. That is the mist Alto puts at the bottom of every layer,
  // and it is what makes one row float off the next without an outline.
  Paint _hazed(Color colour, double top, double bottom, double haze) => Paint()
    ..isAntiAlias = true
    ..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[colour, Color.lerp(colour, colours.horizon, haze)!],
    ).createShader(Rect.fromLTRB(0, top, 1, bottom));

  // A row of mountains as one shape. Each slope is long and shallow at the
  // foot and steepens towards a sharp top: a straight slope reads as a
  // paper triangle, and one bowed outwards reads as a hill.
  Path _mountains(
      List<(double, double, double, double)> row, double w, double h) {
    Path shape = Path();
    for (final (double x, double tall, double left, double right) in row) {
      final Offset peak = Offset(w * x, h - tall);
      final Offset footLeft = Offset(w * (x - left), h);
      final Offset footRight = Offset(w * (x + right), h);
      final Path mountain = Path()
        ..moveTo(footLeft.dx, footLeft.dy)
        ..cubicTo(
            footLeft.dx + (peak.dx - footLeft.dx) * 0.55,
            h - tall * 0.12,
            peak.dx - (peak.dx - footLeft.dx) * 0.18,
            peak.dy + tall * 0.22,
            peak.dx,
            peak.dy)
        ..cubicTo(
            peak.dx + (footRight.dx - peak.dx) * 0.18,
            peak.dy + tall * 0.22,
            footRight.dx - (footRight.dx - peak.dx) * 0.55,
            h - tall * 0.12,
            footRight.dx,
            footRight.dy)
        ..close();
      shape = Path.combine(PathOperation.union, shape, mountain);
    }
    return shape;
  }

  // A fir: five tiers stacked up a point, each one narrower than the one
  // below, and slim -- a fifth as wide as it is tall, as Alto draws them.
  // Every tier's sides bow in a little and its hem dips in the middle, so
  // the branch tips lift at the ends the way a real fir's do. One path, so a
  // see-through paint does not darken where the tiers overlap.
  Path _pine(Offset base, double tall) {
    const int tiers = 5;
    final double step = tall * 0.8 / tiers;
    final double tierHeight = tall * 0.4;
    Path tree = Path();
    for (int i = 0; i < tiers; i++) {
      final double bottom = base.dy - step * i;
      final double apex = i == tiers - 1 ? base.dy - tall : bottom - tierHeight;
      final double spread = tall * 0.2 * (1 - i * 0.16);
      final Offset left = Offset(base.dx - spread, bottom - tierHeight * 0.1);
      final Offset right = Offset(base.dx + spread, bottom - tierHeight * 0.1);
      final Offset top = Offset(base.dx, apex);
      final Path tier = Path()
        ..moveTo(left.dx, left.dy)
        ..quadraticBezierTo(base.dx - spread * 0.35,
            (left.dy + top.dy) / 2 + tierHeight * 0.08, top.dx, top.dy)
        ..quadraticBezierTo(base.dx + spread * 0.35,
            (right.dy + top.dy) / 2 + tierHeight * 0.08, right.dx, right.dy)
        ..quadraticBezierTo(
            base.dx, bottom + tierHeight * 0.16, left.dx, left.dy)
        ..close();
      tree = Path.combine(PathOperation.union, tree, tier);
    }
    return tree;
  }

  // The moon: a wide blurred halo, a disc lit from the upper left, and a few
  // faint seas. Blurred rather than ringed, so the glow has no steps in it.
  void _paintMoon(Canvas canvas, Offset centre, double radius) {
    canvas.drawCircle(
      centre,
      radius * 1.6,
      Paint()
        ..color = colours.glow.withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.9),
    );

    final Rect disc = Rect.fromCircle(center: centre, radius: radius);
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 1.1,
          colors: <Color>[
            Color.lerp(colours.body, colours.star, 0.35)!,
            colours.body,
            Color.lerp(colours.body, colours.glow, 0.6)!,
          ],
          stops: const <double>[0, 0.55, 1],
        ).createShader(disc),
    );

    final Paint sea = Paint()
      ..color = colours.glow.withValues(alpha: 0.22)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.1);
    for (final (double dx, double dy, double r) in <(double, double, double)>[
      (0.28, -0.22, 0.20),
      (-0.20, 0.30, 0.16),
      (0.36, 0.34, 0.11),
      (-0.34, -0.10, 0.09),
    ]) {
      canvas.drawCircle(
          centre + Offset(dx * radius, dy * radius), r * radius, sea);
    }
  }

  @override
  bool shouldRepaint(_StagePainter old) =>
      old.phase != phase || old.colours != colours;
}

// The fireflies and butterflies, painted on the band's clock.
class _LifePainter extends CustomPainter {
  final DayPhase phase;
  final HomeSkyColors colours;
  final Animation<double> clock;

  // False under Reduce Motion. The creatures then rest: every firefly lit,
  // every butterfly at its nearest point with its wings open -- one caught
  // mid-beat is a sliver.
  final bool moving;

  _LifePainter({
    required this.phase,
    required this.colours,
    required this.clock,
    required this.moving,
  }) : super(repaint: clock);

  // Fireflies, evening and night only, as (share of the width, share of the
  // height, radius, lives per loop). Most of them low among the trees at
  // the sides, a few higher. None in the moon's glow.
  //
  // **Each one lives and goes out.** It lights small, swells, drifts up a
  // little, fades, and lights again a short way off -- never the same spot
  // twice running. A field of lights that all stay lit reads as decoration;
  // lights that come and go read as fireflies. Changed 25 September 2026, at
  // the user's request. The loop they live on is `HomeStage.lifeLoop`.
  static const List<(double, double, double, int)> _fireflies =
      <(double, double, double, int)>[
    (0.05, 0.78, 1.8, 3),
    (0.11, 0.66, 1.4, 2),
    (0.17, 0.84, 2.0, 3),
    (0.24, 0.72, 1.3, 2),
    (0.29, 0.88, 1.6, 3),
    (0.08, 0.52, 1.2, 2),
    (0.21, 0.44, 1.5, 3),
    (0.33, 0.62, 1.1, 2),
    (0.70, 0.86, 1.5, 3),
    (0.76, 0.70, 1.8, 2),
    (0.83, 0.80, 1.3, 3),
    (0.90, 0.66, 1.9, 2),
    (0.95, 0.84, 1.4, 3),
    (0.66, 0.58, 1.2, 2),
    (0.93, 0.50, 1.1, 3),
  ];

  // Butterflies, each one a flight: where it appears, where it is nearest,
  // and where it goes, as (share of the width, share of the height, scale)
  // three times, then its full size and where in the loop it sets off.
  //
  // **They come and go.** Each one appears small, as if far off, grows as
  // it comes nearer, then either flies out past the edge of the scene or
  // shrinks back into the distance and fades -- and is gone for a while
  // before the next flight. Three hovering in place for ever read as
  // stickers. Changed 25 September 2026, at the user's request.
  //
  // By day they are the land's colour; by evening and night they glow like
  // the fireflies, the way the reference's do.
  static const List<
      (
        (double, double, double),
        (double, double, double),
        (double, double, double),
        double,
        double
      )> _flights = <(
    (double, double, double),
    (double, double, double),
    (double, double, double),
    double,
    double
  )>[
    // Up out of the valley on the left, and away off the left edge.
    ((0.30, 0.62, 0.25), (0.14, 0.40, 1.0), (-0.10, 0.20, 1.1), 11, 0.0),
    // Out of the right-hand trees, a turn, and back into the distance.
    ((0.72, 0.60, 0.25), (0.88, 0.50, 0.95), (0.70, 0.30, 0.2), 10, 0.40),
    // In from past the right edge, and away behind her into the distance.
    ((1.10, 0.28, 1.1), (0.86, 0.62, 0.9), (0.60, 0.56, 0.2), 9, 0.70),
  ];

  // The share of each butterfly's cycle spent flying. The rest it is out of
  // sight, so the scene is sometimes empty of them.
  static const double _flying = 0.72;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double t = clock.value;
    final bool glowing = phase == DayPhase.evening || phase == DayPhase.night;

    if (glowing) {
      _paintFireflies(canvas, w, h, t);
    }

    for (int i = 0; i < _flights.length; i++) {
      final (
        (double, double, double) from,
        (double, double, double) near,
        (double, double, double) to,
        double size,
        double start,
      ) = _flights[i];

      // Under Reduce Motion each one rests at its nearest point, full size,
      // wings open.
      if (!moving) {
        _paintButterfly(canvas, Offset(w * near.$1, h * near.$2),
            size * near.$3, 0, 1, 1, glowing);
        continue;
      }

      final double cycle = (t + start) % 1;
      if (cycle >= _flying) continue;
      final double p = cycle / _flying;

      // A curve through the three points, eased so it slows as it comes
      // near and speeds up as it leaves, with a flutter on top.
      double along(double a, double b, double c) =>
          (1 - p) * (1 - p) * a + 2 * (1 - p) * p * b + p * p * c;
      final double flutter = math.sin(2 * math.pi * (6 * p + i * 0.3));
      final Offset at = Offset(
        w * along(from.$1, near.$1, to.$1) + 6 * flutter,
        h * along(from.$2, near.$2, to.$2) + 5 * math.cos(2 * math.pi * 4 * p),
      );
      final double scale = along(from.$3, near.$3, to.$3);

      // Fade in as it appears. Fade out at the end only when it is going
      // into the distance -- one leaving the scene simply flies out of it.
      final bool leavesScene = to.$1 < 0 || to.$1 > 1;
      final double opacity = math.min(
        1,
        math.min(p / 0.12, leavesScene ? 1 : (1 - p) / 0.18),
      );

      // Leaning into the way it is going.
      final double heading = to.$1 - from.$1;
      _paintButterfly(
        canvas,
        at,
        size * scale,
        0.25 * heading.sign + 0.15 * flutter,
        // Two wingbeats a second.
        0.5 + 0.5 * math.cos(2 * math.pi * (48 * t + i * 0.29)),
        opacity,
        glowing,
      );
    }
  }

  // Each firefly is a soft halo and a bright point, in the sun or moon's own
  // warm colour so the light in the picture has one source of colour.
  void _paintFireflies(Canvas canvas, double w, double h, double t) {
    for (int i = 0; i < _fireflies.length; i++) {
      final (double x, double y, double r, int lives) = _fireflies[i];
      double life = 0.5;
      int count = 0;
      if (moving) {
        final double run = lives * t + (i * 0.37) % 1;
        life = run % 1;
        // Counted round the loop, so the last life of one loop hands on to
        // the first of the next without a jump.
        count = run.floor() % lives;
      }

      // Lights, swells, fades: brightest halfway through its life.
      final double glow = math.pow(math.sin(math.pi * life), 1.5).toDouble();
      if (glow <= 0.01) continue;

      // Each life starts a short way from the last, picked from a fixed
      // spread so the pattern is the same every loop. The jump happens while
      // it is dark, so nobody sees it.
      final double seed = (i * 7 + count * 13) * 0.618034;
      final Offset home = Offset(
        w * x + ((seed % 1) - 0.5) * 36,
        h * y + (((seed * 1.7) % 1) - 0.5) * 20,
      );
      // Drifts up and a little sideways over its life.
      final Offset at = home +
          Offset(
            8 * math.sin(2 * math.pi * (1.5 * life + i * 0.2)),
            -18 * life,
          );
      final double radius = r * (0.4 + 0.6 * glow);

      canvas
        ..drawCircle(
          at,
          radius * 3,
          Paint()
            ..color = colours.body.withValues(alpha: 0.55 * glow)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
        )
        ..drawCircle(
          at,
          radius,
          Paint()
            ..isAntiAlias = true
            ..color = Color.lerp(colours.body, colours.star, 0.5)!
                .withValues(alpha: glow),
        );
    }
  }

  // A butterfly seen from above: two wide upper wings, two small lower ones,
  // and a thin body, turned by `tilt`. `open` is how far the wings are
  // spread, from 0 (closed, edge on) to 1; `opacity` fades the whole of it.
  void _paintButterfly(Canvas canvas, Offset at, double size, double tilt,
      double open, double opacity, bool glowing) {
    final double spread = 0.25 + 0.75 * open;
    // One layer per butterfly, so its wings and glow fade as one thing
    // rather than showing where they overlap.
    canvas
      ..saveLayer(
        Rect.fromCircle(center: at, radius: size * 3),
        Paint()..color = Color.fromRGBO(0, 0, 0, opacity),
      )
      ..translate(at.dx, at.dy)
      ..rotate(tilt);
    if (glowing) {
      canvas.drawCircle(
        Offset.zero,
        size * 1.4,
        Paint()
          ..color = colours.glow.withValues(alpha: 0.35)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.8),
      );
    }
    final Paint wing = Paint()
      ..isAntiAlias = true
      ..color = glowing ? colours.body : colours.land;
    for (final double side in <double>[-1, 1]) {
      canvas
        ..drawOval(
            Rect.fromCenter(
                center: Offset(side * size * 0.48 * spread, -size * 0.22),
                width: size * 0.9 * spread,
                height: size * 0.72),
            wing)
        ..drawOval(
            Rect.fromCenter(
                center: Offset(side * size * 0.32 * spread, size * 0.32),
                width: size * 0.56 * spread,
                height: size * 0.46),
            wing);
    }
    canvas
      ..drawOval(
          Rect.fromCenter(
              center: Offset.zero, width: size * 0.14, height: size * 0.9),
          Paint()
            ..isAntiAlias = true
            ..color = glowing
                ? Color.lerp(colours.body, colours.glow, 0.6)!
                : colours.grass)
      ..restore();
  }

  @override
  bool shouldRepaint(_LifePainter old) =>
      old.phase != phase ||
      old.colours != colours ||
      old.clock != clock ||
      old.moving != moving;
}
