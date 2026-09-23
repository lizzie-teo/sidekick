import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_exercise_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';

// Which edge the tail comes out of, and therefore who is talking.
enum SkBubbleTail {
  // Out of the left edge, pointing at somebody to the left of it. The
  // character's own bubbles, with her on the left of the screen.
  left,

  // Out of the right edge. A bubble with the character to the right of it.
  right,

  // Out of the top edge, pointing at somebody standing above it. The swap
  // drill's finish screen: her head is too big there to sit beside a
  // sentence, so she is over it instead.
  up,
}

// A rounded bubble with a tail, for words somebody said.
//
// **It exists so a sentence has somebody behind it.** The six sentences in
// the swap drill were a big bold heading in quote marks, which reads as the
// app's own words about the reader. Next to the character, in a bubble, they
// are plainly an example being read out -- and the quote marks come off,
// because a bubble already does that job.
//
// **The side the tail comes out of is who is speaking.** Six steps of hers
// pointing left out of her, then one of the reader's pointing right back at
// her, is the whole lesson said in a layout: she showed them the sentences,
// and now they say one to her.
//
// **The tail is part of one outline, not a triangle laid on a box.** The fill
// and the stroke are drawn from a single unioned path, so no line is drawn
// across the base of the tail. Getting that wrong looks like a seam.
//
// **The tail sits near the top and the bubble grows downward.** The character
// beside it is pinned to the top of her band, so a one-line sentence and a
// four-line one leave her in exactly the same place. She is the one fixed
// thing on a screen somebody is reading, everywhere in this app. An `up` tail
// grows downward for the same reason: she is above it, so nothing the
// sentence does can move her.
//
// **Growing downward is not the same as sitting at the top, and the swap
// drill takes the difference.** There the bubble is centred in a box as tall
// as she is -- she is 180 and a sentence is about 52, so top-aligning it left
// her lower two thirds beside nothing. The tail's 22 does the rest: on a
// one-line bubble centred like that the point lands within a few points of
// her own vertical middle, so it still aims at her rather than past her.
// **The centring belongs to the caller, not to this widget**, because it is
// the height of whoever is speaking -- which this widget cannot see.
class SkSpeechBubble extends StatelessWidget {
  const SkSpeechBubble({
    super.key,
    required this.child,
    this.tail = SkBubbleTail.left,
    this.tailInset,
    this.fill,
    this.edge,
  });

  final Widget child;
  final SkBubbleTail tail;

  // How far the point of an `up` tail sits from the left edge of the bubble.
  // Left unset it is centred. A caller passes the middle of the character's
  // own box, so the tail comes out under her head rather than under the
  // middle of the screen. The two side tails ignore it -- they take their
  // position from [_tailTop].
  final double? tailInset;

  // Left unset, both come from the exercise set for whichever mode the screen
  // is in. They are nullable rather than defaulted because the answer is not
  // known until there is a `BuildContext` to ask.
  final Color? fill;
  final Color? edge;

  // How far the tail sticks out, and how tall it is at the base.
  static const double _tailWidth = 12;
  static const double _tailHeight = 22;

  // Where the tail's point sits, measured down from the top of the bubble.
  // Level with the first line of text rather than the middle of the box, so
  // it aims at a head instead of at a pair of feet.
  static const double _tailTop = 22;

  static const double _radius = 18;

  @override
  Widget build(BuildContext context) {
    final bool isUp = tail == SkBubbleTail.up;
    final bool onLeft = tail == SkBubbleTail.left;
    final bool onRight = tail == SkBubbleTail.right;

    final SkExerciseColors ex = context.exercise;

    return CustomPaint(
      painter: _BubblePainter(
        fill: fill ?? ex.surface,
        edge: edge ?? ex.line,
        tail: tail,
        tailInset: tailInset,
        tailWidth: _tailWidth,
        tailHeight: _tailHeight,
        tailTop: _tailTop,
        radius: _radius,
      ),
      child: Padding(
        // The tail hangs off one edge, so the text is inset past it on that
        // side only. Padded on both, the bubble would look off-centre.
        padding: EdgeInsets.only(
          left: SkLayout.lg + (onLeft ? _tailWidth : 0),
          right: SkLayout.lg + (onRight ? _tailWidth : 0),
          top: SkLayout.md + 3 + (isUp ? _tailWidth : 0),
          bottom: SkLayout.md + 3,
        ),
        child: child,
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final Color fill;
  final Color edge;
  final SkBubbleTail tail;
  final double? tailInset;
  final double tailWidth;
  final double tailHeight;
  final double tailTop;
  final double radius;

  const _BubblePainter({
    required this.fill,
    required this.edge,
    required this.tail,
    required this.tailInset,
    required this.tailWidth,
    required this.tailHeight,
    required this.tailTop,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bool isUp = tail == SkBubbleTail.up;
    final bool onLeft = tail == SkBubbleTail.left;

    // The body stops short of the edge the tail comes out of, so the tail
    // hangs off it rather than eating into the text.
    final Rect body = isUp
        ? Rect.fromLTWH(0, tailWidth, size.width, size.height - tailWidth)
        : Rect.fromLTWH(
            onLeft ? tailWidth : 0,
            0,
            size.width - tailWidth,
            size.height,
          );

    final Path spike = isUp ? _upTail(size) : _sideTail(size, onLeft: onLeft);

    final Path outline = Path.combine(
      PathOperation.union,
      Path()..addRRect(RRect.fromRectAndRadius(body, Radius.circular(radius))),
      spike,
    );

    canvas.drawPath(outline, Paint()..color = fill);
    canvas.drawPath(
      outline,
      Paint()
        ..color = edge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  // A tail out of the top edge. Its base runs along the top of the body and is
  // [tailHeight] wide; the point stands [tailWidth] above it.
  //
  // **Clamped inside the corners.** A point asked for over a rounded corner
  // would leave a notch between the triangle and the curve, which reads as
  // damage rather than as a tail.
  Path _upTail(Size size) {
    final double half = tailHeight / 2;
    final double centre = (tailInset ?? size.width / 2).clamp(
      (radius + half).clamp(0.0, size.width),
      (size.width - radius - half).clamp(0.0, size.width),
    );

    return Path()
      ..moveTo(centre - half, tailWidth)
      ..lineTo(centre, 0)
      ..lineTo(centre + half, tailWidth)
      ..close();
  }

  Path _sideTail(Size size, {required bool onLeft}) {
    // A short bubble would otherwise put the tail's base below its own
    // bottom edge, which draws a spike.
    final double top = tailTop.clamp(
      radius,
      (size.height - tailHeight).clamp(0.0, size.height),
    );

    final double base = onLeft ? tailWidth : size.width - tailWidth;
    final double point = onLeft ? 0 : size.width;

    return Path()
      ..moveTo(base, top)
      ..lineTo(point, top + tailHeight / 2)
      ..lineTo(base, top + tailHeight)
      ..close();
  }

  @override
  bool shouldRepaint(_BubblePainter old) =>
      old.fill != fill ||
      old.edge != edge ||
      old.tail != tail ||
      old.tailInset != tailInset ||
      old.tailWidth != tailWidth ||
      old.tailHeight != tailHeight ||
      old.tailTop != tailTop ||
      old.radius != radius;
}
