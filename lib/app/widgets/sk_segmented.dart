import 'package:flutter/widgets.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// Light / Dark / Auto. Selected pill is a surface with a soft shadow, never
// the action colour -- a selection is not an action.
class SkSegmented extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;

  const SkSegmented({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: sk.hairline,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          for (int i = 0; i < labels.length; i++)
            Expanded(
              child: SkPressable(
                onPressed: () => onChanged(i),
                wash: sk.ink,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  alignment: Alignment.center,
                  decoration: i == selected
                      ? BoxDecoration(
                          color: sk.surface,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: sk.ink.withValues(alpha: 0.18),
                              offset: const Offset(0, 1),
                              blurRadius: 3,
                            ),
                          ],
                        )
                      : null,
                  child: Text(
                    labels[i],
                    style: SkText.caption.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: i == selected ? sk.ink : sk.muted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
