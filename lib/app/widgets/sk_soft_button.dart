import 'package:flutter/widgets.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_disabled.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// Meditate and Play. A paler cut of the action colour as fill, labelled in
// the action colour. Never the action colour itself. No shadow, no border.
class SkSoftButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const SkSoftButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return SkDisabled(
      isDisabled: onPressed == null,
      child: SkPressable(
        onPressed: onPressed,
        wash: sk.action,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 50),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: sk.actionSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: SkText.cardTitle.copyWith(color: sk.action),
          ),
        ),
      ),
    );
  }
}
