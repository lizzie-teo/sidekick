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
  static const String goodThings = '/good-things';
  static const String meditate = '/meditate';
  static const String me = '/me';

  // The centre slot of the tab bar. It opens the feeling picker rather than
  // the breathing, because the sidekick reacts to the face that was picked,
  // so the pick has to happen first. Built in phase 4.
  static const String panic = '/panic';

  // The four tab destinations, in bar order. The panic button is the fifth
  // slot but is not a tab: it is a route the tabs sit behind, not beside.
  static const List<String> tabs = <String>[
    home,
    goodThings,
    meditate,
    me,
  ];

  // Signed-out entry point
  static const String welcome = '/welcome';

  // Authentication
  static const String connect = '/connect';
  static const String verify = '/verify';

  // Design system
  static const String designSystem = '/design-system';

  // Screens that exist to attach an email to the account. Someone who already
  // has one is bounced off them to home; anyone else may visit them freely.
  //
  // The test is "has an email", not "has a session". Every user has a session
  // from first open -- an anonymous one -- so a session-based test would make
  // these screens unreachable to the people who need them.
  static const List<String> authScreens = <String>[
    welcome,
    connect,
    verify,
  ];

  // Screens that need a session of any kind. Empty, and expected to stay that
  // way: the app signs in anonymously on first open, so there is no signed-out
  // state left to guard against. It remains as the hook for a screen that one
  // day needs a real account rather than any account.
  static const List<String> requiresSession = <String>[];
}

// Keys in device-local storage, read and written through DeviceSettingsService.
//
// Nothing here is worth a network round trip and nothing here is worth
// recovering onto a new phone. Anything the user would miss goes to the
// server instead.
abstract class SettingsKeys {
  // Index of the pairing shown on Home last time it opened, so the next open
  // can pick a different one.
  static const String lastHomePairing = 'last_home_pairing';
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
