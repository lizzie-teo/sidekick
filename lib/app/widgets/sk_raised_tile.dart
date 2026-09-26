import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';

// A door the reader taps, on a soft raised tile.
//
// It lived inside `dashboard_view.dart` as Home's `_Tile` until 26 September
// 2026, when the body sheet behind "Can't cope" took the same look at the
// user's request. Two callers, so the face is shared and cannot drift.
//
// **Raised, not frosted, and that was a choice.** Frosted glass was the
// first idea. Glass is only glass when something shows through it, and
// Home's tiles sit on the flat canvas panel -- a blur of a flat colour is the
// same flat colour, so glass there would read as a plain white card.
//
// So the depth is said the way a pebble says it:
//
// | Layer | Job | Derived from |
// | --- | --- | --- |
// | The fill | A top-lit face, lighter at the top | `surface` into `canvas` |
// | The lip | A lit top edge, so the tile has a rim | White, or the ink faintly in the dark |
// | Two shadows | A tight one under the edge, a wide soft one under the body | The ink |
//
// Nothing is picked per palette. The shadow is read off the ink, so in a
// dark palette it turns into a soft pale halo, the way `SkGlassButton` does.
//
// **Radius 20, not a full pill.** A pill is the shape of the primary action
// ("Begin"); a rounded tile is the shape of one choice among several.
class SkRaisedTile extends StatelessWidget {
  const SkRaisedTile({
    super.key,
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
    this.minHeight = SkLayout.tapTarget,
    this.padding = const EdgeInsets.all(SkLayout.lg),
  });

  final Widget child;

  // Null for a door that is not open yet. `SkPressable` then takes no taps
  // and tells a screen reader the tile is disabled.
  final VoidCallback? onPressed;

  // What a screen reader says. The child's own words should be wrapped in
  // `ExcludeSemantics`, or the label is announced twice.
  final String semanticLabel;

  final double minHeight;
  final EdgeInsetsGeometry padding;

  static const double radius = SkLayout.xl;

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final BorderRadius corners = BorderRadius.circular(radius);
    // The lip is always light, because light comes from above in both
    // modes: white on a pale tile, a faint breath of the ink on a dark one.
    final bool darkInk = sk.ink.computeLuminance() < 0.5;
    final Color lip = darkInk
        ? SkContrast.backdropFor(sk.ink).withValues(alpha: 0.8)
        : sk.ink.withValues(alpha: 0.14);
    final Color faceBottom = Color.lerp(sk.surface, sk.canvas, 0.6)!;

    // The shadow is painted outside the pressable, so the press wash lands
    // on the face alone and the tile keeps its lift while held -- the same
    // arrangement `SkGlassButton` uses.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: corners,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: sk.ink.withValues(alpha: 0.10),
            offset: const Offset(0, 2),
            blurRadius: 3,
          ),
          BoxShadow(
            color: sk.ink.withValues(alpha: 0.10),
            offset: const Offset(0, 10),
            blurRadius: 24,
            spreadRadius: -4,
          ),
        ],
      ),
      child: SkPressable(
        onPressed: onPressed,
        wash: sk.ink,
        borderRadius: corners,
        semanticLabel: semanticLabel,
        child: Container(
          constraints: BoxConstraints(minHeight: minHeight),
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: corners,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[sk.surface, faceBottom],
            ),
            border: Border.all(color: sk.border.withValues(alpha: 0.7)),
          ),
          // The lit lip along the top. A rounded border cannot take a
          // different colour per side, so the light is a sheen laid over
          // the face and faded out before the icon.
          foregroundDecoration: BoxDecoration(
            borderRadius: corners,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[lip, lip.withValues(alpha: 0)],
              stops: const <double>[0, 0.08],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// The round soft well an icon sits in on a raised tile. Decoration: the
// tile's label already says the same thing.
class SkIconBadge extends StatelessWidget {
  const SkIconBadge(this.icon, {super.key});

  final IconData icon;

  static const double size = 44;

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    // The icon owes 3:1 against its well, and `action` on `actionSoft` is
    // not promised that in every palette.
    final Color iconColour = SkContrast.readable(
      sk.action,
      sk.actionSoft,
      minRatio: SkContrast.nonText,
    );

    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: sk.actionSoft,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 24, color: iconColour),
      ),
    );
  }
}
