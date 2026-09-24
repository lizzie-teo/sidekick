import 'package:flutter/widgets.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_disabled.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';

// Breathing-flow chrome: close and mute. A 52 circle on a 12% wash of the
// foreground colour, so it reads on any surface including the scene gradient.
class SkCircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  // What the button is called out loud.
  //
  // **Required, so it cannot be forgotten.** `SkPressable` already announces
  // "button", and an icon carries no words at all -- so without this a screen
  // reader reads the ✕ on the breathing screen as "button" and nothing more,
  // on the one screen where somebody mid-panic is looking for the way out.
  // Making it optional would put that one bad announcement one forgotten
  // argument away, every time this widget is used again.
  //
  // **It says the action, not the picture.** "Close", never "cross"; "Turn
  // the voice off", never "speaker". A reader who cannot see the icon needs
  // to know what pressing it does.
  final String label;

  const SkCircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color fg = color ?? context.sk.ink;

    return SkDisabled(
      isDisabled: onPressed == null,
      child: SkPressable(
        onPressed: onPressed,
        wash: fg,
        shape: BoxShape.circle,
        semanticLabel: label,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: fg.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          // The icon is the picture of the label above it, so it is not read
          // a second time.
          child: ExcludeSemantics(child: Icon(icon, size: 27, color: fg)),
        ),
      ),
    );
  }
}
