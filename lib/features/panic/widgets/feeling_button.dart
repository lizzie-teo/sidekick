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
// All four cards share one size and one shape. The panic one stands out by its
// ring alone, so a change to the fill or the press behaviour lands on all four.
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
  static const EdgeInsets _padding = EdgeInsets.all(SkLayout.md);

  // The gap between the face and the words.
  static const double _faceToLabel = SkLayout.sm;

  // How much wider than tall the face box is.
  //
  // The tightened artboards are 360x300 for the girl, 280x240 for the cat and
  // 260x260 for the rabbit -- 1.20, 1.17 and 1.00. A box at 1.15 is within a
  // couple of points of the two wide faces top and bottom, and takes what is
  // left out of the rabbit's sides instead. See SkRiveFace.aspectRatio for why
  // that trade was made in this direction.
  static const double faceAspectRatio = 1.15;

  // The widest the face is ever drawn. Without it a tablet column would hand
  // one head half the screen.
  static const double maxFaceSize = 180;

  // What [faceSize] should be for a card of this width.
  static double faceSizeFor(double cardWidth) {
    final double inner = cardWidth - _padding.horizontal;
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

    final Widget face = SkRiveFace(
      artboard: feeling.artboardFor(character),
      fallbackArtboard: feeling.artboardFor(SidekickCharacter.girl),
      size: faceSize,
      aspectRatio: faceAspectRatio,
    );

    final Widget label = Text(
      feeling.label,
      textAlign: TextAlign.center,
      style: SkText.cardTitle.copyWith(color: sk.ink),
    );

    return SkPressable(
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
          border: Border.all(
            color: ring,
            width: feeling.isPanic ? 3 : 1.5,
          ),
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
    );
  }
}
