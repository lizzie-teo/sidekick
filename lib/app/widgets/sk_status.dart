import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// The four things a screen can tell somebody about what just happened.
//
// **Four, and no more.** A fifth tone is a fifth colour to learn, and the
// reader only ever needs to know: it worked, it did not, be careful, here is
// something. Anything that does not fit one of these is not a status -- it is
// content, and content is `ink` on the page like everything else.
enum SkTone {
  // It worked. The answer was right, the thing saved.
  success,

  // It did not. The answer was wrong, the thing failed, this deletes something.
  //
  // **Named `destructive` rather than `error` because it is both jobs.** The
  // Me tab's delete row and a wrong answer are the same red. Two reds would be
  // two meanings for one colour family, which is worse than one word doing
  // double duty.
  destructive,

  // Careful. Something is about to be harder to undo than it looks.
  warning,

  // Here is something worth knowing. No action, no verdict.
  info,
}

// The three colours a status block is built from, worked out for one tone on
// one ground.
//
// **Text, fill and edge, and the fill is always a wash.** The pattern is the
// same everywhere in the app: the colour at 12% is the ground, the colour at
// 25% is the edge, and the colour itself is the words. A solid fill is not an
// option -- see `SkStatusBlock` for why.
@immutable
class SkStatusStyle {
  // The words and the icon. The tone itself wherever it is legible, nudged in
  // lightness where it is not.
  final Color text;

  // The wash the block sits on: the tone at 12% over whatever is behind it.
  final Color fill;

  // The hairline around it, at 25%.
  final Color edge;

  const SkStatusStyle({
    required this.text,
    required this.fill,
    required this.edge,
  });

  // **The alpha values are the same two the explanation sheet uses**, and
  // that is deliberate: a tinted block should look like a tinted block
  // wherever it appears, whether it is saying "wrong answer" or holding a
  // belief somebody is arguing with.
  static const double fillAlpha = 0.12;
  static const double edgeAlpha = 0.25;

  // Build the three colours for a tone on a given ground.
  //
  // `ground` is what is actually behind the block -- usually `sk.canvas`, but
  // `sk.surface` when the block is inside a card. It is not optional and has
  // no default, because the whole point is that the colours answer the
  // surface rather than assume one.
  factory SkStatusStyle.of(BuildContext context, SkTone tone, Color ground) {
    final Color hue = colourOf(context.sk, tone);
    final Color fill = SkContrast.over(hue, ground, fillAlpha);

    return SkStatusStyle(
      // Measured against the fill, not the ground. The words sit on the wash,
      // and the wash is the thing that eats the contrast -- a colour checked
      // against the page behind it would pass on paper and fail on screen.
      text: SkContrast.readable(hue, fill),
      fill: fill,
      edge: hue.withValues(alpha: edgeAlpha),
    );
  }

  static Color colourOf(SkColors sk, SkTone tone) => switch (tone) {
        SkTone.success => sk.success,
        SkTone.destructive => sk.destructive,
        SkTone.warning => sk.warning,
        SkTone.info => sk.info,
      };

  // The icon that goes with each tone.
  //
  // **An icon, always, because colour is never the only cue.** Roughly one man
  // in twelve cannot separate the red from the green, and a quiz that answers
  // only in colour answers nothing for him. The shapes are the four everybody
  // already knows -- a tick, a cross, a triangle, a circled i -- because a
  // status is recognised, not read.
  static IconData iconOf(SkTone tone) => switch (tone) {
        SkTone.success => Icons.check_circle_outline_rounded,
        SkTone.destructive => Icons.cancel_outlined,
        SkTone.warning => Icons.warning_amber_rounded,
        SkTone.info => Icons.info_outline_rounded,
      };
}

// A block that says what just happened: an icon, a headline, and optionally a
// line or two under it.
//
// **It is a wash and a hairline, never a filled pill, and that is what keeps
// it from being mistaken for a button.** The primary action in this app is a
// filled pill; a status is a block of colour you read. Some palettes put the
// action colour close to a status hue -- Moss dark runs a gold action next to
// a gold warning -- and the difference in *shape* is what survives that,
// where a difference in hue would not.
//
// **It never says how the reader should feel about it.** "Correct" and "Not
// this one" are facts. "Well done" is a score, and the app does not keep
// scores -- the same rule that took the counter off the breathing screen.
class SkStatusBlock extends StatelessWidget {
  final SkTone tone;

  // The headline. One short line: it is read at a glance, and a status that
  // takes a sentence to land has stopped being a status.
  final String label;

  // The optional line or two under it -- why the answer was wrong, what to do
  // next.
  final String? body;

  // What is behind the block. Defaults to the page ground, which is where
  // nearly every one of these sits.
  final Color? ground;

  const SkStatusBlock({
    super.key,
    required this.tone,
    required this.label,
    this.body,
    this.ground,
  });

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final SkStatusStyle style =
        SkStatusStyle.of(context, tone, ground ?? sk.canvas);

    return Semantics(
      container: true,
      liveRegion: true,
      // The tone is in the label as a word as well as in the icon, because a
      // screen reader is handed neither the colour nor the shape.
      label: '${_spokenTone(tone)}. $label${body == null ? '' : '. $body'}',
      excludeSemantics: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(SkLayout.lg),
        decoration: BoxDecoration(
          color: style.fill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: style.edge),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(SkStatusStyle.iconOf(tone), size: 20, color: style.text),
            const SizedBox(width: SkLayout.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    label,
                    style: SkText.sheetHeading.copyWith(color: style.text),
                  ),
                  if (body != null) ...<Widget>[
                    const SizedBox(height: SkLayout.xs),
                    // The body is `ink`, not the tone. A whole paragraph in a
                    // status colour reads as shouting, and the tone has
                    // already been said by the icon and the headline above it.
                    Text(
                      body!,
                      style: SkText.rowLabel.copyWith(color: sk.ink),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _spokenTone(SkTone tone) => switch (tone) {
        SkTone.success => 'Correct',
        SkTone.destructive => 'Not correct',
        SkTone.warning => 'Careful',
        SkTone.info => 'Note',
      };
}
