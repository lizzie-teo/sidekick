import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_outline_button.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// The day's one small thing, on a card, behind Home's "Pause" button.
//
// Built 25 September 2026, at the user's request. The prompt used to sit
// under the sidekick as a line of text, and it read as an order from nowhere.
// A card is a thing you are handed; a line under her is a caption.
//
// **One card, not a deck.** The user decided that. A deck asks "and the
// next?", and a swipe with no end is the shape of doomscrolling. One card is
// the same all day, so coming back finds the same thing rather than a thing
// that was missed. The viewmodel holds the day; this only draws it.
//
// **Nothing marks it done.** The only way out is "Close" -- not "Done", not
// "I did it". Rule 2 of `_docs/briefs/noticing-prompts.md`: a task with a
// finish is a thing to have failed at by bedtime.
//
// **Nothing is behind the card.** It does not flip and it does not explain
// itself. A prompt names one thing and stops.
class PauseSheet extends StatelessWidget {
  // The button's label on Home, and the sheet's own name for a screen
  // reader. One word, because it sits in a row of one-word pills.
  static const String buttonLabel = 'Pause';

  // The small label over the prompt, saying what kind of sentence it is
  // before it is read.
  static const String label = 'One small thing';

  final String prompt;

  const PauseSheet({super.key, required this.prompt});

  static Future<void> show(BuildContext context, String prompt) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      // The root navigator, so the sheet covers the floating tab bar too.
      // `AffirmationSheet` holds the reasoning.
      useRootNavigator: true,
      backgroundColor: context.sk.canvas,
      barrierLabel: 'Close this card',
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext sheetContext) => PauseSheet(prompt: prompt),
    );
  }

  // One plain object per prompt, so the card has a picture the way the
  // reference sheet's cards do. **Each one is the thing the prompt names** --
  // a hand for the hands, a glass for the water -- which is the test the
  // topic cards' icons failed: a situation has no picture of itself, a hand
  // does. Decoration only, so screen readers skip it.
  //
  // Keyed by the prompt's own words. `test/pause_sheet_test.dart` walks the
  // whole set, so a new prompt without a picture fails there rather than
  // quietly falling back.
  static const Map<String, IconData> icons = <String, IconData>{
    'Press both feet flat on the floor.': Icons.directions_walk_rounded,
    'Sit back and let the chair take your weight.': Icons.chair_rounded,
    'Rest your hands on your legs.': Icons.back_hand_rounded,
    'Let your shoulders drop, away from your ears.':
        Icons.accessibility_new_rounded,
    'Let your teeth come apart. Your jaw can hang loose.':
        Icons.sentiment_satisfied_rounded,
    'Let your forehead go smooth.': Icons.face_rounded,
    'Wiggle your fingers slowly.': Icons.back_hand_rounded,
    'Rub your hands together until they are warm.': Icons.back_hand_rounded,
    'Stretch your fingers wide, then let them go.': Icons.front_hand_rounded,
    'Put a hand on your chest and leave it there.': Icons.favorite_rounded,
    'Stretch your arms up over your head.': Icons.accessibility_new_rounded,
    'Roll your shoulders back slowly, three times.':
        Icons.accessibility_new_rounded,
    'Turn your head slowly to one side, then the other.': Icons.face_rounded,
    'Close your eyes, or look down, and count to five.':
        Icons.visibility_off_rounded,
    'Look at the thing furthest away from you.': Icons.visibility_rounded,
    'Find one blue thing near you.': Icons.palette_rounded,
    'Look out of a window for a moment.': Icons.window_rounded,
    'Listen for the quietest sound in the room.': Icons.hearing_rounded,
    'Feel your sleeve between your finger and thumb.': Icons.checkroom_rounded,
    'Have a drink of water. Take the first sip slowly.':
        Icons.local_drink_rounded,
    'Hold something warm in both hands, if something is near.':
        Icons.coffee_rounded,
  };

  static IconData iconFor(String prompt) => icons[prompt] ?? Icons.spa_rounded;

  @override
  Widget build(BuildContext context) {
    final double gutter = SkLayout.gutter(context);

    return SafeArea(
      top: false,
      // Measured from the incoming constraints, never MediaQuery.sizeOf: a
      // bare MediaQueryData reports zero, which is what the test harness
      // supplies, and a cap of zero pushes Close off the bottom.
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double cap = constraints.maxHeight.isFinite
              ? constraints.maxHeight * 0.92
              : double.infinity;

          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: cap),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const _GrabHandle(),

                // The card scrolls only at 200% text on a small phone. Close
                // stays outside it, so the way out is on screen from the first
                // frame.
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        gutter, SkLayout.xs, gutter, SkLayout.sm),
                    child: SkLayout.readable(
                      child: _Card(prompt: prompt),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(
                      gutter, SkLayout.md, gutter, SkLayout.lg),
                  child: SkLayout.readable(
                    child: SkOutlineButton(
                      label: 'Close',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// The card itself: a tinted block in the palette's own action colour, the
// shape rule 7 of the style guide gives every tinted block.
//
// **The palette's colour, not a pastel of its own.** The reference sheet runs
// nine pastels, one per card. Here that would be a hex literal per prompt,
// right in at most one of twelve schemes. One card a day needs one colour,
// and the reader's own palette is the one that is already theirs.
class _Card extends StatelessWidget {
  final String prompt;

  const _Card({required this.prompt});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    // The pixel that actually lands, so the label and the icon can be
    // measured against it.
    final Color ground = SkContrast.over(sk.action, sk.canvas, 0.10);
    final Color caption = SkContrast.captionOn(ground);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: SkLayout.xl,
        vertical: SkLayout.huge,
      ),
      decoration: BoxDecoration(
        color: ground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sk.action.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ExcludeSemantics(
            child: Icon(
              PauseSheet.iconFor(prompt),
              size: 56,
              // The icon carries no meaning the words do not, but it is held
              // to the non-text 3:1 anyway so it never reads as disabled.
              color: SkContrast.readable(sk.action, ground,
                  minRatio: SkContrast.nonText),
            ),
          ),
          const SizedBox(height: SkLayout.xxl),
          Semantics(
            header: true,
            child: Text(
              PauseSheet.label,
              textAlign: TextAlign.center,
              style: SkText.chipLabel.copyWith(color: caption),
            ),
          ),
          const SizedBox(height: SkLayout.sm),
          // `homePrompt`, the size the prompt had on Home: it is still the
          // only thing on this screen at 24, so it is still rank one.
          Text(
            prompt,
            textAlign: TextAlign.center,
            style: SkText.homePrompt
                .copyWith(color: SkContrast.inkOn(sk.action, ground, sk.ink)),
          ),
        ],
      ),
    );
  }
}

class _GrabHandle extends StatelessWidget {
  const _GrabHandle();

  @override
  Widget build(BuildContext context) {
    // Hidden from screen readers: a picture of a gesture somebody using one
    // is not making. Close is their way out.
    return ExcludeSemantics(
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 16),
        child: Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.sk.chevron,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
