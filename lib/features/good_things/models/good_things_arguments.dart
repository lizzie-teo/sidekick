import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';

// What another screen hands to Good things on the way in.
//
// Three places lead here with something already in mind: the panic recap, the
// journal's second layer, and "I want to share my happiness". All of them
// know the first line before the user does, and none of them should have to
// know how the form is built.
//
// Carried as GoRoute `extra` rather than a query parameter. The first line is
// the user's own words -- it does not belong in a URL, where it would be
// logged, length-limited and escaped.
@immutable
class GoodThingsArguments {
  // Dropped into the first box, already typed. Empty means an ordinary visit
  // from the tab bar.
  final String firstLine;

  const GoodThingsArguments({this.firstLine = ''});

  // The one call another feature makes. It keeps the route path and the shape
  // of the argument in this file, so a caller only says what it wants written.
  //
  // push, not go: the caller stays underneath, so closing the form returns to
  // the recap or the journal rather than dropping the user on a tab.
  static void open(BuildContext context, {String firstLine = ''}) {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router == null) return;

    router.push(
      Routes.goodThings,
      extra: GoodThingsArguments(firstLine: firstLine),
    );
  }

  // Reads the argument back off a route, tolerating its absence. A tab tap
  // carries no extra at all, and a deep link or a restored route carries one
  // that did not survive the trip.
  static GoodThingsArguments of(Object? extra) {
    if (extra is GoodThingsArguments) {
      return extra;
    }

    return const GoodThingsArguments();
  }
}
