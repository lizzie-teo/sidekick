import 'package:sidekick/app/core/feature_module.dart';
import 'package:sidekick/features/_template/template_module.dart';
import 'package:sidekick/features/authentication/authentication_module.dart';
import 'package:sidekick/features/welcome/welcome_module.dart';

// The single list of features in the application.
//
// This is the only file that changes when a feature is added or removed.
// Both the service locator and the router read from it.
const List<FeatureModule> featureModules = <FeatureModule>[
  WelcomeModule(),
  AuthenticationModule(),

  // _template is the scaffold, wired up so the skeleton runs end to end.
  // Copy the folder to create a real feature, then delete this entry.
  TemplateModule(),
];
