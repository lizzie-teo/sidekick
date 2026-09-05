import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/auth_service.dart';
import 'package:sidekick/app/core/auth_state_service.dart';
import 'package:sidekick/app/core/device_settings_service.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/data/models/entities/configuration_model.dart';
import 'package:sidekick/data/models/entities/good_thing_model.dart';
import 'package:sidekick/data/services/configuration_service.dart';
import 'package:sidekick/data/services/good_things_service.dart';

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

  // How many anonymous accounts were created. ensureSession() is expected to
  // be idempotent, so a test can assert this stays at one.
  int anonymousSignIns = 0;

  @override
  Future<AuthResponse> signInAnonymously() async {
    if (signInError != null) {
      throw signInError!;
    }
    anonymousSignIns++;
    hasSession = true;
    return AuthResponse();
  }

  @override
  Future<void> ensureSession() async {
    if (hasSession) return;
    await signInAnonymously();
  }

  // Settable, so a test can start from a first open (false) or a returning
  // user (true).
  bool hasSession = true;

  @override
  bool get isAnonymous => hasSession && userEmail == null;

  // An address that has been typed but not confirmed is not an account. Set
  // emailConfirmed false to stand mid-attach: between pressing Send and
  // entering the code.
  bool emailConfirmed = true;

  @override
  bool get hasAccount =>
      hasSession && (userEmail?.isNotEmpty ?? false) && emailConfirmed;

  @override
  String? get pendingEmail =>
      emailConfirmed || (userEmail?.isEmpty ?? true) ? null : userEmail;

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
  FakeAuthStateService({
    bool isAuthenticated = false,
    bool hasAccount = false,
  })  : _isAuthenticated = ValueNotifier<bool>(isAuthenticated),
        _hasAccount = ValueNotifier<bool>(hasAccount);

  final ValueNotifier<bool> _isAuthenticated;
  final ValueNotifier<bool> _hasAccount;

  @override
  ValueListenable<bool> get isAuthenticated => _isAuthenticated;

  @override
  ValueListenable<bool> get hasAccount => _hasAccount;

  @override
  late final Listenable changes =
      Listenable.merge(<Listenable>[_isAuthenticated, _hasAccount]);

  void setAuthenticated(bool value) => _isAuthenticated.value = value;

  void setHasAccount(bool value) => _hasAccount.value = value;

  @override
  void initialize() {}

  @override
  void dispose() {
    _isAuthenticated.dispose();
    _hasAccount.dispose();
  }
}

// Device settings held in a map, so nothing touches the platform channel that
// shared_preferences would otherwise need. Empty is a first open.
class FakeDeviceSettingsService implements DeviceSettingsService {
  final Map<String, Object> values = <String, Object>{};

  @override
  Future<int?> getInt(String key) async => values[key] as int?;

  @override
  Future<bool?> getBool(String key) async => values[key] as bool?;

  @override
  Future<String?> getString(String key) async => values[key] as String?;

  @override
  Future<void> setInt(String key, int value) async => values[key] = value;

  @override
  Future<void> setBool(String key, bool value) async => values[key] = value;

  @override
  Future<void> setString(String key, String value) async => values[key] = value;

  @override
  Future<void> remove(String key) async => values.remove(key);
}

// Holds entries in a list instead of a table. save() stamps them with a
// created_at the test can control, so "a year ago today" and month browsing
// can be exercised without waiting a year.
class FakeGoodThingsService implements GoodThingsService {
  final List<GoodThingModel> entries = <GoodThingModel>[];

  // What each save is dated. Left null, rows are stamped with now.
  DateTime? saveAt;

  Object? saveError;
  Object? readError;

  int reads = 0;

  int _nextId = 1;

  @override
  Future<List<GoodThingModel>> save(List<String> lines) async {
    final List<String> kept = lines
        .map((String line) => line.trim())
        .where((String line) => line.isNotEmpty)
        .toList();

    if (kept.isEmpty) {
      return const <GoodThingModel>[];
    }

    if (saveError != null) {
      throw saveError!;
    }

    final List<GoodThingModel> saved = kept
        .map((String line) => GoodThingModel(
              id: 'entry-${_nextId++}',
              userId: 'user-1',
              entry: line,
              createdAt: saveAt ?? DateTime.now(),
            ))
        .toList();

    entries.addAll(saved);

    return saved;
  }

  @override
  Future<List<GoodThingModel>> getEntriesBetween({
    required DateTime from,
    required DateTime to,
  }) async {
    reads++;

    if (readError != null) {
      throw readError!;
    }

    final List<GoodThingModel> matched = entries
        .where((GoodThingModel entry) =>
            !entry.createdAt.isBefore(from) && entry.createdAt.isBefore(to))
        .toList();

    // Newest first, as the real query orders it.
    matched.sort((GoodThingModel a, GoodThingModel b) =>
        b.createdAt.compareTo(a.createdAt));

    return matched;
  }
}
