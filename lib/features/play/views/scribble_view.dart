import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/widgets/sk_circle_icon_button.dart';
import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_primary_button.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/features/play/widgets/scribble_pad.dart';

// Wound up -- scribble it out.
//
// Anger needs discharge, not calming: a slow breathing exercise offered to
// someone wound up reads as being told off. So this screen is a pad and
// nothing else. Scribble as hard as you like, watch it fade, leave when you
// are done.
//
// Nothing is saved, which is the point rather than an omission. No artefact
// means no judgement: nothing to look back on, nothing that says how angry
// anyone was. The ink lives inside ScribblePad and dies with the screen, so
// this view holds no state and has no viewmodel.
//
// The pad is full-bleed on purpose. A colour, a weight or an undo would each
// be a decision put in front of the discharge, and the wireframe cuts all
// three.
class ScribbleView extends StatelessWidget {
  const ScribbleView({super.key});

  static const String title = 'Scribble it out';
  static const String caption = 'Scribble as hard as you like. It fades away.';

  // Both doors out are the same leaving: the ink is not saved either way, so
  // there is no "done" to commit and no "cancel" to throw away. Popping puts
  // the user back on the picker they came from; going home covers the screen
  // arriving cold from a restored route, with nothing underneath it.
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
            //

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: SkText.cardTitle.copyWith(color: sk.ink),
                  ),
                  SkCircleIconButton(
                    icon: Icons.close,
                    onPressed: () => _leave(context),
                  ),
                ],
              ),
            ),

            // The pad takes everything between the chrome, edge to edge --
            // no horizontal padding, because an edge the ink cannot reach
            // reads as a margin to stay inside.
            const Expanded(child: ScribblePad()),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Text(
                caption,
                textAlign: TextAlign.center,
                style: SkText.caption.copyWith(color: sk.muted),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: SkPrimaryButton(
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
