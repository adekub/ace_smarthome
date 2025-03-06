import 'package:ace_smarthome/core/error/exceptions.dart';
import 'package:ace_smarthome/core/error/failures.dart';
import 'package:ace_smarthome/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:ace_smarthome/features/settings/data/models/app_settings_model.dart';
import 'package:ace_smarthome/features/settings/data/models/mqtt_config_model.dart';
import 'package:ace_smarthome/features/settings/data/models/server_config_model.dart';
import 'package:ace_smarthome/features/settings/domain/entities/app_settings.dart';
import 'package:ace_smarthome/features/settings/domain/entities/mqtt_config.dart';
import 'package:ace_smarthome/features/settings/domain/entities/server_config.dart';
import 'package:ace_smarthome/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, AppSettings>> getAppSettings() async {
    try {
      final appSettings = await localDataSource.getAppSettings();
      return Right(appSettings);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> saveAppSettings(AppSettings settings) async {
    try {
      final appSettingsModel = AppSettingsModel.fromEntity(settings);
      final result = await localDataSource.saveAppSettings(appSettingsModel);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, ServerConfig>> getServerConfig() async {
    try {
      final serverConfig = await localDataSource.getServerConfig();
      return Right(serverConfig);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> saveServerConfig(ServerConfig config) async {
    try {
      final serverConfigModel = ServerConfigModel.fromEntity(config);
      final result = await localDataSource.saveServerConfig(serverConfigModel);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, MqttConfig>> getMqttConfig() async {
    try {
      final mqttConfig = await localDataSource.getMqttConfig();
      return Right(mqttConfig);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> saveMqttConfig(MqttConfig config) async {
    try {
      final mqttConfigModel = MqttConfigModel.fromEntity(config);
      final result = await localDataSource.saveMqttConfig(mqttConfigModel);
      return Right(result);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
