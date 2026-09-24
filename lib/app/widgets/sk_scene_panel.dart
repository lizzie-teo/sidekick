import 'package:flutter/widgets.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';

// The scene: the one place the theme goes full-bleed. It has three shapes.
// On Breathing it takes the whole screen and the corners go. On Home it is
// the **ground** -- the block at the foot of the page, corners at the top --
// since 24 September 2026. Before that it was the header, with the corners
// at the bottom and the sidekick standing on it; that shape is kept because
// the design system demo still shows it and a later screen may want it.
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

  // The foot of the page: corners at the top, and no status bar to pad for,
  // because the top of the screen belongs to somebody else now.
  final bool ground;

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

    final BorderRadius? corners = fullScreen
        ? null
        : ground
            ? const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              )
            : const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              );

    final Widget padded = Padding(
      padding: ground
          ? const EdgeInsets.fromLTRB(24, 28, 24, 28)
          : EdgeInsets.fromLTRB(24, statusBar + 16, 24, 28),
      child: child,
    );

    return Container(
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
  }
}
