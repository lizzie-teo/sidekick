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

  const SkCircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
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
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: fg.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 27, color: fg),
        ),
      ),
    );
  }
}
