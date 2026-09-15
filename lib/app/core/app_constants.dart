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

  // The long view, reached from Good things rather than from the tab bar.
  // A child path so the back arrow returns to the entry form, which is where
  // everyone arrives from.
  static const String goodThingsHistory = '/good-things/history';
  static const String meditate = '/meditate';
  static const String me = '/me';

  // The feeling picker. Reached from the Home CTA, which is the unhurried
  // door: someone tapping "Tap me" has room for a question.
  // The centre slot of the tab bar deliberately does not come here.
  static const String panic = '/panic';

  // The guided breathing, and what the panic button in the tab bar opens
  // directly. A child path of the picker because that is still one way in,
  // but not the only one -- a back gesture from here lands wherever the user
  // came from, which is the point of pushing it.
  static const String breathe = '/panic/breathe';

  // "What's happening in your body?" -- its own screen, reached from the
  // picker's "Can't cope right now" and from nowhere else. It explains the
  // sensation that was picked and then hands over to the breathing.
  //
  // The tab-bar panic button never comes here. It is pressed instead of
  // waiting, and a question in front of relief is a gate.
  static const String body = '/panic/body';

  // Which sensation was picked on the body screen, carried to the breathing
  // as `?sensation=<Sensation.name>`. The script's opening then explains that
  // sensation instead of the general words.
  //
  // A query parameter rather than `extra` so the pick survives a restored
  // route; the plain path -- no parameter, or one that names nothing -- is
  // the general script, which is the safer thing to land on by accident.
  static const String sensationQuery = 'sensation';

  // Wound up -- scribble it out. Reached from the picker's Wound up face,
  // pushed so that leaving lands back on the picker. Nothing drawn on it is
  // ever saved, which is the point of the screen.
  static const String scribble = '/play/scribble';

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

  // Whether the offer of an account has been made and answered. It is made
  // once, after the first save, and a No is final -- so this records "asked",
  // not "accepted". The standing door is the Me tab, which shows "Create an
  // account" for as long as there is no email, and that is not gated on this.
  static const String accountOfferAnswered = 'account_offer_answered';
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
