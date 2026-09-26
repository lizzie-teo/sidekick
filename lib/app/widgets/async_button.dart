import 'package:flutter/widgets.dart';

import 'package:sidekick/app/widgets/sk_primary_button.dart';

// A button that owns its own in-flight state.
//
// This is the reference for ephemeral state: the fact that a tap is currently
// running belongs to the button, not to the page viewmodel. That is what lets
// a page have several independent actions without the viewmodel needing an
// isLoading flag for each one.
//
// While the action runs, further taps are ignored and a spinner replaces the
// label. It draws `SkPrimaryButton` -- this widget adds the in-flight state
// and nothing else, so there is one primary button in the app, not two. Errors are not swallowed -- they propagate to the caller, so the
// viewmodel method being called stays responsible for handling them.
class AsyncButton extends StatefulWidget {
  final String label;
  final Future<void> Function()? onPressed;

  const AsyncButton({
    super.key,
    required this.label,
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
    return SkPrimaryButton(
      label: widget.label,
      onPressed: widget.onPressed == null ? null : _handlePressed,
      busy: _isInFlight,
    );
  }
}
