import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// The small label that says what family a screen belongs to: "Things you're
// allowed" over an explanation sheet, "Assertiveness training" over a lesson.
//
// It is a pill rather than a bare line of small text, and that is an
// accessibility fix rather than decoration. The category was `muted` on
// `canvas`, which measures 2.8:1 to 3.2:1 in every light palette -- under the
// 4.5:1 WCAG 1.4.3 asks of text this size. Ink on its own tinted pill clears
// 9:1 in all twelve, and the pill is what keeps it from shouting at that
// contrast.
//
// **It orients, it never scores.** A category says what kind of thing this
// is. It may not carry a number, a level or a tick, which is the same rule
// that keeps a counter off the breathing screen.
//
// The icon is decorative and is hidden from screen readers: it repeats the
// label beside it, and a reader that announced both would say the same thing
// twice.
class SkCategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;

  // Ink is right on the canvas and invisible on the scene gradient, so a
  // screen sitting on the green hands in its own foreground colour -- the
  // same escape hatch SkOutlineButton and SkTextButton have.
  final Color? color;

  // Defaults to the palette's muted surface. A screen on the scene gradient
  // has no such slot, so it hands in a wash of its own foreground instead.
  final Color? background;

  const SkCategoryChip({
    super.key,
    required this.label,
    required this.icon,
    this.color,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final Color bg = background ?? sk.surfaceMuted;

    // A caption is a darker shade of its own ground, worked out from the
    // pill's fill rather than taken from a slot. `SkContrast.captionOn` holds
    // the reasoning; the short version is that it keeps the hue and clears
    // 4.5:1 on any fill, including one invented after this widget was
    // written.
    final Color fg = color ?? SkContrast.captionOn(bg);

    return Semantics(
      container: true,
      label: label,
      excludeSemantics: true,
      child: Container(
        // 32 is the smallest a pill may be and still read as one. It is not a
        // tap target: nothing here is tappable, so the 48pt rule does not
        // apply.
        constraints: const BoxConstraints(minHeight: 32),
        padding: const EdgeInsets.symmetric(
          horizontal: SkLayout.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            // Wrapped rather than clipped: at 200% text the label is longer
            // than the phone, and a category that ends in an ellipsis names
            // nothing.
            Flexible(
              child: Text(
                label,
                style: SkText.chipLabel.copyWith(color: fg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
