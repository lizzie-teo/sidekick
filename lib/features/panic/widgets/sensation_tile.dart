import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_raised_tile.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/features/panic/models/sensation.dart';

// One body sensation, as a full-width row: the icon in its well, then the
// words.
//
// **Home's tile, laid on its side, from 26 September 2026, at the user's
// request.** It was a slim outline pill, two to a row. The sheet it sits in
// now looks like the other picker sheets, and the four answers read like the
// doors on Home -- one raised face, one icon well, one label.
//
// **One list, not a grid.** Four rows down a left edge are scanned in one
// pass; a two-by-two grid is read in a zigzag, by somebody whose attention is
// already poor. The icon leads so the eye can run down the wells.
//
// It clears the 48-point tap target at every text size, and the label grows
// with the reader's own font rather than being clamped to fit.
class SensationTile extends StatelessWidget {
  final Sensation sensation;
  final VoidCallback onPressed;

  const SensationTile({
    super.key,
    required this.sensation,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SkRaisedTile(
      onPressed: onPressed,
      semanticLabel: sensation.label,
      padding: const EdgeInsets.symmetric(
        horizontal: SkLayout.lg,
        vertical: SkLayout.md,
      ),
      child: Row(
        children: <Widget>[
          SkIconBadge(sensation.icon),
          const SizedBox(width: SkLayout.lg),
          Expanded(
            child: ExcludeSemantics(
              child: Text(
                sensation.label,
                style: SkText.rowLabel.copyWith(
                  color: context.sk.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
