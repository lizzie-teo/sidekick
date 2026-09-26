import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:sidekick/app/models/day_phase.dart';
import 'package:sidekick/app/models/moon_phase.dart';
import 'package:sidekick/app/widgets/home_sky.dart';
import 'package:sidekick/app/widgets/sk_blob_orb.dart';

// Home's scene behind a Play orb: the sky for the time of day, Home's hill
// band with nobody standing on it, and the hill's ground running on down to
// the foot of the screen, where the way out sits. Added 26 September 2026, at
// the user's request, for the tighten screen and the Low face -- the same
// scene the breathing screen stands its pacer in (`_Place` in
// `breathing_view.dart`).
//
// **Nobody stands on the hill.** The orb is the subject here, and the
// character and the orb never share a screen. The introduction in front of
// each script is a sheet on the picker, with nobody in it.
//
// **The fireflies and butterflies move, and that is the user's decision,**
// taken knowing they are a second clock on an eyes-closed screen -- the same
// call as on the breathing screen. The orb is still the only thing the script
// drives. Home's moth is not here.
//
// **The band's foot sits on the way out, not under the orb.** The orb's box
// is centred on the screen and is taller than the gap between it and the
// exit, so the hill cannot sit clear below it: the orb sits in front of the
// far ranges the way the sun does, and the words at the foot sit on the
// ground, deepened only as far as they need. See
// `HomeSkyColors.groundUnderButtons`.
class OrbScene extends StatelessWidget {
  const OrbScene({
    super.key,
    required this.phase,
    required this.moon,
    required this.footAbove,
    required this.child,
  });

  final DayPhase phase;
  final MoonPhase moon;

  // How far above the bottom safe inset the hill band's foot sits: the height
  // of the bands under the orb that hold the way out.
  final double footAbove;

  final Widget child;

  // The orb's colours on this scene: the ramp's two ends and the
  // see-through field. See `SkBlobOrb.lightEnd` and `SkBlobOrb.field`.
  //
  // **The field is a darker, see-through tone of the scene.** Without it the
  // uncovered part of the disc cut a white hole in a pale sky, and in dark
  // mode a black one in a night sky. The tone is taken from where the orb
  // actually sits -- between the sky's horizon and the far land -- and taken
  // darker, so the disc reads as a shaded window onto the picture rather than
  // as a sticker on it. See-through, so each sky's own colour comes through
  // it: the scenes change hue from morning to late night, and a fixed tone
  // would suit one of them.
  //
  // **The ends are the orb's own colours taken further, never white or
  // black.** The light end is the shine on each petal's fringe, a pale tint of
  // [core]; the dark end is where petals pile up, a deep tint of [edge]. Pure
  // white and black were the ends on the plain page, and on a painted sky
  // they read as holes and soot.
  //
  // **The grey is not flipped in dark mode on a scene** -- the screens pass
  // `inverted: false`. The flip exists so one pair of colours reads on a
  // near-white page and a near-black one. Here the page is the sky, and the
  // field layer already carries each sky's brightness, so the petals are
  // shaded the same way round in both modes: pale fringes, deep middles. The
  // shine is quieter in dark mode, where a pale fringe would glare.
  //
  // **Light mode is bolder than dark, on purpose.** Added 26 September 2026,
  // at the user's request: the same colours that glow on a night sky read as
  // faint on a pale one, and the lavender was called too subtle. So in light
  // mode the orb's two colours are richer -- more saturated, a step deeper --
  // and the field is darker and less see-through, so the petals stand out the
  // way they do at night. Dark mode is left as it was. Each orb is still its
  // own one colour in every theme; only how loud it is follows the room.
  static ({Color core, Color edge, Color light, Color dark, Color field})
      orbColours(
    HomeSkyColors sky,
    Brightness brightness, {
    required Color core,
    required Color edge,
  }) {
    final bool isLight = brightness == Brightness.light;
    final Color c = isLight ? _richer(core) : core;
    final Color e = isLight ? _richer(edge) : edge;
    final double shine = isLight ? _lightShine : _darkShine;
    final HSLColor deep = HSLColor.fromColor(e);
    return (
      core: c,
      edge: e,
      light: Color.lerp(c, _defaultLight, shine)!,
      dark: deep.withLightness(deep.lightness * _depth).toColor(),
      field: fieldTone(sky, brightness),
    );
  }

  // How far the fringe shine goes from [core] towards white, in each mode,
  // and how deep the petals' middles go below [edge]. Chosen by eye on the
  // simulator in every sky, 26 September 2026.
  static const double _lightShine = 0.4;
  static const double _darkShine = 0.25;
  static const double _depth = 0.55;

  // One of the orb's colours made bolder for a pale sky: more saturated and a
  // step deeper, with the hue untouched so it is still the same orb.
  static Color _richer(Color colour) {
    final HSLColor hsl = HSLColor.fromColor(colour);
    // A colour that is already strong is left alone. Deepening the Low orb's
    // peach turned it burnt orange; it reads as bright peach on a pale sky
    // once the field behind it is darker, which is the field's job.
    if (hsl.saturation >= _alreadyRich) return colour;
    return hsl
        .withSaturation(math.max(hsl.saturation,
            math.min(hsl.saturation * _lightSaturate, _maxSaturation)))
        .withLightness(hsl.lightness * _lightDeepen)
        .toColor();
  }

  static const double _lightSaturate = 1.35;
  static const double _lightDeepen = 0.9;

  // The ceiling on that. Without it the Low orb's peach went orange, and the
  // Low face is "warm, and never hot" -- an orange orb in front of somebody
  // flat is an alarm. The lavender, which starts much greyer, is not reached
  // by it.
  static const double _maxSaturation = 0.78;
  static const double _alreadyRich = 0.7;

  // The see-through tone behind the uncovered part of the disc. Public so the
  // test can hold it to "darker than the sky it sits on" at every phase.
  static Color fieldTone(HomeSkyColors sky, Brightness brightness) {
    final bool isLight = brightness == Brightness.light;
    final Color behind = Color.lerp(sky.horizon, sky.farHill, 0.5)!;
    final HSLColor hsl = HSLColor.fromColor(behind);
    return hsl
        .withLightness(
            hsl.lightness * (isLight ? _lightFieldDarken : _fieldDarken))
        .toColor()
        .withValues(alpha: isLight ? _lightFieldAlpha : _fieldAlpha);
  }

  // How much darker than the scene behind it, and how much of the scene
  // shows through. Chosen by eye on the simulator in every phase, light and
  // dark, 26 September 2026.
  static const double _fieldDarken = 0.6;
  static const double _fieldAlpha = 0.4;

  // Light mode's field: darker and less see-through, so the petals have
  // something to stand against on a pale sky. See `orbColours`.
  static const double _lightFieldDarken = 0.5;
  static const double _lightFieldAlpha = 0.55;

  // The orb's own white, so the shine above is visibly "the core, towards
  // the orb's white".
  static const Color _defaultLight = SkBlobOrb.defaultLightEnd;

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    final HomeSkyColors sky =
        HomeSkyColors.of(phase, Theme.of(context).brightness);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        final double foot = box.maxHeight - bottomInset - footAbove;
        final double stageTop = foot - HomeStage.bandHeight;

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            HomeSky(phase: phase),
            Positioned(
              left: 0,
              right: 0,
              top: stageTop,
              height: HomeStage.bandHeight,
              // The same band Home draws, with nobody in it.
              child: HomeStage(
                phase: phase,
                moon: moon,
                height: HomeStage.bandHeight,
                child: const SizedBox.shrink(),
              ),
            ),
            // The rest of the hill, down to the foot of the screen: the
            // colour the band's own ground fades to, deepening only where the
            // way out needs it.
            Positioned(
              left: 0,
              right: 0,
              top: foot,
              bottom: 0,
              child: ExcludeSemantics(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        sky.ground,
                        HomeSkyColors.groundUnderButtons(sky.ground),
                      ],
                      stops: const <double>[0, 0.3],
                    ),
                  ),
                ),
              ),
            ),
            child,
          ],
        );
      },
    );
  }
}
