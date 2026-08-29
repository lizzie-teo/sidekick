import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Persists the Supabase session in the platform keystore rather than in plain
// preferences.
//
// supabase_flutter defaults to SharedPreferencesLocalStorage, which writes the
// session to SharedPreferences on Android and NSUserDefaults on iOS, both
// unencrypted. That session holds the refresh token, so it is worth protecting.
// This puts it behind the Android Keystore and the iOS Keychain instead.
//
// What this does not do: protect a rooted or jailbroken device, or one an
// attacker holds unlocked. It raises the bar from "readable by anything running
// as the app" to "needs the platform keystore".
class SecureLocalStorage extends LocalStorage {
  const SecureLocalStorage();

  static const String _key = 'sidekick.supabase.session';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    // Defaults in flutter_secure_storage 11: AES-GCM for the data, RSA-OAEP
    // SHA-256 to wrap the key, API 23+. The older encryptedSharedPreferences
    // flag is gone -- this replaced it and is stronger.
    aOptions: AndroidOptions(),
    // Readable only after the first unlock since boot, and never restored onto
    // a different device from an iCloud backup. The consequence is that the
    // item outlives an uninstall, since the Keychain is not app-scoped storage.
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() => _storage.read(key: _key);

  @override
  Future<bool> hasAccessToken() async {
    return await _storage.read(key: _key) != null;
  }

  @override
  Future<void> persistSession(String persistSessionString) {
    return _storage.write(key: _key, value: persistSessionString);
  }

  @override
  Future<void> removePersistedSession() => _storage.delete(key: _key);
}
