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

  const SkOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return SkDisabled(
      isDisabled: onPressed == null,
      child: SkPressable(
        onPressed: onPressed,
        wash: sk.ink,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: sk.ink, width: 1.5),
          ),
          child: Text(label, style: SkText.button.copyWith(color: sk.ink)),
        ),
      ),
    );
  }
}
