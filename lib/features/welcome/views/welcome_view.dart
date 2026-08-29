import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';

// No viewmodel: this screen holds no state and does no async work, so there is
// nothing for one to own. Add one when it needs to load something.
class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //

            Text(
              'Sidekick',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // Plain button, not AsyncButton: navigation is synchronous, so there
            // is no in-flight state to guard against.
            FilledButton(
              onPressed: () => context.go(Routes.connect),
              child: const Text('Get started'),
            ),

            const SizedBox(height: 8),

            TextButton(
              onPressed: () => context.go(Routes.designSystem),
              child: const Text('Design system'),
            ),
          ],
        ),
      ),
    );
  }
}
