import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// The one press effect for anything with a fill: buttons, cards, rows.
//
// This is Material 3's "state layer" rule, which is also close to what UIKit
// does to a filled button. A press does not make the control see-through. It
// paints a thin wash of the control's own label colour over the fill -- 10%
// per the spec -- so the thing stays solid and simply looks held.
//
// Flutter's CupertinoButton instead fades the whole control to 40%. That is
// Apple's rule for a plain text button, not for a filled one, and on a large
// filled pill it reads as broken rather than pressed. So filled controls use
// this, and only the genuinely text-only ones keep the fade.
//
// Washing in the label colour is what makes one rule work everywhere: cream
// over moss lifts the pill, moss over white sinks the card.
//
// On top of the wash a press also shrinks the control a little and fires a
// light haptic -- the short buzz the phone makes under a finger. Both start on
// touch down rather than on release, so the control answers the finger at the
// moment it lands instead of after the tap completes.
class SkPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;

  // The control's label or icon colour, per the state-layer rule.
  final Color wash;

  // The fill's own shape, so the wash stops exactly where the fill does.
  final BorderRadius? borderRadius;
  final BoxShape shape;

  // Material 3 state layer opacities: pressed 10%, dragged 16%.
  final double opacity;

  // How far the control shrinks while held. 1.0 turns the shrink off, which is
  // what a row inside a clipped group wants: it would pull away from the group
  // edge and show a gap rather than read as pressed.
  final double pressedScale;

  // Off for anything that is not a discrete control -- a whole row or card
  // buzzing on touch is noise, not feedback.
  final bool haptics;

  const SkPressable({
    super.key,
    required this.child,
    required this.onPressed,
    required this.wash,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.opacity = 0.10,
    this.pressedScale = 0.96,
    this.haptics = true,
  });

  @override
  State<SkPressable> createState() => _SkPressableState();
}

class _SkPressableState extends State<SkPressable> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    if (value && widget.haptics) HapticFeedback.lightImpact();
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onPressed == null) return widget.child;

    return Semantics(
      button: true,
      onTap: widget.onPressed,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        // GestureDetector rather than a raw Listener, so a finger that starts
        // on a card and turns into a scroll loses the gesture arena and the
        // wash is taken back. A Listener has no notion of the tap being lost.
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: AnimatedScale(
          scale: _isPressed ? widget.pressedScale : 1.0,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOut,
            // Foreground, so the wash sits over the fill and its border
            // rather than behind them.
            foregroundDecoration: BoxDecoration(
              color: widget.wash.withValues(
                alpha: _isPressed ? widget.opacity : 0,
              ),
              borderRadius:
                  widget.shape == BoxShape.circle ? null : widget.borderRadius,
              shape: widget.shape,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
