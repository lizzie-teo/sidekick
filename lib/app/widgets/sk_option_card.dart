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

  // Chosen on a step that has a right answer, and not checked yet.
  //
  // **It is neutral on purpose, and that is the whole reason it is not
  // [chosen].** On a graded step green already means *you were right*, so a
  // green card the moment a finger lands would mark the answer before the
  // reader has asked for it -- which is the thing the Check button was added
  // to stop. This is the page's own ink: a heavier edge, a bolder label and a
  // filled dot, saying "this one" and claiming nothing about it.
  //
  // **It is not said in colour alone.** The edge doubles in weight, the label
  // goes to 600 and the dot appears, so a reader who cannot see the edge
  // colour still sees which card is picked.
  picked,

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

  // A picked card's edge, against the 1.5 every other card carries. Weight is
  // the non-colour half of the signal.
  static const double _pickedEdge = 2.5;

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
        border: Border.all(color: skin.edge, width: skin.edgeWidth),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: SkText.optionLabel.copyWith(
                color: skin.ink,
                fontWeight: skin.bold ? FontWeight.w600 : null,
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

      // The picked-but-unchecked card. Everything here is the page's own
      // neutral set -- `sk_exercise_colors.dart` -- so nothing about it can
      // be read as a mark.
      case SkOptionState.picked:
        return _CardSkin(
          fill: ex.surface,
          edge: ex.ink,
          ink: ex.ink,
          mark: Icons.radio_button_checked,
          bold: true,
          edgeWidth: _pickedEdge,
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

  // How heavy the edge is. Every card but a picked one carries the hairline.
  final double edgeWidth;

  const _CardSkin({
    required this.fill,
    required this.edge,
    required this.ink,
    this.mark,
    this.bold = false,
    this.edgeWidth = 1.5,
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
