import 'package:flutter/widgets.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';

// The line under a page's pinned header -- the title and the toggle -- that
// shows only once the content has scrolled up under it.
//
// **It is the iOS large-title rule, from 26 September 2026, at the user's
// request.** An underline on every title was asked about first, and most
// apps have none: on a phone an underlined line reads as a link, and a line
// on every page is weight on every page. A line that appears when the words
// go under the header says the one true thing -- "there is more above you" --
// and at the top of the page there is nothing to say, so it is not there.
//
// **Full width, not inside the gutter.** It marks the edge of the header,
// and the header runs edge to edge.
//
// Seen many times a visit, so it only fades: 150ms, nothing moves. A fade is
// kept under Reduce Motion.
class SkScrollEdge extends StatelessWidget {
  final bool visible;

  const SkScrollEdge({super.key, required this.visible});

  // Whether a scroll notification says the content has left the top.
  // Sideways scrolls -- a row of tiles -- say nothing about the header.
  static bool isScrolled(ScrollNotification n) =>
      n.metrics.axis == Axis.vertical && n.metrics.pixels > 0;

  @override
  Widget build(BuildContext context) {
    // Decoration: the edge of a header is not something to announce.
    return ExcludeSemantics(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutQuint,
        child: Container(height: 1, color: context.sk.hairline),
      ),
    );
  }
}
