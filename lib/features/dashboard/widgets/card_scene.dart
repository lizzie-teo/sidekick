import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

// The picture on the Mindfulness card: one of seventeen quiet fantasy
// landscapes, drawn in code in the Alto's Odyssey manner Home's own scene
// uses. Built 26 September 2026, at the user's request. The dawn pond, the
// snow tree and the pastel shore came the same afternoon, from references
// the user brought; the seed tree, the temple steps, the geese and the
// night sail were taken out after a look at the whole set. The last nine -- the
// cabin island to the night hills -- came later that day from a second set
// of eighteen references: Alto's Odyssey, Journey and flat vector
// landscapes.
//
// **A mood, not a match.** The card's prompt names one small thing -- your
// hands, a glass of water -- and a picture of that failed on 26 September
// 2026: four prompts shared one hand, and the set had more steps than honest
// pictures. A landscape does not try to show the prompt, so it cannot show it
// wrongly. It sets the room the words are read in.
//
// **One scene a day, picked by the date, never by the open.** It reads as
// random across a week and stays put within a day, which is the same promise
// the prompt makes: coming back finds the same card, not a card that was
// missed.
//
// **The palette does not reach the scene**, for the reason Home's sky gives:
// a dusk that went teal in Dusk terrarium would not read as dusk. The hex
// literals below are the decision, not a leak. No words sit on the picture,
// so no pair here carries a contrast floor; the back's one line is held to
// 4.5:1 in `test/card_scene_test.dart`.
//
// **Light or dark still reaches it.** A pale dawn opened on a dark phone is a
// lamp. `dim()` takes the sky and the land down and leaves the lights -- the
// sun, the lanterns, the seeds -- where they are, so they glow more, not less.
//
// **Every scene is alive, slowly.** Added 26 September 2026, at the user's
// request, once movement under words was allowed. Each scene has the one or
// two living things that belong in it -- lanterns rising, snow, petals, gulls,
// seeds, fireflies -- on one 24-second loop (`CardScenePicture.loop`). The
// lights shimmer rather than blink. Reduce Motion stops it on a still frame
// where every creature is present. The back has its own, quieter loop.
enum CardScene {
  lanternLake,
  floatingIslands,
  duskWaves,
  auroraValley,
  blossomTerraces,
  lighthouseCliffs,
  dawnPond,
  snowTree,
  pastelShore,
  cabinIsland,
  desertBeacon,
  boatmanSunset,
  moonBoat,
  toriiPeaks,
  snowSlope,
  desertRuins,
  nightHills;

  // The day's scene. Counted in UTC days from a fixed date, so a clock change
  // cannot skip or repeat one, and wrapped so it never runs out.
  static CardScene forDay(DateTime day) {
    final int days = DateTime.utc(day.year, day.month, day.day)
        .difference(DateTime.utc(2026))
        .inDays;
    return values[days % values.length];
  }

  CardSceneColours colours(Brightness brightness) {
    final CardSceneColours light = CardSceneColours._light[this]!;
    return brightness == Brightness.dark ? light.dim() : light;
  }

  // **The part of the picture that must stay in sight**, as fractions of its
  // height, top then bottom. Added 26 September 2026, when the card's words
  // moved onto glass over the foot of the picture: the seventeen scenes keep
  // their subject in different places -- the torii at the very bottom, the
  // lighthouse near the top -- so one fixed crop hid a different thing on
  // each card. The card places the picture so this band clears the glass
  // (`PauseSheet.pictureRect`).
  //
  // Read off each scene drawn at full card size. The band holds the subject
  // and the sun or moon; plain sky above it and plain water or land below it
  // are what may go. **A new scene needs one**, and a subject moved in the
  // painter means moving its band too.
  ({double top, double bottom}) get focus => switch (this) {
        lanternLake => (top: 0.15, bottom: 0.75),
        floatingIslands => (top: 0.15, bottom: 0.70),
        duskWaves => (top: 0.27, bottom: 0.75),
        auroraValley => (top: 0.10, bottom: 0.72),
        blossomTerraces => (top: 0.15, bottom: 0.72),
        lighthouseCliffs => (top: 0.18, bottom: 0.60),
        dawnPond => (top: 0.02, bottom: 0.85),
        snowTree => (top: 0.40, bottom: 0.78),
        pastelShore => (top: 0.35, bottom: 0.76),
        cabinIsland => (top: 0.28, bottom: 0.64),
        desertBeacon => (top: 0.10, bottom: 0.58),
        boatmanSunset => (top: 0.35, bottom: 0.72),
        moonBoat => (top: 0.25, bottom: 0.68),
        toriiPeaks => (top: 0.10, bottom: 0.92),
        snowSlope => (top: 0.12, bottom: 0.80),
        desertRuins => (top: 0.08, bottom: 0.94),
        nightHills => (top: 0.10, bottom: 0.87),
      };
}

class CardSceneColours {
  final Color skyTop;
  final Color skyBottom;

  // The far range, the near range, and the ground at the front. Each is
  // further from the sky than the one behind it.
  final Color far;
  final Color near;
  final Color ground;

  // The sun or moon, and the soft light around it.
  final Color body;
  final Color glow;

  // The one small light the scene is about: a lantern, a seed, the aurora.
  final Color accent;

  // The card's back. Always deep, in both modes, so the one line on it is
  // near-white everywhere and the gold pattern reads as gold.
  final Color deep;

  // Cloud and mist. The same as `glow` in light mode; taken down in dark
  // mode, where a white cloud bank is the lamp `dim()` exists to prevent.
  final Color? _mist;
  Color get mist => _mist ?? glow;

  // The band of sky just above the land, where the light is warmest. Added
  // 26 September 2026: a two-stop sky read as a flat wash behind the hills,
  // and Alto's skies always warm at the foot.
  final Color? _horizon;
  Color get horizon => _horizon ?? skyBottom;

  final bool night;

  const CardSceneColours({
    required this.skyTop,
    required this.skyBottom,
    required this.far,
    required this.near,
    required this.ground,
    required this.body,
    required this.glow,
    required this.accent,
    required this.deep,
    this.night = false,
    Color? mist,
    Color? horizon,
  })  : _mist = mist,
        _horizon = horizon;

  // The words on the back. Near-white, the same as Home's night sky.
  static const Color onDeep = Color(0xFFFBF8F2);

  // The dark-mode version: the sky and the land taken down, the lights left
  // alone. A night scene is already dark, so it moves less.
  //
  // **Darker is also greyer.** Taking a pastel's lightness down on its own
  // leaves its saturation where it was, and a pale pink became a hot red: the
  // first pass read as a sunset poster, not a quiet room. The saturation
  // comes down with it.
  CardSceneColours dim() {
    final double by = night ? 0.8 : 0.5;
    final double grey = night ? 0.9 : 0.55;
    // **A day scene also leans a little towards its own deep colour.** A
    // pale yellow taken down on its own turned mustard -- the blossom
    // morning's sky read as old brass. A step towards the scene's own plum
    // or navy keeps it in the family.
    Color down(Color c) {
      final HSLColor hsl = HSLColor.fromColor(c);
      final Color taken = hsl
          .withLightness(hsl.lightness * by)
          .withSaturation(hsl.saturation * grey)
          .toColor();
      return night ? taken : Color.lerp(taken, deep, 0.3)!;
    }

    return CardSceneColours(
      skyTop: down(skyTop),
      skyBottom: down(skyBottom),
      far: down(far),
      near: down(near),
      ground: down(ground),
      body: body,
      glow: glow,
      accent: accent,
      deep: deep,
      night: night,
      horizon: down(horizon),
      // Mist in the dark is the sky's own colour a little lifted. A white
      // taken down went mustard, which no mist has ever been.
      mist: night ? mist : Color.lerp(down(skyBottom), glow, 0.3),
    );
  }

  static const Map<CardScene, CardSceneColours> _light =
      <CardScene, CardSceneColours>{
    // A still lake at night, with lanterns in the air and on the water.
    CardScene.lanternLake: CardSceneColours(
      skyTop: Color(0xFF1F2560),
      skyBottom: Color(0xFF5B4E98),
      horizon: Color(0xFFA0729F),
      far: Color(0xFF4A4B8C),
      near: Color(0xFF2A2C5E),
      ground: Color(0xFF1E2048),
      body: Color(0xFFF6D58E),
      glow: Color(0xFFF2C07A),
      accent: Color(0xFFFFB35C),
      deep: Color(0xFF1B1D42),
      night: true,
    ),
    // Islands floating over a sea of cloud, a pine or two on each.
    CardScene.floatingIslands: CardSceneColours(
      skyTop: Color(0xFF6FB3E8),
      skyBottom: Color(0xFFC9D8F2),
      horizon: Color(0xFFFBE0DA),
      far: Color(0xFFA7B2E0),
      near: Color(0xFF6A78C2),
      ground: Color(0xFF4E5AA3),
      body: Color(0xFFFFD36B),
      glow: Color(0xFFFFF8EC),
      accent: Color(0xFFFFFFFF),
      deep: Color(0xFF27305F),
    ),
    // Waves at dusk under a big low sun, a paper boat riding them.
    CardScene.duskWaves: CardSceneColours(
      skyTop: Color(0xFF7A5EC0),
      skyBottom: Color(0xFFE9A6B4),
      horizon: Color(0xFFFFC28F),
      far: Color(0xFFC98AA8),
      near: Color(0xFFB0708F),
      ground: Color(0xFF8A5277),
      body: Color(0xFFFFE0A8),
      glow: Color(0xFFFFC98C),
      accent: Color(0xFFFFD27A),
      deep: Color(0xFF3A2447),
    ),
    // An open snowfield under the northern lights. The snow is moonlit
    // blue-grey and the sky's foot a step darker, from 26 September 2026:
    // the near-white field read as too light at the horizon.
    CardScene.auroraValley: CardSceneColours(
      skyTop: Color(0xFF0E2238),
      skyBottom: Color(0xFF26506A),
      horizon: Color(0xFF2F5E70),
      far: Color(0xFF3F6D82),
      near: Color(0xFF1D3A4C),
      ground: Color(0xFFA9C2CF),
      body: Color(0xFFEAF4F2),
      glow: Color(0xFFBFEFE0),
      accent: Color(0xFF7FE3B8),
      deep: Color(0xFF0F2436),
      night: true,
    ),
    // Blossom trees on terraced hills, in morning mist.
    // The top is peach rather than lemon: a lemon taken down for dark mode
    // went to old brass, whatever it was leaned towards.
    CardScene.blossomTerraces: CardSceneColours(
      skyTop: Color(0xFFFCDCBA),
      skyBottom: Color(0xFFF6C9D2),
      horizon: Color(0xFFFFE2D6),
      far: Color(0xFFE0A9BF),
      near: Color(0xFFC27E9E),
      ground: Color(0xFFA0617F),
      body: Color(0xFFFFA9A8),
      glow: Color(0xFFFFF4E4),
      accent: Color(0xFFFFD3E0),
      deep: Color(0xFF4A2A3E),
    ),
    // A lighthouse on a pink cliff over a quiet sea.
    CardScene.lighthouseCliffs: CardSceneColours(
      skyTop: Color(0xFFE995B0),
      skyBottom: Color(0xFFFFCFB4),
      horizon: Color(0xFFFFE4C0),
      far: Color(0xFFD98FA6),
      near: Color(0xFF9C5A7E),
      ground: Color(0xFF7A4264),
      body: Color(0xFFFFE6B8),
      glow: Color(0xFFFFF1DA),
      accent: Color(0xFFE8707E),
      deep: Color(0xFF3D2238),
    ),
    // A still pond in a pine forest at dawn, a snow peak mirrored in it, a
    // blossom branch overhead and one small boat. The user's first ask, and
    // the Fuji-lake reference she brought.
    // The pinks lean violet: a warmer pink taken down for dark mode went to
    // brick red.
    CardScene.dawnPond: CardSceneColours(
      skyTop: Color(0xFFE6B6D0),
      skyBottom: Color(0xFFF3CDD6),
      horizon: Color(0xFFFFE2D4),
      far: Color(0xFFB4A5D8),
      near: Color(0xFF6B6C9E),
      ground: Color(0xFF4A4A7C),
      body: Color(0xFFFFF1DC),
      glow: Color(0xFFFFF6EE),
      accent: Color(0xFFFFD4E2),
      deep: Color(0xFF2F2650),
    ),
    // One blossom tree alone on a wide snowfield, a small snow peak far off.
    CardScene.snowTree: CardSceneColours(
      skyTop: Color(0xFF86BEEA),
      skyBottom: Color(0xFFD2D3EF),
      horizon: Color(0xFFF2CCDB),
      far: Color(0xFF9EABDF),
      near: Color(0xFF6A79C0),
      ground: Color(0xFFCFE4F3),
      body: Color(0xFFFFF4DA),
      glow: Color(0xFFFFFBF2),
      accent: Color(0xFFFBE6F0),
      deep: Color(0xFF27305E),
    ),
    // A lilac shore at dawn, peach clouds, and a crane standing in the
    // shallows.
    CardScene.pastelShore: CardSceneColours(
      skyTop: Color(0xFFA8A2CC),
      skyBottom: Color(0xFFE6C4CC),
      horizon: Color(0xFFFBE2D0),
      far: Color(0xFFB4A7D2),
      near: Color(0xFF8A81B8),
      ground: Color(0xFF5B5590),
      body: Color(0xFFFFE8C4),
      glow: Color(0xFFFFF4E6),
      accent: Color(0xFFF3B39E),
      deep: Color(0xFF2E2A4E),
    ),
    // A log cabin on a rock island, pale pines round it, a big pale sun
    // behind, and all of it mirrored in a still pink lake.
    CardScene.cabinIsland: CardSceneColours(
      skyTop: Color(0xFF8FA3C8),
      skyBottom: Color(0xFFE6B4C8),
      horizon: Color(0xFFF6D2D8),
      far: Color(0xFFC9A9CC),
      near: Color(0xFFA98BB8),
      ground: Color(0xFF7C8AB2),
      body: Color(0xFFFFF4C4),
      glow: Color(0xFFFFF8E4),
      accent: Color(0xFFFFD66B),
      deep: Color(0xFF2F2A4E),
    ),
    // Journey's colours: empty dunes and a ringed planet rising behind
    // them. The sky is teal, the sand warm. The walker, then a boy and his
    // dog, were taken out on 26 September 2026 at the user's request.
    CardScene.desertBeacon: CardSceneColours(
      skyTop: Color(0xFF3E9C9A),
      skyBottom: Color(0xFF7CC4BA),
      horizon: Color(0xFFCFE8DE),
      far: Color(0xFF94BBB4),
      near: Color(0xFFE2B8A0),
      ground: Color(0xFFC99A80),
      body: Color(0xFFFFFFF4),
      glow: Color(0xFFF4FFF8),
      accent: Color(0xFFFFFFFF),
      deep: Color(0xFF1C3448),
    ),
    // A boatman poling across a warm lake under a huge setting sun, a
    // tower of cloud behind it and the first stars out.
    CardScene.boatmanSunset: CardSceneColours(
      skyTop: Color(0xFF9A5A70),
      skyBottom: Color(0xFFE89A7E),
      horizon: Color(0xFFFFD4A2),
      far: Color(0xFFE0A082),
      near: Color(0xFFD48A6C),
      ground: Color(0xFFB06858),
      body: Color(0xFFFFFBF0),
      glow: Color(0xFFFFE8C8),
      accent: Color(0xFFFFF0CC),
      deep: Color(0xFF4A2432),
    ),
    // A crescent boat with one small figure and a lantern, under a full
    // moon sitting on a still violet sea.
    CardScene.moonBoat: CardSceneColours(
      skyTop: Color(0xFF2A2248),
      skyBottom: Color(0xFF4E3F78),
      horizon: Color(0xFF6E5A92),
      far: Color(0xFF7E6CA6),
      near: Color(0xFF5A4A86),
      ground: Color(0xFF3A2E5E),
      body: Color(0xFFF7EBD8),
      glow: Color(0xFFE8DAF0),
      accent: Color(0xFFF6C4D4),
      deep: Color(0xFF1E1838),
      night: true,
    ),
    // A torii gate at the foot of tall violet peaks, a pale sun, and a
    // long line of birds crossing a pink morning. The pink leans violet: a
    // warmer one went to brick red in dark mode.
    CardScene.toriiPeaks: CardSceneColours(
      skyTop: Color(0xFFE4B2CC),
      skyBottom: Color(0xFFF2CAD4),
      horizon: Color(0xFFFCE2DC),
      far: Color(0xFFC8AAD8),
      near: Color(0xFF9A7ACA),
      ground: Color(0xFF4A2E72),
      body: Color(0xFFF8E6E8),
      glow: Color(0xFFFFF4F0),
      accent: Color(0xFFFFFFFF),
      deep: Color(0xFF2C1E48),
    ),
    // A long snowy slope under lilac ranges: pale pines with dark bands,
    // their shadows laid across the snow, and snow falling.
    CardScene.snowSlope: CardSceneColours(
      skyTop: Color(0xFFB4C6E8),
      skyBottom: Color(0xFFDCD8F0),
      horizon: Color(0xFFF4E0E6),
      far: Color(0xFFC0B2D8),
      near: Color(0xFF8E80B8),
      ground: Color(0xFFF2F0F8),
      body: Color(0xFFFFF6E8),
      glow: Color(0xFFFFFBF4),
      accent: Color(0xFFFFFFFF),
      deep: Color(0xFF2E2E58),
    ),
    // A far city under a gigantic ringed planet, a high bridge over a
    // still pool, and a boat.
    CardScene.desertRuins: CardSceneColours(
      skyTop: Color(0xFF8E5E8A),
      skyBottom: Color(0xFFE890A2),
      horizon: Color(0xFFF6B8B2),
      far: Color(0xFFB27C9C),
      near: Color(0xFF8E5A7C),
      ground: Color(0xFF5A2E44),
      body: Color(0xFFFCE8E8),
      glow: Color(0xFFFFD8DE),
      accent: Color(0xFFFFE0E8),
      deep: Color(0xFF3A1E30),
    ),
    // Rolling violet hills at night with small lit houses on them, a
    // crescent moon, a far ringed planet, shooting stars and birds.
    CardScene.nightHills: CardSceneColours(
      skyTop: Color(0xFF2A2458),
      skyBottom: Color(0xFF5A4E90),
      horizon: Color(0xFF7A6AA8),
      far: Color(0xFF6A5EA0),
      near: Color(0xFF4E4488),
      ground: Color(0xFF2E2860),
      body: Color(0xFFF4F0FF),
      glow: Color(0xFFD8D0F8),
      accent: Color(0xFFE6A4B8),
      deep: Color(0xFF1C1840),
      night: true,
    ),
  };
}

// Stops or starts a looping clock with the system's Reduce Motion setting.
// Shared by the picture and the back, so both answer it the same way.
void _followReduceMotion(BuildContext context, AnimationController clock) {
  if (MediaQuery.disableAnimationsOf(context)) {
    clock.stop();
  } else if (!clock.isAnimating) {
    clock.repeat();
  }
}

double _wave(double t, int perLoop, double phase) =>
    math.sin(2 * math.pi * (perLoop * t + phase));

// The picture. Decoration: a screen reader is given the words, not this.
//
// Three layers, each its own `RepaintBoundary`: the sky (it moves only at
// night, where the stars twinkle and the aurora ripples), the land (never
// moves, so it is painted once), and the life in front of it.
class CardScenePicture extends StatefulWidget {
  final CardScene scene;

  // One loop of everything that moves. Every rate in it is a whole number of
  // times per loop, so the end meets the start and nothing jumps.
  static const Duration loop = Duration(seconds: 24);

  const CardScenePicture({super.key, required this.scene});

  @override
  State<CardScenePicture> createState() => _CardScenePictureState();
}

class _CardScenePictureState extends State<CardScenePicture>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock =
      AnimationController(vsync: this, duration: CardScenePicture.loop);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _followReduceMotion(context, _clock);
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CardSceneColours c =
        widget.scene.colours(Theme.of(context).brightness);
    final bool moving = !MediaQuery.disableAnimationsOf(context);
    return ExcludeSemantics(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          RepaintBoundary(
            child: CustomPaint(
              painter:
                  _SkyPainter(widget.scene, c, clock: _clock, moving: moving),
            ),
          ),
          RepaintBoundary(
            child: CustomPaint(painter: _ScenePainter(widget.scene, c)),
          ),
          RepaintBoundary(
            child: CustomPaint(
              painter:
                  _LifePainter(widget.scene, c, clock: _clock, moving: moving),
            ),
          ),
        ],
      ),
    );
  }
}

// The card's back: a lotus medallion in fine gold line, set in a beaded
// double frame with a flourish in each corner, over a faint field of stars.
// Redrawn 26 September 2026, at the user's request: the first back was a sun
// holding a crescent moon, and it read as plain and as a second moon beside
// the moons in the scenes.
//
// **It is symmetric top to bottom, like a printed tarot back**, so it has no
// right way up -- except for the clear band at `hintBand`, where the one line
// sits. Nothing is drawn across it, so the line is read on the deep colour
// alone and its 4.5:1 test stays honest.
//
// The same on every day but for the colour, so the back is recognisably
// *the* card. Gold is the scene's `body`; the one jewel at the centre is its
// `accent`, which is the only thing that tells today's card from tomorrow's
// before the turn.
//
// The parts that move -- the ring of rays, the sparkles, the jewel's glow --
// are `CardBackLifePainter`, painted over this one.
class CardBackPainter extends CustomPainter {
  final CardSceneColours c;

  const CardBackPainter(this.c);

  // Where the hint line sits, as a share of the height. `_Back` aligns the
  // text at 0.62, which is 81% of the way down.
  static const double hintBand = 0.81;

  static Offset centreOf(Size size) =>
      Offset(size.width / 2, size.height * 0.42);
  static double radiusOf(Size size) =>
      math.min(size.width * 0.36, size.height * 0.24);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final Rect all = Offset.zero & size;

    // The ground: the deep colour, a touch lighter behind the medallion and
    // a touch darker at the corners, like a printed card under a lamp.
    final Offset centre = centreOf(size);
    final double lift = math.min(w, h) * 0.75;
    canvas.drawRect(all, Paint()..color = c.deep);
    canvas.drawRect(
      all,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            c.body.withValues(alpha: 0.12),
            c.body.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: centre, radius: lift)),
    );
    canvas.drawRect(
      all,
      Paint()
        ..shader = RadialGradient(
          radius: 0.9,
          colors: <Color>[
            Colors.transparent,
            Color.lerp(c.deep, const Color(0xFF000000), 0.35)!
                .withValues(alpha: 0.6),
          ],
          stops: const <double>[0.6, 1],
        ).createShader(all),
    );

    _stars(canvas, size);
    _frame(canvas, size);
    _medallion(canvas, centre, radiusOf(size));

    // A small finial above the medallion and one below the hint, so the
    // column reads top to bottom and the line sits inside the design.
    _finial(canvas, Offset(w / 2, h * 0.115), 1);
    _finial(canvas, Offset(w / 2, h * 0.905), -1);
  }

  Paint _gold(double alpha, [double width = 1]) => Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..color = c.body.withValues(alpha: alpha);

  Paint _goldFill(double alpha) => Paint()
    ..isAntiAlias = true
    ..color = c.body.withValues(alpha: alpha);

  // A faint scatter of pin-point stars, kept off the hint band. Seeded, so
  // the same stars are in the same places every time.
  void _stars(Canvas canvas, Size size) {
    final math.Random rng = math.Random(7);
    final Paint dot = _goldFill(0.35);
    for (int i = 0; i < 70; i++) {
      final double x = 28 + rng.nextDouble() * (size.width - 56);
      final double y = 28 + rng.nextDouble() * (size.height - 56);
      final double r = 0.4 + rng.nextDouble() * 0.9;
      if ((y / size.height - hintBand).abs() < 0.05) continue;
      canvas.drawCircle(Offset(x, y), r, dot);
    }
  }

  // Two frames with a line of beads between them, and a flourish in each
  // corner.
  void _frame(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    const double outer = 12;
    const double inner = 22;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(outer, outer, w - outer * 2, h - outer * 2),
            const Radius.circular(14)),
        _gold(0.75, 1.2));
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(inner, inner, w - inner * 2, h - inner * 2),
            const Radius.circular(8)),
        _gold(0.45, 0.8));

    // Beads between the frames, spaced evenly along each straight edge.
    const double mid = (outer + inner) / 2;
    final Paint bead = _goldFill(0.55);
    const double step = 9;
    for (double x = 44; x <= w - 44; x += step) {
      canvas.drawCircle(Offset(x, mid), 0.9, bead);
      canvas.drawCircle(Offset(x, h - mid), 0.9, bead);
    }
    for (double y = 44; y <= h - 44; y += step) {
      canvas.drawCircle(Offset(mid, y), 0.9, bead);
      canvas.drawCircle(Offset(w - mid, y), 0.9, bead);
    }

    // One flourish drawn in the top-left corner and mirrored into the
    // other three, so the four always match.
    for (final (double sx, double sy) in <(double, double)>[
      (1, 1),
      (-1, 1),
      (1, -1),
      (-1, -1),
    ]) {
      canvas.save();
      canvas.translate(sx > 0 ? 0 : w, sy > 0 ? 0 : h);
      canvas.scale(sx, sy);
      _corner(canvas);
      canvas.restore();
    }
  }

  // A corner: a quarter-circle held inside the frame, two scrolls running
  // off it along the edges, and a small diamond at the point.
  void _corner(Canvas canvas) {
    const Offset o = Offset(22, 22);
    final Paint line = _gold(0.8, 1);
    canvas.drawArc(
        Rect.fromCircle(center: o, radius: 16), 0, math.pi / 2, false, line);
    canvas.drawArc(Rect.fromCircle(center: o, radius: 22), 0, math.pi / 2,
        false, _gold(0.4, 0.8));

    // Two sprigs, one along each edge: a stem just inside the frame, two
    // small leaves turned in towards the card, and a bead at the end.
    for (final bool alongX in <bool>[true, false]) {
      Offset p(double a, double b) =>
          alongX ? Offset(o.dx + a, o.dy + b) : Offset(o.dx + b, o.dy + a);
      canvas.drawLine(p(20, 6), p(54, 6), _gold(0.6, 0.8));
      for (final double at in <double>[30, 44]) {
        final double angle = alongX ? math.pi * 0.3 : math.pi * 0.2;
        _petal(canvas, p(at, 6), angle, 0, 9, 1.8,
            stroke: _gold(0.75, 0.8), fill: _goldFill(0.3), vein: false);
      }
      canvas.drawCircle(p(58, 6), 1.3, _goldFill(0.8));
    }

    final Offset d = o + const Offset(9, 9);
    final Path diamond = Path()
      ..moveTo(d.dx, d.dy - 5)
      ..lineTo(d.dx + 3.5, d.dy)
      ..lineTo(d.dx, d.dy + 5)
      ..lineTo(d.dx - 3.5, d.dy)
      ..close();
    canvas.save();
    canvas.translate(d.dx, d.dy);
    canvas.rotate(-math.pi / 4);
    canvas.translate(-d.dx, -d.dy);
    canvas.drawPath(diamond, _goldFill(0.85));
    canvas.restore();
  }

  // The medallion, outside in: a beaded ring, twelve open lotus petals,
  // eight closed ones, an eight-point star, and a small flower of six circles
  // round the jewel. The ring of rays outside it turns, so it is in
  // `CardBackLifePainter`.
  void _medallion(Canvas canvas, Offset o, double r) {
    // A soft fill inside the ring, so the medallion reads as a disc of its
    // own rather than lines on the ground.
    canvas.drawCircle(
      o,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            c.body.withValues(alpha: 0.10),
            c.body.withValues(alpha: 0.03),
          ],
        ).createShader(Rect.fromCircle(center: o, radius: r)),
    );

    // The beaded ring.
    canvas.drawCircle(o, r, _gold(0.8, 1.1));
    canvas.drawCircle(o, r * 0.93, _gold(0.5, 0.7));
    for (int i = 0; i < 48; i++) {
      final double a = i * math.pi / 24;
      canvas.drawCircle(o + Offset(math.cos(a), math.sin(a)) * r * 0.965, 0.9,
          _goldFill(0.7));
    }

    // Twelve open petals, outlined, each with a vein.
    for (int i = 0; i < 12; i++) {
      final double a = i * math.pi / 6 - math.pi / 2;
      _petal(canvas, o, a, r * 0.34, r * 0.88, r * 0.1,
          stroke: _gold(0.75, 1), fill: _goldFill(0.06), vein: true);
    }
    // Eight closed petals over them, offset half a step, fuller.
    for (int i = 0; i < 8; i++) {
      final double a = i * math.pi / 4 - math.pi / 2 + math.pi / 8;
      _petal(canvas, o, a, r * 0.24, r * 0.64, r * 0.085,
          stroke: _gold(0.9, 1), fill: _goldFill(0.16), vein: false);
    }

    // The eight-point star: two squares turned an eighth apart.
    final Paint starLine = _gold(0.9, 1);
    for (int k = 0; k < 2; k++) {
      final Path sq = Path();
      for (int i = 0; i < 4; i++) {
        final double a = k * math.pi / 4 + i * math.pi / 2 - math.pi / 2;
        final Offset p = o + Offset(math.cos(a), math.sin(a)) * r * 0.3;
        i == 0 ? sq.moveTo(p.dx, p.dy) : sq.lineTo(p.dx, p.dy);
      }
      sq.close();
      canvas.drawPath(sq, starLine);
    }
    canvas.drawCircle(o, r * 0.22, Paint()..color = c.deep);
    canvas.drawCircle(o, r * 0.22, _gold(0.9, 1));

    // Six circles round the centre, each passing through it: the old
    // six-petal rosette.
    final double k = r * 0.1;
    final Paint rosette = _gold(0.75, 0.8);
    for (int i = 0; i < 6; i++) {
      final double a = i * math.pi / 3;
      canvas.drawCircle(o + Offset(math.cos(a), math.sin(a)) * k, k, rosette);
    }

    // The jewel: the day's own accent, with a gold rim.
    canvas.drawCircle(o, r * 0.05, Paint()..color = c.accent);
    canvas.drawCircle(o, r * 0.05, _gold(0.9, 0.8));
  }

  // One petal: a pointed leaf from `inner` to `outer` along angle `a`.
  void _petal(Canvas canvas, Offset o, double a, double inner, double outer,
      double width,
      {required Paint stroke, required Paint fill, required bool vein}) {
    final Offset dir = Offset(math.cos(a), math.sin(a));
    final Offset side = Offset(-dir.dy, dir.dx);
    final Offset base = o + dir * inner;
    final Offset tip = o + dir * outer;
    final Offset mid = o + dir * (inner + (outer - inner) * 0.45);
    final Path leaf = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo((mid + side * width * 2).dx,
          (mid + side * width * 2).dy, tip.dx, tip.dy)
      ..quadraticBezierTo((mid - side * width * 2).dx,
          (mid - side * width * 2).dy, base.dx, base.dy)
      ..close();
    canvas.drawPath(leaf, fill);
    canvas.drawPath(leaf, stroke);
    if (vein) {
      canvas.drawLine(base + dir * (outer - inner) * 0.15,
          tip - dir * (outer - inner) * 0.2, _gold(0.4, 0.7));
    }
  }

  // A finial: a small diamond on a stem between two curls. `up` is 1 above
  // the medallion and -1 below, so the pair mirror each other.
  void _finial(Canvas canvas, Offset at, double up) {
    final Paint line = _gold(0.75, 1);
    canvas.drawLine(at + const Offset(-26, 0), at + const Offset(-8, 0), line);
    canvas.drawLine(at + const Offset(8, 0), at + const Offset(26, 0), line);
    for (final double s in <double>[-1, 1]) {
      final Path curl = Path()
        ..moveTo(at.dx + s * 26, at.dy)
        ..quadraticBezierTo(
            at.dx + s * 34, at.dy, at.dx + s * 34, at.dy + up * 5)
        ..quadraticBezierTo(
            at.dx + s * 34, at.dy + up * 9, at.dx + s * 30, at.dy + up * 8);
      canvas.drawPath(curl, line);
      canvas.drawCircle(at + Offset(s * 40, 0), 1.3, _goldFill(0.8));
    }
    final Path diamond = Path()
      ..moveTo(at.dx, at.dy - 7)
      ..lineTo(at.dx + 5, at.dy)
      ..lineTo(at.dx, at.dy + 7)
      ..lineTo(at.dx - 5, at.dy)
      ..close();
    canvas.drawPath(diamond, _goldFill(0.18));
    canvas.drawPath(diamond, line);
    canvas.drawCircle(at, 1.6, Paint()..color = c.accent);
  }

  @override
  bool shouldRepaint(CardBackPainter old) => old.c != c;
}

// What moves on the back, on its own 24-second loop:
//
// | Part | How | Per loop |
// | --- | --- | --- |
// | The ring of rays | Turns an eighth of a circle. The ring repeats every eighth, so the end is the start. Its eight beads stay put: they sit at the frame | 1 |
// | Six gold sparkles | Swell and fade, each on its own beat | 1 or 2 |
// | Twelve pin-point stars | Twinkle | 1 to 3 |
// | The jewel | A glow in its own colour breathes round it | 1 |
//
// Nothing crosses the hint band. Under Reduce Motion it is a printed card:
// the ring still, every sparkle at full size.
class CardBackLifePainter extends CustomPainter {
  final CardSceneColours c;
  final Animation<double> clock;
  final bool moving;

  CardBackLifePainter(this.c, {required this.clock, required this.moving})
      : super(repaint: clock);

  static const List<(double, double, double)> _sparkles =
      <(double, double, double)>[
    (0.20, 0.20, 5),
    (0.80, 0.20, 5),
    (0.14, 0.60, 4),
    (0.86, 0.60, 4),
    (0.26, 0.72, 3),
    (0.74, 0.72, 3),
  ];

  static final List<(double, double)> _twinkles = () {
    final math.Random rng = math.Random(31);
    final List<(double, double)> out = <(double, double)>[];
    while (out.length < 12) {
      final double x = 0.1 + rng.nextDouble() * 0.8;
      final double y = 0.08 + rng.nextDouble() * 0.84;
      if ((y - CardBackPainter.hintBand).abs() < 0.06) continue;
      // Clear of the medallion, which has sparkle enough.
      if ((Offset(x, y * 1.7) - const Offset(0.5, 0.42 * 1.7)).distance <
          0.42) {
        continue;
      }
      out.add((x, y));
    }
    return out;
  }();

  @override
  void paint(Canvas canvas, Size size) {
    final double t = moving ? clock.value : 0;
    final Offset o = CardBackPainter.centreOf(size);
    final double r = CardBackPainter.radiusOf(size);

    // The rays: long on the eighths, short between, faint.
    final double turn = moving ? t * math.pi / 4 : 0;
    final Paint ray = Paint()
      ..isAntiAlias = true
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..color = c.body.withValues(alpha: 0.45);
    for (int i = 0; i < 64; i++) {
      final double a = i * math.pi / 32 + turn;
      final double len = i % 8 == 0 ? 1.34 : (i.isEven ? 1.2 : 1.12);
      final Offset dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(o + dir * r * 1.04, o + dir * r * len, ray);
    }
    final Paint bead = Paint()
      ..isAntiAlias = true
      ..color = c.body.withValues(alpha: 0.8);
    for (int i = 0; i < 8; i++) {
      // The beads stay put: they sit out at the frame's edge, and a turning
      // bead would cross it.
      final double a = i * math.pi / 4;
      canvas.drawCircle(
          o + Offset(math.cos(a), math.sin(a)) * r * 1.4, 1.6, bead);
    }

    // The jewel's glow.
    final double breath = moving ? 0.5 + 0.5 * _wave(t, 1, 0) : 1;
    canvas.drawCircle(
      o,
      r * (0.09 + 0.04 * breath),
      Paint()
        ..color = c.accent.withValues(alpha: 0.18 + 0.2 * breath)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.05),
    );

    for (int i = 0; i < _sparkles.length; i++) {
      final (double x, double y, double s) = _sparkles[i];
      final double beat =
          moving ? 0.5 + 0.5 * _wave(t, 1 + i % 2, i * 0.21) : 1;
      final Offset at = Offset(size.width * x, size.height * y);
      canvas.drawCircle(
        at,
        s * 1.6,
        Paint()
          ..color = c.body.withValues(alpha: 0.14 * beat)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s),
      );
      canvas.drawPath(
        _sparkle(at, s * (0.7 + 0.35 * beat)),
        Paint()
          ..isAntiAlias = true
          ..color = c.body.withValues(alpha: 0.45 + 0.35 * beat),
      );
    }

    for (int i = 0; i < _twinkles.length; i++) {
      final (double x, double y) = _twinkles[i];
      final double beat =
          moving ? math.max(0, _wave(t, 1 + i % 3, i * 0.37)) : 0.6;
      if (beat < 0.05) continue;
      canvas.drawPath(
        _sparkle(Offset(size.width * x, size.height * y), 1.2 + 1.6 * beat),
        Paint()
          ..isAntiAlias = true
          ..color = c.body.withValues(alpha: 0.7 * beat),
      );
    }
  }

  @override
  bool shouldRepaint(CardBackLifePainter old) =>
      old.c != c || old.clock != clock || old.moving != moving;
}

// A four-point star: long thin points, a pinched middle.
Path _sparkle(Offset at, double s) {
  final double k = s * 0.22;
  return Path()
    ..moveTo(at.dx, at.dy - s)
    ..quadraticBezierTo(at.dx + k, at.dy - k, at.dx + s, at.dy)
    ..quadraticBezierTo(at.dx + k, at.dy + k, at.dx, at.dy + s)
    ..quadraticBezierTo(at.dx - k, at.dy + k, at.dx - s, at.dy)
    ..quadraticBezierTo(at.dx - k, at.dy - k, at.dx, at.dy - s)
    ..close();
}

// A slim fir, four tiers, a fifth as wide as it is tall, standing on the
// origin and one unit tall. Built once; each tree is this, moved and scaled.
final Path _unitPine = () {
  const int tiers = 4;
  const double step = 0.8 / tiers;
  Path tree = Path();
  for (int i = 0; i < tiers; i++) {
    final double bottom = -step * i;
    final double apex = i == tiers - 1 ? -1 : bottom - 0.42;
    final double spread = 0.2 * (1 - i * 0.2);
    tree = Path.combine(
      PathOperation.union,
      tree,
      Path()
        ..moveTo(-spread, bottom)
        ..quadraticBezierTo(-spread * 0.3, (bottom + apex) / 2, 0, apex)
        ..quadraticBezierTo(spread * 0.3, (bottom + apex) / 2, spread, bottom)
        ..quadraticBezierTo(0, bottom - 0.04, -spread, bottom)
        ..close(),
    );
  }
  return tree;
}();

// ---- The figures, as SVG path data ----
//
// Each is drawn in a box 100 units tall, standing on the origin -- the feet,
// or the waterline for a boat -- with up negative. The parts are joined once,
// here, and placed with `_Brush._place`. The scene-illustrator skill's
// section 9 says why a figure with this many pieces is written this way and
// not as `cubicTo` calls: one string holds a whole outline, and a fix is a
// change to that string.
//
// The parts are joined with a union rather than parsed as one string, so two
// parts drawn in opposite directions cannot cut a hole where they overlap.
Path _figure(List<String> parts) {
  Path out = Path();
  for (final String d in parts) {
    out = Path.combine(PathOperation.union, out, parseSvgPathData(d));
  }
  return out;
}

// A log cabin, from the user's reference: a long front wall under a sloping
// roof, the gable end to the right, a chimney, a porch rail to the left.
// What makes it read: the roof's slope, the gable's point, the lit windows.
final Path _cabinWalls = parseSvgPathData('M-40,0 L-40,-24 L20,-24 L20,0 Z');
final Path _cabinGable =
    parseSvgPathData('M20,0 L20,-24 L36,-42 L52,-24 L52,0 Z');
final Path _cabinRoof = _figure(<String>[
  'M-47,-20 L-31,-45 L37,-45 L22,-20 Z',
  // The trim along the gable's two edges.
  'M20,-20 L37,-47 L56,-20 L52,-20 L37,-41 L24,-20 Z',
  'M-12,-40 L-12,-53 L-5,-53 L-5,-40 Z',
  // The door.
  'M-11,-17 L-5,-17 L-5,0 L-11,0 Z',
  // The porch rail and its posts.
  'M-66,-10 L-40,-10 L-40,-7 L-66,-7 Z',
  'M-66,0 L-66,-12 L-63,-12 L-63,0 Z',
  'M-54,0 L-54,-12 L-51,-12 L-51,0 Z',
]);
final Path _cabinWindows = _figure(<String>[
  'M-33,-17 L-21,-17 L-21,-9 L-33,-9 Z',
  'M3,-17 L15,-17 L15,-9 L3,-9 Z',
  'M32,-20 L40,-20 L40,-11 L32,-11 Z',
]);

// A boatman standing in a long punt, poling it along, a round basket in the
// stern. From the sunset reference. What makes it read: the boat's two
// turned-up ends, the wide cone of the hat, the long pole on a slant.
final Path _boatman = _figure(<String>[
  'M-50,-11 C-42,-4 -32,0 -18,1 L22,1 C34,0 43,-5 50,-13 '
      'C45,-8 36,-6 24,-6 L-20,-6 C-33,-6 -43,-8 -50,-11 Z',
  'M-11,-6 L-10,-24 C-10,-30 -7,-32 -4,-32 C-1,-32 2,-30 2,-24 L3,-6 Z',
  'M-8.5,-36 A3.5,3.5 0 1 0 -1.5,-36 A3.5,3.5 0 1 0 -8.5,-36 Z',
  'M-15,-37 L-5,-44 L5,-37 Z',
  'M-1,-29 L9,-36 L11,-33 L1,-25 Z',
  'M19,-60 L21,-59 L-6,7 L-8,6 Z',
  'M24,-6 C24,-14 36,-14 36,-6 Z',
]);

// A crescent boat, its bow curling high, one figure sitting in it and a post
// for a lantern at `_crescentBoatLantern`. From the full-moon reference.
final Path _crescentBoat = _figure(<String>[
  'M-40,-38 C-50,-18 -38,3 -12,3 L28,3 C39,2 46,-4 49,-11 '
      'L-26,-11 C-34,-15 -38,-25 -40,-38 Z',
  'M4,-11 C2,-19 5,-25 10,-25 C15,-25 18,-19 16,-11 Z',
  'M6,-29.5 A4.5,4.5 0 1 0 15,-29.5 A4.5,4.5 0 1 0 6,-29.5 Z',
  'M-19,-11 L-17,-11 L-17,-30 L-19,-30 Z',
]);
const Offset _crescentBoatLantern = Offset(-18, -33);

// A torii: two posts leaning in a little, the top beam curving up at its
// ends, a straight beam under it and a short strut between. What makes it
// read: the upturned top beam, and the lower beam running past the posts.
final Path _torii = _figure(<String>[
  'M-58,-94 C-40,-86 40,-86 58,-94 L55,-85 C40,-80 -40,-80 -55,-85 Z',
  'M-50,-81 L50,-81 L50,-76 L-50,-76 Z',
  'M-47,-62 L47,-62 L47,-56 L-47,-56 Z',
  'M-37,-80 L-30,-80 L-28,0 L-39,0 Z',
  'M30,-80 L37,-80 L39,0 L28,0 Z',
  'M-3,-76 L3,-76 L3,-62 L-3,-62 Z',
]);

// A small rowing boat with one person sitting in it, an oar dipped behind.
// Added 26 September 2026 to the desert ruins' pool, at the user's request.
final Path _skiff = _figure(<String>[
  'M-44,-12 C-38,-3 -26,1 -10,1 L16,1 C30,0 40,-5 46,-15 L-44,-12 Z',
  'M-8,-12 C-9,-20 -6,-27 0,-27 C6,-27 9,-20 8,-12 Z',
  'M-4.5,-32 A4.5,4.5 0 1 0 4.5,-32 A4.5,4.5 0 1 0 -4.5,-32 Z',
  // A wide cone hat, at the user's request.
  'M-11,-34 L0,-43 L11,-34 Z',
  'M2,-21 L4,-19 L-28,5 L-30,3 Z',
]);

// A castle far off in the sky, for the desert beacon: a keep with a tall
// centre tower, two round side towers, lower walls between, one slim tower
// behind, cone roofs and a flag. The user asked for it on 26 September 2026,
// behind clouds and fading into the sky. What makes it read: the cone
// roofs, the tall centre tower, and the notched top of the keep.
final Path _castle = () {
  final List<String> parts = <String>[
    'M-20,0 L-20,-60 L20,-60 L20,0 Z',
    'M-8,-60 L-8,-88 L8,-88 L8,-60 Z',
    'M-11,-88 L0,-108 L11,-88 Z',
    'M-45,0 L-45,-50 L-33,-50 L-33,0 Z',
    'M-48,-50 L-39,-68 L-30,-50 Z',
    'M33,0 L33,-50 L45,-50 L45,0 Z',
    'M30,-50 L39,-68 L48,-50 Z',
    'M-33,0 L-33,-30 L-20,-30 L-20,0 Z',
    'M20,0 L20,-30 L33,-30 L33,0 Z',
    'M24,-60 L24,-78 L30,-78 L30,-60 Z',
    'M22,-78 L27,-92 L32,-78 Z',
    'M-0.6,-106 L0.6,-106 L0.6,-118 L-0.6,-118 Z',
    'M0.6,-118 L9,-115 L0.6,-112 Z',
  ];
  // The keep's battlements: a notch every few units along its top.
  for (double x = -19; x < 19; x += 7) {
    parts.add('M$x,-60 L${x + 3.5},-60 L${x + 3.5},-65 L$x,-65 Z');
  }
  return _figure(parts);
}();

// The shared brushes: every piece of every scene, so the land painter and
// the life painter draw a thing the same way.
abstract class _Brush extends CustomPainter {
  final CardScene scene;
  final CardSceneColours c;

  _Brush(this.scene, this.c, {super.repaint});

  double w = 0;
  double h = 0;

  // What the haze at the foot of each layer fades towards: the sky just
  // behind it, which is warmer than the middle of the sky.
  Color get _hazeTo => Color.lerp(c.skyBottom, c.horizon, 0.6)!;

  void _sun(Canvas canvas, Offset centre, double r) {
    final double reach = r * 3;
    canvas.drawCircle(
      centre,
      reach,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            c.glow.withValues(alpha: 0.55),
            c.glow.withValues(alpha: 0.2),
            c.glow.withValues(alpha: 0),
          ],
          stops: const <double>[1 / 3, 0.6, 1],
        ).createShader(Rect.fromCircle(center: centre, radius: reach)),
    );
    canvas.drawCircle(centre, r, Paint()..color = c.body);
  }

  void _moon(Canvas canvas, Offset centre, double r) {
    canvas.drawCircle(
      centre,
      r * 1.8,
      Paint()
        ..color = c.glow.withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r),
    );
    canvas.drawCircle(centre, r, Paint()..color = c.body);
    final Paint sea = Paint()..color = c.glow.withValues(alpha: 0.35);
    canvas.drawCircle(centre + Offset(r * 0.3, -r * 0.2), r * 0.2, sea);
    canvas.drawCircle(centre + Offset(-r * 0.25, r * 0.3), r * 0.15, sea);
  }

  // One peak, as (share of the width, height as a share of the card, reach
  // left, reach right), standing on `foot`. Long shallow feet and a
  // steepening top, as Home draws them.
  Path _peakPath(
      double foot, double x, double tall, double left, double right) {
    final double t = h * tall;
    final Offset peak = Offset(w * x, foot - t);
    final double l = w * (x - left);
    final double r = w * (x + right);
    return Path()
      ..moveTo(l, foot)
      ..cubicTo(l + (peak.dx - l) * 0.55, foot - t * 0.12,
          peak.dx - (peak.dx - l) * 0.18, peak.dy + t * 0.22, peak.dx, peak.dy)
      ..cubicTo(peak.dx + (r - peak.dx) * 0.18, peak.dy + t * 0.22,
          r - (r - peak.dx) * 0.55, foot - t * 0.12, r, foot)
      ..close();
  }

  Path _rangePath(double foot, List<(double, double, double, double)> row) {
    Path shape = Path();
    for (final (double x, double tall, double left, double right) in row) {
      shape = Path.combine(
          PathOperation.union, shape, _peakPath(foot, x, tall, left, right));
    }
    return shape;
  }

  // A row of mountains. With `light` -- the sun or moon's share of the
  // width -- each peak gets a shaded face on the side away from it: the lit
  // side and the shaded side are what make a flat shape a mountain.
  void _range(Canvas canvas, double foot,
      List<(double, double, double, double)> row, Color colour, double haze,
      {double? light}) {
    final double top = foot - h * row.map((r) => r.$2).reduce(math.max);
    canvas.drawPath(_rangePath(foot, row), _hazed(colour, top, foot, haze));
    if (light != null) _shade(canvas, foot, top, row, colour, haze, light);
  }

  void _shade(
      Canvas canvas,
      double foot,
      double top,
      List<(double, double, double, double)> row,
      Color colour,
      double haze,
      double light) {
    final Paint shadow =
        _hazed(Color.lerp(colour, c.deep, 0.24)!, top, foot, haze);
    for (final (double x, double tall, double left, double right) in row) {
      final bool shadeLeft = light > x;
      final Offset peak = Offset(w * x, foot - h * tall);
      final double far = shadeLeft ? w * (x - left) : w * (x + right);
      // The ridge line leans towards the light as it comes down, so the
      // shaded face widens at the foot.
      final double lean = (shadeLeft ? 1 : -1) * w * 0.035;
      canvas.save();
      canvas.clipPath(_peakPath(foot, x, tall, left, right));
      canvas.drawPath(
        Path()
          ..moveTo(peak.dx, peak.dy)
          ..quadraticBezierTo(
              peak.dx - lean * 0.2, (peak.dy + foot) / 2, peak.dx + lean, foot)
          ..lineTo(far, foot)
          ..lineTo(far, peak.dy)
          ..close(),
        shadow,
      );
      canvas.restore();
    }
  }

  // A colour at its top, fading towards the sky's foot by `haze`: the mist
  // Alto lays at the bottom of every layer.
  Paint _hazed(Color colour, double top, double bottom, double haze) => Paint()
    ..isAntiAlias = true
    ..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[colour, Color.lerp(colour, _hazeTo, haze)!],
    ).createShader(Rect.fromLTRB(0, top, 1, bottom));

  // A band of mist across the whole card, thickest in its middle.
  void _mist(Canvas canvas, double y, double half, double a) {
    final Rect band = Rect.fromLTRB(0, y - half, w, y + half);
    canvas.drawRect(
      band,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            c.mist.withValues(alpha: 0),
            c.mist.withValues(alpha: a),
            c.mist.withValues(alpha: 0),
          ],
        ).createShader(band),
    );
  }

  Path _pine(Offset base, double tall) =>
      _unitPine.transform((Matrix4.translationValues(base.dx, base.dy, 0)
            ..scaleByDouble(tall, tall, 1, 1))
          .storage);

  // A glowing dot -- a seed -- with its halo. `shimmer` from 0 to 1 swells
  // the halo a little; `opacity` fades the whole of it.
  void _glowDot(Canvas canvas, Offset at, double r,
      {double shimmer = 1, double opacity = 1}) {
    canvas.drawCircle(
      at,
      r * (3.4 + 0.8 * shimmer),
      Paint()
        ..color = c.accent.withValues(alpha: (0.22 + 0.16 * shimmer) * opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 2),
    );
    canvas.drawCircle(
      at,
      r,
      Paint()
        ..isAntiAlias = true
        ..color = Color.lerp(c.accent, c.glow, 0.3 * shimmer)!
            .withValues(alpha: opacity),
    );
  }

  // A paper lantern: a rounded body, a brighter window, and a halo that
  // swells with `shimmer`.
  void _lantern(Canvas canvas, Offset at, double s,
      {double shimmer = 1, double opacity = 1}) {
    canvas.drawCircle(
      at,
      s * (2.4 + 0.4 * shimmer),
      Paint()
        ..color = c.accent.withValues(alpha: (0.24 + 0.14 * shimmer) * opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 1.4),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromCenter(center: at, width: s * 1.3, height: s * 1.6),
          Radius.circular(s * 0.4)),
      Paint()
        ..isAntiAlias = true
        ..color = c.accent.withValues(alpha: opacity),
    );
    canvas.drawRect(
      Rect.fromCenter(
          center: at + Offset(0, -s * 0.2), width: s * 0.7, height: s * 0.7),
      Paint()
        ..color = c.body.withValues(alpha: (0.65 + 0.3 * shimmer) * opacity),
    );
  }

  // A floating island: a flat top over a rock that tapers to a point, a lit
  // face on the sun's side, and two pines on it.
  void _island(Canvas canvas, Offset top, double width) {
    final double half = width / 2;
    final Path rock = Path()
      ..moveTo(top.dx - half, top.dy)
      ..quadraticBezierTo(top.dx - half * 0.6, top.dy + width * 0.3,
          top.dx - half * 0.1, top.dy + width * 0.7)
      ..lineTo(top.dx + half * 0.05, top.dy + width * 0.55)
      ..quadraticBezierTo(
          top.dx + half * 0.7, top.dy + width * 0.25, top.dx + half, top.dy)
      ..close();
    canvas.drawPath(rock, _hazed(c.near, top.dy, top.dy + width * 0.7, 0.3));
    // The shaded face, away from the sun on the left.
    canvas.save();
    canvas.clipPath(rock);
    canvas.drawRect(
      Rect.fromLTRB(
          top.dx - half * 0.05, top.dy, top.dx + half, top.dy + width * 0.7),
      Paint()..color = c.deep.withValues(alpha: 0.18),
    );
    canvas.restore();
    canvas.drawOval(
      Rect.fromCenter(center: top, width: width * 1.02, height: width * 0.12),
      Paint()
        ..isAntiAlias = true
        ..color = c.far,
    );
    final Paint pine = Paint()
      ..isAntiAlias = true
      ..color = c.ground;
    canvas.drawPath(_pine(top + Offset(-half * 0.35, 0), width * 0.55), pine);
    canvas.drawPath(_pine(top + Offset(-half * 0.1, 0), width * 0.38), pine);
  }

  // A blossom tree: a short trunk under a cloud of pale rounds, a shaded
  // under-layer first so the crown has a lit top and a shaded belly.
  void _blossom(Canvas canvas, Offset base, double r, Color trunk) {
    canvas.drawRect(
        Rect.fromLTRB(
            base.dx - r * 0.1, base.dy - r * 1.3, base.dx + r * 0.1, base.dy),
        Paint()..color = trunk);
    const List<(double, double, double)> puffs = <(double, double, double)>[
      (0, -1.7, 0.75),
      (-0.6, -1.35, 0.55),
      (0.6, -1.35, 0.6),
      (-0.3, -2.1, 0.5),
      (0.35, -2.05, 0.5),
    ];
    final Paint shade = Paint()
      ..isAntiAlias = true
      ..color = Color.lerp(c.accent, c.near, 0.3)!;
    final Paint bloom = Paint()
      ..isAntiAlias = true
      ..color = c.accent;
    for (final (double dx, double dy, double s) in puffs) {
      canvas.drawCircle(
          base + Offset(dx * r, dy * r + s * r * 0.18), s * r, shade);
    }
    for (final (double dx, double dy, double s) in puffs) {
      canvas.drawCircle(
          base + Offset(dx * r - s * r * 0.08, dy * r), s * r * 0.9, bloom);
    }
  }

  // Snow on the top `share` of a peak drawn with `_range`: a ragged lower
  // edge where the snow runs down the gullies, and a shaded face on the
  // side away from `light`, the same side `_shade` darkens below it.
  void _snowCap(Canvas canvas, double foot,
      (double, double, double, double) peak, double share,
      {required double light}) {
    final (double x, double tall, double left, double right) = peak;
    final double t = h * tall;
    final double edge = foot - t * share;
    final double from = w * (x - left);
    final double to = w * (x + right);
    final Path cap = Path()..moveTo(from, 0);
    const int teeth = 9;
    for (int i = 0; i <= teeth; i++) {
      final double px = from + (to - from) * i / teeth;
      cap.lineTo(px, edge + (i.isOdd ? t * 0.07 : 0) - (i % 3) * t * 0.015);
    }
    cap
      ..lineTo(to, 0)
      ..close();
    // Snow takes the sky's warm foot rather than the glow, so it goes down
    // with the sky in dark mode instead of staying a white lamp.
    final Color snow = Color.lerp(c.horizon, c.glow, 0.5)!;
    canvas
      ..save()
      ..clipPath(_peakPath(foot, x, tall, left, right))
      ..drawPath(
          cap,
          Paint()
            ..isAntiAlias = true
            ..color = snow)
      ..clipPath(cap);
    final bool shadeLeft = light > x;
    final double px = w * x;
    final double lean = (shadeLeft ? 1 : -1) * w * 0.035;
    canvas
      ..drawPath(
        Path()
          ..moveTo(px, foot - t)
          ..lineTo(px + lean, foot)
          ..lineTo(shadeLeft ? from : to, foot)
          ..lineTo(shadeLeft ? from : to, foot - t)
          ..close(),
        Paint()..color = Color.lerp(snow, c.far, 0.45)!,
      )
      ..restore();
  }

  // A crescent moon: the disc with a second, offset disc taken out of it,
  // and the glow around the whole.
  void _crescent(Canvas canvas, Offset centre, double r) {
    canvas.drawCircle(
      centre,
      r * 2.2,
      Paint()
        ..color = c.glow.withValues(alpha: 0.28)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 1.4),
    );
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addOval(Rect.fromCircle(center: centre, radius: r)),
        Path()
          ..addOval(Rect.fromCircle(
              center: centre + Offset(r * 0.42, -r * 0.28), radius: r * 0.92)),
      ),
      Paint()
        ..isAntiAlias = true
        ..color = c.body,
    );
  }

  // A soft heap of cloud sitting on a flat foot: overlapping rounds, as
  // (share of `width` across, radius as a share of `width`), cut off below
  // `base`. A paler copy a touch higher gives it a lit top.
  void _cloud(Canvas canvas, Offset base, double width,
      List<(double, double)> puffs, Color colour,
      {Color? lit, double opacity = 1}) {
    Path heap = Path();
    for (final (double x, double r) in puffs) {
      heap = Path.combine(
        PathOperation.union,
        heap,
        Path()
          ..addOval(Rect.fromCircle(
              center: Offset(base.dx + width * x, base.dy), radius: width * r)),
      );
    }
    canvas
      ..save()
      ..clipRect(Rect.fromLTRB(0, 0, w, base.dy));
    if (lit != null) {
      canvas.drawPath(
          heap.shift(Offset(0, -width * 0.015)),
          Paint()
            ..isAntiAlias = true
            ..color = lit.withValues(alpha: lit.a * opacity));
    }
    canvas
      ..drawPath(
          heap.shift(Offset(0, lit != null ? width * 0.01 : 0)),
          Paint()
            ..isAntiAlias = true
            ..color = colour.withValues(alpha: colour.a * opacity))
      ..restore();
  }

  // A figure drawn in its 100-unit box, placed standing on `at` and `size`
  // tall.
  Path _place(Path unit, Offset at, double size) =>
      unit.transform((Matrix4.translationValues(at.dx, at.dy, 0)
            ..scaleByDouble(size / 100, size / 100, 1, 1))
          .storage);

  // Faint rings round a big moon, broken into arcs -- from the night
  // references, where a full circle read as a target.
  void _halo(Canvas canvas, Offset centre, double r) {
    final Paint ring = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, r * 0.02)
      ..color = c.glow.withValues(alpha: 0.22);
    for (final (double k, double from) in const <(double, double)>[
      (1.18, 0.5),
      (1.36, 1.3),
    ]) {
      final Rect box = Rect.fromCircle(center: centre, radius: r * k);
      canvas
        ..drawArc(box, from, math.pi * 0.78, false, ring)
        ..drawArc(box, from + math.pi, math.pi * 0.78, false, ring);
    }
  }

  // Wide soft beams of light fanning out from the sun, as (direction in
  // radians, half its spread). Painted over the land and under the life.
  void _shafts(
      Canvas canvas, Offset from, List<(double, double)> beams, double a) {
    final double len = math.max(w, h) * 1.6;
    for (final (double angle, double spread) in beams) {
      final Offset dir = Offset(math.cos(angle), math.sin(angle));
      final Offset side = Offset(-dir.dy, dir.dx) * (len * spread);
      final Offset far = from + dir * len;
      canvas.drawPath(
        Path()
          ..moveTo(from.dx, from.dy)
          ..lineTo((far + side).dx, (far + side).dy)
          ..lineTo((far - side).dx, (far - side).dy)
          ..close(),
        Paint()
          ..blendMode = BlendMode.screen
          ..shader = RadialGradient(colors: <Color>[
            c.glow.withValues(alpha: a),
            c.glow.withValues(alpha: 0),
          ]).createShader(Rect.fromCircle(center: from, radius: len * 0.7)),
      );
    }
  }

  // A reflection broken by short pale lines across the water, more of them
  // and longer towards the front. Seeded, so it is the same on every run.
  void _breaks(Canvas canvas, double top, double bottom, int seed, int count,
      Color colour, double a) {
    final math.Random rng = math.Random(seed);
    final Paint line = Paint()
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = colour.withValues(alpha: a);
    for (int i = 0; i < count; i++) {
      final double q = rng.nextDouble();
      final double y = top + (bottom - top) * q * q;
      final double x = rng.nextDouble() * w;
      final double len = w * (0.03 + 0.14 * q) * (0.5 + rng.nextDouble());
      canvas.drawLine(Offset(x - len / 2, y), Offset(x + len / 2, y), line);
    }
  }

  // A ringed planet, from the user's comments of 26 September 2026: a disc
  // with soft bands across it and a shaded side away from `lightLeft`, and
  // rings tilted by `tilt`. The back half of the rings goes behind the disc
  // and the front half across it, which is what makes them rings rather
  // than a line through a ball.
  //
  // Without `rings` it is a plain banded disc; `fade` below 1 lays it into
  // the sky, for a far planet half lost in the air.
  void _planet(Canvas canvas, Offset centre, double r,
      {double tilt = -0.35,
      bool lightLeft = true,
      bool rings = true,
      double fade = 1,
      double glow = 0.18,
      double soften = 0,
      Color? tint,
      Offset? litFrom}) {
    // `soften` takes the disc towards the sky's own colour and quietens its
    // bands and its shaded side; `glow` is the strength of the halo. `tint`
    // replaces the scene's `body` as the planet's own colour. With
    // `litFrom` -- a light source such as the moon -- the disc runs from
    // full brightness on that side to dim on the far side.
    final Color base = tint ?? c.body;
    final Color face = Color.lerp(base, c.skyBottom, soften * 0.5)!;
    if (fade < 1) {
      canvas.saveLayer(Rect.fromCircle(center: centre, radius: r * 2.2),
          Paint()..color = Color.fromRGBO(0, 0, 0, fade));
    }
    final Rect ringBox =
        Rect.fromCenter(center: Offset.zero, width: r * 4.2, height: r * 0.9);
    void ringHalf({required bool front}) {
      if (!rings) return;
      canvas
        ..save()
        ..translate(centre.dx, centre.dy)
        ..rotate(tilt)
        ..clipRect(front
            ? Rect.fromLTRB(-r * 3, 0, r * 3, r * 3)
            : Rect.fromLTRB(-r * 3, -r * 3, r * 3, 0));
      for (final (double k, double width, double a)
          in const <(double, double, double)>[
        (1.0, 0.07, 0.75),
        (0.86, 0.035, 0.5),
        (1.12, 0.025, 0.4),
      ]) {
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset.zero,
              width: ringBox.width * k,
              height: ringBox.height * k),
          Paint()
            ..isAntiAlias = true
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(1, r * width)
            ..color = Color.lerp(c.glow, c.accent, 0.3)!.withValues(alpha: a),
        );
      }
      canvas.restore();
    }

    canvas.drawCircle(
      centre,
      r * (1.5 + glow),
      Paint()
        ..color = c.glow.withValues(alpha: glow)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * (0.4 + glow)),
    );
    ringHalf(front: false);
    final Path disc = Path()
      ..addOval(Rect.fromCircle(center: centre, radius: r));
    canvas
      ..drawPath(
          disc,
          Paint()
            ..isAntiAlias = true
            ..color = face
            ..shader = litFrom == null
                ? null
                : () {
                    final Offset toward = litFrom - centre;
                    final Offset unit = toward / toward.distance;
                    return ui.Gradient.linear(
                        centre + unit * r, centre - unit * r, <Color>[
                      base,
                      Color.lerp(base, c.skyBottom, 0.6)!,
                    ]);
                  }())
      ..save()
      ..clipPath(disc)
      ..translate(centre.dx, centre.dy)
      ..rotate(tilt);
    final Paint band = Paint()
      ..color = Color.lerp(face, c.far, 0.16 * (1 - soften * 0.6))!;
    for (final (double y, double thick) in const <(double, double)>[
      (-0.55, 0.12),
      (-0.2, 0.2),
      (0.3, 0.14),
      (0.62, 0.1),
    ]) {
      canvas.drawRect(
          Rect.fromLTRB(-r * 1.2, r * y, r * 1.2, r * (y + thick)), band);
    }
    // The night side: a crescent, the disc less a copy of itself moved
    // towards the light.
    final double toLight = lightLeft ? -1 : 1;
    canvas
      ..rotate(-tilt)
      ..drawPath(
        Path.combine(
          PathOperation.difference,
          Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: r)),
          Path()
            ..addOval(Rect.fromCircle(
                center: Offset(toLight * r * 0.32, -r * 0.12),
                radius: r * 1.02)),
        ),
        Paint()
          ..isAntiAlias = true
          ..color = c.deep.withValues(alpha: 0.22 * (1 - soften * 0.6)),
      )
      ..restore();
    ringHalf(front: true);
    if (fade < 1) canvas.restore();
  }

  // A small house on a hill at night, in place of the round trees -- the
  // user's comment, 26 September 2026: a squat body, a steep roof lit on
  // the side facing the moon, a chimney, and one warm window. `r` sets its
  // size, as the tree's crown radius did. The window is the one warm light
  // in a cold scene, so it takes a fixed lamp gold leaned on the scene's
  // own accent rather than a slot: none of the night's slots is warm.
  void _hut(Canvas canvas, Offset base, double r,
      {required double light, Color? tone}) {
    final double half = r * 0.9;
    final double wall = r * 1.2;
    final Color body = tone ?? Color.lerp(c.ground, c.deep, 0.35)!;
    final Paint fill = Paint()
      ..isAntiAlias = true
      ..color = body;
    final Offset eaveL = base + Offset(-half * 1.25, -wall);
    final Offset eaveR = base + Offset(half * 1.25, -wall);
    final Offset ridge = base + Offset(0, -wall - r * 1.15);
    final bool litLeft = light * w < base.dx;
    canvas
      ..drawRect(
          Rect.fromLTRB(base.dx + half * 0.35, ridge.dy + r * 0.45,
              base.dx + half * 0.7, base.dy - wall),
          fill)
      ..drawRect(
          Rect.fromLTRB(
              base.dx - half, base.dy - wall, base.dx + half, base.dy),
          fill)
      ..drawPath(
          Path()
            ..moveTo(eaveL.dx, eaveL.dy)
            ..lineTo(ridge.dx, ridge.dy)
            ..lineTo(eaveR.dx, eaveR.dy)
            ..close(),
          Paint()
            ..isAntiAlias = true
            ..color = Color.lerp(body, c.deep, 0.3)!)
      ..drawPath(
          Path()
            ..moveTo(litLeft ? eaveL.dx : eaveR.dx, eaveL.dy)
            ..lineTo(ridge.dx, ridge.dy)
            ..lineTo(ridge.dx, eaveL.dy)
            ..close(),
          Paint()
            ..isAntiAlias = true
            ..color = Color.lerp(body, c.glow, 0.3)!);
    final Rect window = Rect.fromCenter(
        center: base + Offset(-half * 0.35, -wall * 0.55),
        width: math.max(2, r * 0.45),
        height: math.max(2, r * 0.45));
    final Color lamp = Color.lerp(c.accent, const Color(0xFFFFD27A), 0.7)!;
    canvas
      ..drawRect(
          window.inflate(r * 0.3),
          Paint()
            ..color = lamp.withValues(alpha: 0.35)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.3))
      ..drawRect(window, Paint()..color = lamp)
      ..drawRect(
          Rect.fromLTRB(base.dx + half * 0.15, base.dy - wall * 0.6,
              base.dx + half * 0.55, base.dy),
          Paint()..color = Color.lerp(body, c.deep, 0.5)!);
  }

  // Where the new scenes' figures stand, shared by the land and the life.
  double get _cabinWater => h * 0.62;
  Offset get _cabinAt => Offset(w * 0.52, _cabinWater - h * 0.028);
  double get _cabinSize => w * 0.25;
  // The desert beacon's horizon sits high, from the user's comment of 26
  // September 2026: the planet and the dunes moved up by `_duneLift`.
  double get _duneLift => h * 0.18;
  Offset get _summit => Offset(w * 0.5, h * 0.6 - _duneLift);
  Offset get _castleAt => Offset(w * 0.24, h * 0.22);
  double get _boatSea => h * 0.64;
  double get _moonSea => h * 0.62;
  double get _desertPool => h * 0.8;
  // Where the desert bridge's piers stand in the water, and where the boat
  // rides in front of it.
  double get _bridgeWater => h * 0.86;
  double get _desertBoat => h * 0.93;

  // A crane standing in the shallows, side on, facing right, from a
  // reference the user brought on 26 September 2026: legs like two straight
  // reeds, a body shaped like a drop with the tail feathers hanging down
  // behind, a long thin S of a neck held upright, and a long beak tipped up
  // at the sky. It replaced a stubbier heron with a bent neck. Cranes stand
  // still for minutes, which is why this one is part of the land.
  void _crane(Canvas canvas, Offset feet, double s, Color colour) {
    final Paint fill = Paint()
      ..isAntiAlias = true
      ..color = colour;
    final Paint line = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = colour;
    canvas
      ..save()
      ..translate(feet.dx, feet.dy)
      // The legs: long, thin and nearly straight.
      ..drawLine(Offset(-s * 0.01, -s * 0.6), Offset(-s * 0.03, 0),
          line..strokeWidth = math.max(1, s * 0.024))
      ..drawLine(Offset(s * 0.05, -s * 0.6), Offset(s * 0.06, 0), line)
      // The body: a round breast in front, the tail feathers hanging down
      // behind in a point.
      ..drawPath(
        Path()
          ..moveTo(s * 0.1, -s * 1.0)
          ..cubicTo(s * 0.26, -s * 0.94, s * 0.26, -s * 0.7, s * 0.1, -s * 0.62)
          ..cubicTo(
              s * 0.0, -s * 0.57, -s * 0.14, -s * 0.58, -s * 0.24, -s * 0.46)
          ..quadraticBezierTo(-s * 0.3, -s * 0.4, -s * 0.33, -s * 0.34)
          ..cubicTo(
              -s * 0.3, -s * 0.62, -s * 0.2, -s * 0.9, -s * 0.02, -s * 1.0)
          ..quadraticBezierTo(s * 0.04, -s * 1.02, s * 0.1, -s * 1.0)
          ..close(),
        fill,
      )
      // The neck: a long, thin S, held upright.
      ..drawPath(
        Path()
          ..moveTo(s * 0.1, -s * 0.94)
          ..cubicTo(
              s * 0.04, -s * 1.12, s * 0.02, -s * 1.26, s * 0.07, -s * 1.37)
          ..quadraticBezierTo(s * 0.1, -s * 1.43, s * 0.12, -s * 1.47),
        line..strokeWidth = s * 0.05,
      )
      ..drawCircle(Offset(s * 0.13, -s * 1.48), s * 0.045, fill)
      // The beak: long and fine, tipped up.
      ..drawPath(
        Path()
          ..moveTo(s * 0.14, -s * 1.52)
          ..lineTo(s * 0.44, -s * 1.66)
          ..lineTo(s * 0.16, -s * 1.46)
          ..close(),
        fill,
      )
      ..restore();
  }

  // The line where the pastel shore's water begins.
  double get _shoreLine => h * 0.68;
  Offset get _craneFeet => Offset(w * 0.42, _shoreLine + h * 0.07);

  // A small boat with a girl sitting in the stern and a cat at the bow,
  // side on, as one silhouette standing on the origin.
  void _girlAndCat(Canvas canvas, double s, Color colour) {
    final Paint fill = Paint()
      ..isAntiAlias = true
      ..color = colour;
    canvas
      // The hull.
      ..drawPath(
        Path()
          ..moveTo(-s, -s * 0.2)
          ..quadraticBezierTo(-s * 0.6, s * 0.14, 0, s * 0.14)
          ..quadraticBezierTo(s * 0.6, s * 0.14, s * 1.05, -s * 0.26)
          ..close(),
        fill,
      )
      // The girl: a body, a head, and a ponytail.
      ..drawPath(
        Path()
          ..moveTo(-s * 0.58, -s * 0.18)
          ..lineTo(-s * 0.52, -s * 0.62)
          ..quadraticBezierTo(-s * 0.4, -s * 0.72, -s * 0.28, -s * 0.62)
          ..lineTo(-s * 0.22, -s * 0.18)
          ..close(),
        fill,
      )
      ..drawCircle(Offset(-s * 0.4, -s * 0.84), s * 0.15, fill)
      ..drawOval(
          Rect.fromCenter(
              center: Offset(-s * 0.6, -s * 0.8),
              width: s * 0.16,
              height: s * 0.26),
          fill)
      // The cat: sitting up, ears pricked, tail curled round.
      ..drawOval(
          Rect.fromCenter(
              center: Offset(s * 0.55, -s * 0.36),
              width: s * 0.24,
              height: s * 0.34),
          fill)
      ..drawCircle(Offset(s * 0.58, -s * 0.6), s * 0.1, fill)
      ..drawPath(
        Path()
          ..moveTo(s * 0.5, -s * 0.66)
          ..lineTo(s * 0.52, -s * 0.78)
          ..lineTo(s * 0.57, -s * 0.68)
          ..moveTo(s * 0.6, -s * 0.68)
          ..lineTo(s * 0.66, -s * 0.78)
          ..lineTo(s * 0.67, -s * 0.64)
          ..close(),
        fill,
      )
      ..drawPath(
        Path()
          ..moveTo(s * 0.44, -s * 0.24)
          ..quadraticBezierTo(s * 0.3, -s * 0.3, s * 0.34, -s * 0.46),
        Paint()
          ..isAntiAlias = true
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = s * 0.05
          ..color = colour,
      );
  }

  // The lighthouse's lamp, and the width of the tower's top.
  double get _lighthouseTop => w * 0.03;
  Offset get _lighthouseLamp =>
      Offset(w * 0.82, h * 0.455 - h * 0.22 - _lighthouseTop * 0.9);
}

// The sky: a three-stop gradient, and at night the stars and, in the one
// scene that has it, the aurora. It repaints only at night; a day sky has
// nothing in it that moves.
class _SkyPainter extends _Brush {
  final Animation<double> clock;
  final bool moving;

  _SkyPainter(super.scene, super.c, {required this.clock, required this.moving})
      : super(repaint: c.night ? clock : null);

  static const List<(double, double, double)> _stars =
      <(double, double, double)>[
    (0.08, 0.06, 1.4),
    (0.18, 0.18, 1.0),
    (0.30, 0.05, 1.2),
    (0.42, 0.15, 0.9),
    (0.55, 0.04, 1.3),
    (0.62, 0.24, 1.0),
    (0.88, 0.07, 1.2),
    (0.94, 0.26, 1.0),
    (0.12, 0.32, 0.9),
    (0.36, 0.26, 0.7),
    (0.48, 0.30, 0.8),
    (0.76, 0.33, 0.7),
    (0.24, 0.10, 0.7),
    (0.68, 0.12, 0.8),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    w = size.width;
    h = size.height;
    final double t = moving ? clock.value : 0;
    final Rect all = Offset.zero & size;
    canvas.drawRect(
      all,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[c.skyTop, c.skyBottom, c.horizon],
          stops: const <double>[0, 0.5, 0.78],
        ).createShader(all),
    );

    if (c.night) {
      // Each star twinkles on its own beat, one to three times a loop.
      for (int i = 0; i < _stars.length; i++) {
        final (double x, double y, double r) = _stars[i];
        final double a =
            moving ? 0.55 + 0.35 * _wave(t, 1 + i % 3, i * 0.37) : 0.8;
        canvas.drawCircle(Offset(w * x, h * y), r,
            Paint()..color = c.glow.withValues(alpha: a));
      }
    }

    if (scene == CardScene.auroraValley) _aurora(canvas, t);
  }

  // The lights: three slow ribbons, bright at their lower edge and fading
  // upwards, the way an aurora hangs. **They ripple**: the fold travels
  // along each ribbon once a loop, alternate ribbons the opposite way, and
  // each breathes a little in height and brightness -- a real aurora moves
  // like a curtain in a slow draught.
  void _aurora(Canvas canvas, double t) {
    final List<(double, double, double, double)> ribbons =
        <(double, double, double, double)>[
      (0.30, 0.05, 0.0, 0.55),
      (0.22, 0.04, 1.6, 0.4),
      (0.38, 0.03, 3.0, 0.3),
    ];
    for (int j = 0; j < ribbons.length; j++) {
      final (double y, double amp, double phase, double a) = ribbons[j];
      final double drift = moving ? 2 * math.pi * t * (j.isEven ? 1 : -1) : 0;
      final double breathe = moving ? 1 + 0.25 * _wave(t, 2, j * 0.3) : 1;
      final double bright = moving ? 0.85 + 0.15 * _wave(t, 1, j / 3) : 1;
      double edge(double x) =>
          h *
          (y +
              amp * breathe * math.sin(x * math.pi * 2 + phase + drift) +
              amp * 0.35 * math.sin(x * math.pi * 5 + phase - drift * 2));
      final Path band = Path();
      final double thick = h * 0.16;
      for (double x = 0; x <= 1.0001; x += 0.02) {
        x == 0 ? band.moveTo(0, edge(x)) : band.lineTo(w * x, edge(x));
      }
      for (double x = 1; x >= -0.0001; x -= 0.02) {
        band.lineTo(w * x, edge(x) - thick);
      }
      band.close();
      canvas.drawPath(
        band,
        Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: <Color>[
              c.accent.withValues(alpha: a * bright),
              c.accent.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTWH(0, h * (y - 0.2), w, h * 0.3)),
      );
    }
  }

  @override
  bool shouldRepaint(_SkyPainter old) =>
      old.scene != scene ||
      old.c != c ||
      old.clock != clock ||
      old.moving != moving;
}

// The land: everything that stands still, painted once.
class _ScenePainter extends _Brush {
  _ScenePainter(super.scene, super.c);

  @override
  void paint(Canvas canvas, Size size) {
    w = size.width;
    h = size.height;
    canvas.clipRect(Offset.zero & size);

    switch (scene) {
      case CardScene.lanternLake:
        _lanternLake(canvas);
      case CardScene.floatingIslands:
        _floatingIslands(canvas);
      case CardScene.duskWaves:
        _duskWaves(canvas);
      case CardScene.auroraValley:
        _auroraValley(canvas);
      case CardScene.blossomTerraces:
        _blossomTerraces(canvas);
      case CardScene.lighthouseCliffs:
        _lighthouseCliffs(canvas);
      case CardScene.dawnPond:
        _dawnPond(canvas);
      case CardScene.snowTree:
        _snowTree(canvas);
      case CardScene.pastelShore:
        _pastelShore(canvas);
      case CardScene.cabinIsland:
        _cabinIsland(canvas);
      case CardScene.desertBeacon:
        _desertBeacon(canvas);
      case CardScene.boatmanSunset:
        _boatmanSunset(canvas);
      case CardScene.moonBoat:
        _moonBoat(canvas);
      case CardScene.toriiPeaks:
        _toriiPeaks(canvas);
      case CardScene.snowSlope:
        _snowSlope(canvas);
      case CardScene.desertRuins:
        _desertRuins(canvas);
      case CardScene.nightHills:
        _nightHills(canvas);
    }
  }

  void _lanternLake(Canvas canvas) {
    final Offset moon = Offset(w * 0.72, h * 0.2);
    final double r = w * 0.07;
    _moon(canvas, moon, r);

    // Open water to the horizon. The mountains and pines came out on 26
    // September 2026, at the user's request: they crowded the lanterns, and
    // the lake reads bigger with nothing round it.
    final double shore = h * 0.64;

    // The water: the sky's lower colour, darkening towards the front.
    final Rect water = Rect.fromLTRB(0, shore, w, h);
    canvas.drawRect(
      water,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color.lerp(c.horizon, c.far, 0.45)!,
            c.ground,
          ],
        ).createShader(water),
    );

    // The moon laid on the water as a soft column of light.
    canvas.drawRect(
      Rect.fromLTRB(moon.dx - r * 0.7, shore + 4, moon.dx + r * 0.7, h * 0.94),
      Paint()
        ..color = c.glow.withValues(alpha: 0.28)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5),
    );
    canvas.drawLine(Offset(0, shore), Offset(w, shore),
        Paint()..color = c.glow.withValues(alpha: 0.35));
  }

  void _floatingIslands(Canvas canvas) {
    _sun(canvas, Offset(w * 0.26, h * 0.2), w * 0.07);

    _range(
        canvas,
        h * 0.74,
        <(double, double, double, double)>[
          (0.20, 0.16, 0.30, 0.30),
          (0.70, 0.22, 0.30, 0.34),
        ],
        Color.lerp(c.far, c.skyBottom, 0.4)!,
        0.4,
        light: 0.26);

    // The sea of cloud: rows of soft puffs, the front row the brightest.
    for (final (double y, double r, double a) in <(double, double, double)>[
      (0.74, 0.10, 0.55),
      (0.84, 0.13, 0.8),
      (0.95, 0.16, 1.0),
    ]) {
      final Paint puff = Paint()
        ..isAntiAlias = true
        ..color = c.mist.withValues(alpha: a);
      final double step = w * r * 1.3;
      for (double x = -step / 2; x < w + step; x += step) {
        canvas.drawCircle(Offset(x, h * y), w * r, puff);
      }
      canvas.drawRect(Rect.fromLTRB(0, h * y, w, h), puff);
    }
    // The islands float, so they are drawn with the life.
  }

  void _duskWaves(Canvas canvas) {
    final double sea = h * 0.56;
    _sun(canvas, Offset(w * 0.5, h * 0.47), w * 0.13);

    // The open sea under the low sun: warm at the horizon, deeper to the
    // front. The waves themselves roll, so they are painted as life.
    final Rect water = Rect.fromLTRB(0, sea, w, h);
    canvas
      ..drawRect(
        water,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color.lerp(c.horizon, c.far, 0.35)!,
              c.near,
              c.ground,
            ],
            stops: const <double>[0, 0.4, 1],
          ).createShader(water),
      )
      // The sun laid on the water as a soft column.
      ..drawRect(
        Rect.fromLTRB(w * 0.42, sea + 2, w * 0.58, h * 0.8),
        Paint()
          ..color = c.glow.withValues(alpha: 0.3)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.04),
      )
      ..drawLine(Offset(0, sea), Offset(w, sea),
          Paint()..color = c.glow.withValues(alpha: 0.6));
  }

  void _auroraValley(Canvas canvas) {
    _moon(canvas, Offset(w * 0.18, h * 0.14), w * 0.045);

    // No mountains and no pines, from 26 September 2026, at the user's
    // request: an open snowfield under the lights, with nothing standing
    // between the reader and the sky.
    //
    // A large ringed planet just behind the horizon, so the snowfield cuts
    // off its lower part -- the user's comment, 26 September 2026. It sits
    // in the land layer, so the aurora in the sky passes behind it.
    // Glowing, and dimmer than a plain planet away from the moon, so it does
    // not outshine the aurora -- the user's comments, 26 September 2026.
    // Lit from the moon: bright on its upper left, dimming towards the
    // snow -- the user found it toned down too far when it was dim all over.
    _planet(canvas, Offset(w * 0.5, h * 0.64), w * 0.3,
        tilt: -0.2,
        glow: 0.4,
        soften: 0.3,
        litFrom: Offset(w * 0.18, h * 0.14));
    // A second, smaller planet far off, with no rings, fading into the sky,
    // hung between the moon and the big planet -- the user moved it down
    // there on 26 September 2026.
    _planet(canvas, Offset(w * 0.78, h * 0.31), w * 0.07,
        rings: false, fade: 0.4, lightLeft: false);

    // The snowfield, with a faint green of the aurora laid on it.
    final Path field = Path()
      ..moveTo(0, h * 0.78)
      ..quadraticBezierTo(w * 0.5, h * 0.72, w, h * 0.8)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(field, Paint()..color = c.ground);
    canvas.drawPath(
      field,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            c.accent.withValues(alpha: 0.18),
            c.near.withValues(alpha: 0.12),
          ],
        ).createShader(Rect.fromLTRB(0, h * 0.72, w, h)),
    );

    // A path trodden in the snow, winding from the front of the card to
    // the planet's foot and narrowing as it goes -- the user's comment, 26
    // September 2026. The rows bunch up towards the horizon, the way
    // distance closes up on the ground.
    final List<Offset> left = <Offset>[];
    final List<Offset> right = <Offset>[];
    for (int i = 0; i <= 48; i++) {
      final double v = i / 48;
      final double y =
          h * (1.02 - 0.27 * (1 - math.pow(1 - v, 1.8).toDouble()));
      // More bends and a narrower track, from the user's second comment:
      // the first path made one broad swing and was a third of the card
      // wide at the front.
      final double x = w * (0.5 + 0.12 * (1 - v) * math.sin(v * 4.4 * math.pi));
      final double half = w * 0.085 * math.pow(1 - v, 1.5).toDouble() + 0.6;
      left.add(Offset(x - half, y));
      right.add(Offset(x + half, y));
    }
    final Path path = Path()
      ..addPolygon(<Offset>[...left, ...right.reversed], true);
    canvas
      ..save()
      ..clipPath(field)
      ..drawPath(
          path,
          Paint()
            ..isAntiAlias = true
            ..color = Color.lerp(c.ground, c.near, 0.22)!)
      ..drawPoints(
          ui.PointMode.polygon,
          left,
          Paint()
            ..isAntiAlias = true
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = Color.lerp(c.ground, c.glow, 0.5)!)
      ..restore();
  }

  void _blossomTerraces(Canvas canvas) {
    _sun(canvas, Offset(w * 0.76, h * 0.18), w * 0.06);

    // A large ringed planet rising behind the top terrace, in the scene's
    // own coral and rose, where two mountains stood until the user's
    // comment of 26 September 2026. Glowing and softened, from the next.
    // A soft burnt orange rather than the sun's coral, from the user's
    // comment the same day: warm, and kept quiet by `soften`.
    _planet(canvas, Offset(w * 0.42, h * 0.45), w * 0.3,
        tilt: -0.25, glow: 0.45, soften: 0.7, tint: const Color(0xFFD9895C));

    // The terraces: four shelves, each a gentle arc, stepping down and
    // darkening towards the front, with a pale lip where the light catches.
    final List<(double, Color)> shelves = <(double, Color)>[
      (0.50, Color.lerp(c.far, c.near, 0.2)!),
      (0.62, Color.lerp(c.far, c.near, 0.6)!),
      (0.74, c.near),
      (0.87, c.ground),
    ];
    for (int i = 0; i < shelves.length; i++) {
      final (double y, Color colour) = shelves[i];
      final Path shelf = Path()
        ..moveTo(0, h * (y + 0.03))
        ..quadraticBezierTo(w * 0.5, h * (y - 0.03), w, h * (y + 0.02))
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(shelf, _hazed(colour, h * (y - 0.03), h, 0.2));
      canvas.drawPath(
        Path()
          ..moveTo(0, h * (y + 0.03))
          ..quadraticBezierTo(w * 0.5, h * (y - 0.03), w, h * (y + 0.02)),
        Paint()
          ..isAntiAlias = true
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = c.glow.withValues(alpha: 0.4),
      );
      // The blossom trees on this shelf.
      for (final (double x, double s) in <List<(double, double)>>[
        <(double, double)>[(0.3, 0.5), (0.7, 0.45)],
        <(double, double)>[(0.18, 0.7), (0.84, 0.6)],
        <(double, double)>[(0.62, 0.9)],
        <(double, double)>[(0.12, 1.3), (0.9, 1.1)],
      ][i]) {
        _blossom(canvas, Offset(w * x, h * (y + 0.005)), w * 0.06 * s,
            Color.lerp(colour, c.ground, 0.4)!);
      }
    }

    _mist(canvas, h * 0.56, h * 0.06, 0.45);
    _mist(canvas, h * 0.70, h * 0.05, 0.3);
  }

  void _lighthouseCliffs(Canvas canvas) {
    final Offset sun = Offset(w * 0.28, h * 0.46);
    _sun(canvas, sun, w * 0.08);

    final double horizon = h * 0.56;
    final Rect sea = Rect.fromLTRB(0, horizon, w, h);
    canvas.drawRect(
      sea,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color.lerp(c.horizon, c.far, 0.5)!, c.far],
        ).createShader(sea),
    );
    canvas.drawRect(
      Rect.fromLTRB(sun.dx - w * 0.05, horizon + 2, sun.dx + w * 0.05, h),
      Paint()
        ..color = c.glow.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // A far headland, hazy, and the near cliff on the right.
    final Path headland = Path()
      ..moveTo(0, horizon)
      ..quadraticBezierTo(w * 0.1, horizon - h * 0.07, w * 0.22, horizon)
      ..close();
    canvas.drawPath(
        headland, Paint()..color = Color.lerp(c.near, c.skyBottom, 0.5)!);

    final Path cliff = Path()
      ..moveTo(w * 0.48, h)
      ..cubicTo(w * 0.54, h * 0.72, w * 0.58, h * 0.52, w * 0.66, h * 0.48)
      ..quadraticBezierTo(w * 0.84, h * 0.44, w, h * 0.46)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(cliff, _hazed(c.near, h * 0.46, h, 0.0));
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.56, h)
        ..cubicTo(w * 0.62, h * 0.8, w * 0.66, h * 0.62, w * 0.72, h * 0.54)
        ..lineTo(w, h * 0.54)
        ..lineTo(w, h)
        ..close(),
      Paint()..color = c.ground.withValues(alpha: 0.5),
    );
    // The cliff's lit edge, facing the sun.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.48, h)
        ..cubicTo(w * 0.54, h * 0.72, w * 0.58, h * 0.52, w * 0.66, h * 0.48),
      Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = c.glow.withValues(alpha: 0.4),
    );

    // The lighthouse: a slim tapered tower with two bands, and a lamp. The
    // beam turns, so it is drawn with the life.
    final double base = h * 0.455;
    final double x = w * 0.82;
    final double tall = h * 0.22;
    final double foot = w * 0.045;
    final double top = _lighthouseTop;
    final Path tower = Path()
      ..moveTo(x - foot, base)
      ..lineTo(x - top, base - tall)
      ..lineTo(x + top, base - tall)
      ..lineTo(x + foot, base)
      ..close();
    canvas.drawPath(tower, Paint()..color = c.glow);
    canvas.save();
    canvas.clipPath(tower);
    final Paint band = Paint()..color = c.accent;
    canvas.drawRect(
        Rect.fromLTRB(0, base - tall * 0.36, w, base - tall * 0.24), band);
    canvas.drawRect(
        Rect.fromLTRB(0, base - tall * 0.72, w, base - tall * 0.6), band);
    // The tower's shaded side, away from the sun.
    canvas.drawRect(Rect.fromLTRB(x + foot * 0.15, base - tall, w, base),
        Paint()..color = c.deep.withValues(alpha: 0.14));
    canvas.restore();
    final Offset lamp = _lighthouseLamp;
    canvas.drawRect(
        Rect.fromCenter(center: lamp, width: top * 1.6, height: top * 1.4),
        Paint()..color = c.body);
    canvas.drawPath(
      Path()
        ..moveTo(lamp.dx - top * 1.1, lamp.dy - top * 0.7)
        ..lineTo(lamp.dx, lamp.dy - top * 1.8)
        ..lineTo(lamp.dx + top * 1.1, lamp.dy - top * 0.7)
        ..close(),
      Paint()..color = c.ground,
    );
  }

  // The peak the dawn pond mirrors, and where the forest meets the water.
  static const (double, double, double, double) _pondPeak =
      (0.50, 0.30, 0.36, 0.36);

  void _dawnPond(Canvas canvas) {
    final double shore = h * 0.56;
    _sun(canvas, Offset(w * 0.84, h * 0.33), w * 0.04);

    // Everything above the water, painted twice: once as it stands, once
    // upside down in the pond.
    void above(Canvas canvas) {
      _range(
          canvas,
          shore,
          const <(double, double, double, double)>[
            _pondPeak,
          ],
          c.far,
          0.45,
          light: 0.84);
      _snowCap(canvas, shore, _pondPeak, 0.42, light: 0.84);
      _range(
          canvas,
          shore,
          const <(double, double, double, double)>[
            (0.14, 0.06, 0.22, 0.2),
            (0.86, 0.05, 0.2, 0.22),
          ],
          Color.lerp(c.far, c.near, 0.35)!,
          0.3,
          light: 0.84);

      // Two forested banks reaching in from the sides.
      final Paint forest = Paint()
        ..isAntiAlias = true
        ..color = c.near;
      canvas
        ..drawPath(
            Path()
              ..moveTo(0, shore - h * 0.03)
              ..quadraticBezierTo(w * 0.2, shore - h * 0.03, w * 0.34, shore)
              ..lineTo(0, shore)
              ..close(),
            forest)
        ..drawPath(
            Path()
              ..moveTo(w, shore - h * 0.035)
              ..quadraticBezierTo(w * 0.8, shore - h * 0.03, w * 0.7, shore)
              ..lineTo(w, shore)
              ..close(),
            forest);
      for (final (double x, double tall) in <(double, double)>[
        (0.01, 0.15),
        (0.05, 0.11),
        (0.08, 0.14),
        (0.12, 0.10),
        (0.16, 0.08),
        (0.20, 0.07),
        (0.24, 0.05),
        (0.28, 0.04),
        (0.99, 0.16),
        (0.95, 0.12),
        (0.92, 0.14),
        (0.88, 0.10),
        (0.84, 0.08),
        (0.80, 0.06),
        (0.76, 0.045),
      ]) {
        canvas.drawPath(_pine(Offset(w * x, shore + 1), h * tall), forest);
      }
    }

    above(canvas);

    // The water: the dawn sky again, a shade deeper towards the front.
    final Rect water = Rect.fromLTRB(0, shore, w, h);
    canvas.drawRect(
      water,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color.lerp(c.horizon, c.far, 0.3)!,
            c.skyTop,
            Color.lerp(c.skyTop, c.deep, 0.18)!,
          ],
          stops: const <double>[0, 0.45, 1],
        ).createShader(water),
    );

    // The reflection: still water, so a clean mirror, faded.
    canvas
      ..saveLayer(water, Paint()..color = const Color.fromRGBO(0, 0, 0, 0.4))
      ..translate(0, shore * 2)
      ..scale(1, -1);
    above(canvas);
    canvas.restore();

    _mist(canvas, shore + h * 0.01, h * 0.025, 0.55);

    // A blossom branch reaching in over the top of the card.
    final Color bark = Color.lerp(c.deep, c.near, 0.25)!;
    final Paint limb = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = bark;
    canvas
      ..drawPath(
          Path()
            ..moveTo(-w * 0.02, h * 0.13)
            ..quadraticBezierTo(w * 0.3, h * 0.02, w * 0.72, h * 0.07),
          limb..strokeWidth = w * 0.014)
      ..drawPath(
          Path()
            ..moveTo(w * 0.72, h * 0.07)
            ..quadraticBezierTo(w * 0.82, h * 0.09, w * 0.9, h * 0.06),
          limb..strokeWidth = w * 0.006);
    for (final (double x0, double y0, double x1, double y1)
        in <(double, double, double, double)>[
      (0.18, 0.08, 0.26, 0.16),
      (0.34, 0.05, 0.42, 0.13),
      (0.48, 0.05, 0.50, 0.00),
      (0.58, 0.06, 0.66, 0.14),
      (0.10, 0.10, 0.06, 0.19),
    ]) {
      canvas.drawLine(Offset(w * x0, h * y0), Offset(w * x1, h * y1),
          limb..strokeWidth = w * 0.005);
    }
    final Paint flower = Paint()
      ..isAntiAlias = true
      ..color = c.accent;
    final Paint heart = Paint()..color = Color.lerp(c.accent, c.deep, 0.35)!;
    for (final (double x, double y, double r) in <(double, double, double)>[
      (0.12, 0.10, 1.1),
      (0.07, 0.18, 1.0),
      (0.21, 0.07, 0.9),
      (0.26, 0.16, 1.2),
      (0.30, 0.05, 0.8),
      (0.42, 0.13, 1.1),
      (0.38, 0.04, 0.9),
      (0.50, 0.01, 0.8),
      (0.55, 0.06, 1.0),
      (0.66, 0.14, 1.1),
      (0.63, 0.08, 0.8),
      (0.76, 0.08, 0.9),
      (0.86, 0.065, 0.8),
    ]) {
      // Five petals round a dark heart.
      final Offset at = Offset(w * x, h * y);
      final double p = w * 0.011 * r;
      for (int k = 0; k < 5; k++) {
        final double a = 2 * math.pi * k / 5 + x * 7;
        canvas.drawCircle(
            at + Offset(math.cos(a), math.sin(a)) * p * 0.9, p * 0.75, flower);
      }
      canvas.drawCircle(at, p * 0.4, heart);
    }
  }

  static const (double, double, double, double) _snowPeak =
      (0.52, 0.12, 0.2, 0.2);

  // Where the lone tree stands on the snowfield.
  // Centred, and 28 points lower on the 663-point card than it first
  // stood -- the user's comment, 26 September 2026.
  Offset get _snowTreeBase => Offset(w * 0.5, h * (0.72 + 28 / 663));

  void _snowTree(Canvas canvas) {
    final double shore = h * 0.56;
    _range(
        canvas,
        shore,
        const <(double, double, double, double)>[
          _snowPeak,
        ],
        Color.lerp(c.far, c.skyBottom, 0.3)!,
        0.5,
        light: 0.3);
    _snowCap(canvas, shore, _snowPeak, 0.55, light: 0.3);
    _range(
        canvas,
        shore,
        const <(double, double, double, double)>[
          (0.06, 0.07, 0.3, 0.25),
          (0.34, 0.045, 0.2, 0.2),
          (0.74, 0.06, 0.25, 0.2),
          (1.02, 0.08, 0.3, 0.3),
        ],
        c.far,
        0.35,
        light: 0.3);
    _range(
        canvas,
        shore + h * 0.012,
        const <(double, double, double, double)>[
          (0.0, 0.035, 0.3, 0.42),
          (0.92, 0.042, 0.4, 0.3),
        ],
        c.near,
        0.25,
        light: 0.3);

    // The snowfield: pale near the ridges, warming to the dawn at the front.
    final Rect field = Rect.fromLTRB(0, shore + h * 0.01, w, h);
    canvas.drawRect(
      field,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            c.ground,
            Color.lerp(c.ground, c.horizon, 0.75)!,
          ],
        ).createShader(field),
    );

    // The tree's blue shadow on the snow, then the tree.
    final Offset base = _snowTreeBase;
    canvas.drawOval(
      Rect.fromCenter(
          center: base + Offset(w * 0.02, h * 0.005),
          width: w * 0.26,
          height: h * 0.025),
      Paint()
        ..color = Color.lerp(c.ground, c.near, 0.4)!.withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    _blossom(canvas, base, w * 0.075, Color.lerp(c.near, c.deep, 0.45)!);
  }

  void _pastelShore(Canvas canvas) {
    final double line = _shoreLine;
    _sun(canvas, Offset(w * 0.8, h * 0.4), w * 0.075);

    // Low lilac cloud sitting on the horizon at either side.
    _cloud(canvas, Offset(-w * 0.04, line), w * 0.3,
        const <(double, double)>[(0.2, 0.2), (0.5, 0.14), (0.8, 0.09)], c.far);
    _cloud(canvas, Offset(w * 0.74, line), w * 0.3,
        const <(double, double)>[(0.2, 0.08), (0.5, 0.15), (0.84, 0.2)], c.far);

    // A bright strip of wet sand, then the water.
    canvas.drawRect(Rect.fromLTRB(0, line - 1, w, line + h * 0.014),
        Paint()..color = Color.lerp(c.horizon, c.glow, 0.3)!);
    final Rect water = Rect.fromLTRB(0, line + h * 0.014, w, h);
    canvas.drawRect(
      water,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[c.far, c.near, c.ground],
          stops: const <double>[0, 0.45, 1],
        ).createShader(water),
    );

    // The crane, and its reflection straight down in the still water.
    final Offset feet = _craneFeet;
    final double s = h * 0.13;
    final Color bird = Color.lerp(c.ground, c.deep, 0.75)!;
    canvas
      ..saveLayer(water, Paint()..color = const Color.fromRGBO(0, 0, 0, 0.3))
      ..translate(0, feet.dy * 2)
      ..scale(1, -1);
    _crane(canvas, feet, s, bird);
    canvas.restore();
    _crane(canvas, feet, s, bird);
  }

  // A point on a quadratic curve whose control sits half way across, so the
  // share across is the curve's own parameter. Used to stand things on a
  // hill's crest.
  static double _onCurve(double t, double a, double mid, double b) =>
      (1 - t) * (1 - t) * a + 2 * t * (1 - t) * mid + t * t * b;

  // ---- From the second set of references, 26 September 2026 ----

  void _cabinIsland(Canvas canvas) {
    final double water = _cabinWater;
    final Offset sun = Offset(w * 0.52, water - h * 0.19);
    final double r = w * 0.22;
    _sun(canvas, sun, r);

    // Low far ridges on the horizon either side of the island.
    _range(
        canvas,
        water,
        const <(double, double, double, double)>[
          (0.06, 0.05, 0.14, 0.12),
          (0.2, 0.035, 0.1, 0.12),
          (0.82, 0.04, 0.12, 0.12),
          (0.96, 0.06, 0.12, 0.1),
        ],
        Color.lerp(c.far, c.skyBottom, 0.35)!,
        0.5,
        light: 0.52);

    final Rect sea = Rect.fromLTRB(0, water, w, h);
    canvas.drawRect(
      sea,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color.lerp(c.horizon, c.glow, 0.2)!,
            Color.lerp(c.skyBottom, c.far, 0.35)!,
            Color.lerp(c.skyTop, c.far, 0.5)!,
          ],
          stops: const <double>[0, 0.35, 1],
        ).createShader(sea),
    );

    // The mirror: the sun, the pines, the rock and the cabin upside down,
    // faded, then broken by pale lines.
    canvas
      ..save()
      ..clipRect(sea)
      ..saveLayer(sea, Paint()..color = const Color.fromRGBO(0, 0, 0, 0.4))
      ..translate(0, water * 2)
      ..scale(1, -1)
      ..drawCircle(sun, r, Paint()..color = c.body.withValues(alpha: 0.6));
    _cabinIslandBody(canvas);
    canvas
      ..restore()
      ..restore();
    _breaks(canvas, water + h * 0.012, h * 0.98, 41, 18, c.glow, 0.55);

    _cabinIslandBody(canvas);
  }

  void _cabinIslandBody(Canvas canvas) {
    final double water = _cabinWater;
    final Offset at = _cabinAt;
    final double top = at.dy;

    // Pale pines behind the cabin, as (share of the width, height as a share
    // of the card, nearer). Each has a lit half on the sun's side.
    for (final (double x, double tall, bool nearer)
        in const <(double, double, bool)>[
      (0.2, 0.17, false),
      (0.25, 0.12, true),
      (0.31, 0.2, false),
      (0.37, 0.14, true),
      (0.44, 0.18, false),
      (0.6, 0.27, false),
      (0.66, 0.31, true),
      (0.73, 0.2, false),
      (0.79, 0.16, true),
      (0.85, 0.12, false),
    ]) {
      final Color tree = nearer ? c.near : Color.lerp(c.near, c.far, 0.55)!;
      final Path pine = _pine(Offset(w * x, top), h * tall);
      canvas.drawPath(
          pine,
          Paint()
            ..isAntiAlias = true
            ..color = tree);
      final bool litRight = x < 0.52;
      canvas
        ..save()
        ..clipPath(pine)
        ..drawRect(
            litRight
                ? Rect.fromLTRB(w * x, 0, w, h)
                : Rect.fromLTRB(0, 0, w * x, h),
            Paint()..color = Color.lerp(tree, c.glow, 0.28)!)
        ..restore();
    }

    // The rock: a flat slab with a lit top and faceted shade on its front,
    // two boulders at its right-hand foot.
    final Color rock = c.ground;
    final Path slab = Path()
      ..moveTo(w * 0.12, top + h * 0.004)
      ..lineTo(w * 0.3, top - h * 0.004)
      ..lineTo(w * 0.78, top - h * 0.002)
      ..lineTo(w * 0.9, top + h * 0.01)
      ..lineTo(w * 0.86, water + h * 0.008)
      ..lineTo(w * 0.16, water + h * 0.008)
      ..lineTo(w * 0.08, water - h * 0.004)
      ..close();
    final Paint shade = Paint()
      ..isAntiAlias = true
      ..color = Color.lerp(rock, c.deep, 0.25)!;
    canvas
      ..drawPath(
          slab,
          Paint()
            ..isAntiAlias = true
            ..color = rock)
      ..save()
      ..clipPath(slab)
      ..drawRect(Rect.fromLTRB(0, top - h * 0.01, w, top + h * 0.009),
          Paint()..color = Color.lerp(rock, c.glow, 0.4)!);
    for (final (double a, double b, double peak)
        in const <(double, double, double)>[
      (0.18, 0.34, 0.26),
      (0.5, 0.62, 0.56),
      (0.7, 0.9, 0.82),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(w * a, water + h * 0.01)
          ..lineTo(w * peak, top + h * 0.009)
          ..lineTo(w * b, water + h * 0.01)
          ..close(),
        shade,
      );
    }
    canvas.restore();
    for (final (double x, double s) in const <(double, double)>[
      (0.8, 0.07),
      (0.9, 0.05),
    ]) {
      canvas
        ..drawPath(
          Path()
            ..moveTo(w * (x - s), water + h * 0.006)
            ..lineTo(w * (x - s * 0.5), water - h * s * 0.45)
            ..lineTo(w * (x + s * 0.4), water - h * s * 0.5)
            ..lineTo(w * (x + s), water + h * 0.006)
            ..close(),
          Paint()
            ..isAntiAlias = true
            ..color = Color.lerp(rock, c.glow, 0.15)!,
        )
        ..drawPath(
          Path()
            ..moveTo(w * (x + s * 0.4), water - h * s * 0.5)
            ..lineTo(w * (x + s), water + h * 0.006)
            ..lineTo(w * x, water + h * 0.006)
            ..close(),
          shade,
        );
    }

    // The cabin. Its wood is the one warm solid in the scene, so it is a
    // fixed warm brown taken towards the scene's own deep colour, rather
    // than a slot: none of the scene's slots is wood, and the windows only
    // read as lit against something warm and dark.
    final double s = _cabinSize;
    final Color wood = Color.lerp(c.deep, const Color(0xFFC8784C), 0.72)!;
    final Path walls = _place(_cabinWalls, at, s);
    final Path gable = _place(_cabinGable, at, s);
    canvas
      ..drawPath(
          walls,
          Paint()
            ..isAntiAlias = true
            ..color = wood)
      ..drawPath(
          gable,
          Paint()
            ..isAntiAlias = true
            ..color = Color.lerp(wood, c.glow, 0.18)!);
    // The logs: a darker line every few units, across both walls.
    final Paint log = Paint()
      ..strokeWidth = math.max(1, s * 0.012)
      ..color = Color.lerp(wood, c.deep, 0.35)!;
    canvas
      ..save()
      ..clipPath(Path.combine(PathOperation.union, walls, gable));
    for (double y = -4; y > -44; y -= 4.5) {
      canvas.drawLine(Offset(at.dx - s * 0.42, at.dy + s * y / 100),
          Offset(at.dx + s * 0.54, at.dy + s * y / 100), log);
    }
    canvas
      ..restore()
      ..drawPath(
          _place(_cabinWindows, at, s),
          Paint()
            ..isAntiAlias = true
            ..color = c.accent)
      ..drawPath(
          _place(_cabinRoof, at, s),
          Paint()
            ..isAntiAlias = true
            ..color = Color.lerp(c.deep, c.ground, 0.3)!);
  }

  void _desertBeacon(Canvas canvas) {
    // A great ringed planet rising behind the sand, in place of the peak
    // and its beam -- the user's comment, 26 September 2026. Its foot sinks
    // into the haze and the far dunes cover the rest.
    // The castle high on the left, in the sky's own colour a step paler
    // and faded, so it reads as far off. Its foot is hidden by the cloud
    // bank drawn with the life, which drifts.
    canvas
      ..saveLayer(Rect.fromLTWH(0, 0, w, h * 0.5),
          Paint()..color = const Color.fromRGBO(0, 0, 0, 0.32))
      ..drawPath(
          _place(_castle, _castleAt, h * 0.1),
          Paint()
            ..isAntiAlias = true
            ..color = Color.lerp(c.skyTop, c.glow, 0.45)!)
      ..restore();
    _planet(canvas, _summit, w * 0.3, tilt: -0.3);

    // Everything from the haze down is drawn as it was and lifted, and the
    // near sand is carried on to the foot of the card.
    canvas
      ..save()
      ..translate(0, -_duneLift);
    _mist(canvas, h * 0.67, h * 0.04, 0.85);

    // Far dunes: long low swells, pale.
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.72)
        ..quadraticBezierTo(w * 0.2, h * 0.68, w * 0.42, h * 0.71)
        ..quadraticBezierTo(w * 0.7, h * 0.74, w, h * 0.69)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      _hazed(Color.lerp(c.near, c.far, 0.3)!, h * 0.68, h * 0.8, 0.3),
    );

    // A middle dune on the right, its crest a sharp line with the shaded
    // face behind it, away from the light.
    canvas
      ..drawPath(
        Path()
          ..moveTo(w * 0.3, h * 0.8)
          ..quadraticBezierTo(w * 0.6, h * 0.75, w, h * 0.72)
          ..lineTo(w, h)
          ..lineTo(w * 0.3, h)
          ..close(),
        Paint()
          ..isAntiAlias = true
          ..color = c.near,
      )
      ..drawPath(
        Path()
          ..moveTo(w * 0.6, h * 0.756)
          ..quadraticBezierTo(w * 0.8, h * 0.735, w, h * 0.725)
          ..lineTo(w, h * 0.8)
          ..quadraticBezierTo(w * 0.8, h * 0.79, w * 0.6, h * 0.756)
          ..close(),
        Paint()
          ..isAntiAlias = true
          ..color = Color.lerp(c.near, c.deep, 0.18)!,
      );

    // The near sand the walker stands on, lighter at its crest.
    final Rect front = Rect.fromLTRB(0, h * 0.78, w, h);
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.8)
        ..quadraticBezierTo(w * 0.3, h * 0.78, w * 0.55, h * 0.83)
        ..quadraticBezierTo(w * 0.8, h * 0.88, w, h * 0.86)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      Paint()
        ..isAntiAlias = true
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color.lerp(c.ground, c.glow, 0.15)!, c.ground],
        ).createShader(front),
    );
    canvas
      ..restore()
      ..drawRect(
          Rect.fromLTRB(0, h - _duneLift - 1, w, h), Paint()..color = c.ground);
  }

  void _boatmanSunset(Canvas canvas) {
    final double sea = _boatSea;
    final Offset sun = Offset(w * 0.5, sea - h * 0.13);
    final double r = w * 0.28;

    // Low banks of cloud either side of the sun, each lit along its top. A
    // tower of cloud stood behind the sun until the user took it out, 26
    // September 2026.
    final Color cloud = Color.lerp(c.horizon, c.skyBottom, 0.3)!;
    final Color lit = Color.lerp(cloud, c.glow, 0.5)!;
    _cloud(
        canvas,
        Offset(-w * 0.05, sea),
        w * 0.45,
        const <(double, double)>[
          (0.1, 0.14),
          (0.4, 0.2),
          (0.7, 0.14),
          (0.95, 0.08)
        ],
        cloud,
        lit: lit);
    _cloud(
        canvas,
        Offset(w * 0.62, sea),
        w * 0.45,
        const <(double, double)>[
          (0.05, 0.08),
          (0.3, 0.15),
          (0.6, 0.21),
          (0.9, 0.14)
        ],
        cloud,
        lit: lit);

    // Thin streaks of high cloud.
    final Paint streak = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = Color.lerp(c.skyBottom, c.glow, 0.4)!.withValues(alpha: 0.6);
    for (final (double x, double y, double len)
        in const <(double, double, double)>[
      (0.08, 0.2, 0.3),
      (0.5, 0.16, 0.38),
      (0.2, 0.27, 0.22),
      (0.66, 0.3, 0.26),
    ]) {
      canvas.drawLine(
          Offset(w * x, h * y), Offset(w * (x + len), h * y), streak);
    }

    _sun(canvas, sun, r);
    _range(
        canvas,
        sea,
        const <(double, double, double, double)>[
          (0.04, 0.04, 0.14, 0.2),
          (0.95, 0.035, 0.2, 0.12),
        ],
        c.far,
        0.4,
        light: 0.5);

    final Rect water = Rect.fromLTRB(0, sea, w, h);
    canvas.drawRect(
      water,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color.lerp(c.glow, c.horizon, 0.4)!,
            c.near,
            c.ground,
          ],
          stops: const <double>[0, 0.45, 1],
        ).createShader(water),
    );

    // The sun laid on the water: bright bars, widest near the horizon.
    final math.Random rng = math.Random(53);
    for (int i = 0; i < 14; i++) {
      final double q = i / 13;
      final double y = sea + h * 0.008 + h * 0.24 * q * q;
      final double half =
          r * (0.95 - 0.35 * q) * (0.6 + 0.4 * rng.nextDouble());
      final double x = w * 0.5 + (rng.nextDouble() - 0.5) * r * 0.3;
      canvas.drawLine(
        Offset(x - half, y),
        Offset(x + half, y),
        Paint()
          ..strokeWidth = 1.5 + 2.5 * (1 - q)
          ..strokeCap = StrokeCap.round
          ..color = c.body.withValues(alpha: 0.6 * (1 - q * 0.6)),
      );
    }
    _breaks(canvas, sea + h * 0.02, h * 0.98, 57, 12, c.glow, 0.35);
  }

  void _moonBoat(Canvas canvas) {
    final double sea = _moonSea;
    final Offset moon = Offset(w * 0.5, sea - h * 0.08);
    final double r = w * 0.27;

    canvas
      ..drawCircle(
          moon, r * 1.55, Paint()..color = c.glow.withValues(alpha: 0.07))
      ..drawCircle(
          moon, r * 1.25, Paint()..color = c.glow.withValues(alpha: 0.09));
    _halo(canvas, moon, r);
    _moon(canvas, moon, r);

    // Low banks of cloud on the horizon, lit along their tops, the inner
    // ends laid over the moon's edge.
    final Color bank = Color.lerp(c.far, c.glow, 0.3)!;
    _cloud(
        canvas,
        Offset(-w * 0.06, sea),
        w * 0.42,
        const <(double, double)>[
          (0.1, 0.12),
          (0.35, 0.2),
          (0.6, 0.16),
          (0.85, 0.1)
        ],
        c.far,
        lit: bank);
    _cloud(
        canvas,
        Offset(w * 0.64, sea),
        w * 0.42,
        const <(double, double)>[
          (0.15, 0.1),
          (0.4, 0.16),
          (0.65, 0.21),
          (0.9, 0.14)
        ],
        c.far,
        lit: bank);

    final Rect water = Rect.fromLTRB(0, sea, w, h);
    canvas
      ..drawRect(
        water,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color.lerp(c.far, c.glow, 0.12)!, c.ground],
          ).createShader(water),
      )
      // The moon's reflection, faded, then broken by lines.
      ..save()
      ..clipRect(water)
      ..drawCircle(Offset(moon.dx, sea * 2 - moon.dy), r,
          Paint()..color = c.body.withValues(alpha: 0.12))
      ..restore()
      ..drawLine(Offset(0, sea), Offset(w, sea),
          Paint()..color = c.glow.withValues(alpha: 0.4));
    _breaks(canvas, sea + h * 0.01, h * 0.98, 61, 16, c.glow, 0.4);
  }

  void _toriiPeaks(Canvas canvas) {
    _sun(canvas, Offset(w * 0.26, h * 0.22), w * 0.2);
    final double foot = h * 0.9;
    const double light = 0.26;

    _range(
        canvas,
        foot,
        const <(double, double, double, double)>[
          (0.44, 0.34, 0.2, 0.16),
          (0.62, 0.42, 0.14, 0.2),
        ],
        c.far,
        0.5,
        light: light);
    _mist(canvas, h * 0.72, h * 0.06, 0.5);

    const (double, double, double, double) tall = (0.82, 0.62, 0.2, 0.3);
    _range(
        canvas,
        foot,
        const <(double, double, double, double)>[
          (0.1, 0.5, 0.24, 0.2),
          tall,
        ],
        c.near,
        0.45,
        light: light);
    _mist(canvas, h * 0.84, h * 0.05, 0.45);
    _range(
        canvas,
        h,
        const <(double, double, double, double)>[
          (0.0, 0.3, 0.2, 0.3),
          (1.0, 0.36, 0.34, 0.2),
        ],
        Color.lerp(c.near, c.ground, 0.55)!,
        0.3,
        light: light);

    // The gate stands on a cliff: a rocky top running in from the left and
    // ending in a sheer drop, the ranges falling away below it. The user's
    // comment, 26 September 2026, and the torii reference, where the gate is
    // at a cliff's edge. It replaced two flat ledges with a path between.
    final Path cliff = Path()
      ..moveTo(0, h * 0.895)
      ..lineTo(w * 0.1, h * 0.882)
      ..lineTo(w * 0.24, h * 0.9)
      ..lineTo(w * 0.5, h * 0.91)
      ..lineTo(w * 0.66, h * 0.918)
      ..lineTo(w * 0.7, h * 0.93)
      ..lineTo(w * 0.68, h * 0.955)
      ..lineTo(w * 0.71, h * 0.975)
      ..lineTo(w * 0.69, h)
      ..lineTo(0, h)
      ..close();
    canvas
      ..drawPath(
          cliff,
          Paint()
            ..isAntiAlias = true
            ..color = c.ground)
      ..save()
      ..clipPath(cliff)
      // The face of the drop, turned away from the sun.
      ..drawPath(
        Path()
          ..moveTo(w * 0.6, h)
          ..lineTo(w * 0.64, h * 0.925)
          ..lineTo(w * 0.72, h * 0.925)
          ..lineTo(w * 0.72, h)
          ..close(),
        Paint()..color = Color.lerp(c.ground, c.deep, 0.35)!,
      )
      // The lit rim along the top.
      ..drawPath(
        Path()
          ..moveTo(0, h * 0.895)
          ..lineTo(w * 0.1, h * 0.882)
          ..lineTo(w * 0.24, h * 0.9)
          ..lineTo(w * 0.5, h * 0.91)
          ..lineTo(w * 0.66, h * 0.918),
        Paint()
          ..isAntiAlias = true
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Color.lerp(c.ground, c.far, 0.45)!,
      )
      ..restore();

    canvas.drawPath(
        _place(_torii, Offset(w * 0.42, h * 0.912), h * 0.19),
        Paint()
          ..isAntiAlias = true
          ..color = Color.lerp(c.ground, c.deep, 0.5)!);
  }

  void _snowSlope(Canvas canvas) {
    final Offset sun = Offset(w * 0.82, h * 0.13);
    const double light = 0.82;
    _sun(canvas, sun, w * 0.06);

    const (double, double, double, double) peak = (0.62, 0.26, 0.26, 0.3);
    _range(
        canvas,
        h * 0.5,
        const <(double, double, double, double)>[
          (0.2, 0.2, 0.3, 0.25),
          peak,
        ],
        c.far,
        0.5,
        light: light);
    _snowCap(canvas, h * 0.5, peak, 0.45, light: light);
    _mist(canvas, h * 0.49, h * 0.04, 0.5);
    _range(
        canvas,
        h * 0.62,
        const <(double, double, double, double)>[
          (0.05, 0.16, 0.2, 0.3),
          (0.45, 0.14, 0.25, 0.25),
          (0.92, 0.2, 0.3, 0.25),
        ],
        c.near,
        0.4,
        light: light);

    // The slope, falling from the left to the right-hand foot of the card.
    double slopeY(double x) => h * _onCurve(x, 0.52, 0.6, 0.8);
    final Path slope = Path()
      ..moveTo(0, h * 0.52)
      ..quadraticBezierTo(w * 0.5, h * 0.6, w, h * 0.8)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      slope,
      Paint()
        ..isAntiAlias = true
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[c.ground, Color.lerp(c.ground, c.far, 0.25)!],
        ).createShader(Rect.fromLTRB(0, h * 0.52, w, h)),
    );

    // Wide faint bands lying along the slope.
    canvas
      ..save()
      ..clipPath(slope);
    for (int i = 0; i < 4; i++) {
      canvas.drawPath(
        Path()
          ..moveTo(-w * 0.1, h * (0.56 + 0.1 * i))
          ..quadraticBezierTo(
              w * 0.5, h * (0.64 + 0.1 * i), w * 1.1, h * (0.86 + 0.1 * i)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = h * 0.045
          ..color = (i.isEven ? c.far : c.glow).withValues(alpha: 0.1),
      );
    }
    canvas.restore();

    // Pines on the snow, each with its shadow laid across the slope away
    // from the sun. As (share of the width, how far below the edge, height,
    // striped).
    final Color pale = Color.lerp(c.near, c.glow, 0.5)!;
    final Color band = Color.lerp(c.near, c.deep, 0.45)!;
    final Color dark = Color.lerp(c.near, c.deep, 0.55)!;
    final Paint shadow = Paint()
      ..isAntiAlias = true
      ..color = Color.lerp(c.far, c.deep, 0.2)!.withValues(alpha: 0.35);
    for (final (double x, double below, double tall, bool striped)
        in const <(double, double, double, bool)>[
      (0.3, 0.03, 0.12, true),
      (0.4, 0.02, 0.08, true),
      (0.56, 0.05, 0.15, true),
      (0.7, 0.03, 0.09, false),
      (0.84, 0.06, 0.13, true),
      (0.14, 0.34, 0.42, false),
    ]) {
      final Offset base = Offset(w * x, slopeY(x) + h * below);
      final double t = h * tall;
      final double half = t * 0.18;
      final double len = t * 0.9;
      canvas.drawPath(
        Path()
          ..moveTo(base.dx - half, base.dy)
          ..lineTo(base.dx + half, base.dy)
          ..lineTo(base.dx - len + half * 0.3, base.dy + len * 0.28)
          ..lineTo(base.dx - len - half * 0.3, base.dy + len * 0.28)
          ..close(),
        shadow,
      );
      final Path pine = _pine(base, t);
      final Color body = striped ? pale : dark;
      canvas
        ..drawPath(
            pine,
            Paint()
              ..isAntiAlias = true
              ..color = body)
        ..save()
        ..clipPath(pine)
        ..drawRect(Rect.fromLTRB(base.dx, 0, w, h),
            Paint()..color = Color.lerp(body, c.glow, 0.2)!);
      if (striped) {
        for (final double k in const <double>[0.3, 0.55]) {
          canvas.drawRect(
              Rect.fromLTRB(0, base.dy - t * k - t * 0.06, w, base.dy - t * k),
              Paint()..color = band);
        }
      }
      canvas.restore();
    }
    _shafts(
        canvas,
        sun,
        const <(double, double)>[
          (2.05, 0.05),
          (2.35, 0.04),
          (1.8, 0.035),
        ],
        0.09);
  }

  void _desertRuins(Canvas canvas) {
    // A gigantic ringed planet filling most of the sky where the sun was,
    // and a smaller one far off with no rings, fading into the air -- the
    // user's comments, 26 September 2026.
    _planet(canvas, Offset(w * 0.14, h * 0.1), w * 0.06,
        rings: false, fade: 0.35);
    final Offset sun = Offset(w * 0.6, h * 0.3);
    // 15% smaller than it first was, then 20% smaller again and a little to
    // the right, from the user's comments the same day.
    _planet(canvas, sun, w * 0.42 * 0.85 * 0.8, tilt: -0.35);

    // Ancient buildings in the haze: a stepped pyramid, a domed hall and
    // an obelisk far off, and a columned temple nearer. A handful of big
    // simple shapes, from the user's comment of 26 September 2026: a city
    // skyline stood here for a while and read as too busy.
    final double foot = h * 0.8;
    Path far = Path();
    // The stepped pyramid.
    for (int i = 0; i < 5; i++) {
      final double half = w * (0.17 - i * 0.03);
      far.addRect(Rect.fromLTRB(
          w * 0.2 - half, foot - h * 0.056 * (i + 1), w * 0.2 + half, foot));
    }
    far
      // The domed hall: a drum, the dome, a small finial.
      ..addRect(Rect.fromLTRB(w * 0.6, h * 0.64, w * 0.84, foot))
      ..addOval(
          Rect.fromCircle(center: Offset(w * 0.72, h * 0.64), radius: w * 0.1))
      ..addRect(Rect.fromLTRB(
          w * 0.717, h * 0.64 - w * 0.13, w * 0.723, h * 0.64 - w * 0.09))
      // The obelisk, tapering to a small point.
      ..addPolygon(<Offset>[
        Offset(w * 0.91, foot),
        Offset(w * 0.925, h * 0.53),
        Offset(w * 0.935, h * 0.51),
        Offset(w * 0.945, h * 0.53),
        Offset(w * 0.96, foot),
      ], true);
    far = Path.combine(PathOperation.union, far, Path());
    canvas.drawPath(far, _hazed(c.far, h * 0.46, foot, 0.45));
    _mist(canvas, h * 0.62, h * 0.05, 0.45);
    // The columned temple: three steps, six columns under a beam, and a low
    // pediment. The gaps between the columns are cut through.
    Path temple = Path()
      ..addRect(Rect.fromLTRB(w * 0.28, h * 0.785, w * 0.64, foot))
      ..addRect(Rect.fromLTRB(w * 0.3, h * 0.772, w * 0.62, h * 0.786))
      ..addRect(Rect.fromLTRB(w * 0.32, h * 0.69, w * 0.6, h * 0.773))
      ..addPolygon(<Offset>[
        Offset(w * 0.31, h * 0.692),
        Offset(w * 0.46, h * 0.645),
        Offset(w * 0.61, h * 0.692),
      ], true);
    temple = Path.combine(PathOperation.union, temple, Path());
    for (int i = 0; i < 5; i++) {
      final double x = w * (0.345 + i * 0.052);
      temple = Path.combine(
          PathOperation.difference,
          temple,
          Path()
            ..addRect(Rect.fromLTRB(x, h * 0.705, x + w * 0.028, h * 0.772)));
    }
    // Lifted so its columns stand clear above the bridge deck.
    canvas
      ..save()
      ..translate(0, -h * 0.1)
      ..drawPath(temple,
          _hazed(Color.lerp(c.near, c.deep, 0.2)!, h * 0.645, foot, 0.25))
      ..restore();
    _mist(canvas, h * 0.77, h * 0.03, 0.4);

    // A still pool in the low ground to the right of the hill, the sun laid
    // on it as a pale column. Added 26 September 2026 so a boat could sit
    // on it, at the user's request.
    final double pool = _desertPool;
    final Rect water = Rect.fromLTRB(0, pool, w, h);
    canvas
      ..drawRect(
        water,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color.lerp(c.horizon, c.glow, 0.35)!,
              Color.lerp(c.far, c.skyBottom, 0.4)!,
            ],
          ).createShader(water),
      )
      ..drawRect(
        Rect.fromLTRB(sun.dx - w * 0.1, pool + 2, sun.dx + w * 0.1, h),
        Paint()
          ..color = c.glow.withValues(alpha: 0.3)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.03),
      )
      ..drawLine(Offset(0, pool), Offset(w, pool),
          Paint()..color = c.glow.withValues(alpha: 0.6));
    _breaks(canvas, pool + h * 0.01, h * 0.98, 101, 10, c.glow, 0.45);

    // A high stone bridge crossing the whole pool on tall piers, with an
    // arch between each pair and a rail along the top, and its reflection.
    // The user's comment, 26 September 2026: it was a low wooden jetty,
    // which had itself replaced a stone colonnade the same day.
    canvas
      ..save()
      ..clipRect(water)
      ..saveLayer(water, Paint()..color = const Color.fromRGBO(0, 0, 0, 0.3))
      ..translate(0, _bridgeWater * 2)
      ..scale(1, -1);
    _bridge(canvas);
    canvas
      ..restore()
      ..restore();
    _bridge(canvas);
  }

  void _bridge(Canvas canvas) {
    final double water = _bridgeWater;
    final double deckTop = h * 0.7;
    final double deckBottom = h * 0.72;
    final double spring = h * 0.8;
    final Color stone = Color.lerp(c.ground, c.deep, 0.3)!;
    final Paint fill = Paint()
      ..isAntiAlias = true
      ..color = stone;
    const List<double> piers = <double>[0.1, 0.37, 0.64, 0.91];
    final double half = w * 0.022;
    // The deck, end to end.
    canvas.drawRect(Rect.fromLTRB(-2, deckTop, w + 2, deckBottom), fill);
    // The piers, a little wider at their feet.
    for (final double x in piers) {
      canvas.drawPath(
        Path()
          ..moveTo(w * x - half, deckBottom)
          ..lineTo(w * x + half, deckBottom)
          ..lineTo(w * x + half * 1.3, water)
          ..lineTo(w * x - half * 1.3, water)
          ..close(),
        fill,
      );
    }
    // The stone over each arch, from the deck down to the curve.
    for (int i = 0; i < piers.length - 1; i++) {
      final double x0 = w * piers[i] + half;
      final double x1 = w * piers[i + 1] - half;
      canvas.drawPath(
        Path()
          ..moveTo(x0, deckBottom - 1)
          ..lineTo(x1, deckBottom - 1)
          ..lineTo(x1, spring)
          ..quadraticBezierTo((x0 + x1) / 2, h * 0.67, x0, spring)
          ..close(),
        fill,
      );
    }
    // The rail along the top, on short posts, and the lit edge of the deck.
    final Paint rail = Paint()
      ..strokeWidth = 1.2
      ..color = stone;
    canvas.drawLine(
        Offset(0, deckTop - h * 0.014), Offset(w, deckTop - h * 0.014), rail);
    for (double x = w * 0.01; x < w; x += w * 0.03) {
      canvas.drawLine(Offset(x, deckTop - h * 0.014), Offset(x, deckTop), rail);
    }
    canvas.drawLine(
        Offset(0, deckTop),
        Offset(w, deckTop),
        Paint()
          ..strokeWidth = 1
          ..color = Color.lerp(stone, c.glow, 0.4)!);
  }

  void _nightHills(Canvas canvas) {
    // A thick field of small stars, still; the sky layer's own stars
    // twinkle over them.
    final math.Random rng = math.Random(71);
    final Paint dust = Paint()..color = c.glow.withValues(alpha: 0.5);
    for (int i = 0; i < 46; i++) {
      canvas.drawCircle(
          Offset(rng.nextDouble() * w, rng.nextDouble() * h * 0.5),
          0.5 + rng.nextDouble() * 0.7,
          dust);
    }

    const double light = 0.7;
    _crescent(canvas, Offset(w * 0.7, h * 0.3), w * 0.075);
    // A ringed planet high in the sky on the left, faded as if far away.
    // It rose behind the far hill first; the user moved it, 26 September
    // 2026.
    _planet(canvas, Offset(w * 0.24, h * 0.15), w * 0.1,
        tilt: -0.25, lightLeft: false, fade: 0.4);

    // Three rolling hills, each with a faint moonlit line along its crest,
    // and small houses on them where round trees stood until 26 September
    // 2026.
    void hill(Path top, double from, Color colour) {
      final Path body = Path.from(top)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas
        ..drawPath(
          body,
          Paint()
            ..isAntiAlias = true
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[colour, Color.lerp(colour, c.deep, 0.3)!],
            ).createShader(Rect.fromLTRB(0, h * from, w, h)),
        )
        ..drawPath(
          top,
          Paint()
            ..isAntiAlias = true
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = Color.lerp(colour, c.glow, 0.3)!,
        );
    }

    // Each hill's houses are drawn before the hill itself and stand a
    // little below its crest, so the crest crops them -- they sit behind
    // the swell of the land, the way the user asked on 26 September 2026.
    // The hills step from pale to dark and the houses the other way round,
    // so every house stands clear of what is behind it.
    final Color backHill = Color.lerp(c.far, c.glow, 0.12)!;
    final Color midHill = Color.lerp(c.near, c.far, 0.25)!;
    final Color frontHill = Color.lerp(c.ground, c.deep, 0.45)!;
    final Color farHouse = Color.lerp(c.ground, c.deep, 0.55)!;

    for (final (double x, double r) in const <(double, double)>[
      (0.6, 0.03),
      (0.68, 0.036),
      (0.76, 0.028),
    ]) {
      _hut(canvas,
          Offset(w * x, h * _onCurve(x, 0.66, 0.54, 0.64) + w * r * 0.9), w * r,
          light: light, tone: farHouse);
    }
    hill(
        Path()
          ..moveTo(0, h * 0.66)
          ..quadraticBezierTo(w * 0.5, h * 0.54, w, h * 0.64),
        0.58,
        backHill);

    for (final (double x, double r) in const <(double, double)>[
      (0.06, 0.05),
      (0.16, 0.044),
      (0.44, 0.042),
    ]) {
      _hut(
          canvas,
          Offset(w * x, h * _onCurve(x / 0.7, 0.74, 0.64, 0.7) + w * r * 0.8),
          w * r,
          light: light,
          tone: farHouse);
    }
    hill(
        Path()
          ..moveTo(0, h * 0.74)
          ..quadraticBezierTo(w * 0.35, h * 0.64, w * 0.7, h * 0.7)
          ..quadraticBezierTo(w * 0.85, h * 0.73, w, h * 0.72),
        0.66,
        midHill);

    hill(
        Path()
          ..moveTo(0, h * 0.86)
          ..quadraticBezierTo(w * 0.5, h * 0.78, w, h * 0.88),
        0.8,
        frontHill);
    // The houses in front stand whole on the near hill, bigger, and a step
    // lighter than the dark ground they are on.
    for (final (double x, double r) in const <(double, double)>[
      (0.72, 0.1),
      (0.3, 0.075),
    ]) {
      _hut(canvas, Offset(w * x, h * _onCurve(x, 0.86, 0.78, 0.88) + h * 0.012),
          w * r,
          light: light, tone: Color.lerp(c.near, c.deep, 0.15)!);
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.scene != scene || old.c != c;
}

// The life in each scene, in front of the land, on `CardScenePicture.loop`.
//
// **The real thing first, then slowed down** -- the scene-illustrator rule.
// What each one is, and what ours does:
//
// | Scene | The real thing | Ours | Per 24 s loop |
// | --- | --- | --- | --- |
// | Lantern lake | Sky lanterns rise on their own warm air, swaying, and shrink as they climb. Floating ones bob on the swell; a candle flame shimmers | Four rise, sway and fade into the dark; four on the water bob, each with a wavering reflection; the moon's ripples breathe; a few fireflies low over the water; a girl and her cat in a boat bob on the moon's path | Rise 1, sway 2, bob 2, shimmer 1-2 |
// | Floating islands | Birds flap in bursts and glide between. Cloud drifts on the wind | A flock of three crosses, flapping then gliding; two wisps drift past; the islands bob a hair | Crossing 1, wingbeat 24 (1 a second), bursts 3 |
// | Dusk waves | Swell rolls in rows, each crest lit from the low sun behind. Paper floats high and tips with the slope under it | Three rows of waves roll; a paper boat rides the middle one and leans with it; two birds cross | Roll 1, crossing 1 |
// | Aurora valley (open snowfield, no peaks or pines) | Snow falls slowly and sways, big flakes faster than small. The aurora folds like a curtain | Twenty-four flakes, two speeds (aurora in the sky layer) | Fall 1 or 2, sway 2-3 |
// | Blossom terraces | A petal falls like a leaf: swinging side to side, flipping over. A butterfly bobs with each beat, never glides straight | Twelve petals drift down on a breeze; two butterflies come and go | Fall 1, swing 3, flip 2, wingbeat 48 |
// | Lighthouse cliffs | The light turns, so from the side the beam swings, shortens, and flashes as it faces you. Gulls glide in long curves and flap rarely | The beam swings and flashes; two gulls circle over the sea; glints wink on the sun's path | Turn 2, circuit 1, glints 3 |
// | Dawn pond | A pond this still is a mirror. A fish rising leaves a ring that spreads and fades. Mist lies on the water at dawn and drifts. A rowing boat rides the smallest swell | Two wisps drift; rings spread, each a short way from the last; the boat bobs and tips with its reflection; petals fall from the branch and go out on the water | Drift 1, rings 2, bob 2, tip 1, fall 1 |
// | Snow tree | Petals let go one at a time and settle. Snow crystals catch the light only from one angle, so they wink | Petals fall from the crown onto the snow; six glints wink; the planet shimmers | Fall 1, glints 1-3, shimmer 1 |
// | Pastel shore | A crane stands still for minutes, and its weight shifting sends out a ring. Cloud drifts. Grass bends with the breeze | Four peach clouds drift a little and back; streaks slide; one ring at its feet; two small birds cross; the grass sways | Drift 1, ring 1, crossing 1, sway 2 |
// | Cabin island | Wood smoke rises in a warm column, spreads and thins as it cools, and leans downwind. Firelit windows flicker a little | Four puffs rise from the chimney, grow, lean right and fade; the windows glow and swell; pale lines slide on the water | Rise 1, glow 1, slide 1 |
// | Desert beacon | Wind lifts loose grains off a dune's crest and drops them a little way on. High cloud drifts | Grains of sand lift off the crests, drift downwind and settle; a cloud bank drifts in front of a far castle in the sky | Drift 1, cloud 1 |
// | Boatman sunset | A meteor lasts under a second. Light on water breaks into glints. A punt drifts and rides the swell | Stars twinkle; two shooting stars; glints shimmer on the sun's path; the boat drifts a little way and back, and bobs | Twinkle 1-3, meteor 1 each, glint 1-3, drift 1, bob 2 |
// | Moon boat | A meteor, again. A small boat rocks on still water; a lantern flame shimmers | Two shooting stars; the boat bobs and tips with its reflection; the lantern shimmers; lines slide on the water | Meteor 1 each, bob 2, tip 1, shimmer 2, slide 1 |
// | Torii peaks | Geese and cranes travel in long loose lines, each bird flapping in bursts and gliding between. Flat cloud drifts | A line of nine birds crosses once; the cloud bands drift and back | Crossing 1, wingbeat 24, drift 1 |
// | Snow slope | Snow falls slowly and sways, big flakes faster than small | Sixteen flakes, drawn as Alto's diamonds, fall and sway | Fall 1 or 2, sway 3 |
// | Desert ruins | Dust hangs in low sun, drifting on the air, seen only in the light. Birds circle on the warm air rising off sand | Fourteen motes wander near the sun and shimmer; two birds circle; a rowing boat bobs on the pool | Wander 1-2, shimmer 1-2, circuit 1, bob 2 |
// | Night hills | Meteors come in ones and twos. Birds fly home at dusk in loose flocks. Fireflies flash low among trees | Two shooting stars close together; six birds cross; five fireflies light and go out | Meteor 1 each, crossing 1, lives 2-3 |
//
// **Everything comes and goes and moves only while hidden**: a lantern
// climbs until it fades and is back at the bottom while dark; a flake or a
// petal wraps round outside the card; a bird crosses and is gone for part of
// the loop. Nothing crosses the words, because the words are not on the
// picture.
//
// **Reduce Motion** stops the loop on a frame where everything is present:
// lanterns mid-climb, birds mid-crossing with wings in a glide, petals and
// seeds part-way down, every firefly lit, the beam at full length.
class _LifePainter extends _Brush {
  final Animation<double> clock;
  final bool moving;

  _LifePainter(super.scene, super.c,
      {required this.clock, required this.moving})
      : super(repaint: clock);

  // The still frame's value for a thing whose cycle is `p` in 0..1 with
  // `off` its place in the loop: spread through the middle of its visit.
  double _still(double off) => 0.25 + 0.5 * ((off * 1.618034) % 1);

  @override
  void paint(Canvas canvas, Size size) {
    w = size.width;
    h = size.height;
    canvas.clipRect(Offset.zero & size);
    final double t = moving ? clock.value : 0;
    switch (scene) {
      case CardScene.lanternLake:
        _lanternLake(canvas, t);
      case CardScene.floatingIslands:
        _floatingIslands(canvas, t);
      case CardScene.duskWaves:
        _duskWaves(canvas, t);
      case CardScene.auroraValley:
        _snow(canvas, t);
      case CardScene.blossomTerraces:
        _blossomTerraces(canvas, t);
      case CardScene.lighthouseCliffs:
        _lighthouseCliffs(canvas, t);
      case CardScene.dawnPond:
        _dawnPond(canvas, t);
      case CardScene.snowTree:
        _snowTree(canvas, t);
      case CardScene.pastelShore:
        _pastelShore(canvas, t);
      case CardScene.cabinIsland:
        _cabinIsland(canvas, t);
      case CardScene.desertBeacon:
        _desertBeacon(canvas, t);
      case CardScene.boatmanSunset:
        _boatmanSunset(canvas, t);
      case CardScene.moonBoat:
        _moonBoat(canvas, t);
      case CardScene.toriiPeaks:
        _toriiPeaks(canvas, t);
      case CardScene.snowSlope:
        _snowSlope(canvas, t);
      case CardScene.desertRuins:
        _desertRuins(canvas, t);
      case CardScene.nightHills:
        _nightHills(canvas, t);
    }
  }

  // ---- The scenes ----

  void _lanternLake(Canvas canvas, double t) {
    final Offset moon = Offset(w * 0.72, h * 0.2);
    final double r = w * 0.07;

    // The moon's ripples on the water, breathing in length.
    final Paint ripple = Paint()
      ..color = c.glow.withValues(alpha: 0.35)
      ..strokeWidth = 1.2;
    int k = 0;
    for (final (double y, double half) in <(double, double)>[
      (0.70, 0.9),
      (0.77, 1.2),
      (0.85, 0.8),
    ]) {
      final double s = moving ? 1 + 0.2 * _wave(t, 1 + k % 2, k * 0.3) : 1;
      canvas.drawLine(Offset(moon.dx - r * half * s, h * y),
          Offset(moon.dx + r * half * s, h * y), ripple);
      k++;
    }

    _fireflies(canvas, t, const <(double, double, double, int)>[
      (0.06, 0.70, 1.4, 2),
      (0.13, 0.74, 1.2, 3),
      (0.09, 0.66, 1.0, 2),
    ]);

    // A girl and her cat in a small boat, out on the moon's path. They sit
    // still; only the water moves them.
    final double bob = moving ? 1.2 * _wave(t, 2, 0.4) : 0;
    final double tip = moving ? 0.03 * _wave(t, 1, 0.15) : 0;
    final Offset boat = Offset(w * 0.68, h * 0.71 + bob);
    final double s = w * 0.1;
    final Color shade = Color.lerp(c.deep, c.ground, 0.2)!;
    canvas
      ..save()
      ..translate(boat.dx, boat.dy)
      ..rotate(tip);
    _girlAndCat(canvas, s, shade);
    // The reflection is mirrored about a line just inside the bottom of the
    // hull (0.1 of `s` below the origin; the keel is at 0.14), squashed to
    // 0.6, so it meets the boat with no water between -- the user asked
    // for it to touch. It was
    // mirrored about a line below the hull and floated clear of it until
    // the user's comment, 26 September 2026.
    canvas
      ..saveLayer(null, Paint()..color = const Color.fromRGBO(0, 0, 0, 0.3))
      ..translate(0, s * 0.1 * 1.6)
      ..scale(1, -0.6);
    _girlAndCat(canvas, s, shade);
    canvas
      ..restore()
      ..restore();

    // The lanterns on the water: they bob, drift a little, and each lays a
    // wavering streak of its own light under it.
    const List<(double, double, double)> floating = <(double, double, double)>[
      (0.38, 0.74, 8),
      (0.56, 0.82, 10),
      (0.24, 0.88, 9),
      (0.82, 0.76, 7),
    ];
    for (int i = 0; i < floating.length; i++) {
      final (double x, double y, double s) = floating[i];
      final double bob = moving ? 1.2 * _wave(t, 2, i * 0.23) : 0;
      final double drift = moving ? 3 * _wave(t, 1, i * 0.31) : 0;
      final double shimmer =
          moving ? 0.5 + 0.5 * _wave(t, 1 + i % 2, i * 0.17) : 1;
      final Offset at = Offset(w * x + drift, h * y + bob);
      final double sway = moving ? 0.25 * s * _wave(t, 2, i * 0.4) : 0;
      canvas.drawRect(
        Rect.fromLTRB(at.dx - s * 0.35 + sway, at.dy + s,
            at.dx + s * 0.35 + sway, at.dy + s * 3.4),
        Paint()
          ..color = c.accent.withValues(alpha: 0.2 + 0.12 * shimmer)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.4),
      );
      _lantern(canvas, at, s, shimmer: shimmer);
    }

    // The lanterns in the air: each rises once a loop, swaying, shrinking as
    // it climbs, and fades into the dark before it starts again.
    const List<(double, double, double)> rising = <(double, double, double)>[
      (0.30, 0.30, 7),
      (0.44, 0.44, 5),
      (0.20, 0.50, 4),
      (0.58, 0.36, 4),
    ];
    for (int i = 0; i < rising.length; i++) {
      final (double x, double y, double s) = rising[i];
      final double off = i * 0.25;
      final double p = moving ? (t + off) % 1 : _still(off);
      final double fade =
          math.min(1.0, math.min(p / 0.15, (1 - p) / 0.3)).clamp(0.0, 1.0);
      if (fade <= 0.01) continue;
      final Offset at = Offset(
        w * (x + 0.02 * math.sin(2 * math.pi * (2 * p + i * 0.3))),
        h * (y + 0.12 - 0.3 * p),
      );
      final double shimmer = moving ? 0.5 + 0.5 * _wave(t, 2, i * 0.29) : 1;
      _lantern(canvas, at, s * (1 - 0.35 * p), shimmer: shimmer, opacity: fade);
    }
  }

  void _floatingIslands(Canvas canvas, double t) {
    _wisp(canvas, t, 0.66, 0.34, 0.0, 0.5);
    _wisp(canvas, t, 0.71, 0.24, 0.5, 0.4);

    _flock(
      canvas,
      t,
      y: 0.3,
      leftward: true,
      start: 0,
      members: const <(double, double, double)>[
        (0, 0, 9),
        (0.05, 0.022, 7),
        (0.1, -0.012, 6),
      ],
      colour: Color.lerp(c.ground, c.skyTop, 0.15)!,
    );

    for (final (int i, (double x, double y, double size))
        in <(double, double, double)>[
      (0.66, 0.36, 0.34),
      (0.24, 0.56, 0.24),
      (0.86, 0.60, 0.16),
    ].indexed) {
      final double dy = moving ? h * 0.006 * _wave(t, 1, i * 0.33) : 0;
      _island(canvas, Offset(w * x, h * y + dy), w * size);
    }
  }

  // The rows of waves, as (share of the height, swell, crests across the
  // card, phase, colour). Each rolls one crest-length a loop.
  List<(double, double, double, double, Color)> get _waveRows =>
      <(double, double, double, double, Color)>[
        (0.64, 0.012, 3.0, 0.3, Color.lerp(c.far, c.near, 0.4)!),
        (0.74, 0.02, 2.2, 1.4, c.near),
        (0.88, 0.028, 1.6, 2.3, c.ground),
      ];

  double _waveY(
      double x, double t, (double, double, double, double, Color) row) {
    final (double y, double swell, double crests, double phase, Color _) = row;
    return h *
        (y - swell * math.sin(2 * math.pi * (x * crests / 2 - t) + phase));
  }

  // A paper boat, side on: a folded hull and the tall middle fold that
  // stands up like a sail, with its shaded side.
  void _paperBoat(Canvas canvas, double s) {
    final Color paper = Color.lerp(c.glow, c.body, 0.3)!;
    final Color fold = Color.lerp(paper, c.near, 0.3)!;
    canvas
      ..drawPath(
        Path()
          ..moveTo(-s, -s * 0.35)
          ..lineTo(s, -s * 0.35)
          ..lineTo(s * 0.62, s * 0.12)
          ..lineTo(-s * 0.62, s * 0.12)
          ..close(),
        Paint()
          ..isAntiAlias = true
          ..color = paper,
      )
      ..drawPath(
        Path()
          ..moveTo(-s * 0.45, -s * 0.35)
          ..lineTo(0, -s * 1.05)
          ..lineTo(0, -s * 0.35)
          ..close(),
        Paint()
          ..isAntiAlias = true
          ..color = paper,
      )
      ..drawPath(
        Path()
          ..moveTo(0, -s * 1.05)
          ..lineTo(s * 0.45, -s * 0.35)
          ..lineTo(0, -s * 0.35)
          ..close(),
        Paint()
          ..isAntiAlias = true
          ..color = fold,
      );
  }

  void _duskWaves(Canvas canvas, double t) {
    _flock(
      canvas,
      t,
      y: 0.3,
      leftward: false,
      start: 0.3,
      members: const <(double, double, double)>[
        (0, 0, 8.5),
        (0.06, 0.02, 6.5),
      ],
      colour: Color.lerp(c.ground, c.deep, 0.3)!,
    );

    final double roll = moving ? t : 0.2;
    final List<(double, double, double, double, Color)> rows = _waveRows;
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      final (double y, double swell, _, _, Color colour) = row;

      // The boat rides the middle row, just behind its crest line, so the
      // front row can pass in front of it.
      if (i == 2) {
        const double x = 0.44;
        final double at = _waveY(x, roll, rows[1]);
        final double slope = (_waveY(x + 0.01, roll, rows[1]) -
                _waveY(x - 0.01, roll, rows[1])) /
            (w * 0.02);
        canvas
          ..save()
          ..translate(w * x, at - 1)
          ..rotate(math.atan(slope) * 0.8);
        _paperBoat(canvas, w * 0.065);
        canvas.restore();
      }

      final Path wave = Path()..moveTo(0, h);
      final Path crest = Path();
      for (double x = 0; x <= 1.0001; x += 0.02) {
        final double yy = _waveY(x, roll, row);
        wave.lineTo(w * x, yy);
        x == 0 ? crest.moveTo(0, yy + 0.8) : crest.lineTo(w * x, yy + 0.8);
      }
      wave
        ..lineTo(w, h)
        ..close();
      canvas
        ..drawPath(wave, _hazed(colour, h * (y - swell), h, 0.2))
        ..drawPath(
          crest,
          Paint()
            ..isAntiAlias = true
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2
            ..color = c.glow.withValues(alpha: 0.4 - i * 0.08),
        );
    }
  }

  static final List<(double, double, double, double)> _flakes = () {
    final math.Random rng = math.Random(11);
    return <(double, double, double, double)>[
      for (int i = 0; i < 24; i++)
        (
          rng.nextDouble(),
          rng.nextDouble(),
          0.7 + rng.nextDouble() * 1.5,
          rng.nextDouble(),
        ),
    ];
  }();

  void _snow(Canvas canvas, double t) {
    for (int i = 0; i < _flakes.length; i++) {
      final (double x, double off, double r, double ph) = _flakes[i];
      // Near flakes are bigger and fall faster.
      final int speed = r > 1.6 ? 2 : 1;
      final double fall = moving ? (speed * t + off) % 1 : off;
      final Offset at = Offset(
        w * x + 5 * math.sin(2 * math.pi * ((2 + i % 2) * fall + ph)),
        h * (-0.04 + 1.08 * fall),
      );
      canvas.drawCircle(
        at,
        r,
        Paint()
          ..isAntiAlias = true
          ..color = c.body.withValues(alpha: 0.55 + 0.25 * (r - 0.7) / 1.5),
      );
    }
  }

  static final List<(double, double, double, double)> _petals = () {
    final math.Random rng = math.Random(23);
    return <(double, double, double, double)>[
      for (int i = 0; i < 12; i++)
        (
          -0.1 + rng.nextDouble() * 0.9,
          rng.nextDouble(),
          4.5 + rng.nextDouble() * 3,
          rng.nextDouble(),
        ),
    ];
  }();

  void _blossomTerraces(Canvas canvas, double t) {
    _petalFall(canvas, t, _petals);

    _butterflies(
      canvas,
      t,
      const <(
        (double, double, double),
        (double, double, double),
        (double, double, double),
        double,
        double
      )>[
        // Up off the lower terrace and away past the left edge.
        ((0.20, 0.66, 0.3), (0.34, 0.48, 1.0), (-0.1, 0.30, 1.1), 10, 0.0),
        // Out of the right-hand trees, a turn, and back into the distance.
        ((0.80, 0.70, 0.3), (0.66, 0.56, 0.9), (0.84, 0.40, 0.25), 9, 0.5),
      ],
      wing: Color.lerp(c.body, c.accent, 0.25)!,
      body: c.ground,
    );
  }

  void _lighthouseCliffs(Canvas canvas, double t) {
    // Glints on the sun's path: each winks three times a loop, a short way
    // from where it last was.
    final Offset sun = Offset(w * 0.28, h * 0.46);
    for (int i = 0; i < 8; i++) {
      final double run = moving ? 3 * t + (i * 0.37) % 1 : 0.5;
      final double life = run % 1;
      final double a = math.pow(math.sin(math.pi * life), 2).toDouble();
      if (a <= 0.02) continue;
      final double seed = (i * 7 + (run.floor() % 3) * 13) * 0.618034;
      final Offset at = Offset(
        sun.dx + ((seed % 1) - 0.5) * w * 0.1,
        h * (0.6 + 0.36 * ((seed * 1.7) % 1)),
      );
      canvas.drawPath(
        _sparkle(at, 1.5 + 2 * a),
        Paint()
          ..isAntiAlias = true
          ..color = c.glow.withValues(alpha: 0.85 * a),
      );
    }

    // The beam: the lamp turns twice a loop. Seen from the side it swings
    // out to the left, shortens to nothing, reaches off the right edge, and
    // flashes each time it faces us.
    final Offset lamp = _lighthouseLamp;
    final double turn = moving ? 2 * math.pi * 2 * t : 0;
    final double reach = math.cos(turn);
    final double flash = math.pow(math.sin(turn).abs(), 6).toDouble();
    final double len = w * 0.55 * reach;
    if (len.abs() > 2) {
      final double end = lamp.dx - len;
      canvas.drawPath(
        Path()
          ..moveTo(lamp.dx, lamp.dy)
          ..lineTo(end, lamp.dy - h * 0.06 * reach.abs())
          ..lineTo(end, lamp.dy + h * 0.05 * reach.abs())
          ..close(),
        Paint()
          ..shader = LinearGradient(
            colors: <Color>[
              c.body.withValues(alpha: 0.4),
              c.body.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromPoints(lamp, Offset(end, lamp.dy + 1))),
      );
    }
    final double top = _lighthouseTop;
    canvas.drawCircle(
      lamp,
      top * (2.5 + 4 * flash),
      Paint()
        ..color = c.body.withValues(alpha: 0.3 + 0.45 * flash)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, top * (1 + 2 * flash)),
    );

    // Two gulls circling over the sea, dark against the pink.
    final Color gull = c.ground.withValues(alpha: 0.8);
    _circling(canvas, t,
        centre: const Offset(0.42, 0.26),
        rx: 0.16,
        ry: 0.05,
        phase: 0,
        size: 7.5,
        colour: gull);
    _circling(canvas, t,
        centre: const Offset(0.4, 0.3),
        rx: 0.2,
        ry: 0.04,
        phase: 0.55,
        size: 6,
        colour: gull);
  }

  // Petals for a scene, as (share of the width, place in the loop, size,
  // phase). Seeded, so every run of the app is the same.
  static List<(double, double, double, double)> _scatter(
      int seed, int count, double from, double to, double size) {
    final math.Random rng = math.Random(seed);
    return <(double, double, double, double)>[
      for (int i = 0; i < count; i++)
        (
          from + rng.nextDouble() * (to - from),
          rng.nextDouble(),
          size + rng.nextDouble() * size * 0.6,
          rng.nextDouble(),
        ),
    ];
  }

  static final List<(double, double, double, double)> _branchPetals =
      _scatter(31, 7, 0.02, 0.62, 4);
  static final List<(double, double, double, double)> _treePetals =
      _scatter(37, 8, 0.45, 0.55, 2.6);

  // Petals falling like leaves: each swings side to side and flips over as
  // it drops once a loop, drifting with the breeze. Between `top` and
  // `bottom` (shares of the height); with `fade` they appear from the
  // branch and go out where they land, rather than wrapping past the edges.
  void _petalFall(
    Canvas canvas,
    double t,
    List<(double, double, double, double)> petals, {
    double top = -0.04,
    double bottom = 1.04,
    double drift = 0.18,
    bool fade = false,
  }) {
    for (int i = 0; i < petals.length; i++) {
      final (double x, double off, double s, double ph) = petals[i];
      final double fall = moving ? (t + off) % 1 : off;
      final double swing = math.sin(2 * math.pi * (3 * fall + ph));
      final Offset at = Offset(
        w * (x + drift * fall) + s * 3 * swing,
        h * (top + (bottom - top) * fall),
      );
      final double opacity =
          fade ? math.min(1.0, math.min(fall / 0.1, (1 - fall) / 0.15)) : 1;
      if (opacity <= 0.01) continue;
      final double flip = math.cos(2 * math.pi * (2 * fall + ph));
      canvas
        ..save()
        ..translate(at.dx, at.dy)
        ..rotate(0.6 * swing)
        ..scale(math.max(0.15, flip.abs()), 1);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: s, height: s * 0.62),
        Paint()
          ..isAntiAlias = true
          ..color = (flip >= 0
                  ? Color.lerp(c.accent, c.body, 0.55)!
                  : Color.lerp(c.accent, c.near, 0.4)!)
              .withValues(alpha: opacity),
      );
      canvas.restore();
    }
  }

  // A ring spreading on still water from where a fish has touched it.
  // `per` rings a loop; each spreads and fades in the first half of its
  // turn, and the next one starts a short way off.
  void _rings(Canvas canvas, double t, List<(double, double, double)> spots,
      {int per = 2}) {
    for (int i = 0; i < spots.length; i++) {
      final (double x, double y, double off) = spots[i];
      final double run = moving ? per * t + off : 0.2 + off;
      final double p = run % 1;
      if (p >= 0.5) continue;
      final double q = p / 0.5;
      final double seed = (run.floor() % per + i * 3) * 0.618034;
      final Offset at = Offset(w * (x + ((seed % 1) - 0.5) * 0.08), h * y);
      final double r = w * (0.01 + 0.07 * q);
      for (final double k in <double>[1, 0.6]) {
        canvas.drawOval(
          Rect.fromCenter(center: at, width: r * 2 * k, height: r * 0.5 * k),
          Paint()
            ..isAntiAlias = true
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = c.glow.withValues(alpha: 0.55 * (1 - q)),
        );
      }
    }
  }

  // A small rowing boat with one figure in it, side on.
  void _rowboat(Canvas canvas, Offset at, double s, Color colour) {
    final Paint fill = Paint()
      ..isAntiAlias = true
      ..color = colour;
    canvas
      ..drawPath(
        Path()
          ..moveTo(at.dx - s, at.dy - s * 0.18)
          ..quadraticBezierTo(
              at.dx - s * 0.6, at.dy + s * 0.14, at.dx, at.dy + s * 0.14)
          ..quadraticBezierTo(
              at.dx + s * 0.6, at.dy + s * 0.14, at.dx + s, at.dy - s * 0.22)
          ..close(),
        fill,
      )
      ..drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(
                  at.dx - s * 0.12, at.dy - s * 0.62, s * 0.2, s * 0.46),
              Radius.circular(s * 0.08)),
          fill)
      ..drawCircle(Offset(at.dx - s * 0.02, at.dy - s * 0.72), s * 0.1, fill)
      ..drawLine(
          Offset(at.dx + s * 0.05, at.dy - s * 0.35),
          Offset(at.dx + s * 0.7, at.dy + s * 0.2),
          Paint()
            ..isAntiAlias = true
            ..strokeWidth = math.max(1, s * 0.05)
            ..color = colour);
  }

  void _dawnPond(Canvas canvas, double t) {
    _wisp(canvas, t, 0.575, 0.42, 0.0, 0.45);
    _wisp(canvas, t, 0.63, 0.3, 0.5, 0.3);

    _rings(canvas, t, const <(double, double, double)>[
      (0.26, 0.74, 0.0),
      (0.8, 0.67, 0.5),
    ]);

    // The boat rides the smallest swell, and hangs upside down under
    // itself in the water.
    final double bob = moving ? 1.2 * _wave(t, 2, 0.1) : 0;
    final double tip = moving ? 0.03 * _wave(t, 1, 0.3) : 0;
    final Offset at = Offset(w * 0.62, h * 0.82 + bob);
    final double s = w * 0.07;
    final Color hull = Color.lerp(c.deep, c.near, 0.15)!;
    canvas
      ..save()
      ..translate(at.dx, at.dy)
      ..rotate(tip);
    _rowboat(canvas, Offset.zero, s, hull);
    canvas
      ..saveLayer(null, Paint()..color = const Color.fromRGBO(0, 0, 0, 0.25))
      ..translate(0, s * 0.3)
      ..scale(1, -0.7);
    _rowboat(canvas, Offset.zero, s, hull);
    canvas
      ..restore()
      ..restore();

    _petalFall(canvas, t, _branchPetals,
        top: 0.08, bottom: 0.9, drift: 0.12, fade: true);
  }

  // Glints on the snowfield, as (share of the width, share of the height,
  // size). Each catches the light one to three times a loop.
  static const List<(double, double, double)> _snowGlints =
      <(double, double, double)>[
    (0.14, 0.66, 3.0),
    (0.30, 0.80, 3.5),
    (0.70, 0.64, 2.6),
    (0.82, 0.78, 3.4),
    (0.58, 0.90, 3.0),
    (0.20, 0.92, 2.6),
  ];

  void _snowTree(Canvas canvas, double t) {
    // The one bright planet in the day sky, shimmering slowly.
    _glowDot(canvas, Offset(w * 0.4, h * 0.34), 1.6,
        shimmer: moving ? 0.5 + 0.5 * _wave(t, 1, 0) : 1);

    for (int i = 0; i < _snowGlints.length; i++) {
      final (double x, double y, double s) = _snowGlints[i];
      final double a = moving
          ? math.pow(math.max(0, _wave(t, 1 + i % 3, i * 0.37)), 3).toDouble()
          : 0.8;
      if (a <= 0.01) continue;
      canvas.drawPath(
          _sparkle(Offset(w * x, h * y), s),
          Paint()
            ..isAntiAlias = true
            ..color = c.glow.withValues(alpha: 0.9 * a));
    }

    // Petals let go from the crown and settle on the snow a little way off.
    _petalFall(canvas, t, _treePetals,
        top: 0.62, bottom: 0.84, drift: 0.14, fade: true);
  }

  // The peach clouds, as (share of the width, share of the height, width,
  // phase). Each drifts a little way and back once a loop.
  static const List<(double, double, double, double)> _peachClouds =
      <(double, double, double, double)>[
    (-0.06, 0.2, 0.34, 0.0),
    (0.62, 0.12, 0.3, 0.3),
    (0.78, 0.44, 0.34, 0.6),
    (-0.04, 0.56, 0.36, 0.8),
  ];

  void _pastelShore(Canvas canvas, double t) {
    // Thin streaks of high cloud, sliding slowly.
    for (int i = 0; i < 4; i++) {
      final double dx = moving ? 6 * _wave(t, 1, i * 0.25) : 0;
      final double x = <double>[0.12, 0.5, 0.3, 0.6][i];
      final double y = <double>[0.3, 0.26, 0.48, 0.52][i];
      canvas.drawLine(
          Offset(w * x + dx, h * y),
          Offset(w * (x + 0.22) + dx, h * y),
          Paint()
            ..strokeWidth = 1.2
            ..strokeCap = StrokeCap.round
            ..color = c.glow.withValues(alpha: 0.6));
    }

    // Cloud is lit, not a light: it takes some of the sky, so it goes down
    // with the sky in dark mode.
    final Color cloud = Color.lerp(c.accent, c.skyBottom, 0.35)!;
    for (final (double x, double y, double width, double ph) in _peachClouds) {
      final double dx = moving ? w * 0.025 * _wave(t, 1, ph) : 0;
      _cloud(
          canvas,
          Offset(w * x + dx, h * y),
          w * width,
          const <(double, double)>[
            (0.12, 0.1),
            (0.3, 0.17),
            (0.52, 0.24),
            (0.74, 0.14),
            (0.9, 0.08),
          ],
          cloud,
          lit: Color.lerp(cloud, c.glow, 0.35));
    }

    _flock(
      canvas,
      t,
      y: 0.34,
      leftward: false,
      start: 0.55,
      members: const <(double, double, double)>[(0, 0, 5), (0.05, 0.02, 4)],
      colour: c.ground,
    );

    // A ring now and then round the crane's feet, where it shifted its
    // weight.
    final Offset feet = _craneFeet;
    _rings(
        canvas,
        t,
        <(double, double, double)>[
          (feet.dx / w, feet.dy / h, 0.3),
        ],
        per: 1);

    // Grass at the two front corners, bending with the breeze.
    final Paint blade = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.4
      ..color = Color.lerp(c.ground, c.deep, 0.55)!;
    for (int i = 0; i < 14; i++) {
      final bool left = i < 7;
      final int k = i % 7;
      final double x = left ? 0.02 + k * 0.022 : 0.84 + k * 0.024;
      final double tall = h * (0.05 + 0.035 * ((k * 0.618034) % 1));
      final double sway = moving ? 3 * _wave(t, 2, k * 0.11) : 0;
      final double lean = (k.isEven ? -1 : 1) * w * 0.012 + sway;
      canvas.drawPath(
          Path()
            ..moveTo(w * x, h)
            ..quadraticBezierTo(w * x, h - tall * 0.6, w * x + lean, h - tall),
          blade);
    }
  }

  // ---- From the second set of references ----

  // Pale lines sliding a little way and back on still water, as (share of
  // the width, share of the height, length as a share of the width).
  void _slide(Canvas canvas, double t, List<(double, double, double)> lines,
      Color colour) {
    for (int i = 0; i < lines.length; i++) {
      final (double x, double y, double len) = lines[i];
      final double dx = moving ? w * 0.02 * _wave(t, 1, i * 0.23) : 0;
      canvas.drawLine(
        Offset(w * x + dx, h * y),
        Offset(w * (x + len) + dx, h * y),
        Paint()
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round
          ..color = colour,
      );
    }
  }

  // A boat and its reflection, bobbing and tipping on the water at `line`.
  void _afloat(Canvas canvas, Path boat, Offset at, double tip, Color colour,
      double line,
      {void Function()? extra}) {
    void draw() {
      canvas
        ..save()
        ..translate(at.dx, at.dy)
        ..rotate(tip)
        ..translate(-at.dx, -at.dy)
        ..drawPath(
            boat,
            Paint()
              ..isAntiAlias = true
              ..color = colour);
      extra?.call();
      canvas.restore();
    }

    final Rect water = Rect.fromLTRB(0, line, w, h);
    canvas
      ..save()
      ..clipRect(water)
      ..saveLayer(water, Paint()..color = const Color.fromRGBO(0, 0, 0, 0.35))
      ..translate(0, at.dy * 2)
      ..scale(1, -1);
    draw();
    canvas
      ..restore()
      ..restore();
    draw();
  }

  void _cabinIsland(Canvas canvas, double t) {
    final Offset at = _cabinAt;
    final double s = _cabinSize;

    // The windows' glow, swelling once a loop.
    final double swell = moving ? 0.5 + 0.5 * _wave(t, 1, 0.1) : 1;
    canvas.drawPath(
      _place(_cabinWindows, at, s),
      Paint()
        ..color = c.accent.withValues(alpha: 0.3 + 0.25 * swell)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.04),
    );

    // Wood smoke: four puffs, each rising once a loop, growing, leaning
    // downwind and thinning out.
    final Offset chimney = at + Offset(-s * 0.085, -s * 0.55);
    final Color smoke = Color.lerp(c.glow, c.skyBottom, 0.4)!;
    for (int i = 0; i < 4; i++) {
      final double p = moving ? (t + i / 4) % 1 : _still(i / 4);
      final double a = 0.34 * math.min(1.0, p / 0.12) * (1 - p);
      if (a <= 0.01) continue;
      canvas.drawCircle(
        chimney +
            Offset(
                w * 0.08 * p * p +
                    2 * math.sin(2 * math.pi * (2 * p + i * 0.3)),
                -h * 0.11 * p),
        s * (0.03 + 0.08 * p),
        Paint()
          ..color = smoke.withValues(alpha: a)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.02),
      );
    }

    _slide(
        canvas,
        t,
        const <(double, double, double)>[
          (0.1, 0.68, 0.14),
          (0.62, 0.7, 0.2),
          (0.3, 0.76, 0.24),
          (0.7, 0.82, 0.18),
          (0.05, 0.88, 0.3),
          (0.5, 0.93, 0.32),
        ],
        c.glow.withValues(alpha: 0.5));
  }

  // Grains of sand lifted off the dune crests, drifting slowly downwind and
  // settling: seen only as a few pale specks against the shaded sand.
  static final List<(double, double, double, double)> _sand =
      _scatter(113, 12, 0.0, 1.0, 1.0);

  void _desertBeacon(Canvas canvas, double t) {
    // The cloud bank the castle stands behind, drifting a little way and
    // back once a loop.
    final double drift = moving ? w * 0.02 * _wave(t, 1, 0.2) : 0;
    final Offset base = _castleAt + Offset(drift, h * 0.012);
    // Soft blurred rounds, not a flat-bottomed heap: a hard edge under
    // the castle read as a row of bumps rather than cloud.
    // Kept faint, from 26 September 2026: at full strength it read as a
    // solid white lozenge rather than cloud.
    for (final (double dx, double dy, double rx, double ry, double a)
        in const <(double, double, double, double, double)>[
      (-0.12, 0.004, 0.1, 0.022, 0.35),
      (-0.02, -0.004, 0.09, 0.026, 0.42),
      (0.08, 0.002, 0.1, 0.024, 0.4),
      (0.17, 0.008, 0.08, 0.018, 0.32),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(
            center: base + Offset(w * dx, h * dy),
            width: w * rx * 2,
            height: h * ry * 2),
        Paint()
          ..color = c.mist.withValues(alpha: a)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.025),
      );
    }

    for (int i = 0; i < _sand.length; i++) {
      final (double x, double off, double r, double ph) = _sand[i];
      final double p = moving ? (t + off) % 1 : _still(off);
      final double a = 0.5 * math.sin(math.pi * p);
      canvas.drawCircle(
        Offset(
            w * ((x + 0.12 * p) % 1),
            h * (0.8 + 0.12 * ph) -
                _duneLift -
                h * 0.02 * math.sin(math.pi * p)),
        r,
        Paint()..color = c.glow.withValues(alpha: a),
      );
    }
  }

  // Stars for a scene that is not night, so the sky layer does not draw
  // them: (share of the width, share of the height, radius).
  static const List<(double, double, double)> _duskStars =
      <(double, double, double)>[
    (0.08, 0.05, 1.2),
    (0.22, 0.12, 0.9),
    (0.36, 0.04, 1.0),
    (0.58, 0.08, 1.1),
    (0.74, 0.03, 0.9),
    (0.9, 0.1, 1.2),
    (0.14, 0.2, 0.7),
    (0.84, 0.22, 0.8),
    (0.46, 0.13, 0.7),
  ];

  void _boatmanSunset(Canvas canvas, double t) {
    for (int i = 0; i < _duskStars.length; i++) {
      final (double x, double y, double r) = _duskStars[i];
      final double a =
          moving ? 0.5 + 0.35 * _wave(t, 1 + i % 3, i * 0.37) : 0.75;
      canvas.drawCircle(Offset(w * x, h * y), r,
          Paint()..color = c.glow.withValues(alpha: a));
    }
    _shootingStar(canvas, t,
        from: const Offset(0.12, 0.05),
        to: const Offset(0.38, 0.15),
        start: 0.3);
    _shootingStar(canvas, t,
        from: const Offset(0.64, 0.03),
        to: const Offset(0.86, 0.11),
        start: 0.75);

    final double sea = _boatSea;
    for (int i = 0; i < 10; i++) {
      final double x = 0.36 + ((i * 0.618034) % 1) * 0.28;
      final double y = sea + h * (0.02 + 0.2 * ((i * 0.381966) % 1));
      final double a =
          moving ? 0.2 + 0.6 * math.max(0, _wave(t, 1 + i % 3, i * 0.29)) : 0.6;
      canvas.drawLine(
        Offset(w * x - 5, y),
        Offset(w * x + 5, y),
        Paint()
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round
          ..color = c.body.withValues(alpha: a),
      );
    }

    final double drift = moving ? 0.03 * _wave(t, 1, 0) : 0;
    final double bob = moving ? _wave(t, 2, 0.2) : 0;
    final double tip = moving ? 0.02 * _wave(t, 2, 0.45) : 0;
    final Offset at = Offset(w * (0.5 + drift), sea + h * 0.05 + bob);
    _afloat(canvas, _place(_boatman, at, w * 0.28), at, tip,
        Color.lerp(c.deep, c.ground, 0.25)!, sea);
  }

  void _moonBoat(Canvas canvas, double t) {
    _shootingStar(canvas, t,
        from: const Offset(0.3, 0.06), to: const Offset(0.1, 0.16), start: 0.1);
    _shootingStar(canvas, t,
        from: const Offset(0.94, 0.1),
        to: const Offset(0.74, 0.2),
        start: 0.58);

    final double sea = _moonSea;
    _slide(
        canvas,
        t,
        const <(double, double, double)>[
          (0.08, 0.7, 0.12),
          (0.74, 0.72, 0.16),
          (0.2, 0.8, 0.2),
          (0.64, 0.86, 0.22),
          (0.1, 0.93, 0.26),
        ],
        c.glow.withValues(alpha: 0.45));

    final double bob = moving ? 1.2 * _wave(t, 2, 0.1) : 0;
    final double tip = moving ? 0.04 * _wave(t, 1, 0.35) : 0;
    final Offset at = Offset(w * 0.5, sea + h * 0.035 + bob);
    final double s = w * 0.22;
    final double shimmer = moving ? 0.5 + 0.5 * _wave(t, 2, 0.6) : 1;
    _afloat(canvas, _place(_crescentBoat, at, s), at, tip,
        Color.lerp(c.deep, c.near, 0.4)!, sea,
        extra: () => _lantern(
            canvas, at + _crescentBoatLantern * (s / 100), s * 0.065,
            shimmer: shimmer));
  }

  // The cloud bands across the torii sky, as (share of the width, share of
  // the height, length, thickness, phase).
  static const List<(double, double, double, double, double)> _bands =
      <(double, double, double, double, double)>[
    (-0.1, 0.12, 0.5, 0.012, 0.0),
    (0.55, 0.18, 0.5, 0.01, 0.3),
    (0.3, 0.28, 0.8, 0.016, 0.55),
    (-0.05, 0.33, 0.45, 0.01, 0.8),
    (0.1, 0.42, 0.55, 0.014, 0.15),
  ];

  void _toriiPeaks(Canvas canvas, double t) {
    final Paint band = Paint()
      ..isAntiAlias = true
      ..color = Color.lerp(c.skyBottom, c.glow, 0.5)!.withValues(alpha: 0.7);
    for (final (double x, double y, double len, double thick, double ph)
        in _bands) {
      final double dx = moving ? w * 0.03 * _wave(t, 1, ph) : 0;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(w * x + dx, h * y, w * len, h * thick),
              Radius.circular(h * thick)),
          band);
    }

    // A long line of birds, the leader largest, the rest trailing away
    // behind and below it.
    _flock(
      canvas,
      t,
      y: 0.1,
      leftward: true,
      start: 0.2,
      members: const <(double, double, double)>[
        (0, 0, 8),
        (0.03, 0.035, 7),
        (0.05, 0.07, 6.5),
        (0.08, 0.1, 6),
        (0.1, 0.14, 5),
        (0.12, 0.18, 4.5),
        (0.15, 0.21, 4),
        (0.17, 0.25, 3.5),
        (0.19, 0.28, 3),
      ],
      colour: Color.lerp(c.ground, c.deep, 0.3)!,
    );
  }

  static final List<(double, double, double, double)> _diamonds =
      _scatter(83, 16, 0, 1, 3);

  void _snowSlope(Canvas canvas, double t) {
    final Paint flake = Paint()
      ..isAntiAlias = true
      ..color = c.accent.withValues(alpha: 0.85);
    for (int i = 0; i < _diamonds.length; i++) {
      final (double x, double off, double s, double ph) = _diamonds[i];
      final int speed = s > 3.9 ? 2 : 1;
      final double fall = moving ? (speed * t + off) % 1 : off;
      final Offset at = Offset(
        w * x + 6 * math.sin(2 * math.pi * (3 * fall + ph)),
        h * (-0.03 + 1.06 * fall),
      );
      canvas.drawPath(
        Path()
          ..moveTo(at.dx, at.dy - s)
          ..lineTo(at.dx + s * 0.8, at.dy)
          ..lineTo(at.dx, at.dy + s)
          ..lineTo(at.dx - s * 0.8, at.dy)
          ..close(),
        flake,
      );
    }
  }

  static final List<(double, double, double, double)> _motes =
      _scatter(97, 14, 0.3, 0.7, 1.1);

  void _desertRuins(Canvas canvas, double t) {
    for (int i = 0; i < _motes.length; i++) {
      final (double x, double y, double r, double ph) = _motes[i];
      final Offset at = Offset(
        w * x + (moving ? 8 * _wave(t, 1, ph) : 0),
        h * (0.3 + 0.3 * y) + (moving ? 5 * _wave(t, 1 + i % 2, ph + 0.25) : 0),
      );
      final double a =
          moving ? 0.25 + 0.5 * math.max(0, _wave(t, 1 + i % 2, ph * 2)) : 0.6;
      canvas.drawCircle(at, r, Paint()..color = c.glow.withValues(alpha: a));
    }
    final Color bird = Color.lerp(c.ground, c.deep, 0.3)!;
    _circling(canvas, t,
        centre: const Offset(0.28, 0.2),
        rx: 0.08,
        ry: 0.02,
        phase: 0,
        size: 5,
        colour: bird);
    _circling(canvas, t,
        centre: const Offset(0.34, 0.24),
        rx: 0.06,
        ry: 0.018,
        phase: 0.5,
        size: 4,
        colour: bird);

    // The rowing boat on the pool, bobbing, with its reflection.
    final double pool = _desertPool;
    final double bob = moving ? 0.8 * _wave(t, 2, 0.2) : 0;
    final double tip = moving ? 0.025 * _wave(t, 2, 0.5) : 0;
    final Offset at = Offset(w * 0.78, _desertBoat + bob);
    _afloat(canvas, _place(_skiff, at, w * 0.22), at, tip,
        Color.lerp(c.ground, c.deep, 0.35)!, pool);
  }

  void _nightHills(Canvas canvas, double t) {
    _shootingStar(canvas, t,
        from: const Offset(0.4, 0.06),
        to: const Offset(0.62, 0.16),
        start: 0.2);
    _shootingStar(canvas, t,
        from: const Offset(0.44, 0.12),
        to: const Offset(0.6, 0.19),
        start: 0.24);
    _flock(
      canvas,
      t,
      y: 0.4,
      leftward: false,
      start: 0.55,
      members: const <(double, double, double)>[
        (0, 0, 5.5),
        (0.04, -0.02, 5),
        (0.07, 0.02, 4.5),
        (0.1, -0.01, 4),
        (0.13, 0.03, 4),
        (0.16, 0.0, 3.5),
      ],
      colour: Color.lerp(c.ground, c.deep, 0.4)!,
    );
    _fireflies(canvas, t, const <(double, double, double, int)>[
      (0.1, 0.72, 1.6, 2),
      (0.22, 0.76, 1.4, 3),
      (0.48, 0.74, 1.5, 2),
      (0.8, 0.84, 1.7, 3),
      (0.66, 0.8, 1.3, 2),
    ]);
  }

  // A shooting star: a thin streak, bright at its head and fading to its
  // tail. A real meteor is gone in under a second; this one takes a little
  // over one (a twentieth of the loop), once a loop, and is then gone.
  void _shootingStar(Canvas canvas, double t,
      {required Offset from, required Offset to, required double start}) {
    const double span = 0.05;
    final double p = moving ? (t + start) % 1 : span * 0.55;
    if (p >= span) return;
    final double q = p / span;
    if (q < 0.04) return;
    final Offset a = Offset(w * from.dx, h * from.dy);
    final Offset b = Offset(w * to.dx, h * to.dy);
    final Offset head = Offset.lerp(a, b, q)!;
    final Offset tail = Offset.lerp(a, b, math.max(0, q - 0.4))!;
    final double fade = math.sin(math.pi * q);
    canvas
      ..drawLine(
        tail,
        head,
        Paint()
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round
          ..shader = ui.Gradient.linear(tail, head, <Color>[
            c.glow.withValues(alpha: 0),
            c.glow.withValues(alpha: 0.9 * fade),
          ]),
      )
      ..drawCircle(
        head,
        2.2,
        Paint()
          ..color = c.glow.withValues(alpha: 0.6 * fade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
  }

  // ---- The creatures ----

  // Fireflies, as (share of the width, share of the height, radius, lives
  // per loop). Home's rule: each one lights small, swells, and goes out,
  // then lights again a short way off. The common firefly flashes while
  // rising in a small J -- a dip, then a climb as it lights.
  void _fireflies(
      Canvas canvas, double t, List<(double, double, double, int)> list) {
    for (int i = 0; i < list.length; i++) {
      final (double x, double y, double r, int lives) = list[i];
      double life = 0.5;
      int count = 0;
      if (moving) {
        final double run = lives * t + (i * 0.37) % 1;
        life = run % 1;
        count = run.floor() % lives;
      }
      final double glow = math.pow(math.sin(math.pi * life), 1.5).toDouble();
      if (glow <= 0.01) continue;
      final double seed = (i * 7 + count * 13) * 0.618034;
      final Offset home = Offset(
        w * x + ((seed % 1) - 0.5) * w * 0.06,
        h * y + (((seed * 1.7) % 1) - 0.5) * h * 0.04,
      );
      final Offset at = home +
          Offset(
            4 * math.sin(2 * math.pi * (1.5 * life + i * 0.2)),
            4 * math.sin(math.pi * math.min(1, life * 2)) - 12 * life,
          );
      final double radius = r * (0.4 + 0.6 * glow);
      canvas
        ..drawCircle(
          at,
          radius * 3,
          Paint()
            ..color = c.body.withValues(alpha: 0.5 * glow)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        )
        ..drawCircle(
          at,
          radius,
          Paint()
            ..isAntiAlias = true
            ..color = Color.lerp(c.body, c.glow, 0.5)!.withValues(alpha: glow),
        );
    }
  }

  // A soft wisp of cloud or mist drifting left to right, once a loop. It
  // wraps round outside the card, so it is never seen to jump.
  void _wisp(
      Canvas canvas, double t, double y, double len, double off, double a) {
    final double p = moving ? (t + off) % 1 : 0.3 + 0.4 * off;
    final double cx = -len * w * 0.6 + p * (w + len * w * 1.2);
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, h * y), width: len * w, height: h * 0.035),
      Paint()
        ..color = c.mist.withValues(alpha: a)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  // A small flock crossing the card once a loop, visible for a little over
  // half of it. Real birds flap in bursts and glide between, so the wings
  // beat once a second in three bursts a loop and hold a glide otherwise.
  // Each downstroke lifts the body a touch.
  void _flock(
    Canvas canvas,
    double t, {
    required double y,
    required bool leftward,
    required double start,
    required List<(double, double, double)> members,
    required Color colour,
  }) {
    const double visible = 0.6;
    final double p = moving ? (t + start) % 1 : visible * 0.5;
    if (p >= visible) return;
    final double q = p / visible;
    final double fade = math.min(1.0, math.min(q / 0.08, (1 - q) / 0.08));
    final double lead = leftward ? 1.1 - 1.3 * q : -0.2 + 1.3 * q;
    for (final (double dx, double dy, double s) in members) {
      final double gate =
          moving ? math.max(0, _wave(t, 3, dx * 2)).toDouble() : 0;
      final double beat = 2 * math.pi * (24 * t + dx * 3);
      final double flap = 0.3 + 0.7 * gate * math.sin(beat);
      final Offset at = Offset(
        w * (lead + (leftward ? dx : -dx)),
        h * (y + dy + 0.015 * math.sin(2 * math.pi * q)) +
            s * 0.12 * gate * math.cos(beat),
      );
      _bird(canvas, at, s, flap, colour, fade);
    }
  }

  // A bird circling on a thermal once a loop: an ellipse, a little bigger at
  // its near side, banking gently, flapping in rare short bursts.
  void _circling(
    Canvas canvas,
    double t, {
    required Offset centre,
    required double rx,
    required double ry,
    required double phase,
    required double size,
    required Color colour,
  }) {
    final double a = 2 * math.pi * ((moving ? t : 0.2) + phase);
    final Offset at = Offset(
      w * (centre.dx + rx * math.cos(a)),
      h * (centre.dy + ry * math.sin(a)),
    );
    final double gate =
        moving ? math.pow(math.max(0, _wave(t, 2, phase)), 3).toDouble() : 0;
    final double flap =
        0.3 + 0.7 * gate * math.sin(2 * math.pi * (30 * t + phase));
    _bird(canvas, at, size * (0.85 + 0.2 * math.sin(a)), flap, colour, 1,
        tilt: 0.2 * math.cos(a));
  }

  // A bird as a brushstroke: two wings from the body, the tips high when
  // `flap` is 1 and low when it is -1. At 0.3 it is the gliding "M".
  void _bird(Canvas canvas, Offset at, double size, double flap, Color colour,
      double opacity,
      {double tilt = 0}) {
    final Paint stroke = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.1, size * 0.17)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = colour.withValues(alpha: colour.a * opacity);
    canvas
      ..save()
      ..translate(at.dx, at.dy)
      ..rotate(tilt);
    for (final double side in <double>[-1, 1]) {
      canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(side * size * 0.45, -size * 0.4, side * size,
              -size * 0.35 * flap + size * 0.1),
        stroke,
      );
    }
    canvas.restore();
  }

  // Butterflies, each a flight -- where it appears, where it is nearest,
  // where it goes, as (share of the width, share of the height, scale), then
  // its full size and where in the loop it sets off. Home's own rule: they
  // come and go, bob with each beat, and lean the way they are going.
  void _butterflies(
    Canvas canvas,
    double t,
    List<
            (
              (double, double, double),
              (double, double, double),
              (double, double, double),
              double,
              double
            )>
        flights, {
    required Color wing,
    required Color body,
  }) {
    const double flying = 0.7;
    for (int i = 0; i < flights.length; i++) {
      final (
        (double, double, double) from,
        (double, double, double) near,
        (double, double, double) to,
        double size,
        double start,
      ) = flights[i];

      if (!moving) {
        _butterfly(canvas, Offset(w * near.$1, h * near.$2), size * near.$3, 0,
            1, 1, wing, body);
        continue;
      }

      final double cycle = (t + start) % 1;
      if (cycle >= flying) continue;
      final double p = cycle / flying;
      double along(double a, double b, double c) =>
          (1 - p) * (1 - p) * a + 2 * (1 - p) * p * b + p * p * c;
      // Two wingbeats a second; the body rises on each downstroke.
      final double beat = 2 * math.pi * (48 * t + i * 0.29);
      final double flutter = math.sin(2 * math.pi * (6 * p + i * 0.3));
      final Offset at = Offset(
        w * along(from.$1, near.$1, to.$1) + 6 * flutter,
        h * along(from.$2, near.$2, to.$2) + 2.5 * math.sin(beat),
      );
      final bool leavesScene = to.$1 < 0 || to.$1 > 1;
      final double opacity =
          math.min(1.0, math.min(p / 0.12, leavesScene ? 1 : (1 - p) / 0.18));
      _butterfly(
        canvas,
        at,
        size * along(from.$3, near.$3, to.$3),
        0.25 * (to.$1 - from.$1).sign + 0.15 * flutter,
        0.5 + 0.5 * math.cos(beat),
        opacity,
        wing,
        body,
      );
    }
  }

  void _butterfly(Canvas canvas, Offset at, double size, double tilt,
      double open, double opacity, Color wing, Color body) {
    final double spread = 0.25 + 0.75 * open;
    canvas
      ..saveLayer(
        Rect.fromCircle(center: at, radius: size * 2),
        Paint()..color = Color.fromRGBO(0, 0, 0, opacity),
      )
      ..translate(at.dx, at.dy)
      ..rotate(tilt);
    final Paint paint = Paint()
      ..isAntiAlias = true
      ..color = wing;
    for (final double side in <double>[-1, 1]) {
      canvas
        ..drawOval(
            Rect.fromCenter(
                center: Offset(side * size * 0.48 * spread, -size * 0.22),
                width: size * 0.9 * spread,
                height: size * 0.72),
            paint)
        ..drawOval(
            Rect.fromCenter(
                center: Offset(side * size * 0.32 * spread, size * 0.32),
                width: size * 0.56 * spread,
                height: size * 0.46),
            paint);
    }
    canvas
      ..drawOval(
          Rect.fromCenter(
              center: Offset.zero, width: size * 0.14, height: size * 0.9),
          Paint()
            ..isAntiAlias = true
            ..color = body)
      ..restore();
  }

  @override
  bool shouldRepaint(_LifePainter old) =>
      old.scene != scene ||
      old.c != c ||
      old.clock != clock ||
      old.moving != moving;
}
