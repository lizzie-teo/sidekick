import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/app/core/logger_service.dart';

// Whether anyone is signed in.
//
// This is an app-wide service holding a ValueNotifier, the shape described in
// CLAUDE.md: private notifier, read-only ValueListenable out. It is also the
// router's refreshListenable, so the redirect re-runs the moment a session
// appears or goes away.
//
// This is the only thing watching Supabase's auth stream. Views ask the router
// where they are, and the router asks this.
class AuthStateService {
  final LoggerService _loggerService;
  final SupabaseClient _supabaseClient;

  AuthStateService({
    required LoggerService loggerService,
    required SupabaseClient supabaseClient,
  })  : _loggerService = loggerService,
        _supabaseClient = supabaseClient;

  final ValueNotifier<bool> _isAuthenticated = ValueNotifier<bool>(false);

  ValueListenable<bool> get isAuthenticated => _isAuthenticated;

  StreamSubscription<AuthState>? _subscription;

  // Reads the restored session, then follows every change to it. Supabase
  // restores a persisted session before emitting its first event, so a
  // returning user is already authenticated by the time the router first runs.
  void initialize() {
    _isAuthenticated.value = _supabaseClient.auth.currentSession != null;

    _subscription = _supabaseClient.auth.onAuthStateChange.listen((authState) {
      final next = authState.session != null;
      if (next == _isAuthenticated.value) {
        return;
      }

      _loggerService.debug('AuthStateService: isAuthenticated $next');
      _isAuthenticated.value = next;
    });
  }

  void dispose() {
    _subscription?.cancel();
    _isAuthenticated.dispose();
  }
}
