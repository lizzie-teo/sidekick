import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// A standalone tappable card: optional overline, title, optional caption,
// trailing chevron. The lightest surface in the theme -- pure white in light,
// lifted moss in dark.
class SkListCard extends StatelessWidget {
  final Widget? leading;

  // The subject the card belongs to, in small capitals over the title --
  // "COMMUNICATION SKILLS". Added 22 September 2026, when the Practice tab's
  // group heading came off the page and onto the cards under it.
  //
  // **It is on the card because a shelf with one book on it is not a shelf.**
  // A heading over a list earns its place when the list is long enough to
  // need dividing; over a single card it is a second title the reader has to
  // read before reaching the first one. On the card it travels with the row
  // instead, so a list that later holds two subjects sorts itself.
  //
  // **It sits above the title rather than below it.** Below, it would be a
  // second caption competing with the one that says how long the lesson takes
  // -- and the length is the fact somebody scanning actually needs.
  final String? overline;

  final String title;
  final String? caption;
  final VoidCallback? onTap;

  const SkListCard({
    super.key,
    this.leading,
    this.overline,
    required this.title,
    this.caption,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    final Widget card = Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: sk.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sk.border),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (overline != null) ...[
                  Text(
                    overline!,
                    // Not `muted`, which is under 4.5:1 on every surface in
                    // every light palette. `captionOn` keeps the card's own
                    // hue and takes it dark enough to read.
                    style: SkText.label.copyWith(
                      color: SkContrast.captionOn(sk.surface),
                    ),
                  ),
                  const SizedBox(height: SkLayout.xs),
                ],
                Text(title, style: SkText.cardTitle.copyWith(color: sk.ink)),
                if (caption != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    caption!,
                    style: SkText.caption.copyWith(
                      color: SkContrast.captionOn(sk.surface),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.chevron_right, size: 20, color: sk.chevron),
        ],
      ),
    );

    return SkPressable(
      onPressed: onTap,
      wash: sk.ink,
      borderRadius: BorderRadius.circular(20),
      child: card,
    );
  }
}
