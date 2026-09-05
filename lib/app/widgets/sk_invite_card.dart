import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// A dashed invitation: the empty-state twin of SkListCard, asking for the
// first meditation or the first good thing. Same footprint, but an outline
// with no fill, so it reads as a space waiting to be filled rather than a
// thing that already exists. Per the wireframes, it disappears once done.
class SkInviteCard extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const SkInviteCard({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    final Widget card = CustomPaint(
      painter: _DashedBorderPainter(color: sk.chevron),
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: SkText.cardTitle.copyWith(color: sk.ink),
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.chevron_right, size: 20, color: sk.chevron),
          ],
        ),
      ),
    );

    return SkPressable(
      onPressed: onTap,
      wash: sk.ink,
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
