import 'package:sidekick/app/core/app_constants.dart';

// One row of the _configuration table: a runtime setting the app reads at
// startup, so it can change without an app store release.
class ConfigurationModel {
  final String configKey;
  final String configValue;
  final ConfigurationDataType dataType;

  ConfigurationModel({
    required this.configKey,
    required this.configValue,
    required this.dataType,
  });

  factory ConfigurationModel.fromJson(Map<String, dynamic> json) {
    return ConfigurationModel(
      configKey: json['config_key'] as String,
      configValue: json['config_value'] as String,
      dataType: ConfigurationDataType.values.byName(
        json['data_type'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'config_key': configKey,
      'config_value': configValue,
      'data_type': dataType.name,
    };
  }
}
