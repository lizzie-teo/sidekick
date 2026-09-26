import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/tab_page.dart';
import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/feature_module.dart';
import 'package:sidekick/features/practice/views/practice_view.dart';
import 'package:sidekick/features/practice/views/swap_drill_view.dart';

// Assertiveness practice: the sentence you say, out loud, to somebody who is
// pushing back. The whole brief is `_docs/briefs/assertiveness-practice.md`.
//
// **This is the half the app did not have.** The forty-four affirmation lines
// all answer a belief, and nineteen of them come straight from the rights
// handout. A right removes the reason not to speak. It does not supply the
// words, and somebody can agree they are allowed to say no while having no
// sentence ready when it is their turn.
//
// Built so far: Drill 0, "swap the sentence", which teaches the shape every
// later line is said in. Drill A (holding a line where nothing is at stake)
// and Drill B (holding one where something is) come next, then the seventeen
// remaining rights.
//
// **No services: nothing on these screens is saved**, so there is nothing to
// register. That is not an omission. A tally of how many drills somebody did
// turns a quiet week into a failed test, which is rule 15.
class PracticeModule extends FeatureModule {
  const PracticeModule();

  @override
  String get name => 'practice';

  @override
  List<RouteBase> get routes => <RouteBase>[
        // The tab itself: the two lists, behind a toggle. It owns the third
        // slot in the bar, which used to be Meditate and the wind icon.
        GoRoute(
          path: Routes.practice,
          name: 'practice',
          pageBuilder: (context, state) =>
              TabPage.forState(state, const PracticeView()),
        ),
        GoRoute(
          path: Routes.swapDrill,
          name: 'swap-drill',
          builder: (context, state) => const SwapDrillView(),
        ),
      ];
}
