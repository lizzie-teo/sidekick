import 'package:flutter/widgets.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_disabled.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// The filled pill: Next, Save, Continue. Full width by default; compact hugs
// its label for the scene CTA.
class SkPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool compact;

  const SkPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    final Widget pill = Container(
      constraints: BoxConstraints(minHeight: compact ? 50 : 56),
      width: compact ? null : double.infinity,
      padding: EdgeInsets.symmetric(horizontal: compact ? 26 : 24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: sk.action,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: SkText.button.copyWith(
          color: sk.onAction,
          fontSize: compact ? 17 : 19,
        ),
      ),
    );

    // The shadow is painted by the parent, not by the pill, so the press wash
    // lands on the fill alone and the button keeps its lift while held.
    return SkDisabled(
      isDisabled: onPressed == null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: sk.ink.withValues(alpha: 0.28),
              offset: const Offset(0, 6),
              blurRadius: 16,
            ),
          ],
        ),
        child: SkPressable(
          onPressed: onPressed,
          wash: sk.onAction,
          borderRadius: BorderRadius.circular(999),
          child: pill,
        ),
      ),
    );
  }
}
