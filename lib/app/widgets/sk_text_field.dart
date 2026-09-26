import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';

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

  // What the sign-in fields need: the email and the one-time code. Passed
  // straight through to the TextField underneath.
  final bool autocorrect;
  final bool autofocus;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;

  // Caps what can be typed. The counter Flutter would draw under the field
  // is hidden: a six-digit code does not need "3/6" read out beside it.
  final int? maxLength;

  const SkTextField({
    super.key,
    this.controller,
    this.hint,
    this.errorText,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
    this.autocorrect = true,
    this.autofocus = false,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.maxLength,
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
            autocorrect: autocorrect,
            autofocus: autofocus,
            autofillHints: autofillHints,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            inputFormatters: inputFormatters,
            maxLength: maxLength,
            style: SkText.rowLabel.copyWith(color: sk.ink),
            cursorColor: sk.action,
            decoration: InputDecoration(
              hintText: hint,
              counterText: '',
              // **A placeholder is text somebody has to read**, so it is
              // held to the same 4.5:1 as the words they type. `muted`
              // measures under 3.3:1 on every light palette.
              hintStyle: SkText.rowLabel.copyWith(
                color: SkContrast.captionOn(sk.surface),
              ),
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
              style: SkText.caption.copyWith(
                color: SkContrast.readable(sk.destructive, sk.canvas),
              ),
            ),
          ),
      ],
    );
  }
}
