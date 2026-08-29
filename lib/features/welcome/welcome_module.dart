import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/feature_module.dart';
import 'package:sidekick/features/welcome/views/welcome_view.dart';

// Where a signed-out user lands. Leads into the authentication feature but is
// not part of it: this screen is the app introducing itself, and it will grow
// branding and copy that has nothing to do with signing in.
class WelcomeModule extends FeatureModule {
  const WelcomeModule();

  @override
  String get name => 'welcome';

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: Routes.welcome,
          name: 'welcome',
          builder: (context, state) => const WelcomeView(),
        ),
      ];
}
