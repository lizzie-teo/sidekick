import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/feature_module.dart';
import 'package:sidekick/features/good_things/models/good_things_arguments.dart';
import 'package:sidekick/features/good_things/views/good_things_history_view.dart';
import 'package:sidekick/features/good_things/views/good_things_view.dart';

// The second tab: three good things, and everything noticed so far.
//
// GoodThingsService is not registered here. It lives in lib/data/ and is
// registered in service_locator.dart, because the panic recap, the journal
// and Home all read or write it -- owning it from this feature would mean
// deleting this feature breaks three others.
class GoodThingsModule extends FeatureModule {
  const GoodThingsModule();

  @override
  String get name => 'good_things';

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: Routes.goodThings,
          name: 'good_things',
          builder: (context, state) => GoodThingsView(
            // A tab tap carries nothing; the three screens that lead here
            // with a line already in mind carry a GoodThingsArguments.
            arguments: GoodThingsArguments.of(state.extra),
          ),
          routes: <RouteBase>[
            GoRoute(
              // A child route, declared relative to its parent, so the full
              // path is Routes.goodThingsHistory.
              path: 'history',
              name: 'good_things_history',
              builder: (context, state) => const GoodThingsHistoryView(),
            ),
          ],
        ),
      ];
}
