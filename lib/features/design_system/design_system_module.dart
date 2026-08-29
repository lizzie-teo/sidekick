import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/feature_module.dart';
import 'package:sidekick/features/design_system/views/design_system_view.dart';

// The catalogue of what the app looks like: colour roles, type scale, buttons,
// inputs and the message styles the feature screens use.
//
// It owns no services and no session state, so the module contributes routes
// and nothing else. The route is public because it is reachable from the
// welcome screen, which is where a signed-out user lands.
class DesignSystemModule extends FeatureModule {
  const DesignSystemModule();

  @override
  String get name => 'design_system';

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: Routes.designSystem,
          name: 'design-system',
          builder: (context, state) => const DesignSystemView(),
        ),
      ];
}
