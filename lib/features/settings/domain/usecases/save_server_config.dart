import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:ace_smarthome/core/error/failures.dart';
import 'package:ace_smarthome/features/settings/domain/entities/server_config.dart';
import 'package:ace_smarthome/features/settings/domain/repositories/settings_repository.dart';

@lazySingleton
class SaveServerConfig {
  final SettingsRepository repository;

  SaveServerConfig(this.repository);

  Future<Either<Failure, bool>> call(ServerConfig config) async {
    return await repository.saveServerConfig(config);
  }
}
