import 'package:flutter/material.dart';

import 'package:sidekick/app/widgets/sk_colors.dart';
import 'package:sidekick/app/widgets/sk_outline_button.dart';
import 'package:sidekick/app/widgets/sk_text.dart';
import 'package:sidekick/features/dashboard/models/affirmation_explanations.dart';

// The line, explained.
//
// A sheet rather than a page, so the sidekick stays on screen behind it and
// closing puts the reader back exactly where they were, on the same line.
//
// Nothing is asked, nothing is answered, nothing is stored. Reading it is
// optional and always was: the line on the lock screen is the whole message on
// its own, and somebody who never opens this has missed nothing. It is for the
// evening where a line arrives and the reader thinks "is that actually true?".
//
// Three parts, in this order, and the order is the argument:
//
//   1. The rule you were given -- the belief the line is answering. Eight
//      sheets say "What it sounds like" instead: they answer the shape a
//      thought takes rather than a rule about behaviour, so they open with
//      the thought itself, quoted.
//   2. Why it does not hold -- one reason.
//   3. Closer to the truth -- the line again, plainly. Not "what is true
//      instead": most of these are about nuance rather than swapping one
//      certainty for another, and a heading claiming the last word undoes
//      the sheet that earned it.
//
// Part one is the reason this works at all. A right on its own is an
// assertion; a right beside the rule it replaces is an argument, and you
// cannot put down a belief you cannot see. It is also the half that
// `_docs/briefs/affirmation-lines.md` forbids on a lock screen, and the
// difference is consent -- the reader tapped to get here, and the belief is
// named in order to be answered two paragraphs later.
class AffirmationSheet extends StatelessWidget {
  final String line;
  final AffirmationExplanation explanation;

  const AffirmationSheet({
    super.key,
    required this.line,
    required this.explanation,
  });

  // Opens the sheet for a line, and does nothing at all for a line with no
  // explanation written for it.
  //
  // Silence rather than an empty sheet: every line in the set has one today,
  // so this only fires if the two files fall out of step, and an empty sheet
  // is a worse answer to that than no sheet.
  static Future<void> show(BuildContext context, String line) {
    final AffirmationExplanation? explanation =
        AffirmationExplanations.forLine(line);

    if (explanation == null) return Future<void>.value();

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      // The root navigator, so the sheet covers the floating tab bar as well
      // as the page. Shown on the shell's inner navigator it would sit inside
      // a box that is not the screen, and the Close button lands below the
      // fold on a short phone.
      useRootNavigator: true,
      backgroundColor: context.sk.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (BuildContext sheetContext) =>
          AffirmationSheet(line: line, explanation: explanation),
    );
  }

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return SafeArea(
      top: false,
      // Never more than three quarters of the space the sheet is offered, so
      // the sidekick stays visible above it. The reader should be able to see
      // what they are coming back to.
      //
      // Measured from the incoming constraints rather than from
      // MediaQuery.sizeOf. A bottom sheet is already handed the screen height
      // as its maximum, and a MediaQuery that reports something else -- an
      // ancestor that supplied a bare MediaQueryData, which is exactly what
      // the test harness does -- would hand this a cap of zero and push the
      // Close button off the bottom.
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double cap = constraints.maxHeight.isFinite
              ? constraints.maxHeight * 0.75
              : double.infinity;

          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: cap),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // A grab handle, because the sheet can be dragged away as well
                  // as closed. Two ways out, and neither one is framed as giving
                  // up.
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: sk.chevron,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // The family this line belongs to, so the reader can see
                  // what kind of thing they have opened before they read it.
                  // Plain English, never the name of the technique behind it.
                  Text(
                    explanation.category,
                    style: SkText.sectionHeader.copyWith(color: sk.muted),
                  ),

                  const SizedBox(height: 6),

                  // The line itself, because it is what the reader tapped and
                  // it has to still be there when the sheet opens.
                  Text(line, style: SkText.cardTitle.copyWith(color: sk.ink)),

                  const SizedBox(height: 20),

                  // Long writing scrolls inside the sheet rather than growing it,
                  // so the sidekick behind never gets pushed off.
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          _Part(
                            // "The rule you were given", or "What it sounds
                            // like" for a line that answers the shape of a
                            // thought rather than a belief about behaviour.
                            heading: explanation.ruleHeading,
                            body: explanation.rule,
                          ),
                          _Part(
                            heading: 'Why it does not hold',
                            body: explanation.why,
                          ),
                          _Part(
                            heading: 'Closer to the truth',
                            body: explanation.truth,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // "Close", not "Got it" or "Done". Neither of those is true --
                  // nothing was completed here and nothing has to have landed.
                  SkOutlineButton(
                    label: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Part extends StatelessWidget {
  final String heading;
  final String body;

  const _Part({required this.heading, required this.body});

  @override
  Widget build(BuildContext context) {
    final SkColors sk = context.sk;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            heading,
            style: SkText.sectionHeader.copyWith(color: sk.muted),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: SkText.rowLabel.copyWith(color: sk.ink, height: 1.5),
          ),
        ],
      ),
    );
  }
}
