import 'package:flutter/widgets.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_rive_face.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/features/panic/models/feeling.dart';

// One face on the picker.
//
// All four buttons share one size and one row layout; the panic one stands
// out by its ring alone, so a change to the fill or the press behaviour
// lands on all four.
class FeelingButton extends StatelessWidget {
  final Feeling feeling;

  // Whose face is drawn. Handed in rather than read from ThemeService here,
  // so the button stays a picture of what it is given and one listener on the
  // screen above swaps all four at once.
  final SidekickCharacter character;

  final bool isSelected;
  final VoidCallback? onPressed;

  const FeelingButton({
    super.key,
    required this.feeling,
    required this.character,
    required this.isSelected,
    required this.onPressed,
  });

  static final BorderRadius _radius = BorderRadius.circular(20);

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
      size: 110,
    );

    final Widget label = Text(
      feeling.label,
      style: SkText.cardTitle.copyWith(color: sk.ink, fontSize: 20),
    );

    return SkPressable(
      onPressed: onPressed,
      wash: sk.ink,
      borderRadius: _radius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: _radius,
          border: Border.all(
            color: ring,
            width: feeling.isPanic ? 3 : 1.5,
          ),
        ),
        child: Row(
          children: [
            face,
            const SizedBox(width: 14),
            Expanded(child: label),
          ],
        ),
      ),
    );
  }
}
