import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final bool isDarkMode;

  const AppSettings({
    required this.isDarkMode,
  });

  factory AppSettings.defaultSettings() => const AppSettings(
        isDarkMode: false,
      );

  AppSettings copyWith({
    bool? isDarkMode,
  }) {
    return AppSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  @override
  List<Object?> get props => [isDarkMode];
}
