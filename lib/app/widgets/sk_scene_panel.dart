import 'package:flutter/widgets.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';

// The scene: the one place the theme goes full-bleed. On Home it is the
// header with 32 bottom corners; on Breathing the same gradient takes the
// whole screen and the corners go. It owns the status bar, so it pads for it.
class SkScenePanel extends StatelessWidget {
  final Widget child;
  final bool fullScreen;

  const SkScenePanel({super.key, required this.child, this.fullScreen = false});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final double statusBar = MediaQuery.paddingOf(context).top;

    return Container(
      decoration: BoxDecoration(
        gradient: sk.sceneGradient,
        borderRadius: fullScreen
            ? null
            : const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
      ),
      padding: EdgeInsets.fromLTRB(24, statusBar + 16, 24, 28),
      child: child,
    );
  }
}
