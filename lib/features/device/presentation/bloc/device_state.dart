part of 'device_bloc.dart';

abstract class DeviceState extends Equatable {
  const DeviceState();

  @override
  List<Object> get props => [];
}

class DeviceInitial extends DeviceState {}

class DeviceLoading extends DeviceState {}

class DeviceLoaded extends DeviceState {
  final List<Device> devices;

  const DeviceLoaded({required this.devices});

  @override
  List<Object> get props => [devices];
}

class DeviceOperationInProgress extends DeviceState {}

class DeviceOperationSuccess extends DeviceState {
  final String message;

  const DeviceOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

class DeviceOperationError extends DeviceState {
  final String message;

  const DeviceOperationError({required this.message});

  @override
  List<Object> get props => [message];
}

class DeviceError extends DeviceState {
  final String message;

  const DeviceError({required this.message});

  @override
  List<Object> get props => [message];
}
