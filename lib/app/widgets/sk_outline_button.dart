import 'package:flutter/widgets.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_disabled.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// The quieter sibling of SkPrimaryButton: same pill, no fill, no shadow.
// "No thanks", "End", "Text a crisis line".
class SkOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  // Ink is right on the canvas and invisible on the scene gradient, so a
  // screen sitting on the green hands in its own foreground colour -- the
  // same escape hatch SkTextButton has, for the same reason.
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
