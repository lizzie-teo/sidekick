import 'package:flutter/cupertino.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_disabled.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';

// The quiet text-only action: "Skip", "Just looking", "See everything
// you've noticed". Quiet by shape, not by colour: it has no fill, so it sits
// back from a filled pill on its own.
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
          // A long label ("I already have a code for someone@…") wraps, and
          // a button's lines sit in its middle, not against its left edge.
          textAlign: TextAlign.center,
          // **The default was `muted`, and this is the widest that mistake
          // reached.** Every ghost button that does not pass a colour -- and
          // most do not -- had its label under 3.3:1 on the canvas. They are
          // the quietest controls in the app by design, and "quiet" was
          // costing them legibility rather than weight.
          //
          // It was `captionOn(canvas)` next, a brown taken from the page. That
          // made every ghost button read as "the way out", including ones
          // that are a real next step beside the pill. Since 26 September
          // 2026, at the user's request, it is the action colour: the same
          // green as the pill, so the two read as one family. `readable`
          // nudges it only where a palette's action is too pale for text.
          style: SkText.button.copyWith(
            color: color ?? SkContrast.readable(sk.action, sk.canvas),
          ),
        ),
      ),
    );
  }
}
