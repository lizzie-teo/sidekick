import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_disabled.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// The filled pill: Next, Save, Continue. Full width by default; compact hugs
// its label for the scene CTA. Compact is a width, not a size -- the label is
// `SkText.button` either way.
//
// **There is one fill, and the panic button shares it.** A `panic` tone was
// added here for an hour on 24 September 2026 and removed the same day: the
// decision that followed was that `SkColors.panic` *is* `action`, so a tone
// switch would have been two names for one colour.
class SkPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool compact;

  // An action is running: a spinner stands where the label was. The pill
  // keeps its size and its colour -- it is busy, not disabled -- and the
  // label is still announced. Blocking a second tap is not this widget's
  // job; `AsyncButton` owns that, and passes this in.
  final bool busy;

  const SkPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.compact = false,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    final Widget pill = Container(
      constraints: BoxConstraints(minHeight: SkLayout.buttonHeight),
      width: compact ? null : double.infinity,
      padding: EdgeInsets.symmetric(horizontal: compact ? 26 : 24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: sk.action,
        borderRadius: BorderRadius.circular(999),
      ),
      // The label stays laid out under the spinner, only hidden, so the pill
      // is the same width and height busy or not and nothing around it moves.
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: busy ? 0 : 1,
            child: Text(
              label,
              // Compact shrinks the pill, never the label. The two used to
              // move together, which dropped the scene CTA to 17 -- under the
              // soft buttons below it and under the invite card below those,
              // so the one action the screen is built around was the smallest
              // thing on it.
              style: SkText.button.copyWith(color: sk.onAction),
            ),
          ),
          if (busy)
            ExcludeSemantics(
              child: SizedBox.square(
                dimension: SkLayout.xl,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: sk.onAction,
                ),
              ),
            ),
        ],
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
