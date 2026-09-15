import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/feature_module.dart';
import 'package:sidekick/features/play/views/scribble_view.dart';

// The three faces that are not panic, reached from the feeling picker. Each
// one is allowed to end in nothing.
//
// So far it holds Wound up -- the scribble pad. Low and Actually okay land
// here too as phase 5 goes on.
//
// No services: nothing in Play saves anything, and that is the feature's
// point rather than a gap.
class PlayModule extends FeatureModule {
  const PlayModule();

  @override
  String get name => 'play';

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: Routes.scribble,
          name: 'scribble',
          builder: (context, state) => const ScribbleView(),
        ),
      ];
}
