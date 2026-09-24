import 'package:flutter/cupertino.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_disabled.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';

// The quiet text-only action: "Skip", "Just looking", "Done for today".
// Muted on purpose -- it is always the road away from the screen's point.
//
// The one control that keeps the fade rather than the SkPressable wash. It
// has no fill, so there is nothing for a state layer to sit on, and Apple's
// rule for a plain text button is exactly this: fade the label to about half.
class SkTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  // Muted reads as quiet on the canvas but nearly vanishes on the scene
  // gradient, so a screen that sits on the green hands in its own colour.
  final Color? color;

  const SkTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return SkDisabled(
      isDisabled: onPressed == null,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        pressedOpacity: 0.5,
        onPressed: onPressed,
        child: Text(
          label,
          // **The default was `muted`, and this is the widest that mistake
          // reached.** Every ghost button that does not pass a colour -- and
          // most do not -- had its label under 3.3:1 on the canvas. They are
          // the quietest controls in the app by design, and "quiet" was
          // costing them legibility rather than weight.
          //
          // `captionOn(canvas)` is the ground taken down until it clears
          // 4.5:1, so the button still sits back from a filled pill without
          // being the thing on the screen nobody can read.
          style: SkText.buttonGhost.copyWith(
            color: color ?? SkContrast.captionOn(sk.canvas),
          ),
        ),
      ),
    );
  }
}
