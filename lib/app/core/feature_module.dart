import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

// The contract every feature implements.
//
// A feature is a folder under lib/features/ plus one entry in
// feature_registry.dart. It contributes its own services and its own routes,
// so the service locator and the router never need to know what features exist
// -- they iterate the registry instead of enumerating each feature by hand.
//
// To remove a feature: delete the folder, delete its line in the registry.
abstract class FeatureModule {
  const FeatureModule();

  // Identifier used in logs and as the namespace prefix for any state keys
  // this feature owns.
  String get name;

  // Register services this feature owns. Use registerLazySingleton or
  // registerFactory so that registration order between modules never matters.
  void registerServices(GetIt locator) {}

  // Routes contributed to the shell. Paths are declared in app_constants.dart.
  List<RouteBase> get routes => const <RouteBase>[];

  // Optional async work at startup, run after all services are registered.
  Future<void> onAppStart() async {}

  // Optional cleanup on sign-out, for features holding session-scoped state.
  Future<void> onSessionEnded() async {}
}
