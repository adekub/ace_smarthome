import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:ace_smarthome/core/error/failures.dart';
import 'package:ace_smarthome/features/device/domain/entities/device.dart';
import 'package:ace_smarthome/features/device/domain/usecases/add_device.dart';
import 'package:ace_smarthome/features/device/domain/usecases/delete_device.dart';
import 'package:ace_smarthome/features/device/domain/usecases/get_devices.dart';
import 'package:ace_smarthome/features/device/domain/usecases/toggle_device_switch.dart';
import 'package:ace_smarthome/features/device/domain/usecases/toggle_all_switches.dart';
import 'package:ace_smarthome/features/device/domain/usecases/set_schedule.dart';
import 'package:ace_smarthome/features/device/domain/usecases/check_device_connection.dart';
import 'package:ace_smarthome/features/device/domain/usecases/update_device.dart';

part 'device_event.dart';
part 'device_state.dart';

@injectable
class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final GetDevices getDevices;
  final AddDevice addDevice;
  final UpdateDevice updateDevice;
  final DeleteDevice deleteDevice;
  final ToggleDeviceSwitch toggleDeviceSwitch;
  final ToggleAllSwitches toggleAllSwitches;
  final SetSchedule setSchedule;
  final CheckDeviceConnection checkDeviceConnection;

  // Timer for periodic connection check
  Timer? _connectionTimer;

  DeviceBloc({
    required this.getDevices,
    required this.addDevice,
    required this.updateDevice,
    required this.deleteDevice,
    required this.toggleDeviceSwitch,
    required this.toggleAllSwitches,
    required this.setSchedule,
    required this.checkDeviceConnection,
  }) : super(DeviceInitial()) {
    on<LoadDevices>(_onLoadDevices);
    on<AddDeviceEvent>(_onAddDevice);
    on<UpdateDeviceEvent>(_onUpdateDevice);
    on<DeleteDeviceEvent>(_onDeleteDevice);
    on<ToggleDeviceSwitchEvent>(_onToggleDeviceSwitch);
    on<ToggleAllSwitchesEvent>(_onToggleAllSwitches);
    on<SetScheduleEvent>(_onSetSchedule);
    on<CheckDeviceConnectionEvent>(_onCheckDeviceConnection);
    on<StartConnectionMonitoringEvent>(_onStartConnectionMonitoring);
    on<StopConnectionMonitoringEvent>(_onStopConnectionMonitoring);
  }

  FutureOr<void> _onLoadDevices(
    LoadDevices event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceLoading());

    final result = await getDevices();

    result.fold(
      (failure) => emit(DeviceError(message: _mapFailureToMessage(failure))),
      (devices) => emit(DeviceLoaded(devices: devices)),
    );
  }

  FutureOr<void> _onAddDevice(
    AddDeviceEvent event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceOperationInProgress());

    final result = await addDevice(event.device);

    result.fold(
      (failure) => emit(DeviceError(message: _mapFailureToMessage(failure))),
      (device) {
        if (state is DeviceLoaded) {
          final currentDevices = (state as DeviceLoaded).devices;
          emit(DeviceLoaded(devices: [...currentDevices, device]));
        } else {
          add(LoadDevices());
        }
      },
    );
  }

  FutureOr<void> _onUpdateDevice(
    UpdateDeviceEvent event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceOperationInProgress());

    final result = await updateDevice(event.device);

    result.fold(
      (failure) => emit(DeviceError(message: _mapFailureToMessage(failure))),
      (updatedDevice) {
        if (state is DeviceLoaded) {
          final currentDevices = (state as DeviceLoaded).devices;
          final updatedDevices = currentDevices.map((device) {
            return device.id == updatedDevice.id ? updatedDevice : device;
          }).toList();

          emit(DeviceLoaded(devices: updatedDevices));
        } else {
          add(LoadDevices());
        }
      },
    );
  }

  FutureOr<void> _onDeleteDevice(
    DeleteDeviceEvent event,
    Emitter<DeviceState> emit,
  ) async {
    emit(DeviceOperationInProgress());

    final result = await deleteDevice(event.deviceId);

    result.fold(
      (failure) => emit(DeviceError(message: _mapFailureToMessage(failure))),
      (success) {
        if (success && state is DeviceLoaded) {
          final currentDevices = (state as DeviceLoaded).devices;
          final updatedDevices = currentDevices
              .where((device) => device.id != event.deviceId)
              .toList();

          emit(DeviceLoaded(devices: updatedDevices));
        } else {
          add(LoadDevices());
        }
      },
    );
  }

  FutureOr<void> _onToggleDeviceSwitch(
    ToggleDeviceSwitchEvent event,
    Emitter<DeviceState> emit,
  ) async {
    if (state is! DeviceLoaded) return;

    final currentState = state as DeviceLoaded;
    final device = currentState.devices.firstWhere(
      (d) => d.id == event.deviceId,
      orElse: () => throw Exception('Device not found'),
    );

    // Optimistic update
    final optimisticSwitchStates = List<bool>.from(device.switchStates);
    optimisticSwitchStates[event.switchIndex] =
        !optimisticSwitchStates[event.switchIndex];

    final optimisticDevice = device.copyWith(
      switchStates: optimisticSwitchStates,
    );

    final optimisticDevices = currentState.devices.map((d) {
      return d.id == device.id ? optimisticDevice : d;
    }).toList();

    emit(DeviceLoaded(devices: optimisticDevices));

    // Actual API call
    final result = await toggleDeviceSwitch(device, event.switchIndex);

    result.fold(
      (failure) {
        // Revert back on failure
        emit(DeviceLoaded(devices: currentState.devices));
        emit(DeviceOperationError(message: _mapFailureToMessage(failure)));
      },
      (updatedDevice) {
        final updatedDevices = currentState.devices.map((d) {
          return d.id == updatedDevice.id ? updatedDevice : d;
        }).toList();

        emit(DeviceLoaded(devices: updatedDevices));
      },
    );
  }

  FutureOr<void> _onToggleAllSwitches(
    ToggleAllSwitchesEvent event,
    Emitter<DeviceState> emit,
  ) async {
    if (state is! DeviceLoaded) return;

    final currentState = state as DeviceLoaded;
    final device = currentState.devices.firstWhere(
      (d) => d.id == event.deviceId,
      orElse: () => throw Exception('Device not found'),
    );

    // Optimistic update
    final optimisticSwitchStates = List<bool>.filled(
      device.numberOfSwitches,
      event.state,
    );

    final optimisticDevice = device.copyWith(
      switchStates: optimisticSwitchStates,
    );

    final optimisticDevices = currentState.devices.map((d) {
      return d.id == device.id ? optimisticDevice : d;
    }).toList();

    emit(DeviceLoaded(devices: optimisticDevices));

    // Actual API call
    final result = await toggleAllSwitches(device, event.state);

    result.fold(
      (failure) {
        // Revert back on failure
        emit(DeviceLoaded(devices: currentState.devices));
        emit(DeviceOperationError(message: _mapFailureToMessage(failure)));
      },
      (updatedDevice) {
        final updatedDevices = currentState.devices.map((d) {
          return d.id == updatedDevice.id ? updatedDevice : d;
        }).toList();

        emit(DeviceLoaded(devices: updatedDevices));
      },
    );
  }

  // ส่วนที่ปรับปรุงในไฟล์ lib/features/device/presentation/bloc/device_bloc.dart
  FutureOr<void> _onSetSchedule(
    SetScheduleEvent event,
    Emitter<DeviceState> emit,
  ) async {
    if (state is! DeviceLoaded) return;

    // บันทึก currentState ก่อนเปลี่ยน state
    final currentState = state as DeviceLoaded;

    // จากนั้นค่อยเปลี่ยน state
    emit(DeviceOperationInProgress());

    // Optimistic update ทำทันที ไม่ต้องรอ API
    final optimisticSchedules = Map<int, Schedule>.from(currentState.devices
        .firstWhere((d) => d.id == event.deviceId)
        .schedules);
    optimisticSchedules[event.switchIndex] = event.schedule;

    final device = currentState.devices.firstWhere(
      (d) => d.id == event.deviceId,
      orElse: () => throw Exception('Device not found'),
    );

    final optimisticDevice = device.copyWith(
      schedules: optimisticSchedules,
    );

    final optimisticDevices = currentState.devices.map((d) {
      return d.id == device.id ? optimisticDevice : d;
    }).toList();

    // อัพเดท UI ทันที
    emit(DeviceLoaded(devices: optimisticDevices));

    // ทำการเรียก API ในพื้นหลัง
    final result = await setSchedule(device, event.switchIndex, event.schedule);

    result.fold(
      (failure) {
        // ถ้าเกิด error ให้แจ้งเตือนแต่ไม่ต้อง revert UI
        emit(DeviceOperationError(message: _mapFailureToMessage(failure)));
      },
      (updatedDevice) {
        // อัพเดทจากข้อมูลจริงจาก API
        final updatedDevices = currentState.devices.map((d) {
          return d.id == updatedDevice.id ? updatedDevice : d;
        }).toList();

        emit(DeviceLoaded(devices: updatedDevices));
        emit(DeviceOperationSuccess(message: 'Schedule updated successfully'));
      },
    );
  }

  FutureOr<void> _onCheckDeviceConnection(
    CheckDeviceConnectionEvent event,
    Emitter<DeviceState> emit,
  ) async {
    if (state is! DeviceLoaded) return;

    final currentState = state as DeviceLoaded;
    final device = currentState.devices.firstWhere(
      (d) => d.id == event.deviceId,
      orElse: () => throw Exception('Device not found'),
    );

    final result = await checkDeviceConnection(device);

    result.fold(
      (failure) {
        // Just ignore the error
      },
      (isConnected) {
        if (state is DeviceLoaded) {
          final currentDevices = (state as DeviceLoaded).devices;
          final updatedDevices = currentDevices.map((d) {
            if (d.id == device.id) {
              return d.copyWith(isConnected: isConnected);
            }
            return d;
          }).toList();

          emit(DeviceLoaded(devices: updatedDevices));
        }
      },
    );
  }

  FutureOr<void> _onStartConnectionMonitoring(
    StartConnectionMonitoringEvent event,
    Emitter<DeviceState> emit,
  ) {
    // Cancel existing timer if any
    _connectionTimer?.cancel();

    // Start periodic connection check
    _connectionTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (state is DeviceLoaded) {
          final devices = (state as DeviceLoaded).devices;
          for (final device in devices) {
            add(CheckDeviceConnectionEvent(deviceId: device.id));
          }
        }
      },
    );
  }

  FutureOr<void> _onStopConnectionMonitoring(
    StopConnectionMonitoringEvent event,
    Emitter<DeviceState> emit,
  ) {
    _connectionTimer?.cancel();
    _connectionTimer = null;
  }

  @override
  Future<void> close() {
    _connectionTimer?.cancel();
    return super.close();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return failure.message;
      case CacheFailure:
        return failure.message;
      case ConnectionFailure:
        return failure.message;
      default:
        return 'Unexpected error occurred';
    }
  }
}
