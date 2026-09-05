import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/feature_module.dart';
import 'package:sidekick/features/meditate/views/meditate_view.dart';

// The third tab, and the MVP feature. In the registry from phase 0 so the tab
// bar has a destination; the Breath session is built in phase 2.
class MeditateModule extends FeatureModule {
  const MeditateModule();

  @override
  String get name => 'meditate';

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: Routes.meditate,
          name: 'meditate',
          builder: (context, state) => const MeditateView(),
        ),
      ];
}
