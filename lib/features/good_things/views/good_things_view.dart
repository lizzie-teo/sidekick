import 'package:flutter/material.dart';

import 'package:sidekick/app/views/tab_placeholder_view.dart';

// Placeholder. The real screens, the Supabase table and the long view are
// phase 1.
class GoodThingsView extends StatelessWidget {
  const GoodThingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPlaceholderView(
      title: 'Good things',
      line: 'Three good things a day. Coming next.',
      tabIndex: 1,
    );
  }
}
