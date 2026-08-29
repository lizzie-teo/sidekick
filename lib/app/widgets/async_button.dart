import 'package:flutter/material.dart';

// A button that owns its own in-flight state.
//
// This is the reference for ephemeral state: the fact that a tap is currently
// running belongs to the button, not to the page viewmodel. That is what lets
// a page have several independent actions without the viewmodel needing an
// isLoading flag for each one.
//
// While the action runs, further taps are ignored and a spinner replaces the
// label. Errors are not swallowed -- they propagate to the caller, so the
// viewmodel method being called stays responsible for handling them.
class AsyncButton extends StatefulWidget {
  final Widget child;
  final Future<void> Function()? onPressed;

  const AsyncButton({
    super.key,
    required this.child,
    this.onPressed,
  });

  @override
  State<AsyncButton> createState() => _AsyncButtonState();
}

class _AsyncButtonState extends State<AsyncButton> {
  bool _isInFlight = false;

  Future<void> _handlePressed() async {
    final action = widget.onPressed;

    if (_isInFlight || action == null) {
      return;
    }

    setState(() => _isInFlight = true);

    try {
      await action();
    } finally {
      // The button may have left the tree while the action was running.
      if (mounted) {
        setState(() => _isInFlight = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: widget.onPressed == null ? null : _handlePressed,
      // Fixed height so the button does not resize when the label is swapped
      // for the spinner.
      child: SizedBox(
        height: 20,
        child: Center(
          child: _isInFlight
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : widget.child,
        ),
      ),
    );
  }
}
