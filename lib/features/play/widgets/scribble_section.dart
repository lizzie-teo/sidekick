import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_contrast.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_main_tab_bar.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/features/play/widgets/scribble_pad.dart';

// The Scribble part of the Good things tab: one ink, no choices, and every
// mark fades. Nothing on it is saved, which is the point.
//
// It was its own screen, pushed from Home, with an X and "I'm done" to leave
// by, until 26 September 2026. On a tab there is nothing to leave -- the tab
// bar is the way out -- so both doors went with the screen.
//
// **The toggle above it changes by a tap, never a swipe.** A sideways swipe
// is also a line being drawn, and a page that changed part in the middle of a
// stroke would be a screen fighting the reader's finger.
//
// **It used to be the picker's Wound up face, and that was wrong.** Kjærvik &
// Bushman's 2024 meta-analysis of anger management -- roughly 154 studies,
// around 10,000 people -- found that things which raise arousal (hitting,
// venting, jogging) do not reduce anger and sometimes increase it. "Scribble
// as hard as you like" was on the wrong side of that line, and that face now
// leads to `TightenView`.
//
// The sidekick is deliberately absent. Being watched while you make something
// is wrong even when the watching is kind.
class ScribbleSection extends StatelessWidget {
  const ScribbleSection({super.key});

  static const String label = 'Scribble';

  static const String promise = 'Draw whatever you like. It fades away.';

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(height: SkLayout.sm),

        // Full-bleed: the pad runs edge to edge, with no frame around it. A
        // box to stay inside is one more rule, and this part is for having
        // none. It stops above the tab bar, so no stroke is drawn under the
        // glass where it cannot be seen.
        Expanded(child: ScribblePad(color: sk.ink)),

        Padding(
          padding: EdgeInsets.fromLTRB(
            SkLayout.gutter(context),
            SkLayout.md,
            SkLayout.gutter(context),
            SkLayout.md + SkMainTabBar.heightOf(context),
          ),
          child: Text(
            promise,
            textAlign: TextAlign.center,
            style: SkText.caption.copyWith(
              color: SkContrast.captionOn(sk.canvas),
            ),
          ),
        ),
      ],
    );
  }
}
