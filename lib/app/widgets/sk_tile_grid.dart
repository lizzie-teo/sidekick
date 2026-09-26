import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_raised_tile.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// Doors, two abreast. Home's tiles, shared with the Practice tab's
// Meditations half.
//
// It lived inside `dashboard_view.dart` as `_Tiles` and `_Tile` until 26
// September 2026, when the Meditations half took the same tiles at the user's
// request. Two callers, so the grid cannot drift between them.
//
// Two abreast, from 26 September 2026, at the user's request. It was one row
// that scrolled sideways on Home: the fourth tile was cut at the edge and
// needed a swipe.
//
// **An odd tile out takes the full width.** Half a row with a hole beside it
// reads as a tile that failed to load. Meditations has five, so the
// last one -- the panic breathing -- spans the row.
//
// A column at 200% text -- `SkLayout.isLargeText`, the same answer the
// feeling dial and the topic grid give: change shape rather than shrink the
// words.
class SkTileGrid extends StatelessWidget {
  final List<Widget> children;

  const SkTileGrid({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    if (SkLayout.isLargeText(context)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < children.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: SkLayout.md),
            children[i],
          ],
        ],
      );
    }

    // `IntrinsicHeight` makes the two tiles in a row one height, so a label
    // that wraps does not leave its neighbour short.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (int i = 0; i < children.length; i += 2) ...<Widget>[
          if (i > 0) const SizedBox(height: SkLayout.md),
          if (i + 1 == children.length)
            children[i]
          else
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(child: children[i]),
                  const SizedBox(width: SkLayout.md),
                  Expanded(child: children[i + 1]),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

// One door: an icon over a label, on a soft raised tile.
//
// **`note` is for a door that is not open yet**, and it is said in words.
// Leave `onPressed` null with it: the tile takes no taps, and the note --
// "Not ready yet" -- sits under the label. A tile that looks open and does nothing reads as a
// bug; one that says it is on its way reads as work outstanding.
class SkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final String? note;

  static const double minHeight = 104;

  const SkTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final String? note = this.note;

    // The note sits low on the tile, where the face has faded toward the
    // canvas, so its caption colour is taken from that end of the fill.
    final Color noteGround = Color.lerp(sk.surface, sk.canvas, 0.6)!;

    return SkRaisedTile(
      onPressed: onPressed,
      semanticLabel: note == null ? label : '$label, $note',
      minHeight: minHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SkIconBadge(icon),
          const SizedBox(height: SkLayout.lg),
          ExcludeSemantics(
            child: Text(
              label,
              style: SkText.button.copyWith(color: sk.ink),
            ),
          ),
          if (note != null) ...<Widget>[
            const SizedBox(height: SkLayout.xs),
            ExcludeSemantics(
              child: Text(
                note,
                style: SkText.caption.copyWith(
                  color: SkContrast.captionOn(noteGround),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
