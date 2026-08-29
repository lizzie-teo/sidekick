import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/app/core/app_router.dart';
import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/auth_state_service.dart';
import 'package:sidekick/app/core/event_bus.dart';
import 'package:sidekick/app/core/feature_registry.dart';
import 'package:sidekick/app/core/logger_service.dart';

final GetIt getIt = GetIt.instance;

// Registers every service in the application.
//
// Everything is registered lazily, so declaration order here is NOT
// significant -- a dependency is constructed the first time it is resolved,
// not the moment it is registered. Anything needing async setup gets an
// explicit initialise() call in the second phase below.
Future<void> setupServiceLocator() async {
  // Core services
  getIt.registerLazySingleton<LoggerService>(() => LoggerService());
  getIt.registerLazySingleton<EventBus>(() => EventBus());

  // Supabase. Supabase.initialize() must already have run in main().
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  getIt.registerLazySingleton<AuthService>(
    () => AuthService(
      loggerService: getIt<LoggerService>(),
      supabaseClient: getIt<SupabaseClient>(),
    ),
  );

  getIt.registerLazySingleton<AuthStateService>(
    () => AuthStateService(
      loggerService: getIt<LoggerService>(),
      supabaseClient: getIt<SupabaseClient>(),
    ),
  );

  // Feature services
  for (final module in featureModules) {
    module.registerServices(getIt);
  }

  // Router, built from the routes the modules contributed
  getIt.registerLazySingleton<GoRouter>(
    () => AppRouter.create(
      loggerService: getIt<LoggerService>(),
      authStateService: getIt<AuthStateService>(),
    ),
  );

  // Second phase: async initialisation, once everything is resolvable.
  //
  // AuthStateService must be listening before the router is first built, so a
  // returning user is already authenticated when the redirect first runs.
  getIt<AuthStateService>().initialize();

  for (final module in featureModules) {
    await module.onAppStart();
  }

  getIt<LoggerService>().debug(
    'ServiceLocator: ready with ${featureModules.length} feature module(s)',
  );
}

// Tears down services holding streams or subscriptions. Called when the app
// is detached.
Future<void> disposeServices() async {
  if (getIt.isRegistered<AuthStateService>()) {
    getIt<AuthStateService>().dispose();
  }

  if (getIt.isRegistered<EventBus>()) {
    getIt<EventBus>().dispose();
  }

  await getIt.reset();
}

// Used by tests to start from a clean container.
Future<void> resetServiceLocator() async {
  await getIt.reset();
}
