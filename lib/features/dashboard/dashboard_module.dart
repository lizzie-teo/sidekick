import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/feature_module.dart';
import 'package:sidekick/features/dashboard/views/dashboard_view.dart';

// The authenticated destination. It owns Routes.home because that is where the
// redirect sends anyone with a session -- there is no separate /dashboard path
// to keep in step with the guard.
class DashboardModule extends FeatureModule {
  const DashboardModule();

  @override
  String get name => 'dashboard';

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: Routes.home,
          name: 'dashboard',
          builder: (context, state) => const DashboardView(),
        ),
      ];
}
