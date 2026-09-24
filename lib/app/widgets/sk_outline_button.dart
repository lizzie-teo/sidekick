import 'package:flutter/widgets.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_disabled.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// The quieter sibling of SkPrimaryButton: same pill, no fill, no shadow.
// "No thanks", "End", "Text a crisis line", and since 24 September 2026
// Home's Meditate and Scribble.
//
// **It is the primary's shape, one weight down, and that is the point.**
// Same 999 radius, same 56 height, same `SkText.button` label -- so the two
// read as the same kind of control, and only the treatment says which one the
// screen is built around. The weight comes off by dropping the fill, never by
// fading the label: an outline states its bounds with a line and spends no
// area doing it, so it cannot out-weigh a filled pill however strong the line
// is, while a fill competes on area, which is the one axis the primary has to
// win. Fading the label buys the same drop by spending contrast, which is the
// one thing this app does not spend.
//
// **Home reached for it after two filled treatments failed on the gradient.**
// The 24 September 2026 swap put its two secondaries on the scene. A pale
// `actionSoft` tint measured 1.01:1 against the Moss light sky -- invisible,
// and reported that way from the simulator -- because a quiet fill needs a
// plain ground to be quiet *against*, and three saturated stops are not one.
// A solid `onScene` fill measured 4.51:1 and looked it: two slabs
// out-shouting a page they are secondary to. A line carries the shape at 1.5
// points of area, which is what the sky leaves room for.
class SkOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  // Ink is right on the canvas and invisible on the scene gradient, so a
  // screen sitting on the green hands in its own foreground colour -- the
  // same escape hatch SkTextButton has, for the same reason.
  //
  // **`onScene` is the colour to hand in, and it rides free.** It is the slot
  // the scene panel's own words are set in, so `SkContrast.sceneScrim` has
  // already solved it to 4.5:1 against the worst of the three gradient stops
  // in every palette -- which covers the label outright and clears the 3:1
  // WCAG 1.4.11 asks of the edge with room to spare. Nothing here picks a
  // colour, so a palette added next year needs no edit.
  final Color? color;

  const SkOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = color ?? context.sk.ink;

    return SkDisabled(
      isDisabled: onPressed == null,
      child: SkPressable(
        onPressed: onPressed,
        wash: fg,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: fg, width: 1.5),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: SkText.button.copyWith(color: fg),
          ),
        ),
      ),
    );
  }
}
