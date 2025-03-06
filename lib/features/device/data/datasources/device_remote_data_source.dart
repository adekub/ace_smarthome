import 'dart:convert';
import 'package:ace_smarthome/core/error/exceptions.dart';
import 'package:ace_smarthome/features/device/data/models/device_model.dart';
import 'package:ace_smarthome/features/settings/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;

abstract class DeviceRemoteDataSource {
  Future<List<DeviceModel>> getDevices();
  Future<bool> toggleDeviceSwitch(String deviceId, int switchIndex, bool state);
  Future<bool> toggleAllSwitches(String deviceId, bool state);
  Future<bool> setSchedule(
      String deviceId, int switchIndex, ScheduleModel schedule);
  Future<bool> checkDeviceConnection(String deviceId);
  Future<Map<String, dynamic>> fetchDeviceStates(String deviceId);
  Future<Map<String, dynamic>> fetchDeviceSchedules(String deviceId);
}

@LazySingleton(as: DeviceRemoteDataSource)
class DeviceRemoteDataSourceImpl implements DeviceRemoteDataSource {
  final http.Client client;
  final SettingsRepository settingsRepository;

  DeviceRemoteDataSourceImpl({
    required this.client,
    required this.settingsRepository,
  });
  Future<String> get _baseUrl async {
    final result = await settingsRepository.getServerConfig();
    return result.fold(
      (failure) => 'http://localhost:1880', // Default fallback
      (config) => 'http://${config.host}:${config.port}',
    );
  }

  @override
  Future<List<DeviceModel>> getDevices() async {
    // This is often delegated to local cache since the server doesn't store device list
    return [];
  }

  @override
  Future<bool> toggleDeviceSwitch(
      String deviceId, int switchIndex, bool state) async {
    final url = Uri.parse(
        '${await _baseUrl}/api/$deviceId/switch/$switchIndex/${state ? 'on' : 'off'}');

    try {
      final response = await client.get(url).timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ServerException(
          message: 'Failed to toggle switch: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Network error when toggling switch: $e',
      );
    }
  }

  @override
  Future<bool> toggleAllSwitches(String deviceId, bool state) async {
    final url = Uri.parse(
        '${await _baseUrl}/api/$deviceId/switch/all/${state ? 'on' : 'off'}');

    try {
      final response = await client.get(url).timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ServerException(
          message: 'Failed to toggle all switches: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Network error when toggling all switches: $e',
      );
    }
  }

  @override
  Future<bool> setSchedule(
      String deviceId, int switchIndex, ScheduleModel schedule) async {
    final url = Uri.parse('${await _baseUrl}/api/$deviceId/schedule');

    try {
      final response = await client
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'switchIndex': switchIndex,
              'onTime': schedule.onTime,
              'offTime': schedule.offTime,
              'isEnabled': schedule.isEnabled,
              'isDaily': schedule.isDaily,
            }),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ServerException(
          message: 'Failed to set schedule: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Network error when setting schedule: $e',
      );
    }
  }

  @override
  Future<bool> checkDeviceConnection(String deviceId) async {
    final url = Uri.parse('${await _baseUrl}/api/$deviceId/status');

    try {
      final response = await client.get(url).timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'connected';
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> fetchDeviceStates(String deviceId) async {
    final url = Uri.parse('${await _baseUrl}/api/$deviceId/switches');

    try {
      final response = await client.get(url).timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ServerException(
          message: 'Failed to fetch device states: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Network error when fetching device states: $e',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> fetchDeviceSchedules(String deviceId) async {
    final url = Uri.parse('${await _baseUrl}/api/$deviceId/schedules');

    try {
      final response = await client.get(url).timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ServerException(
          message: 'Failed to fetch device schedules: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw ServerException(
        message: 'Network error when fetching device schedules: $e',
      );
    }
  }
}
