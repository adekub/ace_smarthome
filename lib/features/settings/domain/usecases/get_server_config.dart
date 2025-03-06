import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:ace_smarthome/core/error/failures.dart';
import 'package:ace_smarthome/features/settings/domain/entities/server_config.dart';
import 'package:ace_smarthome/features/settings/domain/repositories/settings_repository.dart';

@lazySingleton
class GetServerConfig {
  final SettingsRepository repository;

  GetServerConfig(this.repository);

  Future<Either<Failure, ServerConfig>> call() async {
    return await repository.getServerConfig();
  }
}
