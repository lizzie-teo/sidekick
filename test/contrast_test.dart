import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_invite_card.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_palettes.dart';
import 'package:sidekick/app/widgets/sk_glass_button.dart';
import 'package:sidekick/app/widgets/sk_status.dart';

// **Contrast is measured in every palette, in both modes, by arithmetic.**
//
// This is the test the app did not have, and the one that would have caught
// the bug it was written after: `muted` on `canvas` measures between 2.79:1
// and 3.23:1 in every light palette -- under the 4.5:1 WCAG 1.4.3 asks of
// small text -- and it was the colour of every caption and section header in
// the app. Nothing failed, nothing looked obviously wrong in a screenshot,
// and the least readable text in the app was the text explaining things to
// somebody on a hard evening.
//
// `_docs/design-guidelines/visual-style.md` holds the rules these pin.
void main() {
  // Every palette, both modes, named so a failure says which one.
  final List<(String, SkColors)> schemes = <(String, SkColors)>[
    for (final SkPalette palette in SkPalettes.all) ...<(String, SkColors)>[
      ('${palette.name} light', palette.light),
      ('${palette.name} dark', palette.dark),
    ],
  ];

  // **The rule the app follows instead of the `muted` slot.** A caption is a
  // darker shade of whatever it is on, worked out at the use site, so it
  // holds for a ground nobody has measured -- a card tint, a palette added
  // next year. This one is a gate, not an audit: it has never failed and it
  // must not start.
  group('a caption clears 4.5:1 on any ground it is given', () {
    for (final (String name, SkColors sk) in schemes) {
      test(name, () {
        final List<Color> grounds = <Color>[
          sk.canvas,
          sk.surface,
          sk.surfaceMuted,
          sk.actionSoft,
          ...sk.scene,
          // The two tinted cards in the explanation sheet, flattened.
          SkContrast.over(sk.destructive, sk.canvas, 0.10),
          SkContrast.over(sk.action, sk.canvas, 0.10),
        ];

        for (final Color ground in grounds) {
          final Color caption = SkContrast.captionOn(ground);
          expect(
            SkContrast.ratio(caption, ground),
            greaterThanOrEqualTo(SkContrast.bodyText),
            reason: '$name: caption on '
                '#${ground.toARGB32().toRadixString(16)}',
          );
        }
      });
    }
  });

  // **The status family, and this one is a hard gate.**
  //
  // Four tones, twelve schemes, two grounds each. The demanding case is the
  // one the app actually draws: the tone's own colour on a 12% wash of itself.
  // The wash moves the ground toward the text, so a colour that clears 4.5:1
  // against the bare page can still fail here -- which is exactly how the old
  // dark `destructive` (#E0705C) was caught.
  //
  // These colours are two values, not twenty-four: one set for the light
  // canvases and one for the dark, the same in all six palettes. A status
  // means the same thing in every theme or it means nothing.
  group('every status tone is legible on a wash of itself', () {
    for (final (String name, SkColors sk) in schemes) {
      test(name, () {
        for (final SkTone tone in SkTone.values) {
          final Color hue = SkStatusStyle.colourOf(sk, tone);

          for (final (String slot, Color ground) in <(String, Color)>[
            ('canvas', sk.canvas),
            ('surface', sk.surface),
          ]) {
            final Color fill =
                SkContrast.over(hue, ground, SkStatusStyle.fillAlpha);

            // What the widget actually draws, which may have been nudged.
            final Color text = SkContrast.readable(hue, fill);

            expect(
              SkContrast.ratio(text, fill),
              greaterThanOrEqualTo(SkContrast.bodyText),
              reason: '$name: ${tone.name} text on its own wash over $slot',
            );

            // A paragraph on that wash is the wash's own darkest shade,
            // from 24 September 2026. It must be at least as legible as the
            // `ink` it replaced, and at least as dark as the tone -- see
            // `SkContrast.inkOn`, and the same three assertions over the
            // exercise sets in `exercise_contrast_test.dart`.
            final Color paragraph = SkContrast.inkOn(hue, fill, sk.ink);

            expect(
              SkContrast.ratio(paragraph, fill),
              greaterThanOrEqualTo(SkContrast.ratio(sk.ink, fill)),
              reason: '$name: ${tone.name} body is fainter than ink on $slot',
            );
            expect(
              SkContrast.ratio(paragraph, fill),
              greaterThanOrEqualTo(SkContrast.ratio(text, fill)),
              reason: '$name: ${tone.name} body is lighter than the tone '
                  'on $slot',
            );

            // The block has to read as a block. Below about 1.1:1 the wash is
            // invisible and the words are floating on the page.
            expect(
              SkContrast.ratio(fill, ground),
              greaterThanOrEqualTo(1.1),
              reason: '$name: ${tone.name} wash is invisible on $slot',
            );
          }
        }
      });
    }
  });

  // **On the canvas the tone is used as it is, never nudged.** That is what
  // the colours were tuned for, and it is the case that happens on almost
  // every screen. A nudge there would mean the palette value is wrong rather
  // than the ground being unusual.
  group('a status tone needs no correction on the page ground', () {
    for (final (String name, SkColors sk) in schemes) {
      test(name, () {
        for (final SkTone tone in SkTone.values) {
          final Color hue = SkStatusStyle.colourOf(sk, tone);
          final Color fill =
              SkContrast.over(hue, sk.canvas, SkStatusStyle.fillAlpha);

          expect(
            SkContrast.readable(hue, fill),
            hue,
            reason: '$name: ${tone.name} had to be corrected on the canvas',
          );
        }
      });
    }
  });

  // **Two values, not twenty-four.** Every light scheme carries the same four
  // status colours and every dark scheme carries the same four. A palette
  // that grows its own is the drift this replaced: `destructive` used to be
  // five different reds between #9C2B22 and #C2402A, for no reason anybody
  // wrote down.
  test('the status colours do not vary by palette', () {
    final Set<int> lightSets = <int>{};
    final Set<int> darkSets = <int>{};

    for (final SkPalette palette in SkPalettes.all) {
      lightSets.add(_statusKey(palette.light));
      darkSets.add(_statusKey(palette.dark));
    }

    expect(lightSets.length, 1,
        reason: 'a light palette has its own status colours');
    expect(darkSets.length, 1,
        reason: 'a dark palette has its own status colours');
  });

  // **Every tone has an icon, because colour is never the only cue.** Roughly
  // one man in twelve cannot separate the red from the green.
  test('every tone carries its own icon', () {
    final Set<IconData> icons = SkTone.values.map(SkStatusStyle.iconOf).toSet();

    expect(icons.length, SkTone.values.length);
  });

  // Body text on a surface. Passes in all twelve today, and is a gate.
  group('ink clears 4.5:1 on every surface', () {
    for (final (String name, SkColors sk) in schemes) {
      test(name, () {
        for (final (String slot, Color ground) in <(String, Color)>[
          ('canvas', sk.canvas),
          ('surface', sk.surface),
          ('surfaceMuted', sk.surfaceMuted),
          ('actionSoft', sk.actionSoft),
        ]) {
          expect(
            SkContrast.ratio(sk.ink, ground),
            greaterThanOrEqualTo(SkContrast.bodyText),
            reason: '$name: ink on $slot',
          );
        }
      });
    }
  });

  // **The audit became a gate on 24 September 2026.**
  //
  // Eleven foreground/background pairs across five palettes used to measure
  // under 4.5:1, four of them under 3.0:1 -- short even for large text. They
  // were listed here rather than fixed, because fixing them meant choosing
  // new colours for shipped themes and that is a design decision rather than
  // a test's to make. The project then decided to hold itself above the
  // floor, so they were fixed and the list is empty.
  //
  // Two different fixes, because they were two different problems:
  //
  // | Pair | What moved |
  // | --- | --- |
  // | `onAction` on `action`, twice | The **fill**. A white label cannot get lighter, so Harvest moon and Coral diorama light took the smallest darkening that reaches 4.5:1 |
  // | `onScene` on a gradient stop, nine times | The **ground**. Five of the nine could not reach 4.5:1 at any lightness, so `SkScenePanel` lays `SkContrast.sceneScrim` under the words -- nothing at all on the three palettes that already cleared it |
  //
  // **The scene is measured through the scrim, because that is the pixel the
  // reader sees.** Measuring the bare stop would fail a screen that is
  // legible; measuring only the stop the words happen to sit over today would
  // pass a screen that breaks the moment a line moves.
  group('palette contrast', () {
    for (final (String name, SkColors sk) in schemes) {
      test(name, () {
        final Map<String, double> failing = <String, double>{};

        void check(String pair, Color foreground, Color background) {
          final double r = SkContrast.ratio(foreground, background);
          if (r < SkContrast.bodyText) {
            failing[pair] = double.parse(r.toStringAsFixed(2));
          }
        }

        check('onAction/action', sk.onAction, sk.action);

        // **The soft button's own label, added 24 September 2026.** The gate
        // held `ink` and a caption against `actionSoft` and never the action
        // colour on it, which is the pair `SkSoftButton` actually paints.
        // Three light palettes measured between 3.43:1 and 3.63:1 -- under
        // the 4.5:1 a 17/600 label owes, since WCAG's large-text step starts
        // at 14pt at weight 700. The widget runs the label through
        // `SkContrast.readable`, so this checks the colour it really uses.
        check(
          'action/actionSoft',
          SkContrast.readable(sk.action, sk.actionSoft),
          sk.actionSoft,
        );

        final Color? scrim = SkContrast.sceneScrim(sk.onScene, sk.scene);
        for (int i = 0; i < sk.scene.length; i++) {
          final Color ground = scrim == null
              ? sk.scene[i]
              : SkContrast.over(scrim, sk.scene[i], scrim.a);
          check('onScene/scene$i', sk.onScene, ground);

          // **The invitation's dashed outline, added 24 September 2026.** It
          // is the edge of a control rather than text, so it owes the 3:1 of
          // WCAG 1.4.11 and not 4.5:1 -- checked here rather than in the map
          // above, which is the body-text gate. On Home the card sits inside
          // the scene panel with no fill of its own, so the dash is the only
          // thing saying where it starts and stops. At the 55% it shipped
          // with for an hour it ran 2.22:1 to 2.64:1 in all twelve schemes.
          expect(
            SkContrast.ratio(
              SkContrast.over(sk.onScene, ground, SkInviteCard.sceneDashAlpha),
              ground,
            ),
            greaterThanOrEqualTo(SkContrast.nonText),
            reason: '$name: the invitation dash on scene stop $i',
          );

          // **The glass pill's label, added 24 September 2026.** Home's two
          // secondaries are `SkGlassButton`s on the gradient. The pill's fill
          // is a wash of the backdrop over the scene, so the label does not
          // sit on the stop measured above -- it sits on the stop plus the
          // fill, and that is the pixel to check.
          //
          // **The direction is the whole test.** Washing with the ink instead
          // -- which is what `SkCircleIconButton` does, correctly, for icons
          // at the 3:1 floor -- puts this at 3.62:1. The line above clears
          // 4.5:1 by hundredths in most palettes, so there is no headroom for
          // a wash that costs any.
          //
          // The rim and the shadow are not checked: neither carries meaning,
          // and the label is what identifies the control.
          expect(
            SkContrast.ratio(
              sk.onScene,
              SkContrast.over(
                SkContrast.backdropFor(sk.onScene),
                ground,
                SkGlassButton.fillAlpha,
              ),
            ),
            greaterThanOrEqualTo(SkContrast.bodyText),
            reason: '\$name: the glass pill label on scene stop \$i',
          );
        }

        expect(
          failing,
          <String, double>{},
          reason: 'a foreground/background pair in $name is under 4.5:1. '
              'Every palette has cleared this since 24 September 2026, so '
              'this is a regression rather than a known gap.',
        );
      });
    }
  });

  // **`muted` is not a text colour, and this test says so out loud.** It is
  // kept for hairlines, dividers and disabled states. If somebody deletes
  // this because it looks like it is asserting a bug, the comment is the
  // argument: the failure is the slot, not the check.
  test('muted is below the body-text threshold and is not for text', () {
    int belowThreshold = 0;

    for (final (String _, SkColors sk) in schemes) {
      if (SkContrast.ratio(sk.muted, sk.canvas) < SkContrast.bodyText) {
        belowThreshold++;
      }
    }

    expect(
      belowThreshold,
      greaterThan(0),
      reason: 'if every palette now passes, muted can become a text colour '
          'again and SkContrast.captionOn can go -- check all twelve first',
    );
  });

  group('SkLayout', () {
    test('the width bands are the platform ones', () {
      expect(SkLayout.bandFor(320), SkWidthBand.compact);
      expect(SkLayout.bandFor(375), SkWidthBand.compact);
      expect(SkLayout.bandFor(390), SkWidthBand.medium);
      expect(SkLayout.bandFor(599), SkWidthBand.medium);
      expect(SkLayout.bandFor(600), SkWidthBand.expanded);
      expect(SkLayout.bandFor(899), SkWidthBand.expanded);
      expect(SkLayout.bandFor(900), SkWidthBand.wide);
    });

    // Every step on the scale is a multiple of four. A gap that is not is a
    // decision somebody made in a hurry.
    test('the spacing scale is a four-point grid', () {
      for (final double step in <double>[
        SkLayout.xs,
        SkLayout.sm,
        SkLayout.md,
        SkLayout.lg,
        SkLayout.xl,
        SkLayout.xxl,
        SkLayout.xxxl,
        SkLayout.huge,
      ]) {
        expect(step % 4, 0, reason: '$step is off the grid');
      }
    });

    test('display type never scales below a phone', () {
      expect(SkLayout.displayScaleFor(SkWidthBand.compact), 1.0);
      expect(SkLayout.displayScaleFor(SkWidthBand.medium), 1.0);
      expect(SkLayout.displayScaleFor(SkWidthBand.expanded), greaterThan(1.0));
      expect(
        SkLayout.displayScaleFor(SkWidthBand.wide),
        greaterThan(SkLayout.displayScaleFor(SkWidthBand.expanded)),
      );
    });

    // The gutter grows with the screen and never the other way round.
    test('the gutter only grows with the screen', () {
      double previous = 0;
      for (final SkWidthBand band in SkWidthBand.values) {
        expect(SkLayout.gutterFor(band), greaterThanOrEqualTo(previous));
        previous = SkLayout.gutterFor(band);
      }
    });
  });
}

int _statusKey(SkColors sk) => Object.hash(
      sk.success.toARGB32(),
      sk.destructive.toARGB32(),
      sk.warning.toARGB32(),
      sk.info.toARGB32(),
    );
