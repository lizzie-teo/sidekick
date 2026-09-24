import 'package:flutter/widgets.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_rive_face.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/features/panic/models/feeling.dart';

// One face on the picker.
//
// A tall card: the face on top, the words underneath. It was a full-width row
// with the face beside the words until 23 September 2026, and four of those
// filled a phone and still scrolled -- the screen asked a question and then
// hid half its answers below the fold.
//
// All four cards share one size, one shape and one ring weight. The panic one
// stands out by the ring's colour alone, so a change to the fill, the shadow or
// the press behaviour lands on all four.
class FeelingButton extends StatelessWidget {
  final Feeling feeling;

  // Whose face is drawn. Handed in rather than read from ThemeService here,
  // so the button stays a picture of what it is given and one listener on the
  // screen above swaps all four at once.
  final SidekickCharacter character;

  // How wide the face is drawn, worked out by the screen above from the
  // column width. Handed in rather than measured here: the cards in a row are
  // held to one height, and a LayoutBuilder cannot report an intrinsic height.
  final double faceSize;

  final bool isSelected;
  final VoidCallback? onPressed;

  const FeelingButton({
    super.key,
    required this.feeling,
    required this.character,
    required this.faceSize,
    required this.isSelected,
    required this.onPressed,
  });

  static final BorderRadius _radius = BorderRadius.circular(20);

  // Even on every side, and the gap under the face is smaller than the gap
  // around the card's own edge, so the face and its words read as one thing.
  //
  // It was 0 at the top and 20 at the bottom until 23 September 2026, paying
  // for the empty margin the artboards used to carry. They were tightened
  // around their drawings that day, so the card owes them nothing and the
  // padding is the card's own again.
  //
  // It went from `md` to `lg` on 24 September 2026: the tightened artboards
  // put the heads hard against the card's edge, and a drawing touching its
  // own frame reads as cropped rather than as placed.
  static const EdgeInsets _padding = EdgeInsets.all(SkLayout.lg);

  // Air beside the head, inside the card's own padding.
  //
  // The head used to take the full inner width, so the only space around it
  // was the card padding. A drawing wants more room than a line of text does,
  // and the label below is still full width, so this is the face's alone.
  static const double _faceInset = SkLayout.sm;

  // The gap between the face and the words.
  static const double _faceToLabel = SkLayout.sm;

  // The widest the face is ever drawn. Without it a tablet column would hand
  // one head half the screen.
  static const double maxFaceSize = 180;

  // What [faceSize] should be for a card of this width.
  static double faceSizeFor(double cardWidth) {
    final double inner = cardWidth - _padding.horizontal - _faceInset * 2;
    return inner < maxFaceSize ? inner : maxFaceSize;
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    // The picked face is shown by the fill rather than the border, so the
    // panic ring can stay panic-coloured while it is the one picked. Panic is
    // the same colour in every theme and mode, which is what makes it findable
    // without reading the words next to it.
    final Color fill = isSelected ? sk.actionSoft : sk.surface;
    final Color ring = feeling.isPanic ? sk.panic : sk.border;

    // **Every card wears the same weight of ring, panic included.** The panic
    // one was 3 points against the others' 1.5 until 24 September 2026, and a
    // heavier ring is the shape a picked control takes everywhere else in this
    // app -- so the screen opened looking as though it had already answered
    // its own question, and the reader's first tap was a correction rather
    // than a choice.
    //
    // Panic stays findable by its colour, which is the half of the treatment
    // that was doing the work: it is the one hue that does not move between
    // the six palettes or the two modes. Nothing else on the picker is that
    // colour.
    const double ringWidth = 1.5;

    final Widget face = SkRiveFace(
      artboard: feeling.artboardFor(character),
      fallbackArtboard: feeling.artboardFor(SidekickCharacter.girl),
      // The box's shape is SkRiveFace's own default now. It is a fact about
      // the artboards rather than about this card, and it lived here while
      // the picker was the only screen that had noticed.
      size: faceSize,
    );

    final Widget label = Text(
      feeling.label,
      textAlign: TextAlign.center,
      style: SkText.cardTitle.copyWith(color: sk.ink),
    );

    // A soft lift, so the card reads as a thing to press rather than a thing
    // to read. It is the recipe the Home CTA runs on -- `ink` at a low alpha,
    // dropped straight down -- at a lower alpha, because this is a 200-point
    // card rather than a pill and a shadow's weight is its area as much as
    // its colour.
    //
    // Painted by the parent rather than by the card, so the press wash lands
    // on the fill alone and the card keeps its lift while it is held.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: _radius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: sk.ink.withValues(alpha: 0.16),
            offset: const Offset(0, 4),
            blurRadius: 14,
          ),
        ],
      ),
      child: SkPressable(
        onPressed: onPressed,
        wash: sk.ink,
        borderRadius: _radius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: _padding,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: _radius,
            border: Border.all(color: ring, width: ringWidth),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              face,
              const SizedBox(height: _faceToLabel),
              label,
            ],
          ),
        ),
      ),
    );
  }
}
