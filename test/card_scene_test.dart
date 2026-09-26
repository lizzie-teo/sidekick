import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_palettes.dart';
import 'package:sidekick/features/dashboard/widgets/pause_sheet.dart';
import 'package:sidekick/features/dashboard/widgets/card_scene.dart';

void main() {
  // One scene a day: the same all day, a different one tomorrow, and never
  // out of range however far the date runs.
  test('the scene is picked by the day, not the hour', () {
    expect(CardScene.forDay(DateTime(2026, 9, 26, 7)),
        CardScene.forDay(DateTime(2026, 9, 26, 23, 59)));
    expect(CardScene.forDay(DateTime(2026, 9, 26)),
        isNot(CardScene.forDay(DateTime(2026, 9, 27))));

    final Set<CardScene> week = <CardScene>{
      for (int d = 0; d < CardScene.values.length; d++)
        CardScene.forDay(DateTime(2026, 9, 1 + d)),
    };
    expect(week, CardScene.values.toSet(),
        reason: 'every scene comes round before any repeats');
  });

  // The one line on the back is read on the scene's deep colour, in both
  // modes.
  test('the back\'s hint clears 4.5:1 on every scene', () {
    for (final CardScene scene in CardScene.values) {
      for (final Brightness b in Brightness.values) {
        final double ratio =
            SkContrast.ratio(CardSceneColours.onDeep, scene.colours(b).deep);
        expect(ratio, greaterThanOrEqualTo(4.5), reason: '$scene $b');
      }
    }
  });

  // The words on the face sit on glass over the scene. However clear the
  // pane is, `ink` must clear `PauseSheet.glassTarget` (7:1) over every
  // colour the scene paints, in every palette and both modes.
  test('the words on the glass clear 7:1 in every palette and scene', () {
    for (final SkPalette palette in SkPalettes.all) {
      for (final Brightness b in Brightness.values) {
        final SkColors sk =
            b == Brightness.light ? palette.light : palette.dark;
        for (final CardScene scene in CardScene.values) {
          final CardSceneColours c = scene.colours(b);
          final double alpha = PauseSheet.glassAlpha(sk, c);
          for (final Color g in <Color>[
            c.skyTop,
            c.skyBottom,
            c.horizon,
            c.far,
            c.near,
            c.ground,
            c.glow,
            c.mist,
            c.accent,
          ]) {
            expect(
              SkContrast.ratio(sk.ink,
                  SkContrast.over(SkContrast.backdropFor(sk.ink), g, alpha)),
              greaterThanOrEqualTo(PauseSheet.glassTarget),
              reason: '${palette.name} $b $scene',
            );
          }
        }
      }
    }
  });

  // Each scene keeps its subject in a different place, so the card lifts the
  // picture per scene. The subject's band must clear the glass and stay on
  // the card, on a small phone and a tall one.
  test('every scene\'s subject stays clear of the glass', () {
    for (final Size card in const <Size>[Size(343, 540), Size(358, 626)]) {
      final double glassTop = card.height *
          PauseSheet.pictureFlex /
          (PauseSheet.pictureFlex + PauseSheet.glassFlex);
      for (final CardScene scene in CardScene.values) {
        final ({double top, double bottom}) f = scene.focus;
        expect(f.top, lessThan(f.bottom), reason: '\$scene');
        final Rect at = PauseSheet.pictureRect(card, f);
        expect(at.top + f.top * at.height, greaterThanOrEqualTo(-0.01),
            reason: '\$scene: the top of its subject is off the card');
        expect(at.top + f.bottom * at.height, lessThan(glassTop),
            reason: '\$scene: its subject is under the glass');
        expect(at.top, lessThanOrEqualTo(0),
            reason: '\$scene: a gap above the sky');
      }
    }
  });
}
