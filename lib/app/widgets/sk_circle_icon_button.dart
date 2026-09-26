import 'package:flutter/widgets.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_disabled.dart';
import 'package:sidekick/app/widgets/sk_pressable.dart';

// The app's one icon-only button: back, close, the voice on and off. A 52
// circle on a 12% wash of the foreground colour, so it reads on any surface
// including the scene gradient.
//
// **Every icon-only button is this one, from 26 September 2026, at the
// user's request.** The practice lessons had their own rounded-square tile
// for back and close; the round one from the guided screens was preferred,
// and a lesson is not a different product from a meditation. Pass `color`
// where the page does not follow the palette -- an exercise passes
// `context.exercise.ink`.
class SkCircleIconButton extends StatelessWidget {
  // Its width and height. The breathing screen works out where her band is
  // from this, so it is a name rather than a number at the use site.
  static const double size = 52;

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

  // Whether the circle is drawn behind the icon.
  //
  // **Off on a practice lesson, at the user's request, 26 September 2026.**
  // The circle is there so the icon reads on a moving sky; a lesson page is a
  // plain, still ground, so the icon alone reads and the circle was only
  // weight. The button keeps its full 52 and its round press wash either way,
  // so it is still the same size to a finger and still one component.
  final bool filled;

  const SkCircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.label,
    this.color,
    this.filled = true,
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
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: filled ? fg.withValues(alpha: 0.12) : null,
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
