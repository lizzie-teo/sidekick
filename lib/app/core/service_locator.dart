import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/app_router.dart';
import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/auth_state_service.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/event_bus.dart';
import 'package:sidekick/app/core/feature_registry.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/app/core/notification_service.dart';
import 'package:sidekick/app/core/theme_service.dart';
import 'package:sidekick/data/services/configuration_service.dart';
import 'package:sidekick/data/services/good_things_service.dart';

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

  getIt.registerLazySingleton<DeviceSettingsService>(
    () => DeviceSettingsService(loggerService: getIt<LoggerService>()),
  );

  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(
      loggerService: getIt<LoggerService>(),
      deviceSettingsService: getIt<DeviceSettingsService>(),
    ),
  );

  getIt.registerLazySingleton<ThemeService>(
    () => ThemeService(deviceSettingsService: getIt<DeviceSettingsService>()),
  );

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
      // Signing out is the end of the session, so it is what runs the
      // features' session-scoped cleanup.
      onSessionEnded: () async {
        for (final module in featureModules) {
          await module.onSessionEnded();
        }

        // The session ending does not mean the app is now signed out: it
        // means the account the user was on is no longer theirs to write to.
        // A fresh anonymous one puts them back where a first-time user
        // stands, so Good things still saves and nothing on screen is
        // half-working.
        await getIt<AuthService>().ensureSession();
      },
    ),
  );

  // Data services
  getIt.registerLazySingleton<ConfigurationService>(
    () => ConfigurationService(
      loggerService: getIt<LoggerService>(),
      supabaseClient: getIt<SupabaseClient>(),
    ),
  );

  getIt.registerLazySingleton<GoodThingsService>(
    () => GoodThingsService(
      loggerService: getIt<LoggerService>(),
      supabaseClient: getIt<SupabaseClient>(),
      authService: getIt<AuthService>(),
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

  // Awaited, unlike ensureSession below: these are local reads, so the cost
  // is a few ms, and the win is that the first frame is already in the
  // user's chosen appearance rather than flashing the default and swapping.
  await getIt<ThemeService>().initialize();

  // Awaited for the same reason -- local reads, and the Me tab's reminder rows
  // would otherwise show the defaults for a frame and then swap.
  //
  // This also tops the booked run of alerts back up to a fortnight, which is
  // why it is on every open rather than only the first: a notification's
  // words are fixed when it is booked, so the run has to be laid down again
  // to stay ahead of the reader.
  await getIt<NotificationService>().initialize();

  // Awaited for the same reason: a local read, and the Me tab's day count is
  // wrong for the life of the install if the stamp is skipped on the one open
  // that should have written it.
  await _stampFirstOpen();

  // Everyone gets a session on first open, so there is never a state where the
  // app is running without somewhere to save to.
  //
  // Deliberately not awaited. It is a network call, and blocking the first
  // frame on it would mean a slow or absent connection holds the app on a
  // blank screen. Nothing is gated on the session, so the app opens either
  // way, and ensureSession() is safe to call again from the first save.
  unawaited(getIt<AuthService>().ensureSession());

  for (final module in featureModules) {
    await module.onAppStart();
  }

  getIt<LoggerService>().debug(
    'ServiceLocator: ready with ${featureModules.length} feature module(s)',
  );
}

// Writes the day this install was first opened, once, and never again.
//
// Read-then-write rather than a plain write: the value has to be the first
// open, not the latest one. A failed read returns null, which stamps today
// and restarts the count -- the lesser harm, since the alternative is a write
// on every open, which resets it every time.
Future<void> _stampFirstOpen() async {
  final DeviceSettingsService settings = getIt<DeviceSettingsService>();

  final String? stamped = await settings.getString(SettingsKeys.firstOpenedAt);
  if (stamped != null) return;

  await settings.setString(
    SettingsKeys.firstOpenedAt,
    DateTime.now().toIso8601String(),
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
