import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/auth_state_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/data/models/entities/configuration_model.dart';
import 'package:sidekick/data/services/configuration_service.dart';

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
  String? getUserEmail() => userEmail;

  @override
  String requireUserId() => 'user-1';

  // Settable so a test can stand in a different address, or none at all.
  String? userEmail = 'someone@example.com';

  bool signedOut = false;
  Object? signOutError;

  @override
  Future<void> signOut() async {
    if (signOutError != null) {
      throw signOutError!;
    }
    signedOut = true;
  }
}

// Serves whatever is put in values, keyed by config_key. An absent key reads
// back as null, the same as a row that was never inserted. Set readError to
// make the read throw instead.
class FakeConfigurationService implements ConfigurationService {
  final Map<String, String> values = <String, String>{};
  final List<String> keysRead = <String>[];

  Object? readError;

  @override
  Future<ConfigurationModel?> getConfiguration(
    String configKey,
    ConfigurationDataType dataType,
  ) async {
    keysRead.add(configKey);

    if (readError != null) {
      throw readError!;
    }

    final value = values[configKey];
    if (value == null) {
      return null;
    }

    return ConfigurationModel(
      configKey: configKey,
      configValue: value,
      dataType: dataType,
    );
  }
}

// Stands in for the real thing so a widget test can drive the router's
// redirect: setAuthenticated() is what a session appearing or disappearing
// looks like from the router's side.
class FakeAuthStateService implements AuthStateService {
  FakeAuthStateService({bool isAuthenticated = false})
      : _isAuthenticated = ValueNotifier<bool>(isAuthenticated);

  final ValueNotifier<bool> _isAuthenticated;

  @override
  ValueListenable<bool> get isAuthenticated => _isAuthenticated;

  void setAuthenticated(bool value) => _isAuthenticated.value = value;

  @override
  void initialize() {}

  @override
  void dispose() => _isAuthenticated.dispose();
}
