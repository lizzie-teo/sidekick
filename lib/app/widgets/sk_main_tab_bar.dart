import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/widgets/sk_tab_bar.dart';

// The application's five slots -- four tabs and the panic button -- declared
// once and dropped into each of the four tab screens.
//
// The bar is not in ShellView. It floats over each page's content so the page
// scrolls under the glass, and each page keeps SkMainTabBar.heightOf(context)
// of clear space at the bottom so its last row stays reachable. A bar in the
// shell would sit outside the inner Navigator that animates between routes and
// could not do either.
//
// SkTabBar is the presentation; this is where the labels, the icons and the
// destinations live, so a screen only says which slot it is.
class SkMainTabBar extends StatelessWidget {
  // Index into Routes.tabs: 0 Home, 1 Good things, 2 Meditate, 3 Me.
  final int selected;

  const SkMainTabBar({super.key, required this.selected});

  static const List<SkTabItem> _items = <SkTabItem>[
    SkTabItem(icon: Icons.home_rounded, label: 'Home'),
    SkTabItem(icon: Icons.auto_awesome, label: 'Good things'),
    SkTabItem(icon: Icons.air_rounded, label: 'Meditate'),
    SkTabItem(icon: Icons.person_outline_rounded, label: 'Me'),
  ];

  // How much of the screen bottom the bar covers. Pages pad by this so their
  // last row is not left under the glass.
  static double heightOf(BuildContext context) => SkTabBar.heightOf(context);

  void _go(BuildContext context, String path) {
    // The design system preview harness has no router; taps are inert there
    // rather than throwing.
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router == null) return;

    router.go(path);
  }

  // The panic route is pushed, not gone to, because it is not a tab: it opens
  // over whichever tab the user was on, and closing it puts them back there
  // rather than on Home.
  void _push(BuildContext context, String path) {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router == null) return;

    router.push(path);
  }

  @override
  Widget build(BuildContext context) {
    return SkTabBar(
      items: _items,
      selected: selected,
      onSelect: (int index) {
        if (index == selected) return;
        _go(context, Routes.tabs[index]);
      },
      // Straight into the breathing, with no question in front of it. This
      // button is pressed by someone who could not wait, so the fastest thing
      // it can do is start pacing. The feeling picker is still there behind
      // the Home CTA, for the calmer arrival that has room for a question.
      onPanic: () => _push(context, Routes.breathe),
    );
  }
}
