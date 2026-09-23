import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_exercise_colors.dart';

// How far through something the reader is, as one bar filling.
//
// **One bar, and it fills once.** The prototype this came from ran two -- one
// for the six sentences and one for the four builder steps -- and the second
// started empty, which reads as starting again halfway through. A single fill
// from empty to full is the whole thing.
//
// **It is continuous rather than segmented, and that is rule 15.** Segments
// can be counted: thirteen ticks in a row is "3 of 13" drawn instead of
// written, and a number in front of somebody reads as a target whether or not
// it was meant as one. It is the rule that took the breath counter off the
// breathing screen and the "2/4" off this one. A fill says how far along
// without putting a figure on it.
//
// **It reports, it does not steer.** Nothing here is tappable: a bar somebody
// can drag is a scrubber, and a lesson is not a video.
//
// The colours are the fixed exercise pair rather than the theme's, for the
// reason in `sk_exercise_colors.dart`. The fill takes the theme's accent,
// because two small marks of the user's own palette on an otherwise neutral
// page read as deliberate.
class SkProgressBar extends StatelessWidget {
  const SkProgressBar({
    super.key,
    required this.value,
    required this.fill,
    this.track,
    this.height = 5,
  });

  // How far along, 0 to 1. Out-of-range values are clamped rather than
  // asserted: a bar is not worth crashing a lesson over.
  final double value;

  final Color fill;

  // Left unset it is the exercise set's own hairline, for whichever mode the
  // screen is in. It is nullable rather than defaulted because the answer is
  // not known until there is a `BuildContext` to ask.
  final Color? track;

  final double height;

  // Long enough to be seen as a move rather than a jump, short enough that
  // the next step's words are not waiting on it.
  static const Duration _travel = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(999);
    final Color groove = track ?? context.exercise.line;

    return Semantics(
      label: 'How far through',
      value: '${(value.clamp(0.0, 1.0) * 100).round()}%',
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          height: height,
          child: ColoredBox(
            color: groove,
            child: TweenAnimationBuilder<double>(
              duration: _travel,
              curve: Curves.easeOut,
              tween: Tween<double>(end: value.clamp(0.0, 1.0)),
              builder: (BuildContext context, double t, Widget? child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: t,
                  child: child,
                );
              },
              child: DecoratedBox(
                decoration: BoxDecoration(color: fill, borderRadius: radius),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
