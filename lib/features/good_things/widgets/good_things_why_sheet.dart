import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_layout.dart';
import 'package:sidekick/app/widgets/sk_primary_button.dart';
import 'package:sidekick/app/widgets/sk_text.dart';

// Why noticing good things helps, behind the info icon beside the title.
//
// It used to sit on the form itself, under the boxes. It is read once and
// then only gets in the way: somebody on their fortieth entry does not need
// the reason again, and the form is the thing they came for.
class GoodThingsWhySheet extends StatelessWidget {
  const GoodThingsWhySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.sk.canvas,
      barrierLabel: 'Close',
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
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
            // against their own experience. It does not claim to rewire
            // anything.
            Text(
              'When you\'re anxious, your brain keeps looking for bad things. '
              'This gives it good things to find too. Doing it often is what '
              'helps, not doing it perfectly.',
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
