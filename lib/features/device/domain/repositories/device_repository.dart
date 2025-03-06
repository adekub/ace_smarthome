import 'package:ace_smarthome/core/error/failures.dart';
import 'package:ace_smarthome/features/device/domain/entities/device.dart';
import 'package:dartz/dartz.dart';

abstract class DeviceRepository {
  Future<Either<Failure, List<Device>>> getDevices();
  Future<Either<Failure, Device>> addDevice(Device device);
  Future<Either<Failure, Device>> updateDevice(Device device);
  Future<Either<Failure, bool>> deleteDevice(String deviceId);
  Future<Either<Failure, Device>> toggleDeviceSwitch(
      Device device, int switchIndex);
  Future<Either<Failure, Device>> toggleAllSwitches(Device device, bool state);
  Future<Either<Failure, Device>> setSchedule(
      Device device, int switchIndex, Schedule schedule);
  Future<Either<Failure, bool>> checkDeviceConnection(Device device);
}
