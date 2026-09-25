import 'package:flutter/widgets.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';

// The scene: the one place the theme goes full-bleed. It has three shapes.
// On Breathing it takes the whole screen and the corners go. On Home it is
// the **ground** -- the block at the foot of the page -- since 24 September
// 2026. Before that it was the header, with the corners at the bottom and
// the sidekick standing on it; that shape is kept because the design system
// demo still shows it and a later screen may want it.
//
// **The ground's own top is square, and the curve belongs to the page above
// it.** Changed 25 September 2026, at the user's request. The gradient used
// to carry two rounded corners at its top, so the green was the shape and
// the off-white was the hole it was cut out of. It is the other way round
// now: `groundCap` paints `canvas` over the gradient's first 32 points with
// its **bottom** corners rounded, so the page reads as an off-white card
// resting on the ground rather than as a green panel sliding under it. The
// gradient itself is untouched -- it still starts where it always did, and
// only its two top corners are ever seen, in the notches the curve leaves.
//
// **The sidekick came off the gradient on 24 September 2026.** She spans
// almost the whole luminance range -- her lightest part measures 0.97 and
// her darkest 0.02 -- so a mid-tone saturated sky matches one end of her
// whatever it is set to. On the Harvest moon light sky her light half
// measured 1.72:1. It is the same fact that killed `sceneGlow` (see
// `SkColors`), arrived at from the other side: nothing **behind** her fixes
// her, so she was moved to the page's own quiet ground and the gradient took
// the two soft buttons instead. A filled button carries its own ground
// inside it, so the sky cannot wash it out.
//
// **The words on it sit on a scrim, since 24 September 2026, and most
// palettes get none of it.** Nine of the twelve scene inks measured under
// 4.5:1 against at least one of their three gradient stops, and five of those
// nine could not reach 4.5:1 at any lightness -- pure white on the Harvest
// moon dark sky tops out at 3.08, pure black on the Night forest light sky at
// 2.72. The stops are mid-tone and saturated, which is exactly what makes
// them worth looking at and exactly what leaves no headroom at either end.
//
// So the ground had to move. The alternative was repainting five gradients a
// designer chose, and this is the smaller change: `SkContrast.sceneScrim`
// returns the least opacity that makes the ink legible on the worst of the
// three stops, or null when the palette already clears it. Moss, Harvest moon
// light and Coral diorama light return null and are pixel-for-pixel what they
// were.
class SkScenePanel extends StatelessWidget {
  final Widget child;

  // The whole screen: no corners, and the caller owns the status bar.
  final bool fullScreen;

  // The foot of the page: a square top under the page's own curve, and no
  // status bar to pad for, because the top of the screen belongs to somebody
  // else now.
  final bool ground;

  // How far the page's off-white reaches down into the gradient. It is the
  // corner radius itself, so the curve finishes exactly where the cap ends
  // and the ground below it is a straight edge of green.
  static const double groundCap = 32;

  const SkScenePanel({
    super.key,
    required this.child,
    this.fullScreen = false,
    this.ground = false,
  }) : assert(
          !(fullScreen && ground),
          'A panel is either the whole screen or the foot of it, not both.',
        );

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final double statusBar = MediaQuery.paddingOf(context).top;
    final Color? scrim = SkContrast.sceneScrim(sk.onScene, sk.scene);

    final BorderRadius? corners = fullScreen || ground
        ? null
        : const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          );

    // The ground's first `groundCap` points are under the page's off-white,
    // so its own top padding starts below them. The gap the reader sees
    // between the curve and the first control is the same 28 it always was.
    final Widget padded = Padding(
      padding: ground
          ? const EdgeInsets.fromLTRB(24, groundCap + 28, 24, 28)
          : EdgeInsets.fromLTRB(24, statusBar + 16, 24, 28),
      child: child,
    );

    final Widget panel = Container(
      decoration:
          BoxDecoration(gradient: sk.sceneGradient, borderRadius: corners),
      // Clipped only when there is a wash to clip. A panel that needs none
      // keeps the cheaper paint it always had.
      clipBehavior: scrim == null ? Clip.none : Clip.antiAlias,
      child: scrim == null
          ? padded
          : Stack(
              children: <Widget>[
                // **Under the whole panel, not in a plate behind the words.**
                // A plate has an edge, and an edge across a sky reads as a
                // label stuck on it. The wash deepens the scene instead, which
                // is what a backdrop for reading is meant to be.
                Positioned.fill(child: ColoredBox(color: scrim)),
                padded,
              ],
            ),
    );

    if (!ground) return panel;

    // `passthrough`, not the default loose fit: the ground is handed a
    // minimum height by the sliver above it, and a loose Stack would drop
    // that on the floor and leave the gradient short of the bottom of the
    // screen.
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        panel,
        // The page's own ground, carried down over the gradient so the curve
        // is the off-white's and not the green's. It is the same colour as
        // the page above it, so the two read as one block with a rounded
        // foot; the green shows only in the two notches the curve leaves.
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: groundCap,
          child: _GroundCap(),
        ),
      ],
    );
  }
}

class _GroundCap extends StatelessWidget {
  const _GroundCap();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.sk.canvas,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(SkScenePanel.groundCap),
          bottomRight: Radius.circular(SkScenePanel.groundCap),
        ),
      ),
    );
  }
}
