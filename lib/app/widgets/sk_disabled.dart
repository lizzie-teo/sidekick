import 'package:flutter/widgets.dart';

// Makes a disabled control look disabled.
//
// SkPressable handles the pressed state, but not the disabled one: a control
// with a null onPressed simply stops responding, and still looks live. The
// user taps a dead button and nothing happens. This wrapper is the other
// half. 38% is Material 3's opacity for disabled content.
class SkDisabled extends StatelessWidget {
  final Widget child;
  final bool isDisabled;

  const SkDisabled({
    super.key,
    required this.child,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    if (!isDisabled) return child;

    // Also swallows pointer events, so a disabled control does not eat a tap
    // meant for whatever sits behind it.
    return IgnorePointer(
      child: Opacity(opacity: 0.38, child: child),
    );
  }
}
