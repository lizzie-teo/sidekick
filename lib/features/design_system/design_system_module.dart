import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/feature_module.dart';
import 'package:sidekick/features/design_system/views/design_system_view.dart';
import 'package:sidekick/features/design_system/views/shader_lab_view.dart';

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

        // **Debug builds only.** The shader lab is a workbench, not a screen:
        // it exists so the breathing halo can be tuned without spending a
        // lead-in and two counted breaths per look. kDebugMode is a const, so
        // the release build drops the route and tree-shakes the view with it.
        //
        // A flag on the view would not be enough -- the route would still
        // exist, and a deep link could reach it.
        if (kDebugMode)
          GoRoute(
            path: Routes.shaderLab,
            name: 'shader-lab',
            builder: (context, state) => const ShaderLabView(),
          ),
      ];
}
