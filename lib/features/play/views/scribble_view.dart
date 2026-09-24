import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/widgets/sk_circle_icon_button.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_outline_button.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/features/play/widgets/scribble_pad.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';

// A surface to draw on, reached from the Play button on Home.
//
// **It used to be the picker's Wound up face, and that was wrong.** Kjærvik &
// Bushman's 2024 meta-analysis of anger management -- roughly 154 studies,
// around 10,000 people -- splits the field cleanly: things that raise arousal
// (hitting, venting, jogging) do not reduce anger and sometimes increase it,
// while things that lower it (muscle relax-and-release, slow breathing,
// timeout) do. "Scribble as hard as you like" was on the wrong side of that
// line. The old comment here blamed *dwelling* on the artefact, which is why
// the marks fade -- but the arousal was the bigger problem, and fading a mark
// does not fix a fast, hard, angry action. That face now leads to
// `TightenView`.
//
// **The pad itself is fine; the framing was the problem.** Opened from Home
// by somebody who is not angry, it is drawing, and the fade is charm rather
// than therapy. So the copy no longer invites hard fast marks, and nothing on
// the screen mentions anger.
//
// The fade stays for its own reasons: there is no gallery to build, nothing to
// manage, and nothing to come back to. Nothing is saved, which is the point.
//
// The sidekick is deliberately absent. Being watched while you make a mess is
// wrong even when the watching is kind.
//
// No state lives here beyond the strokes, and those belong to the pad
// itself, so there is no viewmodel. An empty one is ceremony, not
// consistency.
class ScribbleView extends StatelessWidget {
  const ScribbleView({super.key});

  static const String title = 'Scribble';
  static const String promise = 'Draw whatever you like. It fades away.';

  // Same exit shape as the picker: pop back to wherever the user was, or go
  // home when the screen was opened cold with nothing underneath.
  //
  // Both doors -- the X and "I'm done" -- lead here. Leaving is the only
  // thing to do when the scribbling is done, and neither door is the wrong
  // kind of leaving.
  void _leave(BuildContext context) {
    final GoRouter? router = GoRouter.maybeOf(context);
    if (router == null) return;

    if (router.canPop()) {
      router.pop();
    } else {
      router.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: SkText.cardTitle.copyWith(color: sk.ink),
                    ),
                  ),
                  SkCircleIconButton(
                    icon: Icons.close,
                    label: 'Close',
                    onPressed: () => _leave(context),
                  ),
                ],
              ),
            ),

            // Full-bleed: the pad runs edge to edge, with no frame around
            // it. A box to stay inside is one more rule, and this screen is
            // for having none.
            Expanded(
              child: ScribblePad(color: sk.ink),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Text(
                promise,
                textAlign: TextAlign.center,
                style: SkText.caption.copyWith(
                  color: SkContrast.captionOn(sk.canvas),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              child: SkOutlineButton(
                label: "I'm done",
                onPressed: () => _leave(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
