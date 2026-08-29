import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/app/core/logger_service.dart';

// Thin wrapper over Supabase auth, so viewmodels depend on this rather than
// reaching for Supabase.instance directly and becoming untestable.
class AuthService {
  final LoggerService _loggerService;
  final SupabaseClient _supabaseClient;

  AuthService({
    required LoggerService loggerService,
    required SupabaseClient supabaseClient,
  })  : _loggerService = loggerService,
        _supabaseClient = supabaseClient;

  // Email the user a one-time code. Also used to resend one.
  Future<void> signInWithOtp(String email) {
    _loggerService.debug('AuthService: signInWithOtp');
    return _supabaseClient.auth.signInWithOtp(email: email);
  }

  // Exchange an emailed code for a session.
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) {
    _loggerService.debug('AuthService: verifyOtp');
    return _supabaseClient.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  Session? get currentSession => _supabaseClient.auth.currentSession;

  User? get currentUser => _supabaseClient.auth.currentUser;

  String? getUserId() => currentUser?.id;

  String? getUserEmail() => currentUser?.email;

  // The current user id, throwing if there is none. Only call this behind the
  // auth gate, where a missing session is a bug rather than a state to handle.
  String requireUserId() {
    final userId = getUserId();
    if (userId == null) {
      throw StateError(
        'No authenticated user - this should never happen behind the auth gate',
      );
    }
    return userId;
  }

  Future<void> signOut() {
    _loggerService.debug('AuthService: signOut');
    return _supabaseClient.auth.signOut();
  }
}
