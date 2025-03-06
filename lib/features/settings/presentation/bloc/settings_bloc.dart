import 'dart:async';
import 'package:ace_smarthome/features/settings/domain/usecases/get_mqtt_config.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/entities/mqtt_config.dart';
import '../../domain/entities/server_config.dart';
import '../../domain/usecases/get_app_settings.dart';
import '../../domain/usecases/get_server_config.dart';
import '../../domain/usecases/save_app_settings.dart';
import '../../domain/usecases/save_mqtt_config.dart';
import '../../domain/usecases/save_server_config.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetAppSettings getAppSettings;
  final SaveAppSettings saveAppSettings;
  final GetServerConfig getServerConfig;
  final SaveServerConfig saveServerConfig;
  final GetMqttConfig getMqttConfig;
  final SaveMqttConfig saveMqttConfig;

  SettingsBloc({
    required this.getAppSettings,
    required this.saveAppSettings,
    required this.getServerConfig,
    required this.saveServerConfig,
    required this.getMqttConfig,
    required this.saveMqttConfig,
  }) : super(SettingsState.initial()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleTheme>(_onToggleTheme);
    on<UpdateServerConfig>(_onUpdateServerConfig);
    on<UpdateMqttConfig>(_onUpdateMqttConfig);
  }

  FutureOr<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    // Load app settings
    final appSettingsResult = await getAppSettings();
    final serverConfigResult = await getServerConfig();
    final mqttConfigResult = await getMqttConfig();

    final AppSettings appSettings = appSettingsResult.fold(
      (failure) => AppSettings.defaultSettings(),
      (settings) => settings,
    );

    final ServerConfig serverConfig = serverConfigResult.fold(
      (failure) => ServerConfig.defaultConfig(),
      (config) => config,
    );

    final MqttConfig mqttConfig = mqttConfigResult.fold(
      (failure) => MqttConfig.defaultConfig(),
      (config) => config,
    );

    emit(state.copyWith(
      themeMode: appSettings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      serverConfig: serverConfig,
      mqttConfig: mqttConfig,
    ));
  }

  FutureOr<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<SettingsState> emit,
  ) async {
    final newThemeMode =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

    emit(state.copyWith(themeMode: newThemeMode));

    await saveAppSettings(AppSettings(
      isDarkMode: newThemeMode == ThemeMode.dark,
    ));
  }

  FutureOr<void> _onUpdateServerConfig(
    UpdateServerConfig event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(serverConfig: event.config));
    await saveServerConfig(event.config);
  }

  FutureOr<void> _onUpdateMqttConfig(
    UpdateMqttConfig event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(mqttConfig: event.config));
    await saveMqttConfig(event.config);
  }
}

// Settings Event
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadSettings extends SettingsEvent {}

class ToggleTheme extends SettingsEvent {}

class UpdateServerConfig extends SettingsEvent {
  final ServerConfig config;

  const UpdateServerConfig({required this.config});

  @override
  List<Object> get props => [config];
}

class UpdateMqttConfig extends SettingsEvent {
  final MqttConfig config;

  const UpdateMqttConfig({required this.config});

  @override
  List<Object> get props => [config];
}

// Settings State
class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final ServerConfig serverConfig;
  final MqttConfig mqttConfig;

  const SettingsState({
    required this.themeMode,
    required this.serverConfig,
    required this.mqttConfig,
  });

  factory SettingsState.initial() => SettingsState(
        themeMode: ThemeMode.system,
        serverConfig: ServerConfig.defaultConfig(),
        mqttConfig: MqttConfig.defaultConfig(),
      );

  SettingsState copyWith({
    ThemeMode? themeMode,
    ServerConfig? serverConfig,
    MqttConfig? mqttConfig,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      serverConfig: serverConfig ?? this.serverConfig,
      mqttConfig: mqttConfig ?? this.mqttConfig,
    );
  }

  @override
  List<Object> get props => [themeMode, serverConfig, mqttConfig];
}
