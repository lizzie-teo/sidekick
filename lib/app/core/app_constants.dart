// Application-wide constants and enums.
//
// Route paths live here rather than in app_router.dart so that feature modules
// can reference them without importing the router (which imports every module).

abstract class Routes {
  // App-level routes
  static const String loading = '/loading';
  static const String error = '/error';

  // Feature routes
  // Each feature module owns its own paths, declared here to keep the full
  // route surface visible in one place.
  static const String home = '/';

  // Signed-out entry point
  static const String welcome = '/welcome';

  // Authentication
  static const String connect = '/connect';
  static const String verify = '/verify';

  // Design system
  static const String designSystem = '/design-system';

  // Reachable without a session. Everything else needs one.
  static const List<String> public = <String>[
    welcome,
    connect,
    verify,
    designSystem,
  ];
}

// Keys in the _configuration table. Every one of these rows is expected to
// exist -- see _supabase/migrations. A missing row degrades the screen that
// reads it rather than breaking it.
abstract class ConfigKeys {
  static const String otpResendCooldownSeconds = 'otp_resend_cooldown_seconds';
}

// How to read a _configuration.config_value, which is always stored as text.
// Part of the table's primary key, so it is asked for on every read.
enum ConfigurationDataType {
  integer,
  string,
}

// Lifecycle of a value held by the state layer.
//
// Application: survives for the life of the process, shared app-wide.
// Session: created on sign-in, destroyed on sign-out.
enum StateScope {
  application,
  session,
}
