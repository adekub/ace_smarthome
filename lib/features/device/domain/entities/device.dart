import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Device extends Equatable {
  final String id;
  final String name;
  final IconData icon;
  final String deviceID;
  final bool isConnected;
  final int numberOfSwitches;
  final List<bool> switchStates;
  final List<String> switchNames;
  final Map<int, Schedule> schedules;

  const Device({
    required this.id,
    required this.name,
    required this.icon,
    required this.deviceID,
    this.isConnected = false,
    required this.numberOfSwitches,
    required this.switchStates,
    required this.switchNames,
    required this.schedules,
  });

  Device copyWith({
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
    return Device(
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

  @override
  List<Object?> get props => [
        id,
        name,
        icon,
        deviceID,
        isConnected,
        numberOfSwitches,
        switchStates,
        switchNames,
        schedules,
      ];
}

class Schedule extends Equatable {
  final String onTime;
  final String offTime;
  final bool isEnabled;
  final bool isDaily;

  const Schedule({
    required this.onTime,
    required this.offTime,
    required this.isEnabled,
    required this.isDaily,
  });

  @override
  List<Object?> get props => [onTime, offTime, isEnabled, isDaily];
}
