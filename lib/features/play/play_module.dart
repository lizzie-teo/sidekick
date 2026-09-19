import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/feature_module.dart';
import 'package:sidekick/features/play/views/scribble_view.dart';
import 'package:sidekick/features/play/views/tighten_view.dart';

// The three faces that are not panic, phase 5 of the build plan. Each one is
// allowed to end in nothing.
//
// Built so far: Wound up (5.1), "Tighten, and stop". Low (5.2) and Actually
// okay (5.3) land here beside it.
//
// **"Play" means two things in this app and this module holds both.** The
// folder is named for the three non-panic faces on the picker. The soft
// button on Home also says "Play", and since 19 September 2026 it means the
// scribble pad. Two meanings, one word. Flagged rather than fixed -- a rename
// touches the registry, the routes and every test, and buys nothing a comment
// does not.
//
// The pad is not a feeling any more. Anger research puts a hard, fast scribble
// on the arousal-raising side of the line, so the Wound up face leads to the
// muscle script instead, and the pad is reached from Home by somebody who is
// not angry. See `_docs/briefs/wound-up-tighten-and-stop.md`.
//
// No services: nothing on these screens is saved, so there is nothing to
// register.
class PlayModule extends FeatureModule {
  const PlayModule();

  @override
  String get name => 'play';

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: Routes.tighten,
          name: 'tighten',
          builder: (context, state) => const TightenView(),
        ),
        GoRoute(
          path: Routes.scribble,
          name: 'scribble',
          builder: (context, state) => const ScribbleView(),
        ),
      ];
}
