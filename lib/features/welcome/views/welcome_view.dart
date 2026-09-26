import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_primary_button.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_text_button.dart';

// A placeholder for onboarding, which is not built yet. Nothing routes here:
// the app opens on Home, and the only door in is the Design system lab.
// `_docs/build-plan.md`, phase 6, says what replaces it.
//
// No viewmodel: this screen holds no state and does no async work, so there is
// nothing for one to own. Add one when it needs to load something.
class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Scaffold(
      // **The body is inside a SafeArea.** A Scaffold does not inset its
      // body for the status bar or the home indicator unless an AppBar is
      // doing it, so without this the first line sits under the notch on
      // every phone that has one -- and at a large text size the scroll view
      // reaches the top edge on every phone.
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SkLayout.gutter(context),
            vertical: SkLayout.xxxl,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //

              Semantics(
                header: true,
                child: Text(
                  'Sidekick',
                  style: SkText.h1.copyWith(color: sk.ink),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 48),

              // Plain button, not AsyncButton: navigation is synchronous, so there
              // is no in-flight state to guard against.
              SkPrimaryButton(
                label: 'Get started',
                onPressed: () => context.go(Routes.connect),
              ),

              const SizedBox(height: SkLayout.sm),

              SkTextButton(
                label: 'Design system',
                onPressed: () => context.go(Routes.designSystem),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
