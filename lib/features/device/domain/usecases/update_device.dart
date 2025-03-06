import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:ace_smarthome/core/error/failures.dart';
import 'package:ace_smarthome/features/device/domain/entities/device.dart';
import 'package:ace_smarthome/features/device/domain/repositories/device_repository.dart';

@lazySingleton
class UpdateDevice {
  final DeviceRepository repository;

  UpdateDevice(this.repository);

  Future<Either<Failure, Device>> call(Device device) async {
    return await repository.updateDevice(device);
  }
}
