import 'package:flutter/cupertino.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_disabled.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// The quiet text-only action: "Skip", "Just looking", "Done for today".
// Muted on purpose -- it is always the road away from the screen's point.
//
// The one control that keeps the fade rather than the SkPressable wash. It
// has no fill, so there is nothing for a state layer to sit on, and Apple's
// rule for a plain text button is exactly this: fade the label to about half.
class SkTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const SkTextButton({super.key, required this.label, required this.onPressed});

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
          style: SkText.rowLabel.copyWith(
            color: sk.muted,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
