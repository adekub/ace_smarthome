import 'package:ace_smarthome/core/error/failures.dart';
import 'package:ace_smarthome/features/device/domain/entities/device.dart';
import 'package:ace_smarthome/features/device/domain/repositories/device_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetDevices {
  final DeviceRepository repository;

  GetDevices(this.repository);

  Future<Either<Failure, List<Device>>> call() async {
    return await repository.getDevices();
  }
}
