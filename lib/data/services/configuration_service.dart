import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:sidekick/app/core/app_constants.dart';
import 'package:sidekick/app/core/logger_service.dart';
import 'package:sidekick/data/models/entities/configuration_model.dart';

// Reads the _configuration table: runtime settings that can change without an
// app store release.
//
// A data service rather than a feature service, so it is registered in
// service_locator.dart alongside AuthService. No feature owns it, and the
// authentication feature is not the only one that will read from it.
class ConfigurationService {
  final LoggerService _loggerService;
  final SupabaseClient _supabaseClient;

  ConfigurationService({
    required LoggerService loggerService,
    required SupabaseClient supabaseClient,
  })  : _loggerService = loggerService,
        _supabaseClient = supabaseClient;

  // Returns null when the key is not configured, rather than throwing -- a
  // missing setting should degrade the screen, not break sign-in.
  //
  // A failed read still throws, so a caller can tell "nobody set this" apart
  // from "the database could not be reached" if it ever needs to.
  Future<ConfigurationModel?> getConfiguration(
    String configKey,
    ConfigurationDataType dataType,
  ) async {
    try {
      final Map<String, dynamic>? row = await _supabaseClient
          .from('_configuration')
          .select()
          .eq('config_key', configKey)
          .eq('data_type', dataType.name)
          .maybeSingle();

      if (row == null) {
        _loggerService.warning(
          'ConfigurationService: $configKey is not configured',
        );
        return null;
      }

      return ConfigurationModel.fromJson(row);
    } catch (e, s) {
      _loggerService.errorShort(e, s);
      rethrow;
    }
  }
}
