import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:ace_smarthome/core/error/failures.dart';
import 'package:ace_smarthome/features/settings/domain/entities/mqtt_config.dart';
import 'package:ace_smarthome/features/settings/domain/repositories/settings_repository.dart';

@lazySingleton
class SaveMqttConfig {
  final SettingsRepository repository;

  SaveMqttConfig(this.repository);

  Future<Either<Failure, bool>> call(MqttConfig config) async {
    return await repository.saveMqttConfig(config);
  }
}
