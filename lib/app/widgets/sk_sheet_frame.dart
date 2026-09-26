import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';

// The shell every bottom sheet on the feeling picker sits in: the page's own
// ground, a grab handle, and a height cap.
//
// Shared by `BodySensationSheet` and `GuidedIntroSheet`, because "Can't cope"
// turns one into the other in place. Two frames drawn two ways would make that
// swap move the handle.
//
// [show] is wider than the frame: every sheet in the app opens through it,
// whether or not it draws this frame.
class SkSheetFrame extends StatelessWidget {
  const SkSheetFrame({super.key, required this.child});

  // What the sheet holds. It gets the height left under the handle and must
  // scroll its own words inside that -- see [maxHeightFraction].
  final Widget child;

  // The tallest a sheet may be, as a share of the screen.
  //
  // **Measured from `View.of(context)`, never `MediaQuery.sizeOf`**, the same
  // rule `SkFeedbackSheet` learned: a bare `MediaQueryData` reports a size of
  // zero, which is what the widget-test harness supplies, and a cap of zero
  // collapses the sheet and pushes its button off the screen.
  //
  // 0.9 rather than the feedback sheet's 0.6, because this sheet is the whole
  // of what the reader is doing and the page behind it is waiting, not being
  // read. The last tenth keeps a strip of the picker in view, which is what
  // says a swipe down goes back to it.
  static const double maxHeightFraction = 0.9;

  // How every sheet in the app rises and falls. One place, so two sheets can
  // never move two ways.
  //
  // In on the iOS drawer curve -- fast off the mark, a long soft landing --
  // and out a third quicker, because the reader has already decided to go.
  // Flutter's own sheet runs 250ms in on a weaker ease-out.
  //
  // The drag is untouched: a sheet let go mid-swipe still carries the
  // finger's speed, because Flutter hands that over itself.
  static const AnimationStyle motion = AnimationStyle(
    duration: Duration(milliseconds: 320),
    reverseDuration: Duration(milliseconds: 220),
    curve: Cubic(0.32, 0.72, 0, 1),
  );

  // Opens [builder] as a sheet over the whole screen.
  //
  // Every bottom sheet in the app opens through here, not only the picker's,
  // so they all share [motion].
  //
  // A swipe down or a tap on the page behind closes it with null. The
  // picker's callers read null as "I changed my mind": nothing starts.
  //
  // [useRootNavigator] is on by default, so the sheet covers the floating tab
  // bar as well as the page. The two Good things sheets keep it off, as they
  // always had it.
  static Future<T?> show<T>(
    BuildContext context, {
    required String barrierLabel,
    required WidgetBuilder builder,
    bool useRootNavigator = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: useRootNavigator,
      // With Reduce Motion on, the sheet is simply there. A slide is
      // movement, and there is no fade a sheet can do instead.
      sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
          ? AnimationStyle.noAnimation
          : motion,
      backgroundColor: context.sk.canvas,
      // What a screen reader says when the sheet takes focus, and what a tap
      // outside it is announced as. The default is "Scrim", which tells
      // somebody who cannot see the sheet nothing about what just opened.
      barrierLabel: barrierLabel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final double screenHeight = View.of(context).physicalSize.height /
        View.of(context).devicePixelRatio;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: screenHeight > 0
            ? BoxConstraints(maxHeight: screenHeight * maxHeightFraction)
            : const BoxConstraints(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // A picture of a gesture a screen-reader user is not making.
            ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.only(top: SkLayout.md),
                child: Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: sk.chevron,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
