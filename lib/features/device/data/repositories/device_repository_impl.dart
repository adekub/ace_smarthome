import 'package:ace_smarthome/core/error/exceptions.dart';
import 'package:ace_smarthome/core/error/failures.dart';
import 'package:ace_smarthome/core/network/network_info.dart';
import 'package:ace_smarthome/features/device/data/datasources/device_local_data_source.dart';
import 'package:ace_smarthome/features/device/data/datasources/device_remote_data_source.dart';
import 'package:ace_smarthome/features/device/data/models/device_model.dart';
import 'package:ace_smarthome/features/device/domain/entities/device.dart';
import 'package:ace_smarthome/features/device/domain/repositories/device_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'package:dartz/dartz.dart';

@LazySingleton(as: DeviceRepository)
class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceLocalDataSource localDataSource;
  final DeviceRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final Uuid uuid;

  DeviceRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.networkInfo,
    required this.uuid,
  });

  @override
  Future<Either<Failure, List<Device>>> getDevices() async {
    try {
      final localDevices = await localDataSource.getDevices();

      // If we're online, update device connection status
      if (await networkInfo.isConnected) {
        for (var device in localDevices) {
          try {
            final isConnected =
                await remoteDataSource.checkDeviceConnection(device.deviceID);

            if (isConnected) {
              // Update switch states and schedules if connected
              try {
                final statesData =
                    await remoteDataSource.fetchDeviceStates(device.deviceID);
                final switchStates = List<bool>.from(statesData['states']);

                final schedulesData = await remoteDataSource
                    .fetchDeviceSchedules(device.deviceID);
                Map<int, Schedule> schedules = {};

                if (schedulesData['schedules'] != null) {
                  final schedulesMap =
                      schedulesData['schedules'] as Map<String, dynamic>;
                  schedulesMap.forEach((key, value) {
                    schedules[int.parse(key)] = ScheduleModel.fromJson(value);
                  });
                }

                // Update local device with remote state
                final int index = localDevices.indexOf(device);
                if (index != -1) {
                  localDevices[index] = device.copyWith(
                    isConnected: true,
                    switchStates: switchStates,
                    schedules: schedules,
                  ) as DeviceModel;
                }
              } catch (e) {
                // Just mark as connected if we can't fetch states
                final int index = localDevices.indexOf(device);
                if (index != -1) {
                  localDevices[index] = device.copyWith(
                    isConnected: true,
                  ) as DeviceModel;
                }
              }
            } else {
              // Mark as disconnected
              final int index = localDevices.indexOf(device);
              if (index != -1) {
                localDevices[index] = device.copyWith(
                  isConnected: false,
                ) as DeviceModel;
              }
            }
          } catch (e) {
            // Mark as disconnected on error
            final int index = localDevices.indexOf(device);
            if (index != -1) {
              localDevices[index] = device.copyWith(
                isConnected: false,
              ) as DeviceModel;
            }
          }
        }
      }

      // Cache updated devices
      await localDataSource.cacheDevices(localDevices);

      return Right(localDevices);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Device>> addDevice(Device device) async {
    try {
      final deviceModel = DeviceModel(
        id: uuid.v4(),
        name: device.name,
        icon: device.icon,
        deviceID: device.deviceID,
        isConnected: false,
        numberOfSwitches: device.numberOfSwitches,
        switchStates: List.filled(device.numberOfSwitches, false),
        switchNames: List.generate(
          device.numberOfSwitches,
          (index) => 'Switch ${index + 1}',
        ),
        schedules: {},
      );

      final addedDevice = await localDataSource.addDevice(deviceModel);

      // Check connection if online
      if (await networkInfo.isConnected) {
        try {
          final isConnected = await remoteDataSource
              .checkDeviceConnection(deviceModel.deviceID);
          if (isConnected) {
            final updatedDevice =
                deviceModel.copyWith(isConnected: true) as DeviceModel;
            await localDataSource.updateDevice(updatedDevice);
            return Right(updatedDevice);
          }
        } catch (e) {
          // Ignore connection errors on add
        }
      }

      return Right(addedDevice);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(DeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Device>> updateDevice(Device device) async {
    try {
      final deviceModel = device as DeviceModel;
      final updatedDevice = await localDataSource.updateDevice(deviceModel);
      return Right(updatedDevice);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(DeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteDevice(String deviceId) async {
    try {
      final result = await localDataSource.deleteDevice(deviceId);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(DeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Device>> toggleDeviceSwitch(
      Device device, int switchIndex) async {
    try {
      final bool newState = !device.switchStates[switchIndex];

      if (await networkInfo.isConnected) {
        try {
          final success = await remoteDataSource.toggleDeviceSwitch(
            device.deviceID,
            switchIndex,
            newState,
          );

          if (success) {
            final List<bool> newStates = List.from(device.switchStates);
            newStates[switchIndex] = newState;

            final updatedDevice = device.copyWith(
              switchStates: newStates,
              isConnected: true,
            );

            // Update local cache
            await localDataSource.updateDevice(updatedDevice as DeviceModel);

            return Right(updatedDevice);
          } else {
            return Left(ServerFailure(
              message: 'Failed to toggle switch on server',
            ));
          }
        } on ServerException catch (e) {
          return Left(ServerFailure(message: e.message));
        }
      } else {
        // Optimistic update for offline mode
        final List<bool> newStates = List.from(device.switchStates);
        newStates[switchIndex] = newState;

        final updatedDevice = device.copyWith(
          switchStates: newStates,
          isConnected: false,
        );

        // Update local cache
        await localDataSource.updateDevice(updatedDevice as DeviceModel);

        return Right(updatedDevice);
      }
    } catch (e) {
      return Left(DeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Device>> toggleAllSwitches(
      Device device, bool state) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final success = await remoteDataSource.toggleAllSwitches(
            device.deviceID,
            state,
          );

          if (success) {
            final List<bool> newStates =
                List.filled(device.numberOfSwitches, state);

            final updatedDevice = device.copyWith(
              switchStates: newStates,
              isConnected: true,
            );

            // Update local cache
            await localDataSource.updateDevice(updatedDevice as DeviceModel);

            return Right(updatedDevice);
          } else {
            return Left(ServerFailure(
              message: 'Failed to toggle all switches on server',
            ));
          }
        } on ServerException catch (e) {
          return Left(ServerFailure(message: e.message));
        }
      } else {
        // Optimistic update for offline mode
        final List<bool> newStates =
            List.filled(device.numberOfSwitches, state);

        final updatedDevice = device.copyWith(
          switchStates: newStates,
          isConnected: false,
        );

        // Update local cache
        await localDataSource.updateDevice(updatedDevice as DeviceModel);

        return Right(updatedDevice);
      }
    } catch (e) {
      return Left(DeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Device>> setSchedule(
      Device device, int switchIndex, Schedule schedule) async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final success = await remoteDataSource.setSchedule(
            device.deviceID,
            switchIndex,
            schedule as ScheduleModel,
          );

          if (success) {
            final Map<int, Schedule> newSchedules = Map.from(device.schedules);
            newSchedules[switchIndex] = schedule;

            final updatedDevice = device.copyWith(
              schedules: newSchedules,
              isConnected: true,
            );

            // Update local cache
            await localDataSource.updateDevice(updatedDevice as DeviceModel);

            return Right(updatedDevice);
          } else {
            return Left(ServerFailure(
              message: 'Failed to set schedule on server',
            ));
          }
        } on ServerException catch (e) {
          // Even if server fails, still update locally
          final Map<int, Schedule> newSchedules = Map.from(device.schedules);
          newSchedules[switchIndex] = schedule;

          final updatedDevice = device.copyWith(
            schedules: newSchedules,
            isConnected: false,
          );

          // Update local cache
          await localDataSource.updateDevice(updatedDevice as DeviceModel);

          return Left(ServerFailure(message: e.message));
        }
      } else {
        // Optimistic update for offline mode
        final Map<int, Schedule> newSchedules = Map.from(device.schedules);
        newSchedules[switchIndex] = schedule;

        final updatedDevice = device.copyWith(
          schedules: newSchedules,
          isConnected: false,
        );

        // Update local cache
        await localDataSource.updateDevice(updatedDevice as DeviceModel);

        return Right(updatedDevice);
      }
    } catch (e) {
      return Left(DeviceFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkDeviceConnection(Device device) async {
    try {
      if (await networkInfo.isConnected) {
        final isConnected =
            await remoteDataSource.checkDeviceConnection(device.deviceID);

        // Update local cache with connection status
        await localDataSource.updateDevice(
          DeviceModel.fromDevice(device).copyWith(isConnected: isConnected),
        );

        return Right(isConnected);
      } else {
        // If no internet, device is disconnected
        await localDataSource.updateDevice(
          (device as DeviceModel).copyWith(isConnected: false),
        );
        return Right(false);
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(DeviceFailure(message: e.toString()));
    }
  }
}
