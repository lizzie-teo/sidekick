import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// A one-line (or few-line) input on a surface card. Errors come from the
// viewmodel's state.errors and are passed in as errorText, per the MVVM
// contract.
class SkTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final String? errorText;
  final int maxLines;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const SkTextField({
    super.key,
    this.controller,
    this.hint,
    this.errorText,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: sk.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: errorText != null ? sk.destructive : sk.border,
            ),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: SkText.rowLabel.copyWith(color: sk.ink),
            cursorColor: sk.action,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: SkText.rowLabel.copyWith(color: sk.muted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 6),
            child: Text(
              errorText!,
              style: SkText.caption.copyWith(color: sk.destructive),
            ),
          ),
      ],
    );
  }
}
