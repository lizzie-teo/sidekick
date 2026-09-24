import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// A dashed invitation: the empty-state twin of SkListCard, asking for the
// first meditation or the first good thing. Same footprint, but an outline
// with no fill, so it reads as a space waiting to be filled rather than a
// thing that already exists. Per the wireframes, it disappears once done.
//
// **It has no fill, so the ground under it decides its ink.** On the canvas
// that is `ink` and `chevron`, as it always was. On Home it now sits inside
// the scene gradient, where both of those are the wrong family -- `ink` is
// picked against the canvas and would read as a smudge on a sky. `onScene`
// is the slot for words on the gradient, and the dash takes the same colour
// at 75%: quieter than the words it surrounds, and still clear of the 3:1
// WCAG 1.4.11 asks of the edge of a control.
//
// **75%, not 55%, and it was measured rather than picked.** At 55% the dash
// ran between 2.22:1 and 2.64:1 across the twelve schemes -- under the floor
// in every one of them, on the one part of this card that says where it
// starts and stops. 75% is the first step of five that clears it everywhere:
// the worst scheme lands at 3.08:1.
class SkInviteCard extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  // The dash opacity over the scene. Named so `test/contrast_test.dart`
  // measures the number the card actually paints.
  static const double sceneDashAlpha = 0.75;

  // True when the card is laid on the scene gradient rather than the canvas.
  final bool onScene;

  const SkInviteCard({
    super.key,
    required this.title,
    this.onTap,
    this.onScene = false,
  });

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final Color ink = onScene ? sk.onScene : sk.ink;
    final Color dash =
        onScene ? sk.onScene.withValues(alpha: sceneDashAlpha) : sk.chevron;

    final Widget card = CustomPaint(
      painter: _DashedBorderPainter(color: dash),
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: SkText.cardTitle.copyWith(color: ink),
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.chevron_right, size: 20, color: dash),
          ],
        ),
      ),
    );

    return SkPressable(
      onPressed: onTap,
      wash: ink,
      borderRadius: BorderRadius.circular(20),
      child: card,
    );
  }
}

// Flutter has no dashed BorderSide, so the outline is painted by hand:
// build the rounded-rect path, then walk it drawing dash-length slices.
class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Inset by half the stroke so the line is not clipped at the edges.
    final Path border = Path()
      ..addRRect(RRect.fromRectAndRadius(
        (Offset.zero & size).deflate(0.75),
        const Radius.circular(20),
      ));

    const double dash = 6;
    const double gap = 5;
    for (final metric in border.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
