import 'package:flutter/widgets.dart';

import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_scroll_edge.dart';

// A main tab page's shape: the header -- the title, and a toggle when there
// is one -- stays at the top, and the body scrolls up under it. The line
// between the two shows only once the body has left its top (`SkScrollEdge`).
//
// **Every main tab with a title uses this, from 26 September 2026, at the
// user's request.** Practice and Me used to scroll their title away with the
// page, so nothing ever went under anything and the line had nowhere to be.
// Unwind already held its title still, and now all three do.
//
// **`part` is for a page whose toggle swaps between bodies that each keep
// their own scroll** -- Unwind's parts sit in an `IndexedStack`. The line
// remembers which parts have been scrolled, so it is right the moment the
// toggle changes. Only the part on screen can be scrolled, so a notification
// always belongs to the current part. Leave it unset for one body.
class SkPinnedHeader extends StatefulWidget {
  final Widget header;
  final Widget body;
  final Object? part;

  const SkPinnedHeader({
    super.key,
    required this.header,
    required this.body,
    this.part,
  });

  @override
  State<SkPinnedHeader> createState() => _SkPinnedHeaderState();
}

class _SkPinnedHeaderState extends State<SkPinnedHeader> {
  // Widget-owned state: the line is this widget's business, not the page's.
  final Set<Object?> _scrolled = <Object?>{};

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    final bool scrolled = SkScrollEdge.isScrolled(n);
    if (scrolled != _scrolled.contains(widget.part)) {
      setState(() => scrolled
          ? _scrolled.add(widget.part)
          : _scrolled.remove(widget.part));
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        widget.header,
        const SizedBox(height: SkLayout.sm),
        SkScrollEdge(visible: _scrolled.contains(widget.part)),
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: widget.body,
          ),
        ),
      ],
    );
  }
}
