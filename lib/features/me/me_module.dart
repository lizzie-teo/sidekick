import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/feature_module.dart';
import 'package:sidekick/features/me/views/me_view.dart';

// The Me tab: the sidekick's profile, the panic and daily settings, and the
// account actions -- including sign-out, which is why the route is guarded.
class MeModule extends FeatureModule {
  const MeModule();

  @override
  String get name => 'me';

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: Routes.me,
          name: 'me',
          builder: (context, state) => const MeView(),
        ),
      ];
}
