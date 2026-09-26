import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/models/day_phase.dart';
import 'package:sidekick/app/widgets/home_sky.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/features/play/widgets/orb_scene.dart';

// The two Play orbs stand in Home's scene (`OrbScene`). The script's words and
// the X sit on the sky in its `onSky`, which `home_sky_test.dart` already
// holds to 4.5:1 across the top of every sky. The way out sits on the hill's
// ground, at full strength, and the orb's field becomes a see-through
// tone of the scene rather than a white or black hole.
void main() {
  const Color white = Color(0xFFFFFFFF);
  const Color black = Color(0xFF000000);
  // The tighten screen's pair. The rules below hold for any pair.
  const Color core = Color(0xFFB99DE3);
  const Color edge = Color(0xFF5A3E96);

  for (final DayPhase phase in DayPhase.values) {
    for (final Brightness brightness in Brightness.values) {
      final HomeSkyColors sky = HomeSkyColors.of(phase, brightness);
      final Color ground = HomeSkyColors.groundUnderButtons(sky.ground);
      final Color words = HomeSkyColors.wordsOn(ground);

      group('${phase.name}, ${brightness.name}:', () {
        test('the way out reads on the ground', () {
          expect(SkContrast.ratio(words, ground),
              greaterThanOrEqualTo(SkContrast.bodyText));
        });

        test('the X reads on the sky', () {
          expect(SkContrast.ratio(sky.onSky, sky.top),
              greaterThanOrEqualTo(SkContrast.nonText));
        });

        // The whole point of the change: the end the grey field rests on is
        // see-through and darker than the scene it sits in.
        test('the orb field is a see-through, darker tone of the scene', () {
          final Color field = OrbScene.fieldTone(sky, brightness);
          expect(field.a, lessThan(1.0));
          expect(field.a, greaterThan(0.0));
          final Color opaque = field.withValues(alpha: 1);
          expect(opaque.computeLuminance(),
              lessThan(sky.horizon.computeLuminance()));
        });

        test('nothing in the orb is pure white or pure black', () {
          final ({
            Color core,
            Color edge,
            Color light,
            Color dark,
            Color field
          }) c = OrbScene.orbColours(sky, brightness, core: core, edge: edge);
          for (final Color colour in <Color>[
            c.core,
            c.edge,
            c.light,
            c.dark,
            c.field,
          ]) {
            expect(colour.withValues(alpha: 1), isNot(white));
            expect(colour.withValues(alpha: 1), isNot(black));
          }
        });

        // The shine is what gives each petal a light edge. It must stay
        // lighter than the core and the deep end darker than the edge, or the
        // petals go flat again.
        test('the petals have a light fringe and a deep middle', () {
          final ({
            Color core,
            Color edge,
            Color light,
            Color dark,
            Color field
          }) c = OrbScene.orbColours(sky, brightness, core: core, edge: edge);
          expect(c.light.computeLuminance(),
              greaterThan(c.core.computeLuminance()));
          expect(
              c.dark.computeLuminance(), lessThan(c.edge.computeLuminance()));
        });
      });
    }
  }

  // The user's call, 26 September 2026: the orb read as too subtle on a pale
  // sky. Light mode must stay the bolder of the two.
  test('the orb is richer in light mode than in dark', () {
    final HomeSkyColors sky =
        HomeSkyColors.of(DayPhase.midday, Brightness.light);
    final Color lightCore =
        OrbScene.orbColours(sky, Brightness.light, core: core, edge: edge).core;
    expect(HSLColor.fromColor(lightCore).saturation,
        greaterThan(HSLColor.fromColor(core).saturation));
    expect(OrbScene.fieldTone(sky, Brightness.light).a,
        greaterThan(OrbScene.fieldTone(sky, Brightness.dark).a));
  });
}
