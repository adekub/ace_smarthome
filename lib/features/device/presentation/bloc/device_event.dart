part of 'device_bloc.dart';

abstract class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object> get props => [];
}

class LoadDevices extends DeviceEvent {}

class AddDeviceEvent extends DeviceEvent {
  final Device device;

  const AddDeviceEvent({required this.device});

  @override
  List<Object> get props => [device];
}

class UpdateDeviceEvent extends DeviceEvent {
  final Device device;

  const UpdateDeviceEvent({required this.device});

  @override
  List<Object> get props => [device];
}

class DeleteDeviceEvent extends DeviceEvent {
  final String deviceId;

  const DeleteDeviceEvent({required this.deviceId});

  @override
  List<Object> get props => [deviceId];
}

class ToggleDeviceSwitchEvent extends DeviceEvent {
  final String deviceId;
  final int switchIndex;

  const ToggleDeviceSwitchEvent({
    required this.deviceId,
    required this.switchIndex,
  });

  @override
  List<Object> get props => [deviceId, switchIndex];
}

class ToggleAllSwitchesEvent extends DeviceEvent {
  final String deviceId;
  final bool state;

  const ToggleAllSwitchesEvent({
    required this.deviceId,
    required this.state,
  });

  @override
  List<Object> get props => [deviceId, state];
}

class SetScheduleEvent extends DeviceEvent {
  final String deviceId;
  final int switchIndex;
  final Schedule schedule;

  const SetScheduleEvent({
    required this.deviceId,
    required this.switchIndex,
    required this.schedule,
  });

  @override
  List<Object> get props => [deviceId, switchIndex, schedule];
}

class CheckDeviceConnectionEvent extends DeviceEvent {
  final String deviceId;

  const CheckDeviceConnectionEvent({required this.deviceId});

  @override
  List<Object> get props => [deviceId];
}

class StartConnectionMonitoringEvent extends DeviceEvent {}

class StopConnectionMonitoringEvent extends DeviceEvent {}
