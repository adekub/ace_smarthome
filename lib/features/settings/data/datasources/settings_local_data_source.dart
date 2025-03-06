import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ace_smarthome/core/error/exceptions.dart';
import 'package:ace_smarthome/features/settings/data/models/app_settings_model.dart';
import 'package:ace_smarthome/features/settings/data/models/server_config_model.dart';
import 'package:ace_smarthome/features/settings/data/models/mqtt_config_model.dart';

abstract class SettingsLocalDataSource {
  Future<AppSettingsModel> getAppSettings();
  Future<bool> saveAppSettings(AppSettingsModel settings);
  Future<ServerConfigModel> getServerConfig();
  Future<bool> saveServerConfig(ServerConfigModel config);
  Future<MqttConfigModel> getMqttConfig();
  Future<bool> saveMqttConfig(MqttConfigModel config);
}

@LazySingleton(as: SettingsLocalDataSource)
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String APP_SETTINGS_KEY = 'APP_SETTINGS';
  static const String SERVER_CONFIG_KEY = 'SERVER_CONFIG';
  static const String MQTT_CONFIG_KEY = 'MQTT_CONFIG';

  SettingsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<AppSettingsModel> getAppSettings() async {
    final jsonString = sharedPreferences.getString(APP_SETTINGS_KEY);
    if (jsonString != null) {
      try {
        return AppSettingsModel.fromJson(json.decode(jsonString));
      } catch (e) {
        throw CacheException(message: 'Failed to parse cached app settings');
      }
    } else {
      return AppSettingsModel.defaultSettings();
    }
  }

  @override
  Future<bool> saveAppSettings(AppSettingsModel settings) async {
    return await sharedPreferences.setString(
      APP_SETTINGS_KEY,
      json.encode(settings.toJson()),
    );
  }

  @override
  Future<ServerConfigModel> getServerConfig() async {
    final jsonString = sharedPreferences.getString(SERVER_CONFIG_KEY);
    if (jsonString != null) {
      try {
        return ServerConfigModel.fromJson(json.decode(jsonString));
      } catch (e) {
        throw CacheException(message: 'Failed to parse cached server config');
      }
    } else {
      return ServerConfigModel.defaultConfig();
    }
  }

  @override
  Future<bool> saveServerConfig(ServerConfigModel config) async {
    return await sharedPreferences.setString(
      SERVER_CONFIG_KEY,
      json.encode(config.toJson()),
    );
  }

  @override
  Future<MqttConfigModel> getMqttConfig() async {
    final jsonString = sharedPreferences.getString(MQTT_CONFIG_KEY);
    if (jsonString != null) {
      try {
        return MqttConfigModel.fromJson(json.decode(jsonString));
      } catch (e) {
        throw CacheException(message: 'Failed to parse cached MQTT config');
      }
    } else {
      return MqttConfigModel.defaultConfig();
    }
  }

  @override
  Future<bool> saveMqttConfig(MqttConfigModel config) async {
    return await sharedPreferences.setString(
      MQTT_CONFIG_KEY,
      json.encode(config.toJson()),
    );
  }
}
