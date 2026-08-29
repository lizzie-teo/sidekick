import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/feature_module.dart';
import 'package:sidekick/features/_template/views/template_view.dart';

// Copy this file alongside the folder when creating a new feature, then add
// the module to feature_registry.dart.
class TemplateModule extends FeatureModule {
  const TemplateModule();

  @override
  String get name => 'template';

  @override
  void registerServices(GetIt locator) {
    // Services owned by this feature are registered here, for example:
    // locator.registerLazySingleton<ThingService>(
    //   () => ThingService(loggerService: locator<LoggerService>()),
    // );
  }

  @override
  List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: Routes.home,
          name: 'home',
          builder: (context, state) => const TemplateView(),
        ),
      ];
}
