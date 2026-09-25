import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_exercise_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_status.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// A card the reader taps to choose which subject a lesson runs on.
//
// **It is not an answer, and that is the whole reason it is not
// `SkOptionCard`.** An option card is the shape of a guess: it is marked
// right or wrong, its neighbour dims, and it stops taking taps. Nothing here
// can be wrong. The reader is picking which branch of the lesson to walk
// down, and the pick stays changeable for as long as the step is open.
//
// The two are told apart by the things a reader notices without being told:
//
// | | Option card | Topic card |
// | --- | --- | --- |
// | What it holds | A sentence to judge | The name of a subject |
// | The words | 16/400 -- something to read | 18/600 -- something to choose |
// | The shape | Full width, stacked | A tile, sat beside its neighbour |
// | The words sit | Left, where a line of prose starts | Centred in the tile |
// | After the tap | Marked, and dead | Chosen, and still changeable |
//
// **It had an icon for one day and it came out on 25 September 2026, at the
// user's request.** The argument for it was that a picture is a second way
// to tell the cards apart. Two things were wrong with that here. The topics
// are *situations* -- "someone's often late", "I'm left out of decisions" --
// and there is no picture of a situation, so each icon was a nearby object
// standing in for one, which the reader has to decode rather than recognise.
// And a picture at the front of a tile pushes the words into a narrow column
// beside it, on the one step where the words are the whole card. **Do not
// re-add one without a drawing that names the situation itself.**
//
// **There is no tick either, and the title sits in the middle of the tile.**
// The tick came off with the icon on 25 September 2026, at the user's
// request. A mark is what an *answer* wears, and it was the last thing on
// this card still borrowing the graded shape -- `SkStatusStyle.iconOf` draws
// the same circled tick a right answer wears two steps earlier.
//
// **Chosen is still said twice, so the colour rule holds.** The edge goes
// from a hairline to 2.5, which is visible without seeing its colour, and
// `SkPressable(selected:)` announces the card as selected. Weight is the
// same non-colour half of the signal `SkOptionCard`'s picked state runs on.
//
// Losing the mark also means a card is the same height picked and unpicked,
// so nothing in the grid moves under the finger that just tapped it.
//
// **The colours are the fixed exercise set**, like every other card in a
// lesson. `sk_exercise_colors.dart` holds why a lesson does not follow the
// palette.
class SkTopicCard extends StatelessWidget {
  const SkTopicCard({
    super.key,
    required this.title,
    required this.onPressed,
    this.chosen = false,
  });

  final String title;

  // Null disables the card.
  final VoidCallback? onPressed;

  // **Chosen wears the app's own success green, and it is not a mark.** The
  // rule that green means *you were right* holds on a screen that grades
  // answers; there is no grading on this step and nothing for the green to
  // be confused with, so here it means "this is the one you picked" -- the
  // same job it does on the sentence builder's tiles.
  //
  // It is not said in colour alone: the edge thickens to `_chosenEdge`, and
  // the card is announced as selected. There is no tick -- see the note on
  // the class.
  final bool chosen;

  // A chosen card's edge, against the hairline every plain one carries.
  // Weight is the non-colour half of the signal, exactly as it is on
  // `SkOptionCard`'s picked state.
  static const double _chosenEdge = 2.5;

  @override
  Widget build(BuildContext context) {
    final SkExerciseColors ex = context.exercise;
    final SkStatusStyle tone = ex.statusOf(SkTone.success);

    final Color fill = chosen ? tone.fill : ex.surface;
    final Color edge = chosen ? tone.text : ex.line;
    final Color ink = chosen ? tone.text : ex.ink;

    final Widget card = Container(
      constraints: const BoxConstraints(minHeight: SkLayout.tapTarget),
      padding: const EdgeInsets.symmetric(
        horizontal: SkLayout.lg,
        vertical: SkLayout.lg,
      ),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(SkLayout.xl),
        border: Border.all(
          color: edge,
          width: chosen ? _chosenEdge : 1.5,
        ),
      ),
      // **Centred both ways.** The tile is stretched to its row's height by
      // `_Situation`, so a one-line title beside a two-line one would
      // otherwise sit up against the top of a taller box.
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: SkText.cardTitle.copyWith(color: ink, height: 1.3),
        ),
      ),
    );

    if (onPressed == null) return card;

    return SkPressable(
      onPressed: onPressed,
      wash: ex.ink,
      borderRadius: BorderRadius.circular(SkLayout.xl),
      selected: chosen,
      child: card,
    );
  }
}
