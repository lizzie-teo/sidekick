import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Theme, Brightness, Colors;

import 'package:sidekick/app/widgets/sk_colors.dart';

// The iPhone switch at its native 51x31, recoloured to the theme's action
// colour when on.
//
// It used to be panic orange in both modes. The six-themes settings design
// reversed that on purpose: the panic button is the ONE control that stays
// C2542A in every theme and every mode, and it can only be the one if
// nothing else wears its colour. Toggles say "on", not "urgent".
//
// The knob follows the design's other rule: white in light mode, ink in
// dark -- a pure white knob glows harder than anything else on a dark theme.
class SkToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SkToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return CupertinoSwitch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: sk.action,
      inactiveTrackColor: sk.toggleOff,
      thumbColor: isDark ? sk.ink : Colors.white,
    );
  }
}
