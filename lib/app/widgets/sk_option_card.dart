import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_exercise_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_status.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// What an option card is showing.
enum SkOptionState {
  // Not chosen, and still choosable.
  plain,

  // Chosen, where there is no right answer -- one of the offered lines in the
  // sentence builder. It wears the same green as a right answer on purpose:
  // green here means "this is the one you picked", and there is nothing on
  // those steps for it to be confused with.
  chosen,

  // The right answer, after a guess.
  right,

  // The card the reader picked, and it was not the right one.
  wrong,

  // The other card, once the answer is known. Faded rather than removed, so
  // the row does not change height under the finger that just tapped it.
  dimmed,
}

// A full-width card the reader taps: an answer, or a line to put in a
// sentence.
//
// **The tick and the cross are part of the card, not a badge on it.** A
// coloured fill, a coloured edge and a circle at the end all say the same
// thing at once, which is what makes the answer readable without reading.
//
// **A card in an answered state is disabled, and keeps its height.** The two
// answer cards stop taking taps the moment one is chosen, so the explanation
// on screen always belongs to the tap that produced it. Nothing is removed
// and nothing shrinks: the losing card fades, so the stack under the reader's
// finger does not move.
//
// The colours are the fixed exercise set rather than the theme's. An exercise
// reads the same in every palette -- `sk_exercise_colors.dart` holds why --
// and the green and red in particular are meaning rather than decoration.
class SkOptionCard extends StatelessWidget {
  const SkOptionCard({
    super.key,
    required this.label,
    required this.onPressed,
    this.state = SkOptionState.plain,
  });

  final String label;

  // Null disables the card. It is how an answered question stops taking
  // taps.
  final VoidCallback? onPressed;

  final SkOptionState state;

  static const double _markSize = 26;

  @override
  Widget build(BuildContext context) {
    final SkExerciseColors ex = context.exercise;
    final _CardSkin skin = _skinFor(state, ex);

    final Widget card = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SkLayout.lg,
        vertical: SkLayout.lg + 1,
      ),
      decoration: BoxDecoration(
        color: skin.fill,
        borderRadius: BorderRadius.circular(SkLayout.lg),
        border: Border.all(color: skin.edge, width: 1.5),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: SkText.caption.copyWith(
                color: skin.ink,
                fontWeight: skin.bold ? FontWeight.w600 : FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
          // **The status system's own icon, drawn as an icon.** It used to be
          // a white glyph inside a filled circle of the card's edge colour --
          // a second filled shape on a card whose whole job is to be a wash
          // with a hairline. `SkStatusStyle.iconOf` is already a circled tick
          // and a circled cross, so the circle was being drawn twice.
          if (skin.mark != null) ...<Widget>[
            const SizedBox(width: SkLayout.md),
            ExcludeSemantics(
              child: Icon(skin.mark, size: _markSize, color: skin.ink),
            ),
          ],
        ],
      ),
    );

    final Widget faded = state == SkOptionState.dimmed
        ? Opacity(opacity: 0.45, child: card)
        : card;

    if (onPressed == null) return faded;

    return SkPressable(
      onPressed: onPressed,
      wash: ex.ink,
      borderRadius: BorderRadius.circular(SkLayout.lg),
      child: faded,
    );
  }

  // **A card is neutral until it is answered.** The two options in a sorting
  // drill are the names of two kinds of sentence, and painting them by kind
  // was tried on 21 September 2026 and taken straight back out: on a screen
  // that marks answers, green already means *you were right*. Two meanings
  // for one colour on one screen is one too many, and the option the reader
  // has not chosen yet is not a verdict about anything.
  //
  // The colours are the app's own two status tones, taken from
  // `sk_status.dart` through `SkExerciseColors.statusOf` -- so a right answer
  // here is the same green as every other "it worked" in the app.
  static _CardSkin _skinFor(SkOptionState state, SkExerciseColors ex) {
    switch (state) {
      case SkOptionState.plain:
      case SkOptionState.dimmed:
        return _CardSkin(
          fill: ex.surface,
          edge: ex.line,
          ink: ex.ink,
        );

      case SkOptionState.chosen:
      case SkOptionState.right:
        return _CardSkin.of(SkTone.success, ex);

      case SkOptionState.wrong:
        return _CardSkin.of(SkTone.destructive, ex);
    }
  }
}

class _CardSkin {
  final Color fill;
  final Color edge;
  final Color ink;
  final IconData? mark;
  final bool bold;

  const _CardSkin({
    required this.fill,
    required this.edge,
    required this.ink,
    this.mark,
    this.bold = false,
  });

  // A marked card, in one of the app's status tones.
  //
  // **The edge is the tone's text colour, not its 25% hairline.** A hairline
  // is right around a block somebody reads; this is the edge of a control,
  // and the guide holds those to 3:1. The wash and the icon are the status
  // system's own.
  factory _CardSkin.of(SkTone tone, SkExerciseColors ex) {
    final SkStatusStyle style = ex.statusOf(tone);

    return _CardSkin(
      fill: style.fill,
      edge: style.text,
      ink: style.text,
      mark: SkStatusStyle.iconOf(tone),
      bold: true,
    );
  }
}
