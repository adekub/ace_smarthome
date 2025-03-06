import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:ace_smarthome/core/error/failures.dart';
import 'package:ace_smarthome/features/settings/domain/entities/app_settings.dart';
import 'package:ace_smarthome/features/settings/domain/repositories/settings_repository.dart';

@lazySingleton
class SaveAppSettings {
  final SettingsRepository repository;

  SaveAppSettings(this.repository);

  Future<Either<Failure, bool>> call(AppSettings settings) async {
    return await repository.saveAppSettings(settings);
  }
}
