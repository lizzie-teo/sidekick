import 'package:shared_preferences/shared_preferences.dart';

import 'package:sidekick/app/core/logger_service.dart';

// Small settings that live on the phone and nowhere else: which pairing Home
// showed last, the onboarding answers. Losing any of it costs the user
// nothing, which is why it does not go to the server. Anything they would
// miss on a new phone belongs in a Supabase table instead.
//
// Keys are declared in SettingsKeys in app_constants.dart, so the full set is
// visible in one place.
//
// SharedPreferencesAsync talks to the platform on every call rather than
// caching a snapshot at startup. That means no initialise() step and no window
// where a read quietly returns null because the cache has not loaded yet --
// the cost is that every read is a Future, which viewmodels await in init().
//
// A failed read returns the fallback rather than throwing. Nothing here is
// important enough to break a screen over.
class DeviceSettingsService {
  final LoggerService _loggerService;
  final SharedPreferencesAsync _preferences;

  DeviceSettingsService({
    required LoggerService loggerService,
    SharedPreferencesAsync? preferences,
  })  : _loggerService = loggerService,
        _preferences = preferences ?? SharedPreferencesAsync();

  Future<int?> getInt(String key) => _read(key, _preferences.getInt);

  Future<bool?> getBool(String key) => _read(key, _preferences.getBool);

  Future<String?> getString(String key) => _read(key, _preferences.getString);

  Future<void> setInt(String key, int value) =>
      _write(key, () => _preferences.setInt(key, value));

  Future<void> setBool(String key, bool value) =>
      _write(key, () => _preferences.setBool(key, value));

  Future<void> setString(String key, String value) =>
      _write(key, () => _preferences.setString(key, value));

  Future<void> remove(String key) =>
      _write(key, () => _preferences.remove(key));

  Future<T?> _read<T>(String key, Future<T?> Function(String) read) async {
    try {
      return await read(key);
    } catch (e, s) {
      _loggerService.errorShort(e, s);
      return null;
    }
  }

  Future<void> _write(String key, Future<void> Function() write) async {
    try {
      await write();
    } catch (e, s) {
      _loggerService.errorShort(e, s);
    }
  }
}
