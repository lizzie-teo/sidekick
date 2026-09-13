import 'package:flutter/widgets.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';

// A soft green pool of light behind the sidekick.
//
// The scene gradient runs top to bottom and is the same everywhere on the
// panel, so on its own it does not say where she is standing. This adds a
// round wash of sceneGlow -- a deeper green than any stop in the gradient --
// centred just below her middle, so she reads as standing in light rather
// than pasted onto a flat field.
//
// Two rules keep it from looking like a shape:
//
// - It must not be sk.scene.last. That is the colour already under her at the
//   bottom of the panel, so painting with it shows nothing at all.
// - The fade must reach zero *inside* the box. A radius above 0.5 is still
//   part-opaque when it meets the top and bottom edges, and the paint stops
//   dead there -- which is exactly the visible rectangle this is meant to
//   avoid. Flutter measures the radius against the shortest side, so 0.5 is
//   the largest value that lands on the edge at nothing.
//
// The box takes the full width it is offered. Without that it is only as wide
// as the child, and the child is the Rive widget -- which is nothing at all
// until the file decodes, so the wash had no box to paint into and never
// appeared.
//
// It is a decoration only: the child is laid out as if the glow were not
// there, so a screen that puts her in an Expanded still gets the whole space.
class SkCharacterGlow extends StatelessWidget {
  final Widget child;

  // How far the wash reaches, as a fraction of the shortest side. Keep at or
  // below 0.5 -- see the note above.
  final double radius;

  final double opacity;

  const SkCharacterGlow({
    super.key,
    required this.child,
    this.radius = 0.5,
    this.opacity = 0.38,
  });

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final Color green = sk.sceneGlow;

    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            // Slightly low, so the light pools around her feet rather than
            // haloing her head.
            center: const Alignment(0, 0.18),
            radius: radius,
            // Four stops rather than two. A straight ramp from solid to clear
            // has a visible middle; most of the fade happening early leaves a
            // long, faint tail that the eye cannot find an edge in.
            colors: [
              green.withValues(alpha: opacity),
              green.withValues(alpha: opacity * 0.62),
              green.withValues(alpha: opacity * 0.22),
              green.withValues(alpha: 0),
            ],
            stops: const [0.0, 0.32, 0.66, 1.0],
          ),
        ),
        child: child,
      ),
    );
  }
}
