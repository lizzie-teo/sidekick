import 'package:flutter/material.dart';

import 'package:sidekick/app/views/tab_placeholder_view.dart';

// Placeholder. The Breath session and the breathing pacer are phase 2;
// Mountain and Walk wait on the voice recordings.
class MeditateView extends StatelessWidget {
  const MeditateView({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholderView(
      title: 'Meditate',
      line: 'Breathe for two minutes. Coming soon.',
      tabIndex: 2,
    );
  }
}
