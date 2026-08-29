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

  // Reachable without a session. Everything else needs one.
  static const List<String> public = <String>[welcome, connect, verify];
}

// Lifecycle of a value held by the state layer.
//
// Application: survives for the life of the process, shared app-wide.
// Session: created on sign-in, destroyed on sign-out.
enum StateScope {
  application,
  session,
}
