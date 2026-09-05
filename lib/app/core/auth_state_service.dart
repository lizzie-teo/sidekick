import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/logger_service.dart';

// Two facts about the current user, kept apart on purpose.
//
// isAuthenticated -- there is a session. True for everyone from first open,
// because the app signs in anonymously. Almost nothing should ask this.
//
// hasAccount -- there is an email on the account, so it can be recovered on a
// new phone. This is what "signed in" means to the user, and what the account
// screens and the Me tab hang off.
//
// Collapsing the two would break both ends: a session test makes /connect
// unreachable, and an email test would let a screen run with no session.
//
// This is an app-wide service holding ValueNotifiers, the shape described in
// CLAUDE.md: private notifier, read-only ValueListenable out. isAuthenticated
// is also the router's refreshListenable, so the redirect re-runs the moment
// a session appears or goes away.
//
// This is the only thing watching Supabase's auth stream. Views ask the router
// where they are, and the router asks this.
class AuthStateService {
  final LoggerService _loggerService;
  final SupabaseClient _supabaseClient;
  final Future<void> Function()? _onSessionEnded;

  AuthStateService({
    required LoggerService loggerService,
    required SupabaseClient supabaseClient,
    Future<void> Function()? onSessionEnded,
  })  : _loggerService = loggerService,
        _supabaseClient = supabaseClient,
        _onSessionEnded = onSessionEnded;

  final ValueNotifier<bool> _isAuthenticated = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _hasAccount = ValueNotifier<bool>(false);

  ValueListenable<bool> get isAuthenticated => _isAuthenticated;

  ValueListenable<bool> get hasAccount => _hasAccount;

  // Both facts as one listenable, for the router's refreshListenable.
  //
  // It must be both. The redirect reads hasAccount as well as isAuthenticated,
  // and verifying a code changes only hasAccount -- everyone already has a
  // session, so isAuthenticated never moves. Listening to that one alone left
  // the router unaware that the account had arrived, so a user who entered a
  // correct code sat on the verify screen watching nothing happen, pressed
  // Verify again, and was told the code had expired. It had: they had just
  // spent it.
  late final Listenable changes =
      Listenable.merge(<Listenable>[_isAuthenticated, _hasAccount]);

  StreamSubscription<AuthState>? _subscription;

  // Reads the restored session, then follows every change to it. Supabase
  // restores a persisted session before emitting its first event, so a
  // returning user is already authenticated by the time the router first runs.
  void initialize() {
    _apply(_supabaseClient.auth.currentSession);

    _subscription = _supabaseClient.auth.onAuthStateChange.listen((authState) {
      final bool wasAuthenticated = _isAuthenticated.value;

      _apply(authState.session);

      // Every way a session can end arrives here -- the sign-out button, an
      // expired refresh token, a sign-out on another device -- so this is the
      // one place session-scoped state can be reset from. Deliberately after
      // the notifiers are updated, so the redirect has already moved the user
      // off the screens that were reading them.
      //
      // The callback is passed in rather than reached for: this service knows
      // nothing about features, and service_locator.dart is where the registry
      // is already iterated.
      if (wasAuthenticated && !_isAuthenticated.value) {
        _endSession();
      }
    });
  }

  // The session decides both notifiers. Assigning an unchanged value to a
  // ValueNotifier notifies nobody, so there is nothing to guard here: a token
  // refresh that changes neither fact rebuilds nothing.
  void _apply(Session? session) {
    final User? user = session?.user;
    final bool authenticated = session != null;
    // The shared rule, not a second copy of it. This service and AuthService
    // must agree, and when each kept its own version they stopped agreeing.
    final bool account = userHasAccount(user);

    if (authenticated != _isAuthenticated.value ||
        account != _hasAccount.value) {
      _loggerService.debug(
        'AuthStateService: isAuthenticated $authenticated, '
        'hasAccount $account',
      );
    }

    _isAuthenticated.value = authenticated;
    _hasAccount.value = account;
  }

  // Fire and forget: nothing waits on cleanup, and a feature that throws while
  // resetting must not stop the others or leave the app wedged mid-sign-out.
  Future<void> _endSession() async {
    try {
      await _onSessionEnded?.call();
    } catch (e, s) {
      _loggerService.errorShort(e, s);
    }
  }

  void dispose() {
    _subscription?.cancel();
    _isAuthenticated.dispose();
    _hasAccount.dispose();
  }
}
