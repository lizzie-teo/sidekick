import 'package:flutter/cupertino.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';

// The iPhone switch at its native 51x31, recoloured: panic orange when on, in
// both modes -- the one control where the app's most urgent colour also means
// "yes, this is on".
class SkToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SkToggle({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return CupertinoSwitch(
      value: value,
      onChanged: onChanged,
      activeTrackColor: sk.panic,
      inactiveTrackColor: sk.toggleOff,
    );
  }
}
