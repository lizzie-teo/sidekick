import 'package:sidekick/app/core/feature_module.dart';
import 'package:sidekick/features/authentication/authentication_module.dart';
import 'package:sidekick/features/dashboard/dashboard_module.dart';
import 'package:sidekick/features/welcome/welcome_module.dart';

// The single list of features in the application.
//
// This is the only file that changes when a feature is added or removed.
// Both the service locator and the router read from it.
//
// lib/features/_template/ is deliberately absent: it is the scaffold to copy,
// not a feature. Adding it back would put a second route on '/'.
const List<FeatureModule> featureModules = <FeatureModule>[
  WelcomeModule(),
  AuthenticationModule(),
  DashboardModule(),
];
