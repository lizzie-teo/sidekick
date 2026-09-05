import 'package:flutter/material.dart';

import 'package:sidekick/app/utilities/date_format_utils.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// Which month is on screen, and the two arrows either side of it.
//
// Back has no floor: someone can walk past their first entry and find empty
// months, which is honest. Forward stops at the current month, because there
// is nothing ahead to look at.
class GoodThingsMonthSwitcher extends StatelessWidget {
  final DateTime month;
  final bool canShowNext;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const GoodThingsMonthSwitcher({
    super.key,
    required this.month,
    required this.canShowNext,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Row(
      children: <Widget>[
        _Arrow(
          icon: Icons.chevron_left,
          semanticLabel: 'Previous month',
          onPressed: onPrevious,
        ),
        Expanded(
          child: Text(
            DateFormatUtils.monthLabel(month),
            textAlign: TextAlign.center,
            style: SkText.cardTitle.copyWith(color: sk.ink),
          ),
        ),
        _Arrow(
          icon: Icons.chevron_right,
          semanticLabel: 'Next month',
          // Null rather than a no-op, so the arrow is fully off to a screen
          // reader as well as to the eye.
          onPressed: canShowNext ? onNext : null,
        ),
      ],
    );
  }
}

class _Arrow extends StatelessWidget {
  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;

  const _Arrow({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return SkPressable(
      onPressed: onPressed,
      wash: sk.ink,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          size: 24,
          semanticLabel: semanticLabel,
          color: onPressed == null ? sk.chevron : sk.ink,
        ),
      ),
    );
  }
}
