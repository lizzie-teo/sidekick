import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/features/panic/models/sensation.dart';

// One body sensation, as a slim outline pill.
//
// Not `SkOutlineButton`, which is a 56-point full-width pill for a primary
// "No thanks". These sit two to a row inside the body sheet, under a heading,
// and they have to read as a set of equal answers rather than as four primary
// actions stacked up.
//
// It still clears the 48-point tap target at every text size, and the label
// grows with the reader's own font rather than being clamped to fit.
//
// **It lived inside `feeling_picker_view.dart` until 24 September 2026**, when
// the four tiles moved off the page and into the sheet behind "Can't cope".
// The sheet is a second caller, so the pill is its own file rather than a
// private class one screen owns and another reaches into.
class SensationPill extends StatelessWidget {
  final Sensation sensation;
  final VoidCallback onPressed;

  const SensationPill({
    super.key,
    required this.sensation,
    required this.onPressed,
  });

  static final BorderRadius _radius = BorderRadius.circular(999);

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    // A small lift, on the parent so the press wash lands on the fill alone.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: _radius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: sk.ink.withValues(alpha: 0.10),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SkPressable(
        onPressed: onPressed,
        wash: sk.ink,
        borderRadius: _radius,
        child: Container(
          constraints: const BoxConstraints(minHeight: SkLayout.tapTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: SkLayout.md,
            vertical: SkLayout.md,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: sk.surface,
            borderRadius: _radius,
            border: Border.all(color: sk.border, width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              // Decoration, so it is kept out of the screen reader's way --
              // the label beside it already says the same thing, and an icon
              // with a name of its own would have it announced twice.
              //
              // It grows with the reader's own text size rather than staying
              // at 20 beside a 34-point label.
              ExcludeSemantics(
                child: Icon(
                  sensation.icon,
                  size: MediaQuery.textScalerOf(context).scale(20),
                  color: sk.ink,
                ),
              ),
              const SizedBox(width: SkLayout.sm),
              Flexible(
                child: Text(
                  sensation.label,
                  textAlign: TextAlign.center,
                  style: SkText.buttonSmall.copyWith(color: sk.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
