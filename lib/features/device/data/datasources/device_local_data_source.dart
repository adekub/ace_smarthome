import 'dart:convert';
import 'package:ace_smarthome/core/error/exceptions.dart';
import 'package:ace_smarthome/features/device/data/models/device_model.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class DeviceLocalDataSource {
  Future<List<DeviceModel>> getDevices();
  Future<void> cacheDevices(List<DeviceModel> devices);
  Future<DeviceModel> addDevice(DeviceModel device);
  Future<DeviceModel> updateDevice(DeviceModel device);
  Future<bool> deleteDevice(String deviceId);
}

@LazySingleton(as: DeviceLocalDataSource)
class DeviceLocalDataSourceImpl implements DeviceLocalDataSource {
  final SharedPreferences sharedPreferences;

  DeviceLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<DeviceModel>> getDevices() async {
    final jsonString = sharedPreferences.getString('CACHED_DEVICES');
    if (jsonString != null) {
      try {
        List<dynamic> deviceList = json.decode(jsonString);
        return deviceList
            .map((deviceJson) => DeviceModel.fromJson(deviceJson))
            .toList();
      } catch (e) {
        throw CacheException(message: 'Failed to parse cached devices');
      }
    }
    return [];
  }

  @override
  Future<void> cacheDevices(List<DeviceModel> devices) async {
    final List<Map<String, dynamic>> deviceJsonList =
        devices.map((device) => (device as DeviceModel).toJson()).toList();
    await sharedPreferences.setString(
      'CACHED_DEVICES',
      json.encode(deviceJsonList),
    );
  }

  @override
  Future<DeviceModel> addDevice(DeviceModel device) async {
    final devices = await getDevices();
    devices.add(device);
    await cacheDevices(devices);
    return device;
  }

  @override
  Future<DeviceModel> updateDevice(DeviceModel device) async {
    final devices = await getDevices();
    final index = devices.indexWhere((d) => d.id == device.id);
    if (index != -1) {
      devices[index] = device;
      await cacheDevices(devices);
      return device;
    }
    throw CacheException(message: 'Device not found');
  }

  @override
  Future<bool> deleteDevice(String deviceId) async {
    final devices = await getDevices();
    final newDevices = devices.where((d) => d.id != deviceId).toList();
    if (newDevices.length != devices.length) {
      await cacheDevices(newDevices);
      return true;
    }
    return false;
  }
}
