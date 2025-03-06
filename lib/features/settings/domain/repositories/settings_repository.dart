import 'package:ace_smarthome/core/error/failures.dart';
import 'package:ace_smarthome/features/settings/domain/entities/mqtt_config.dart';
import 'package:ace_smarthome/features/settings/domain/entities/server_config.dart';
import 'package:dartz/dartz.dart';

import '../entities/app_settings.dart';

abstract class SettingsRepository {
  Future<Either<Failure, AppSettings>> getAppSettings();
  Future<Either<Failure, bool>> saveAppSettings(AppSettings settings);
  Future<Either<Failure, ServerConfig>> getServerConfig();
  Future<Either<Failure, bool>> saveServerConfig(ServerConfig config);
  Future<Either<Failure, MqttConfig>> getMqttConfig();
  Future<Either<Failure, bool>> saveMqttConfig(MqttConfig config);
}
