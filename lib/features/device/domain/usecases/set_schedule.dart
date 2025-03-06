import 'package:ace_smarthome/core/error/failures.dart';
import 'package:ace_smarthome/features/device/domain/entities/device.dart';
import 'package:ace_smarthome/features/device/domain/repositories/device_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SetSchedule {
  final DeviceRepository repository;

  SetSchedule(this.repository);

  Future<Either<Failure, Device>> call(
      Device device, int switchIndex, Schedule schedule) async {
    return await repository.setSchedule(device, switchIndex, schedule);
  }
}
