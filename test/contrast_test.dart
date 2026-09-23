import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_palettes.dart';
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

    expect(lightSets.length, 1, reason: 'a light palette has its own status colours');
    expect(darkSets.length, 1, reason: 'a dark palette has its own status colours');
  });

  // **Every tone has an icon, because colour is never the only cue.** Roughly
  // one man in twelve cannot separate the red from the green.
  test('every tone carries its own icon', () {
    final Set<IconData> icons =
        SkTone.values.map(SkStatusStyle.iconOf).toSet();

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

  // **The audit, and it is deliberately not a gate.**
  //
  // Eleven foreground/background pairs across five palettes measure under
  // 4.5:1 today, and four of them are under 3.0:1 -- short even for large
  // text. They are listed rather than fixed because fixing them means
  // choosing new colours for shipped themes, which is a design decision and
  // not a test's to make. Measured 21 September 2026.
  //
  // The list is exact in both directions. A new pair failing is a regression;
  // a listed pair that now passes means somebody fixed it and the list is
  // stale. Either way the test says which.
  //
  // | Where | Why it is here rather than fixed |
  // | --- | --- |
  // | `onAction` on `action` | A button label. 19/600 reads as large text under WCAG, so 3.0 is arguably the right bar and both entries clear it |
  // | `onScene` on a gradient stop | The stop named is one of three, and the words may not sit over that end of it. Worth looking at on the device before repainting a theme |
  group('palette contrast audit', () {
    // palette -> the pairs known to be under 4.5:1, and their ratios rounded
    // to two places.
    const Map<String, Map<String, double>> known = <String, Map<String, double>>{
      'Harvest moon light': <String, double>{'onAction/action': 4.07},
      'Harvest moon dark': <String, double>{
        'onScene/scene0': 2.78,
        'onScene/scene1': 4.42,
      },
      'Moonlit valley light': <String, double>{'onScene/scene2': 4.00},
      'Moonlit valley dark': <String, double>{'onScene/scene1': 3.88},
      'Night forest light': <String, double>{'onScene/scene0': 2.41},
      'Night forest dark': <String, double>{'onScene/scene0': 4.16},
      'Coral diorama light': <String, double>{'onAction/action': 3.58},
      'Coral diorama dark': <String, double>{'onScene/scene0': 2.79},
      'Dusk terrarium light': <String, double>{'onScene/scene2': 2.60},
      'Dusk terrarium dark': <String, double>{'onScene/scene0': 3.98},
    };

    for (final (String name, SkColors sk) in schemes) {
      test(name, () {
        final Map<String, double> measured = <String, double>{};

        void check(String pair, Color foreground, Color background) {
          final double r = SkContrast.ratio(foreground, background);
          if (r < SkContrast.bodyText) {
            measured[pair] = double.parse(r.toStringAsFixed(2));
          }
        }

        check('onAction/action', sk.onAction, sk.action);
        for (int i = 0; i < sk.scene.length; i++) {
          check('onScene/scene$i', sk.onScene, sk.scene[i]);
        }

        expect(
          measured,
          known[name] ?? <String, double>{},
          reason: 'the contrast audit for $name has changed. A new entry is a '
              'regression; a missing one means it was fixed and this list '
              'needs the entry removed.',
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
