import 'package:sidekick/app/core/feature_registry.dart';
import 'package:sidekick/app/models/guided_intro.dart';

// The introduction a route opens behind, or null for a route that opens
// directly.
//
// It walks the registry the way the router and the service locator do, so
// the picker can put a feature's introduction in front of its screen without
// importing that feature. A feature that is removed takes its introductions
// with it.
GuidedIntro? guidedIntroFor(String route) {
  for (final module in featureModules) {
    final GuidedIntro? intro = module.guidedIntros[route];
    if (intro != null) return intro;
  }
  return null;
}
