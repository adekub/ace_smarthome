import 'package:ace_smarthome/features/settings/domain/entities/app_settings.dart';

class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    required bool isDarkMode,
  }) : super(isDarkMode: isDarkMode);

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      isDarkMode: json['isDarkMode'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
    };
  }

  factory AppSettingsModel.defaultSettings() => const AppSettingsModel(
        isDarkMode: false,
      );

  factory AppSettingsModel.fromEntity(AppSettings settings) {
    return AppSettingsModel(
      isDarkMode: settings.isDarkMode,
    );
  }
}
