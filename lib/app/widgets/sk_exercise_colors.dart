import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_status.dart';

// The ground an exercise sits on: one neutral set for the light mode and one
// for the dark, the same two in all six palettes.
//
// **These are fixed literals, not theme slots, and that is the point.**
// `_docs/design-guidelines/visual-style.md` says colour comes from
// `context.sk` and never from a hex literal. That rule is about a screen
// quietly falling out of step with the palette the user picked. Here the
// literal *is* the decision: an exercise must read the same on the sixth
// visit as on the first, and a ground that goes warm in Coral diorama and
// cool in Dusk terrarium makes six different promises about the same lesson.
//
// It is the same call the tighten screen already made. There the orb is two
// fixed constants and the page ground is the palette; here it is the other
// way round, because the exercise is a page of text rather than one thing to
// sit with. The theme stops at the edge of the screen.
//
// **The second reason is plain readability.** A lesson is long-form reading
// -- six sentences, three builder steps, an explanation after every answer.
// A near-neutral ground is the quietest thing text can sit on: almost no hue
// to tint the ink, and a fraction off the end of the range so it does not
// glare or go to pitch black.
//
// **Light and dark are two different questions, and this file only stopped
// answering one of them on 22 September 2026.** There was a single off-white
// set here, used in both modes, so a reader on a dark phone opened a lesson
// and got a page of white light. "The palette does not reach in here" was
// right; "light or dark does not reach in here" was never argued for -- it
// was the same rule stretched past what it was written about, which is the
// mistake `CLAUDE.md` has a whole section on. Light and dark is the phone's
// own setting and it is about the room the reader is in, not about decorating
// the lesson.
//
// So: **the palette stops at the edge of the screen, the mode does not.** The
// two sets are neutral greys in both directions, so the lesson still looks
// the same in Moss as in Coral diorama.
//
// Every pair below is above the 4.5:1 WCAG 1.4.3 asks of small text, in both
// sets. `test/exercise_contrast_test.dart` walks both and asserts them, so a
// later tweak cannot quietly drop one under.
@immutable
class SkExerciseColors {
  const SkExerciseColors._({
    required this.brightness,
    required this.ground,
    required this.surface,
    required this.ink,
    required this.caption,
    required this.line,
    required this.lineStrong,
    required this.tile,
    required this.pillFill,
  });

  // Which of the two sets this is. It decides where the status tones come
  // from, and nothing else reads it.
  final Brightness brightness;

  // The page.
  final Color ground;

  // A card on it: a small step away from the ground, up in the light set and
  // up again in the dark one. The step is deliberately small -- every card
  // here already has a border, and a card that shouts is a card competing
  // with the sentence inside it.
  final Color surface;

  // Body and heading text.
  final Color ink;

  // The helper lines under a question.
  //
  // **It is a shade of its own ground, and it is named `caption` rather than
  // `muted` on purpose.** `muted` is a banned text colour in this app --
  // `SkColors.light.muted` is #8B8A72 and measures 3.2:1 on the light ground,
  // failing at body size the same way it fails on cream. A field called
  // `muted` on a colour set would read as the banned one to the next person,
  // and it is not: it is roughly what `SkContrast.captionOn()` returns for its
  // own ground, worked out once and frozen because the grounds are frozen.
  final Color caption;

  // A card's edge, and the progress bar's empty track.
  final Color line;

  // The same edge under a finger, and a scrollbar.
  final Color lineStrong;

  // A rounded tile: the two nav buttons, and the box the sentence is built in.
  final Color tile;

  // The neutral forward pill's fill. Its label is `surface`, the same as the
  // toned pill's inside the feedback sheet.
  //
  // **In the light set this is exactly `ink`. In the dark set it deliberately
  // is not, and the reason is area rather than colour.** The rule the pill was
  // built on -- "it is the same near-black the body text is set in, so it
  // belongs to the page" -- was written on 21 September 2026, when the light
  // set was the only set. There `ink` on `ground` is the darkest thing on a
  // pale page: relative luminance 0.023 against the ground's 0.896, so the
  // pill *absorbs* light.
  //
  // Turning the ground over on 22 September 2026 turned that round without
  // anybody choosing it. `ink` became #EDECE5, and the pill became the
  // brightest object on a near-black page -- 0.837 against the ground's 0.010
  // -- **and it is also the largest solid block on the screen**, full width
  // and 56 tall. A line of text at that brightness is thin strokes; a slab at
  // that brightness is a lamp. Reported as harsh the day it shipped.
  //
  // So the dark pill is a dimmed ink: about a third less light out of it,
  // while the label still clears 9.16:1 and the pill still clears 10.25:1
  // against the page. It is still a filled pill, because the shape is what
  // separates the primary action from a status block.
  //
  // **This is the `CLAUDE.md` scope rule caught in the act.** "The pill is
  // `ink`" was protecting against a third colour on the page. A dimmed ink is
  // not a third colour, so the rule does not reach the brightness question,
  // and applying it in the dark made the screen worse while looking careful.
  final Color pillFill;

  // The light set. Off-white rather than white: pure white glares under a long
  // read, and a grey ground tints the ink.
  //
  // | Pair | Ratio |
  // | --- | --- |
  // | ink on ground | 13.0:1 |
  // | ink on a card | 14.4:1 |
  // | caption on ground | 5.9:1 |
  // | caption on a card | 6.5:1 |
  static const SkExerciseColors light = SkExerciseColors._(
    brightness: Brightness.light,
    ground: Color(0xFFF4F3EF),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF2A2A28),
    caption: Color(0xFF5E5E58),
    line: Color(0xFFE4E3DD),
    lineStrong: Color(0xFFC9C8C1),
    tile: Color(0xFFEAE9E3),
    // Exactly `ink`. On a pale page the pill is the darkest thing on screen,
    // which is the shape the rule was written for.
    pillFill: Color(0xFF2A2A28),
  );

  // The dark set, built on 22 September 2026 as the light set turned over.
  //
  // **It is a near-black with a trace of warmth in it, not pitch black.** The
  // light ground is a hair warm -- more red than blue by the smallest amount
  // that is still a decision -- and this keeps the same bias, so the two modes
  // are one family rather than two. Pure black was rejected for the reason
  // pure white was: maximum contrast against body text is not comfort, it is
  // glare, and it is worse in the dark because the reader's eyes are open wide.
  //
  // | Pair | Ratio | APCA |
  // | --- | --- | --- |
  // | ink on ground | 14.7:1 | Lc 87 |
  // | ink on a card | 13.2:1 | Lc 85 |
  // | caption on ground | 9.4:1 | Lc 59 |
  // | caption on a card | 8.4:1 | Lc 58 |
  //
  // **The caption was #9A9A8E for a day and it was too faint.** It measured
  // 6.1:1, which is *better* than the light set's 5.9:1 by WCAG, and that is
  // the number lying. WCAG is known to over-reward pale text on a dark ground.
  // APCA, which models the eye rather than a ratio, put the same pair at
  // Lc 39 against the light set's Lc 68 -- so the helper line under a
  // question, the line whose whole job is explaining, was the faintest text
  // in the lesson on a dark phone and the clearest on a light one. The value
  // here is the one that brings the two modes back level.
  //
  // **The hairline is a slightly bigger step off the ground than the light
  // set's is** -- 1.30:1 against 1.16:1. An edge in the dark reads weaker than
  // the same edge in the light, and the disabled forward pill is filled with
  // this colour, so its label has to clear 4.5:1 against it as well. At
  // #2C2C29 it did not.
  static const SkExerciseColors dark = SkExerciseColors._(
    brightness: Brightness.dark,
    ground: Color(0xFF1A1A17),
    surface: Color(0xFF24241F),
    ink: Color(0xFFEDECE5),
    caption: Color(0xFFC0BFB3),
    line: Color(0xFF2F2F2B),
    lineStrong: Color(0xFF4E4D46),
    tile: Color(0xFF282823),
    // A dimmed `ink`, not `ink`. See `pillFill` above.
    pillFill: Color(0xFFC8C7BB),
  );

  // Which set this screen is on.
  //
  // **It reads the theme's brightness, never `context.sk`.** The palette has
  // nothing to say here; light or dark does. `ThemeData.brightness` is the one
  // fact about the theme an exercise page is allowed to look at.
  static SkExerciseColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? dark : light;

  // Success and destructive, on this ground.
  //
  // **They are the app's own two status tones, not a pair invented here.**
  // Until 21 September 2026 this file held six hand-picked literals --
  // `rightFill`, `wrongInk` and so on -- an olive green and a burnt orange
  // that existed nowhere else in the app. A lesson marking an answer in one
  // green while every other screen uses another is the kind of difference
  // nobody can name and everybody feels. `sk_status.dart` owns the four
  // tones; this asks it for two of them.
  //
  // **The set follows this ground, not the app's theme, and that is the whole
  // reason this is a method rather than a call to `SkStatusStyle.of`.** That
  // factory reads `context.sk`, which follows the palette as well as the mode.
  // Here the light tones go on the light ground and the dark tones on the dark
  // one, whatever palette is switched on -- so a right answer in a lesson is
  // the same green as every other "it worked" in the app, and never a
  // dark-mode green stranded on an off-white page.
  //
  // The three colours are built exactly as `SkStatusStyle.of` builds them, at
  // the same two alphas, so a marked answer here and a status block anywhere
  // else are the same object in two places.
  SkStatusStyle statusOf(SkTone tone) =>
      _statusCache[(brightness, tone)] ??= _build(tone);

  // The same tone, mixed weak, for a block of colour large enough that the
  // usual wash would shout.
  //
  // **Area is the whole reason this exists.** A status block is a strip a
  // couple of lines tall with an icon in it; an example speech bubble on an
  // introduction page is a full-width shape wrapped round a whole sentence,
  // and the reader has to read that sentence *through* the colour. The wash
  // that makes a verdict land makes an exhibit hard to look at. Reported on
  // 23 September 2026, the same day the ordinary wash was brightened.
  //
  // It is a weaker mix of exactly the same colours, not a different pair, so
  // a green example and a green verdict are still the same green -- one said
  // quietly and one said plainly. The words inside stay `ink`: a sentence the
  // reader is being shown is content, and the tone around it is the label.
  SkStatusStyle softStatusOf(SkTone tone) =>
      _softStatusCache[(brightness, tone)] ??= _build(tone, soft: true);

  // A twelfth of the way to the tone rather than a fifth, and a hairline that
  // still reads as an edge. Both apply in either mode.
  static const double _softFillAlpha = 0.10;
  static const double _softEdgeAlpha = 0.30;

  SkStatusStyle _build(SkTone tone, {bool soft = false}) {
    final bool isDark = brightness == Brightness.dark;

    // The words keep the app's own tone. It was picked to be legible on a
    // pale ground and it is the colour every other "it worked" in the app is
    // set in, so a lesson still marks an answer in the same green.
    final Color hue = SkStatusStyle.colourOf(
      isDark ? SkColors.dark : SkColors.light,
      tone,
    );

    // The wash is built from a brighter relative of that tone, not from the
    // tone itself. See `_lightTint` for why.
    final Color wash = isDark ? hue : _lightTint(tone);
    final double fillAlpha = soft
        ? _softFillAlpha
        : (isDark ? SkStatusStyle.fillAlpha : _lightFillAlpha);
    final double edgeAlpha = soft
        ? _softEdgeAlpha
        : (isDark ? SkStatusStyle.edgeAlpha : _lightEdgeAlpha);

    final Color fill = SkContrast.over(wash, ground, fillAlpha);

    return SkStatusStyle(
      // Measured against the fill it sits on, never against the page behind
      // it -- the wash is what eats the contrast.
      text: SkContrast.readable(hue, fill),
      fill: fill,
      edge: wash.withValues(alpha: edgeAlpha),
    );
  }

  // The brighter relative each tone is washed with in the light set.
  //
  // **This exists because the light tones are dark and low in colour, and a
  // twelfth of a dark colour on an off-white page is not a colour at all.**
  // Reported as dull on 23 September 2026, and the numbers agree: `success`
  // #246D43 at 12% over #F4F3EF lands on #DBE3DA, `info` #336399 lands on
  // #DDE2E5. Those are greys with a rumour of a hue in them. A reader
  // finishing a question was being told the answer in a colour they could
  // not quite see.
  //
  // **More of the same colour does not fix it.** Raising the alpha on a
  // desaturated dark green only produces a darker grey-green, and it eats the
  // contrast the words and the quoted sentence need. The missing quality is
  // chroma -- how much colour is in the colour -- so the wash is mixed from a
  // tone of the same hue with far more of it, at roughly the lightness the
  // page wants.
  //
  // **The tone itself is untouched, and that is what keeps the rule.** The
  // app's four status colours are still the only things the words and the
  // icon are set in, so a right answer in a lesson is the same green as a
  // right answer anywhere else. What changed is how much colour sits behind
  // it. A brighter wash is the same green said louder, not a second green.
  //
  // **The dark set is deliberately not given one.** Its tones are already
  // pale and saturated -- #6FC094, #E8897B -- and 12% of those on a near-black
  // page already reads as a colour. A brighter wash there would be a lamp,
  // which is the mistake `pillFill` above records.
  static Color _lightTint(SkTone tone) => switch (tone) {
        SkTone.success => const Color(0xFF1FA85E),
        SkTone.destructive => const Color(0xFFE04A2E),
        SkTone.warning => const Color(0xFFD19320),
        SkTone.info => const Color(0xFF2F7FD1),
      };

  // A fifth rather than an eighth, and a stronger hairline with it. Both are
  // the light set's alone: `SkStatusStyle.fillAlpha` and `edgeAlpha` still
  // govern the dark set and the rest of the app.
  static const double _lightFillAlpha = 0.20;
  static const double _lightEdgeAlpha = 0.40;

  // Built once per mode. `SkContrast.readable` solves a loop, and these are
  // read on every rebuild of every card on the screen.
  static final Map<(Brightness, SkTone), SkStatusStyle> _statusCache =
      <(Brightness, SkTone), SkStatusStyle>{};

  static final Map<(Brightness, SkTone), SkStatusStyle> _softStatusCache =
      <(Brightness, SkTone), SkStatusStyle>{};
}

extension SkExerciseTheme on BuildContext {
  // The exercise colours for this screen. Short because it is read on nearly
  // every line of a lesson view, the way `context.sk` is everywhere else.
  SkExerciseColors get exercise => SkExerciseColors.of(this);
}
