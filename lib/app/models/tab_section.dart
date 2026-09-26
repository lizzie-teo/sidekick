import 'package:flutter/widgets.dart';

// One part of a tab that holds several, shown behind a segmented toggle.
//
// **It is plain data in `lib/app/` because the tab is in one feature and
// the parts can be in another.** The Good things tab is the good_things
// feature's, and its Colouring and Scribble parts are the play feature's. A
// feature hands its parts over through `FeatureModule.tabSections` and the
// tab finds them with `tabSectionsFor` -- the same shape as `GuidedIntro` --
// so neither feature imports the other, and deleting play leaves the tab
// with its own part and no toggle.
class TabSection {
  const TabSection({
    required this.id,
    required this.label,
    required this.order,
    required this.builder,
  });

  // Stored as the part last shown, and read from a route's query. Declared
  // in `app_constants.dart` so other screens can name it.
  final String id;

  // The word on the toggle.
  final String label;

  // Where it sits on the toggle, lowest first.
  final int order;

  // The part itself. It is kept alive once built, so a line half-written in
  // one part is still there after a look at another.
  final WidgetBuilder builder;
}
