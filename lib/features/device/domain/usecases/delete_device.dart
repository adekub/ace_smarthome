import 'package:ace_smarthome/core/error/failures.dart';
import 'package:ace_smarthome/features/device/domain/repositories/device_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';

@lazySingleton
class DeleteDevice {
  final DeviceRepository repository;

  DeleteDevice(this.repository);

  Future<Either<Failure, bool>> call(String deviceId) async {
    return await repository.deleteDevice(deviceId);
  }
}
