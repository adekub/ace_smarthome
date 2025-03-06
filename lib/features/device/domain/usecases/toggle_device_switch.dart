import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:ace_smarthome/core/error/failures.dart';
import 'package:ace_smarthome/features/device/domain/entities/device.dart';
import 'package:ace_smarthome/features/device/domain/repositories/device_repository.dart';

@lazySingleton
class ToggleDeviceSwitch {
  final DeviceRepository repository;

  ToggleDeviceSwitch(this.repository);

  Future<Either<Failure, Device>> call(Device device, int switchIndex) async {
    return await repository.toggleDeviceSwitch(device, switchIndex);
  }
}
