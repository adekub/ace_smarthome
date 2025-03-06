import 'package:ace_smarthome/features/device/domain/entities/device.dart';
import 'package:flutter/material.dart';

class DeviceModel extends Device {
  const DeviceModel({
    required String id,
    required String name,
    required IconData icon,
    required String deviceID,
    required bool isConnected,
    required int numberOfSwitches,
    required List<bool> switchStates,
    required List<String> switchNames,
    required Map<int, Schedule> schedules,
  }) : super(
          id: id,
          name: name,
          icon: icon,
          deviceID: deviceID,
          isConnected: isConnected,
          numberOfSwitches: numberOfSwitches,
          switchStates: switchStates,
          switchNames: switchNames,
          schedules: schedules,
        );

  /// สร้าง [DeviceModel] จาก [Device] (ใน Domain layer)
  factory DeviceModel.fromDevice(Device device) {
    // แปลงตาราง schedules ให้เป็น ScheduleModel หากยังไม่ใช่
    final mappedSchedules =
        device.schedules.map<int, Schedule>((key, schedule) {
      if (schedule is ScheduleModel) {
        return MapEntry(key, schedule);
      } else {
        return MapEntry(
          key,
          ScheduleModel(
            onTime: schedule.onTime,
            offTime: schedule.offTime,
            isEnabled: schedule.isEnabled,
            isDaily: schedule.isDaily,
          ),
        );
      }
    });

    return DeviceModel(
      id: device.id,
      name: device.name,
      icon: device.icon,
      deviceID: device.deviceID,
      isConnected: device.isConnected,
      numberOfSwitches: device.numberOfSwitches,
      switchStates: device.switchStates,
      switchNames: device.switchNames,
      schedules: mappedSchedules,
    );
  }

  /// สร้าง [DeviceModel] จาก JSON
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    // Parse schedules
    Map<int, Schedule> schedules = {};
    if (json['schedules'] != null) {
      final schedulesMap = json['schedules'] as Map<String, dynamic>;
      schedulesMap.forEach((key, value) {
        schedules[int.parse(key)] = ScheduleModel.fromJson(value);
      });
    }

    return DeviceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: IconData(
        json['icon'] as int,
        fontFamily: 'MaterialIcons',
      ),
      deviceID: json['deviceID'] as String,
      isConnected: json['isConnected'] as bool,
      numberOfSwitches: json['numberOfSwitches'] as int,
      switchStates: List<bool>.from(json['switchStates'] as List),
      switchNames: List<String>.from(json['switchNames'] as List),
      schedules: schedules,
    );
  }

  /// เมธอด copyWith ที่คืนค่าเป็น [DeviceModel] (แก้ไขบางฟิลด์แล้วได้ออบเจ็กต์ใหม่)
  DeviceModel copyWith({
    String? id,
    String? name,
    IconData? icon,
    String? deviceID,
    bool? isConnected,
    int? numberOfSwitches,
    List<bool>? switchStates,
    List<String>? switchNames,
    Map<int, Schedule>? schedules,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      deviceID: deviceID ?? this.deviceID,
      isConnected: isConnected ?? this.isConnected,
      numberOfSwitches: numberOfSwitches ?? this.numberOfSwitches,
      switchStates: switchStates ?? this.switchStates,
      switchNames: switchNames ?? this.switchNames,
      schedules: schedules ?? this.schedules,
    );
  }

  /// แปลง [DeviceModel] กลับเป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'deviceID': deviceID,
      'isConnected': isConnected,
      'numberOfSwitches': numberOfSwitches,
      'switchStates': switchStates,
      'switchNames': switchNames,
      'schedules': schedules.map(
        (key, value) => MapEntry(
          key.toString(),
          (value as ScheduleModel).toJson(),
        ),
      ),
    };
  }
}

class ScheduleModel extends Schedule {
  const ScheduleModel({
    required String onTime,
    required String offTime,
    required bool isEnabled,
    required bool isDaily,
  }) : super(
          onTime: onTime,
          offTime: offTime,
          isEnabled: isEnabled,
          isDaily: isDaily,
        );

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      onTime: json['onTime'] as String? ?? '',
      offTime: json['offTime'] as String? ?? '',
      isEnabled: json['isEnabled'] as bool? ?? false,
      isDaily: json['isDaily'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'onTime': onTime,
      'offTime': offTime,
      'isEnabled': isEnabled,
      'isDaily': isDaily,
    };
  }
}
