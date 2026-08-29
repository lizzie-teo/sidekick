import 'package:flutter/material.dart';

// Persistent chrome wrapped around every feature route: app bar, navigation,
// and anything else that should survive navigation between features.
//
// This Scaffold does not make the route pages opaque. The ShellRoute child is
// an inner Navigator, and it animates between pages inside this one, so each
// feature view needs its own Scaffold or the outgoing and incoming screens show
// through each other mid-transition.
class ShellView extends StatelessWidget {
  final Widget child;

  const ShellView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
    );
  }
}
