import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// A standalone tappable card: title, optional caption, trailing chevron.
// The lightest surface in the theme -- pure white in light, lifted moss in
// dark.
class SkListCard extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? caption;
  final VoidCallback? onTap;

  const SkListCard({
    super.key,
    this.leading,
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
                Text(title, style: SkText.cardTitle.copyWith(color: sk.ink)),
                if (caption != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    caption!,
                    style: SkText.caption.copyWith(color: sk.muted),
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
