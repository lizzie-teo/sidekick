import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_disabled.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// The glass pill: the secondary action on the scene gradient. Home's Meditate
// and Scribble, from 24 September 2026, at the user's request.
//
// **It began as `SkCircleIconButton` with words in it** -- the breathing
// screen's close and mute, which is a translucent chip at 12% with its
// content in the scene's own ink. Two things were wrong with it here, and
// both were measured rather than argued:
//
// | | |
// | --- | --- |
// | That chip washes with the **ink**, which costs contrast | Fine at the 3:1 an icon owes; a 17/600 word owes 4.5:1 and lands at 3.62:1 |
// | A tint alone barely separates from the sky | 1.05:1 to 1.08:1 against the gradient, at any strength from 18% to 32% |
//
// The second is the one the user reported, as washed out, and the first is
// why the obvious repair -- more tint -- does nothing: a translucent layer
// over a gradient stays near the gradient by definition. The pale palettes
// are the worst case, because a light tint over an already-light sky changes
// the brightness by about six percent.
//
// **So the glass is stated by its rim and its shadow, not by its fill.** That
// is what iOS glass actually is, and the reason is the same one: it has to
// sit on top of whatever the app happens to be showing, so it cannot rely on
// being a different brightness from it. Four layers, each with a job:
//
// | Layer | Job | Derived from |
// | --- | --- | --- |
// | The blur | Separates the pill from anything textured behind it | -- |
// | The fill | Gives the pill a body, and buys the label contrast | The backdrop, at 28% |
// | The rim | States the edge where the fill cannot | The backdrop, at 60% |
// | The shadow | Lifts it off, and is the layer that carries the pale palettes | The ink, at 20% |
//
// **The shadow and the rim point opposite ways, and both are read off the
// ink.** In a light palette the fill and rim are white and the shadow is
// dark, so the pill is a bright chip with a soft drop under it. In a dark
// palette they invert: the fill and rim darken, so the pill is a well, and
// the "shadow" becomes a pale halo -- which is rim light, and is what glass
// does on a dark ground. Nothing here is chosen per palette.
//
// **The blur does almost nothing today, and that is not a reason to drop
// it.** A gradient blurred is the same gradient. It will do its job the day
// the scene becomes the illustrated day and night art, which is the whole
// reason the sidekick moved off the gradient in the first place -- and adding
// it then would mean rebuilding the pill after it had been signed off.
//
// **The label rides on the fill, not on the sky, and that is the pixel the
// gate measures.** The scene panel's scrim solves `onScene` to *exactly*
// 4.5:1 against the worst of the three stops, so there is no headroom: a
// chip that washes toward the ink breaks it, and no chip that washes toward
// the ink can repair it, because moving a ground toward its ink only ever
// costs contrast. Washing toward the backdrop instead puts the worst of the
// twelve schemes at 6.01:1.
class SkGlassButton extends StatelessWidget {
  // The four strengths. Named so `test/contrast_test.dart` measures what is
  // painted, and so the recipe is readable as one thing.
  static const double fillAlpha = 0.28;
  static const double rimAlpha = 0.60;
  static const double shadowAlpha = 0.20;
  static const double blurSigma = 16;

  final String label;
  final VoidCallback? onPressed;

  // Hugs its label instead of filling the width. `SkPrimaryButton.compact`,
  // and the same rule: compact is a width, never a smaller label.
  final bool compact;

  // The ink of the ground this sits on. `sk.onScene` on the scene gradient.
  // Defaults to the canvas ink, the same escape hatch `SkOutlineButton` and
  // `SkTextButton` take, for the same reason.
  final Color? color;

  const SkGlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.compact = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color ink = color ?? context.sk.ink;
    final Color backdrop = SkContrast.backdropFor(ink);
    final BorderRadius corners = BorderRadius.circular(999);

    final Widget pill = DecoratedBox(
      decoration: BoxDecoration(
        color: backdrop.withValues(alpha: fillAlpha),
        borderRadius: corners,
        border: Border.all(color: backdrop.withValues(alpha: rimAlpha)),
      ),
      child: Container(
        constraints: BoxConstraints(minHeight: SkLayout.buttonHeight),
        width: compact ? null : double.infinity,
        padding: EdgeInsets.symmetric(horizontal: compact ? 26 : 24),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: SkText.button.copyWith(color: ink),
        ),
      ),
    );

    return SkDisabled(
      isDisabled: onPressed == null,
      // The shadow is painted by the parent, not by the pill, so the press
      // wash lands on the glass alone and the button keeps its lift while
      // held -- the same arrangement `SkPrimaryButton` uses.
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: corners,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: ink.withValues(alpha: shadowAlpha),
              offset: const Offset(0, 3),
              blurRadius: 10,
            ),
          ],
        ),
        child: SkPressable(
          onPressed: onPressed,
          wash: ink,
          borderRadius: corners,
          child: ClipRRect(
            borderRadius: corners,
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: pill,
            ),
          ),
        ),
      ),
    );
  }
}
