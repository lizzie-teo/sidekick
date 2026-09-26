import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// What the tab bar hands over as `extra` when it changes tab, so the tab's
// page knows it was reached by a tab tap rather than pushed.
class TabTap {
  const TabTap();
}

// The page every tab sits on: Home, Good things, Practice, Me.
//
// **A tab is not a place you travel to.** A tab tap is a `go`, and on the
// theme's Cupertino page it slid the new tab in from the right while the old
// one slid off left -- the shape of pushing a new page. It was the same going
// back to Home, so a tab to the *left* arrived from the right. iOS tab bars
// change without a slide.
//
// So a tab fades in, quickly, and the tab it replaces stays still under it.
// That is the whole switch. Measured on 26 September 2026 with a probe test:
// Me was 555 points off to the right 60ms into the switch.
//
// A page pushed on top of a tab -- the history, a colouring picture -- is
// still a Cupertino page and still slides. The tab under it still drifts
// left as it goes, because this page keeps that half of the Cupertino
// transition. Only tab-to-tab is different.
//
// **Only a tap on the tab bar gets it.** Good things is also *pushed* -- from
// the picker's Good stops and from "Actually okay" -- and a pushed page must
// keep its slide and its back swipe. The tab bar says which is which by
// handing [TabTap] over as the route's `extra`; [forState] reads it. Anything
// else -- a push, a deep link, a `go(Routes.home)` on the way out of a script
// -- stays the theme's page, exactly as it was.
class TabPage<T> extends Page<T> {
  const TabPage({super.key, required this.child});

  final Widget child;

  // Fast and short: a tab is tapped many times a visit, so the switch is
  // near-invisible. `ui-motion` has the table.
  static const Duration duration = Duration(milliseconds: 180);

  // The page a tab's `GoRoute.pageBuilder` returns: this one after a tab tap,
  // the theme's own page otherwise.
  static Page<void> forState(GoRouterState state, Widget child) {
    if (state.extra is TabTap) {
      return TabPage<void>(key: state.pageKey, child: child);
    }
    return MaterialPage<void>(key: state.pageKey, child: child);
  }

  @override
  Route<T> createRoute(BuildContext context) => _TabRoute<T>(page: this);
}

class _TabRoute<T> extends PageRoute<T> {
  _TabRoute({required TabPage<T> page}) : super(settings: page);

  TabPage<T> get _page => settings as TabPage<T>;

  @override
  Duration get transitionDuration => TabPage.duration;

  @override
  bool get maintainState => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  // **Tab to tab never moves the old tab.** Without these two the tab being
  // left would still drift left under the incoming fade, because any page
  // route normally animates the route beneath it.
  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) =>
      nextRoute is! _TabRoute && super.canTransitionTo(nextRoute);

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) =>
      previousRoute is! _TabRoute && super.canTransitionFrom(previousRoute);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      _page.child;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // The fade is kept under Reduce Motion: it moves nothing, and it is what
    // says the page changed.
    return CupertinoPageTransition(
      // Always arrived, so it never slides in -- but the secondary animation
      // still carries the drift when a page is pushed over this tab.
      primaryRouteAnimation: kAlwaysCompleteAnimation,
      secondaryRouteAnimation: secondaryAnimation,
      linearTransition: false,
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutQuint,
        ),
        child: child,
      ),
    );
  }
}
