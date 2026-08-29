import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/logger_service.dart';

// The fakes `implements` rather than `extends` the real services, so no
// SupabaseClient is constructed -- a real one starts a token refresh timer that
// outlives the test and trips the pending-timer assertion.

class SilentLoggerService implements LoggerService {
  @override
  void debug(String message) {}

  @override
  void info(String message) {}

  @override
  void warning(String message) {}

  @override
  void error(String message, [Object? e, StackTrace? s]) {}

  @override
  void errorShort(Object e, [StackTrace? s]) {}
}

// Every auth call succeeds. Set signInError or verifyError to make one fail.
class FakeAuthService implements AuthService {
  final List<String> otpSentTo = <String>[];
  final List<String> tokensVerified = <String>[];

  Object? signInError;
  Object? verifyError;

  @override
  Future<void> signInWithOtp(String email) async {
    if (signInError != null) {
      throw signInError!;
    }
    otpSentTo.add(email);
  }

  @override
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    if (verifyError != null) {
      throw verifyError!;
    }
    tokensVerified.add(token);
    return AuthResponse();
  }

  @override
  Session? get currentSession => null;

  @override
  User? get currentUser => null;

  @override
  String? getUserId() => 'user-1';

  @override
  String? getUserEmail() => 'someone@example.com';

  @override
  String requireUserId() => 'user-1';

  @override
  Future<void> signOut() async {}
}
