import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/tab_page.dart';
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
  // Index into Routes.tabs: 0 Home, 1 Unwind, 2 Practice, 3 Me.
  final int selected;

  const SkMainTabBar({super.key, required this.selected});

  // **Slot 2 was Meditate and the wind icon until 20 September 2026.** The tab
  // now holds two kinds of thing -- lessons somebody does, and meditations
  // somebody sits through -- and "Practice" is the one word that covers both:
  // nobody learns a meditation, they do one.
  //
  // The wind went with the name. It stood for breathing, and breathing is not
  // what the tab is any more -- it is the panic button in the centre of this
  // bar, where somebody who could not wait can reach it.
  //
  // `_docs/briefs/practice-tab-layout.md` holds the decision.
  //
  // **Slot 1 was "Good things" until 26 September 2026.** It holds colouring
  // and scribbling now as well as the good things form, and "Unwind" covers
  // all three. "Feel better" was considered and turned down: the dial's Good
  // and Really good faces lead here, and it would tell somebody on a good day
  // that they need to feel better.
  static const List<SkTabItem> _items = <SkTabItem>[
    SkTabItem(icon: Icons.home_rounded, label: 'Home'),
    SkTabItem(icon: Icons.auto_awesome, label: 'Unwind'),
    SkTabItem(icon: Icons.self_improvement, label: 'Practice'),
    SkTabItem(icon: Icons.person_outline_rounded, label: 'Me'),
  ];

  // How much of the screen bottom the bar covers. Pages pad by this so their
  // last row is not left under the glass.
  static double heightOf(BuildContext context) => SkTabBar.heightOf(context);

  // The room under a scrolling page's last row, clear of the panic button
  // that rises above the bar. Lists and forms pad by this.
  static double clearanceOf(BuildContext context) =>
      SkTabBar.clearanceOf(context);

  void _go(BuildContext context, String path) {
    // The design system preview harness has no router; taps are inert there
    // rather than throwing.
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router == null) return;

    // Marked as a tab tap, so the tab fades in rather than sliding -- see
    // `TabPage`.
    router.go(path, extra: const TabTap());
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
