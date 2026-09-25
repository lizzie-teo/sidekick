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
// | Mountains are ranges, not bumps: uneven peaks with shoulders, a paler range behind a darker one | `_distantRange`, `_farRange` |
// | The moon is a warm gold, lit from one side, with faint darker seas on it | `_paintMoon` |
//
// **The palette does not reach the scene, and that is deliberate.** The
// time of day is a fact about the world: a dawn that went coral in Coral
// diorama and teal in Dusk terrarium would not read as dawn. The palette
// keeps the rest of the page -- the panel under the scene, Tap me, the
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
    (DayPhase.day, Brightness.light): HomeSkyColors(
      top: Color(0xFF8EC2EE),
      bottom: Color(0xFFD4EAFA),
      farHill: Color(0xFF94BDE6),
      land: Color(0xFF6E9CD0),
      body: Color(0xFFFFE27A),
      glow: Color(0xFFFFF3B8),
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
      bottom: Color(0xFF6B4A67),
      farHill: Color(0xFF7B5676),
      land: Color(0xFF9A6C8C),
      body: Color(0xFFE8C98A),
      glow: Color(0xFFD9A77A),
      star: _starlight,
      onSky: _lightText,
    ),
    (DayPhase.day, Brightness.dark): HomeSkyColors(
      top: Color(0xFF17304F),
      bottom: Color(0xFF2F5680),
      farHill: Color(0xFF3C6690),
      land: Color(0xFF4F7CA6),
      body: Color(0xFFE8C66A),
      glow: Color(0xFFB9A060),
      star: _starlight,
      onSky: _lightText,
    ),
    (DayPhase.evening, Brightness.dark): HomeSkyColors(
      top: Color(0xFF241B44),
      bottom: Color(0xFF6E3963),
      farHill: Color(0xFF7C4575),
      land: Color(0xFF99588F),
      body: Color(0xFFE9A36F),
      glow: Color(0xFFC0706A),
      star: _starlight,
      onSky: _lightText,
    ),
    (DayPhase.night, Brightness.dark): HomeSkyColors(
      top: Color(0xFF0E1330),
      bottom: Color(0xFF242C5C),
      farHill: Color(0xFF323B70),
      land: Color(0xFF454F88),
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
class HomeStage extends StatelessWidget {
  final DayPhase phase;
  final double height;
  final Widget child;

  // How far above the foot of the band the crown of the near land sits.
  static const double hillRise = 72;

  const HomeStage({
    super.key,
    required this.phase,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final HomeSkyColors colours =
        HomeSkyColors.of(phase, Theme.of(context).brightness);

    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ExcludeSemantics(
            child: CustomPaint(
              painter: _StagePainter(phase: phase, colours: colours),
            ),
          ),
          Align(alignment: Alignment.bottomCenter, child: child),
        ],
      ),
    );
  }
}

class _StagePainter extends CustomPainter {
  final DayPhase phase;
  final HomeSkyColors colours;

  const _StagePainter({required this.phase, required this.colours});

  // Where the stars sit, as fractions of the band, with a radius each.
  // Fixed, so the sky is the same every night rather than a new scatter on
  // every rebuild.
  static const List<(double, double, double)> _stars =
      <(double, double, double)>[
    (0.06, 0.12, 1.6),
    (0.14, 0.40, 1.2),
    (0.24, 0.08, 1.4),
    (0.36, 0.26, 1.0),
    (0.62, 0.06, 1.2),
    (0.70, 0.34, 1.6),
    (0.93, 0.44, 1.2),
    (0.97, 0.08, 1.0),
  ];

  // The two mountain ranges, as (share of the width, height above the foot
  // of the band). Uneven on purpose: a real range has a tallest peak,
  // shoulders beside it and saddles between, and never two peaks the same.
  // The range behind is taller and paler, which is what makes it read as
  // further away.
  static const List<(double, double)> _distantRange = <(double, double)>[
    (0.00, 150),
    (0.12, 190),
    (0.19, 174),
    (0.30, 218),
    (0.44, 158),
    (0.56, 194),
    (0.66, 226),
    (0.80, 172),
    (0.90, 198),
    (1.00, 180),
  ];

  static const List<(double, double)> _farRange = <(double, double)>[
    (0.00, 126),
    (0.10, 150),
    (0.15, 142),
    (0.24, 180),
    (0.38, 118),
    (0.50, 106),
    (0.62, 140),
    (0.74, 178),
    (0.78, 170),
    (0.88, 136),
    (1.00, 152),
  ];

  // How high the near land still is at the edges of the screen.
  static const double hillRiseAtEdge = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Paint paint = Paint()..isAntiAlias = true;

    // The sun or moon first, so it sits behind the peaks.
    final (Offset centre, double radius) = switch (phase) {
      DayPhase.morning => (Offset(w * 0.18, h * 0.56), 30.0),
      DayPhase.day => (Offset(w * 0.82, h * 0.16), 28.0),
      DayPhase.evening => (Offset(w * 0.78, h * 0.60), 40.0),
      DayPhase.night => (Offset(w * 0.74, h - 212), 36.0),
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

    // The range behind: the far hills' colour taken halfway back into the
    // sky, so it sits between the two without a third colour to keep.
    final Color horizon =
        Color.lerp(colours.top, colours.bottom, HomeSkyColors.horizonAt)!;
    paint.color = Color.lerp(colours.farHill, horizon, 0.5)!;
    canvas.drawPath(_range(_distantRange, w, h), paint);

    paint.color = colours.farHill;
    canvas.drawPath(_range(_farRange, w, h), paint);

    // The near land: a low crown in the middle, falling away to both edges.
    final Path near = Path()
      ..moveTo(0, h - hillRiseAtEdge)
      ..quadraticBezierTo(w / 2, h - HomeStage.hillRise * 2 + hillRiseAtEdge, w,
          h - hillRiseAtEdge)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    paint.color = colours.land;
    canvas.drawPath(near, paint);
  }

  // A ridge line through the points, closed down to the foot of the band.
  // Each slope bows inward, the way a real mountainside steepens towards its
  // top, so the peaks stay pointed. A smooth curve through the points would
  // melt the range back into hills; straight lines read as a zigzag.
  Path _range(List<(double, double)> ridge, double w, double h) {
    final Path path = Path()
      ..moveTo(0, h)
      ..lineTo(0, h - ridge.first.$2);
    for (int i = 1; i < ridge.length; i++) {
      final Offset from = Offset(w * ridge[i - 1].$1, h - ridge[i - 1].$2);
      final Offset to = Offset(w * ridge[i].$1, h - ridge[i].$2);
      final double sag = (to.dy - from.dy).abs() * 0.3;
      path.quadraticBezierTo(
          (from.dx + to.dx) / 2, (from.dy + to.dy) / 2 + sag, to.dx, to.dy);
    }
    return path
      ..lineTo(w, h)
      ..close();
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
