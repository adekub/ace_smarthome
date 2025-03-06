import 'package:ace_smarthome/core/error/failures.dart';
import 'package:ace_smarthome/features/device/domain/entities/device.dart';
import 'package:ace_smarthome/features/device/domain/repositories/device_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ToggleAllSwitches {
  final DeviceRepository repository;

  ToggleAllSwitches(this.repository);

  Future<Either<Failure, Device>> call(Device device, bool state) async {
    return await repository.toggleAllSwitches(device, state);
  }
}
