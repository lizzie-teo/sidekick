import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_exercise_colors.dart';
import 'package:sidekick/app/widgets/sk_palettes.dart';
import 'package:sidekick/app/widgets/sk_status.dart';
import 'package:sidekick/app/widgets/theme.dart';

// The exercise grounds are fixed hex literals rather than theme slots, so
// nothing else in the app is checking them. `test/contrast_test.dart` walks
// the six palettes; this walks the two grounds that ignore them.
//
// **Every pair here passes, and that is not true of the palettes.** That file
// carries an audit baseline of eleven pairs that are under 4.5:1 and listed
// rather than fixed, because fixing them means repainting shipped themes.
// These grounds are new, so there is nothing to grandfather and no reason for
// a list.
//
// **Both sets are walked, every time.** The dark set arrived on 22 September
// 2026 and the light one had been the only set for a day, which is exactly
// long enough for a screen to be built against it and never checked in the
// dark. Every test below runs over `both`.
void main() {
  const List<SkExerciseColors> both = <SkExerciseColors>[
    SkExerciseColors.light,
    SkExerciseColors.dark,
  ];

  String named(SkExerciseColors ex) =>
      ex.brightness == Brightness.dark ? 'dark' : 'light';

  group('text on the exercise ground', () {
    test('body and headings clear AA on the ground and on a card', () {
      for (final SkExerciseColors ex in both) {
        expect(
          SkContrast.ratio(ex.ink, ex.ground),
          greaterThanOrEqualTo(SkContrast.bodyText),
          reason: named(ex),
        );
        expect(
          SkContrast.ratio(ex.ink, ex.surface),
          greaterThanOrEqualTo(SkContrast.bodyText),
          reason: '${named(ex)} on a card',
        );
        expect(
          SkContrast.ratio(ex.ink, ex.tile),
          greaterThanOrEqualTo(SkContrast.bodyText),
          reason: '${named(ex)} on a tile',
        );
      }
    });

    test('the helper lines clear AA at body size', () {
      // **This is the assertion `muted` failed.** `SkColors.light.muted` is
      // #8B8A72 and measures about 3.2:1 on the light ground -- a neutral
      // ground does not rescue it, which is why the exercise has a caption of
      // its own rather than borrowing the theme's.
      for (final SkExerciseColors ex in both) {
        expect(
          SkContrast.ratio(ex.caption, ex.ground),
          greaterThanOrEqualTo(SkContrast.bodyText),
          reason: named(ex),
        );
        expect(
          SkContrast.ratio(ex.caption, ex.surface),
          greaterThanOrEqualTo(SkContrast.bodyText),
          reason: '${named(ex)} on a card',
        );
        expect(
          SkContrast.ratio(ex.caption, ex.tile),
          greaterThanOrEqualTo(SkContrast.bodyText),
          reason: '${named(ex)} on a tile',
        );
      }
    });

    test('the dark helper line is held higher than AA, on purpose', () {
      // **AA is not enough here and the numbers say why.** The dark caption
      // was #9A9A8E for a day: 6.13:1, which passes, and is a *better* ratio
      // than the light set's 5.88:1. APCA -- which models the eye rather than
      // a ratio -- put the same pair at Lc 39 against the light set's Lc 68.
      // WCAG is known to over-reward pale text on a dark ground, so the pair
      // that measured better was the one nobody could read.
      //
      // There is no APCA in `SkContrast`, so the fix is pinned as the WCAG
      // number that goes with it. 8:1 on the ground is roughly Lc 55 and up;
      // anything back down at the AA floor puts the faintest text in the
      // lesson under the sentence explaining the lesson.
      expect(
        SkContrast.ratio(
          SkExerciseColors.dark.caption,
          SkExerciseColors.dark.ground,
        ),
        greaterThanOrEqualTo(8.0),
      );
    });

    // Since 21 September 2026 the two answer colours are the app's own status
    // tones rather than a green and a red invented for this file. Each set
    // takes the tones built for its own brightness -- the light tones on the
    // off-white, the dark tones on the near-black -- and never the palette's,
    // because the ground ignores the palette.
    test('the two tones are the app\'s own, not a pair of their own', () {
      for (final SkExerciseColors ex in both) {
        expect(
          ex.statusOf(SkTone.success).text,
          isNot(ex.statusOf(SkTone.destructive).text),
          reason: named(ex),
        );

        final SkColors source =
            ex.brightness == Brightness.dark ? SkColors.dark : SkColors.light;

        for (final SkTone tone in <SkTone>[
          SkTone.success,
          SkTone.destructive,
        ]) {
          final Color hue = SkStatusStyle.colourOf(source, tone);

          // **The words are the app's own tone, and that is the part that
          // carries the meaning.** A right answer in a lesson is set in the
          // same green as a right answer anywhere else, so the two are the
          // same object in two places.
          //
          // The wash behind them is not pinned to the tone, and since 23
          // September 2026 it deliberately is not in the light set. The light
          // tones are dark and low in colour, and a twelfth of one of those
          // on an off-white page is a grey -- `success` landed on #DBE3DA.
          // `SkExerciseColors` mixes the light wash from a brighter relative
          // of the same hue instead. A louder green, not a second green.
          expect(
            SkContrast.ratio(ex.statusOf(tone).text, ex.ground),
            greaterThanOrEqualTo(SkContrast.bodyText),
            reason: '$tone ${named(ex)}',
          );

          if (ex.brightness == Brightness.dark) {
            expect(
              ex.statusOf(tone).fill,
              SkContrast.over(hue, ex.ground, SkStatusStyle.fillAlpha),
              reason: '$tone ${named(ex)}',
            );
          }
        }
      }
    });

    test('the light set never takes a dark-mode tone, or the reverse', () {
      // The pairing is the whole point, and getting it backwards is silent:
      // the dark green on the off-white page measures about 1.5:1, and the
      // light green on the near-black is about the same the other way. Both
      // look like a slightly odd shade in a screenshot.
      for (final SkTone tone in <SkTone>[SkTone.success, SkTone.destructive]) {
        expect(
          SkContrast.ratio(
            SkStatusStyle.colourOf(SkColors.dark, tone),
            SkExerciseColors.light.ground,
          ),
          lessThan(SkContrast.bodyText),
          reason: '$tone: the dark tone does not belong on the light ground',
        );
        expect(
          SkContrast.ratio(
            SkStatusStyle.colourOf(SkColors.light, tone),
            SkExerciseColors.dark.ground,
          ),
          lessThan(SkContrast.bodyText),
          reason: '$tone: the light tone does not belong on the dark ground',
        );
      }
    });

    test('a quoted sentence is readable on both tinted fills', () {
      // The two example sentences on the introduction pages sit inside a
      // tinted tile and are set in `caption`, not `ink` -- the sentence is an
      // exhibit and the label above it in the tone is what the eye lands on
      // first. `caption` was worked out against the page ground, so its ratio
      // on a 12% wash is a different number and has to be held separately.
      for (final SkExerciseColors ex in both) {
        for (final SkTone tone in <SkTone>[
          SkTone.success,
          SkTone.destructive,
        ]) {
          expect(
            SkContrast.ratio(ex.caption, ex.statusOf(tone).fill),
            greaterThanOrEqualTo(SkContrast.bodyText),
            reason: '$tone ${named(ex)}',
          );
        }
      }
    });

    test('the soft mix still carries the sentence inside it', () {
      // An example speech bubble on an introduction page takes
      // `softStatusOf` rather than `statusOf`, because it is a whole sentence
      // wrapped in colour rather than a two-line verdict. The sentence is
      // `ink` and the label above it is the tone, so both have to clear the
      // weaker wash.
      for (final SkExerciseColors ex in both) {
        for (final SkTone tone in <SkTone>[
          SkTone.success,
          SkTone.destructive,
        ]) {
          final SkStatusStyle soft = ex.softStatusOf(tone);

          expect(
            SkContrast.ratio(ex.ink, soft.fill),
            greaterThanOrEqualTo(SkContrast.bodyText),
            reason: '$tone ${named(ex)} sentence',
          );
          expect(
            SkContrast.ratio(ex.caption, soft.fill),
            greaterThanOrEqualTo(SkContrast.bodyText),
            reason: '$tone ${named(ex)} caption',
          );

          // Softer than the block it is a quieter relative of. The whole
          // point is that it is less colour, so a later tweak that makes them
          // equal has undone it.
          expect(
            SkContrast.ratio(soft.fill, ex.ground),
            lessThan(SkContrast.ratio(ex.statusOf(tone).fill, ex.ground)),
            reason: '$tone ${named(ex)} is not softer than the block',
          );
        }
      }
    });

    test('a paragraph on a tint is the tint\'s own darkest shade', () {
      // The rule, from 24 September 2026: text on a coloured ground is that
      // ground's own colour taken to the far end of its range. It replaced
      // `ink` on every paragraph that sits on a wash -- the status block, the
      // feedback sheet, the drill's note, the example bubble's sentence.
      //
      // Three things have to hold at once, and the middle one is what makes
      // the change safe to have made at all.
      for (final SkExerciseColors ex in both) {
        for (final SkTone tone in <SkTone>[
          SkTone.success,
          SkTone.destructive,
          SkTone.warning,
          SkTone.info,
        ]) {
          for (final SkStatusStyle style in <SkStatusStyle>[
            ex.statusOf(tone),
            ex.softStatusOf(tone),
          ]) {
            // 1. It is legible. The floor every piece of text in the app
            //    stands on.
            expect(
              SkContrast.ratio(style.body, style.fill),
              greaterThanOrEqualTo(SkContrast.bodyText),
              reason: '$tone ${named(ex)} body is under AA',
            );

            // 2. It is no fainter than the `ink` it replaced. A rule about
            //    where a colour belongs must never cost somebody legibility,
            //    and this is the assertion that says so.
            expect(
              SkContrast.ratio(style.body, style.fill),
              greaterThanOrEqualTo(SkContrast.ratio(ex.ink, style.fill)),
              reason: '$tone ${named(ex)} body is fainter than ink was',
            );

            // 3. It is not the tone itself. `text` is the tone at its own
            //    strength -- right for a headline, a raised voice for five
            //    lines somebody reads through. That is the half of the old
            //    rule which survives.
            expect(
              SkContrast.ratio(style.body, style.fill),
              greaterThanOrEqualTo(SkContrast.ratio(style.text, style.fill)),
              reason: '$tone ${named(ex)} body is lighter than the tone',
            );
          }
        }
      }
    });

    test('an answered card is readable on its own fill', () {
      // The words and the icon both take `text`, and both sit on `fill`.
      for (final SkExerciseColors ex in both) {
        for (final SkTone tone in <SkTone>[
          SkTone.success,
          SkTone.destructive,
        ]) {
          final SkStatusStyle style = ex.statusOf(tone);

          expect(
            SkContrast.ratio(style.text, style.fill),
            greaterThanOrEqualTo(SkContrast.bodyText),
            reason: '$tone ${named(ex)}',
          );

          // And on the page behind it, since the wash is only 12% and the
          // card is read against the ground as much as against itself.
          expect(
            SkContrast.ratio(style.text, ex.ground),
            greaterThanOrEqualTo(SkContrast.bodyText),
            reason: '$tone ${named(ex)} on the ground',
          );
        }
      }
    });
  });

  // The forward control. Neutral on its own, and the answer's tone inside
  // the feedback sheet.
  group('the forward pill', () {
    test('its label is readable on every fill it takes', () {
      for (final SkExerciseColors ex in both) {
        for (final SkTone tone in <SkTone>[
          SkTone.success,
          SkTone.destructive,
        ]) {
          expect(
            SkContrast.ratio(ex.surface, ex.statusOf(tone).text),
            greaterThanOrEqualTo(SkContrast.bodyText),
            reason: '$tone ${named(ex)}',
          );
        }

        expect(
          SkContrast.ratio(ex.surface, ex.pillFill),
          greaterThanOrEqualTo(SkContrast.bodyText),
          reason: named(ex),
        );
      }
    });

    test('disabled, it is still readable and still visibly off', () {
      for (final SkExerciseColors ex in both) {
        expect(
          SkContrast.ratio(ex.caption, ex.line),
          greaterThanOrEqualTo(SkContrast.bodyText),
          reason: named(ex),
        );

        // A disabled pill must not be mistakable for a live one, and the two
        // are told apart by more than their label's colour.
        expect(
          SkContrast.ratio(ex.line, ex.pillFill),
          greaterThanOrEqualTo(SkContrast.nonText),
          reason: named(ex),
        );
      }
    });

    test('the dark pill is dimmer than the ink, and the light one is not', () {
      // **The pill is the largest solid block on the screen, so its fill is a
      // question about emitted light rather than about contrast.** For one
      // day the dark set filled it with `ink` -- #EDECE5, luminance 0.837, on
      // a ground of 0.010 -- and it was reported as harsh immediately. The
      // light set has the opposite problem and therefore no problem: there
      // the pill is the darkest thing on a pale page.
      //
      // Both halves are pinned, because taking the light pill off `ink` would
      // introduce the third colour the original rule exists to prevent, and
      // putting the dark pill back on `ink` would bring the lamp back.
      expect(
        SkExerciseColors.light.pillFill,
        SkExerciseColors.light.ink,
        reason: 'the light pill is the ink exactly',
      );
      expect(
        SkExerciseColors.dark.pillFill.computeLuminance(),
        lessThan(SkExerciseColors.dark.ink.computeLuminance()),
        reason: 'the dark pill is a dimmed ink, never the ink',
      );
      // Still unmistakably the primary action, not a quiet tile.
      expect(
        SkContrast.ratio(
          SkExerciseColors.dark.pillFill,
          SkExerciseColors.dark.ground,
        ),
        greaterThanOrEqualTo(SkContrast.nonText),
      );
    });
  });

  // The progress bar's fill is the one thing on an exercise page that still
  // follows the user's palette. Everything else is neutral, so the fill is the
  // only way a theme can break this screen.
  group('the progress bar fill', () {
    test('every palette\'s action is visible on the matching ground', () {
      for (final SkPalette palette in SkPalettes.all) {
        expect(
          SkContrast.ratio(
            palette.light.action,
            SkExerciseColors.light.ground,
          ),
          greaterThanOrEqualTo(SkContrast.nonText),
          reason: '${palette.name} light',
        );
        expect(
          SkContrast.ratio(palette.dark.action, SkExerciseColors.dark.ground),
          greaterThanOrEqualTo(SkContrast.nonText),
          reason: '${palette.name} dark',
        );
      }
    });

    test('the grounds have to turn over together for that to hold', () {
      // **This is what the dark set bought, stated as a measurement.** While
      // the page was off-white in both modes the bar took a dark-mode action
      // and landed on it between 2.32:1 and 1.38:1 -- in Moonlit valley very
      // nearly invisible. If somebody ever freezes the ground back to the
      // light set, this fails and says why.
      for (final SkPalette palette in SkPalettes.all) {
        expect(
          SkContrast.ratio(palette.dark.action, SkExerciseColors.light.ground),
          lessThan(SkContrast.nonText),
          reason: '${palette.name}: a dark action on a light ground',
        );
      }
    });

    test('the track is quiet, not held to 3:1 itself', () {
      // **The pair that carries the meaning is the fill against the page.**
      // The empty track is `line`, about 1.2:1 on its own ground -- a
      // hairline, not a second colour, and the bar reads because the fill sits
      // in a groove rather than because the groove is visible. Holding the
      // fill to 3:1 against the track as well was tried on 22 September 2026
      // and dropped: Coral diorama's light action lands at 2.79:1 there, and
      // every way of closing that gap makes the bar worse.
      for (final SkExerciseColors ex in both) {
        expect(
          SkContrast.ratio(ex.line, ex.ground),
          lessThan(SkContrast.nonText),
          reason: named(ex),
        );
      }
    });
  });

  group('the grounds themselves', () {
    test('neither is pure, and both are warm rather than grey', () {
      // Pure white glares under a long read and pure black glares in the
      // dark; a grey ground tints the ink. All three are the reasons these
      // colours exist, so all three are pinned.
      expect(SkExerciseColors.light.ground.r, lessThan(1.0));
      expect(SkExerciseColors.light.ground.r, greaterThan(0.92));

      expect(SkExerciseColors.dark.ground.r, greaterThan(0.0));
      expect(SkExerciseColors.dark.ground.r, lessThan(0.15));

      for (final SkExerciseColors ex in both) {
        expect(ex.ground.r, greaterThan(ex.ground.b), reason: named(ex));
      }
    });

    test('a card is visible against its own ground', () {
      // The step is small on purpose -- the card has a border as well -- but
      // it may not be nothing, or a card and the page are one surface.
      for (final SkExerciseColors ex in both) {
        expect(
          SkContrast.ratio(ex.surface, ex.ground),
          greaterThan(1.0),
          reason: named(ex),
        );
      }
    });

    test('the two sets face opposite ways', () {
      // The light set is dark ink on a pale page; the dark set is the other
      // way round. Stated so a half-finished edit -- a dark ground with the
      // light ink still on it -- cannot pass every ratio above and still be
      // wrong.
      expect(
        SkExerciseColors.light.ground.computeLuminance(),
        greaterThan(SkExerciseColors.light.ink.computeLuminance()),
      );
      expect(
        SkExerciseColors.dark.ground.computeLuminance(),
        lessThan(SkExerciseColors.dark.ink.computeLuminance()),
      );
    });
  });

  group('picking a set', () {
    testWidgets('follows the theme brightness, never the palette', (
      WidgetTester tester,
    ) async {
      for (final SkPalette palette in SkPalettes.all) {
        for (final bool isDark in <bool>[false, true]) {
          late SkExerciseColors seen;

          // **A fresh key per pump, or this reads a half-finished theme.**
          // `MaterialApp` crossfades between two `ThemeData`s, so the first
          // frame after swapping light for dark is a lerp of the two and its
          // brightness is whatever the halfway point rounds to. A new key
          // builds a new element with no animation to be in the middle of.
          await tester.pumpWidget(
            MaterialApp(
              key: ValueKey<String>('${palette.id}-$isDark'),
              theme:
                  isDark ? appDarkTheme(palette.dark) : appTheme(palette.light),
              home: Builder(
                builder: (BuildContext context) {
                  seen = context.exercise;
                  return const SizedBox.shrink();
                },
              ),
            ),
          );

          expect(
            seen,
            same(isDark ? SkExerciseColors.dark : SkExerciseColors.light),
            reason: '${palette.name} ${isDark ? 'dark' : 'light'}',
          );
        }
      }
    });
  });
}
