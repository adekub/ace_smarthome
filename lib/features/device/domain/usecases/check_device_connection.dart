import 'package:ace_smarthome/core/error/failures.dart';
import 'package:ace_smarthome/features/device/domain/entities/device.dart';
import 'package:ace_smarthome/features/device/domain/repositories/device_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';

@lazySingleton
class CheckDeviceConnection {
  final DeviceRepository repository;

  CheckDeviceConnection(this.repository);

  Future<Either<Failure, bool>> call(Device device) async {
    return await repository.checkDeviceConnection(device);
  }
}
