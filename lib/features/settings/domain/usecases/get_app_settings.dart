import 'package:ace_smarthome/features/settings/domain/entities/app_settings.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:ace_smarthome/core/error/failures.dart';
import 'package:ace_smarthome/features/settings/domain/repositories/settings_repository.dart';

@lazySingleton
class GetAppSettings {
  final SettingsRepository repository;

  GetAppSettings(this.repository);

  Future<Either<Failure, AppSettings>> call() async {
    return await repository.getAppSettings();
  }
}
