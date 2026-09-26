import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_primary_button.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/app/widgets/sk_sheet_frame.dart';

// Why noticing good things helps, behind the info icon beside the caption.
//
// It used to sit on the form itself, under the boxes. It is read once and
// then only gets in the way: somebody on their fortieth entry does not need
// the reason again, and the form is the thing they came for.
class GoodThingsWhySheet extends StatelessWidget {
  const GoodThingsWhySheet({super.key});

  static Future<void> show(BuildContext context) {
    return SkSheetFrame.show<void>(
      context,
      useRootNavigator: false,
      barrierLabel: 'Close',
      builder: (BuildContext sheetContext) => const GoodThingsWhySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return SafeArea(
      top: false,
      // Scrolls, so the words and the button both survive 200% text on a
      // small phone.
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          SkLayout.xxl,
          SkLayout.xxl,
          SkLayout.xxl,
          SkLayout.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Semantics(
              header: true,
              child: Text(
                'Why this helps',
                style: SkText.cardTitle.copyWith(color: sk.ink),
              ),
            ),
            const SizedBox(height: SkLayout.md),
            // Says what the practice is for, in terms the user can check
            // against their own experience.
            //
            // **The middle sentence is building new paths in the brain, in
            // plain words** -- added 26 September 2026, at the user's request.
            // "Neural pathways" is not written out: `_docs/kind-writing-style.md`
            // rule 12 keeps the science in the repository and puts the plain
            // version of the same idea on screen. It claims practice gets
            // easier, which a reader can check for themselves, and nothing
            // about rewiring.
            //
            // Three paragraphs: what anxiety does, what practice does, and
            // that often beats perfectly.
            Text(
              'When you\'re anxious, your brain keeps looking for bad things. '
              'This gives it good things to find too.',
              style: SkText.rowLabel.copyWith(color: sk.ink),
            ),
            const SizedBox(height: SkLayout.paragraphGap),
            Text(
              'Your brain gets better at what it practises, so each '
              'positive thing you notice makes the next one a little easier '
              'to spot.',
              style: SkText.rowLabel.copyWith(color: sk.ink),
            ),
            const SizedBox(height: SkLayout.paragraphGap),
            Text(
              'Doing it often is what helps, not doing it perfectly.',
              style: SkText.rowLabel.copyWith(color: sk.ink),
            ),
            const SizedBox(height: SkLayout.xxl),
            SkPrimaryButton(
              label: 'Got it',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
