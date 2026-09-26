import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import 'package:sidekick/app/models/guided_intro.dart';
import 'package:sidekick/app/models/tab_section.dart';

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

  // Routes of this feature that the feeling picker opens through an
  // introduction sheet rather than directly, keyed by path. The screen behind
  // each one starts running the moment it is pushed; the sheet is where the
  // reader decides. See `guidedIntroFor`.
  Map<String, GuidedIntro> get guidedIntros => const <String, GuidedIntro>{};

  // Parts this feature adds to another feature's tab, keyed by that tab's
  // route. The tab shows them behind its toggle. See `tabSectionsFor`.
  Map<String, List<TabSection>> get tabSections =>
      const <String, List<TabSection>>{};

  // Optional async work at startup, run after all services are registered.
  Future<void> onAppStart() async {}

  // Optional cleanup on sign-out, for features holding session-scoped state.
  Future<void> onSessionEnded() async {}
}
