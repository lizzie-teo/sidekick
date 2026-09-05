import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/feature_module.dart';
import 'package:sidekick/features/good_things/views/good_things_view.dart';

// The second tab. In the registry from phase 0 so the tab bar has a
// destination; the screen behind it is filled in during phase 1.
class GoodThingsModule extends FeatureModule {
  const GoodThingsModule();

  @override
  String get name => 'good_things';

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: Routes.goodThings,
          name: 'good_things',
          builder: (context, state) => const GoodThingsView(),
        ),
      ];
}
