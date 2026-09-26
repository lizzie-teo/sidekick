import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';

// A grouped settings list: rounded surface card that clips its rows, with
// hairline dividers between rows and none after the last. Optional uppercase
// header above and caption footer below, both with an 8 gap.
class SkListGroup extends StatelessWidget {
  final String? header;
  final String? footer;
  final List<Widget> children;

  const SkListGroup({
    super.key,
    this.header,
    this.footer,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    final List<Widget> rows = [];
    for (int i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i < children.length - 1) {
        rows.add(Container(height: 1, color: sk.hairline));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              header!,
              style: SkText.label.copyWith(
                color: SkContrast.captionOn(sk.canvas),
              ),
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: sk.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: sk.border),
            ),
            child: Column(children: rows),
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, top: 8),
            child: Text(
              footer!,
              style: SkText.caption.copyWith(
                color: SkContrast.captionOn(sk.canvas),
              ),
            ),
          ),
      ],
    );
  }
}

// One row in an SkListGroup: label, then optionally a value, a trailing
// widget (usually SkToggle), and a chevron. Destructive turns the label red.
class SkRow extends StatelessWidget {
  final String label;

  // A second line under the label, for something the row has to say about
  // itself -- a setting the phone is refusing, a consequence of the toggle
  // beside it. Null on almost every row, and it takes no height when it is.
  final String? caption;

  final String? value;
  final Widget? trailing;
  final bool chevron;
  final bool destructive;
  final VoidCallback? onTap;

  const SkRow({
    super.key,
    required this.label,
    this.caption,
    this.value,
    this.trailing,
    this.chevron = false,
    this.destructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    final Widget row = Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: SkText.rowLabel.copyWith(
                    color: destructive ? sk.destructive : sk.ink,
                  ),
                ),
                if (caption != null) ...[
                  const SizedBox(height: 4),
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
          if (value != null) ...[
            const SizedBox(width: 12),
            Text(
              value!,
              style: SkText.rowLabel.copyWith(
                color: SkContrast.captionOn(sk.surface),
              ),
            ),
          ],
          if (trailing != null) ...[
            const SizedBox(width: 12),
            trailing!,
          ],
          if (chevron) ...[
            const SizedBox(width: 12),
            Icon(Icons.chevron_right, size: 20, color: sk.chevron),
          ],
        ],
      ),
    );

    // Square corners: a row is clipped by the group that holds it, and the
    // group already rounds its own outer edge.
    return SkPressable(
      onPressed: onTap,
      wash: sk.ink,
      borderRadius: BorderRadius.zero,
      // No shrink: the group clips this row, so a scaled row would pull away
      // from the group edge and show a gap instead of reading as pressed.
      pressedScale: 1.0,
      child: row,
    );
  }
}
