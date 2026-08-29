import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/feature_module.dart';
import 'package:sidekick/features/authentication/views/connect_view.dart';
import 'package:sidekick/features/authentication/views/verify_view.dart';

// Sign-in by emailed one-time code.
//
// AuthService and AuthStateService are registered in service_locator.dart
// rather than here: the router depends on AuthStateService, so it has to exist
// whether or not this feature is in the registry.
class AuthenticationModule extends FeatureModule {
  const AuthenticationModule();

  @override
  String get name => 'authentication';

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: Routes.connect,
          name: 'connect',
          builder: (context, state) => const ConnectView(),
        ),
        GoRoute(
          path: Routes.verify,
          name: 'verify',
          builder: (context, state) => VerifyView(
            email: state.uri.queryParameters['email'] ?? '',
          ),
        ),
      ];
}
