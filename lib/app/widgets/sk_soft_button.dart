import 'package:flutter/widgets.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_disabled.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// A paler cut of the action colour as fill, labelled in the action colour.
// Never the action colour itself. No shadow, no border.
//
// **It is the canvas's secondary button, and only the canvas's.** A quiet
// fill needs a plain ground to be quiet *against*. On the scene gradient this
// treatment measured 1.01:1 to 1.50:1 and was reported from the simulator as
// invisible, so Home's two secondaries moved to `SkOutlineButton` on
// 24 September 2026. That widget's comment holds the three treatments that
// were tried and what each measured.
//
// **The label goes through `SkContrast.readable`, since 24 September 2026.**
// It is 17/600, which WCAG counts as small text -- large text starts at 14pt
// at weight 700 -- so the pair owes 4.5:1. Measured raw it ran 3.43:1 in
// Coral diorama light, 3.55:1 in Harvest moon light and 3.63:1 in Night
// forest light. Nothing was checking it: the contrast gate held `ink` and a
// caption against `actionSoft`, and never the action colour on its own tint.
// `readable` nudges the lightness the smallest step that reaches the ratio
// and keeps the hue, so the nine schemes that already cleared it are
// untouched.
class SkSoftButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const SkSoftButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final Color ink = SkContrast.readable(sk.action, sk.actionSoft);

    return SkDisabled(
      isDisabled: onPressed == null,
      child: SkPressable(
        onPressed: onPressed,
        wash: ink,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: SkLayout.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: sk.actionSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: SkText.button.copyWith(color: ink),
          ),
        ),
      ),
    );
  }
}
