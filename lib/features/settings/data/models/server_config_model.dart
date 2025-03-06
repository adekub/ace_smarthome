import 'package:ace_smarthome/features/settings/domain/entities/server_config.dart';

class ServerConfigModel extends ServerConfig {
  const ServerConfigModel({
    required String host,
    required int port,
    required bool useSecureConnection,
    required int connectionTimeout,
    required int retryInterval,
  }) : super(
          host: host,
          port: port,
          useSecureConnection: useSecureConnection,
          connectionTimeout: connectionTimeout,
          retryInterval: retryInterval,
        );

  factory ServerConfigModel.fromJson(Map<String, dynamic> json) {
    return ServerConfigModel(
      host: json['host'] ?? '192.168.1.199',
      port: json['port'] ?? 1880,
      useSecureConnection: json['useSecureConnection'] ?? false,
      connectionTimeout: json['connectionTimeout'] ?? 5,
      retryInterval: json['retryInterval'] ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'port': port,
      'useSecureConnection': useSecureConnection,
      'connectionTimeout': connectionTimeout,
      'retryInterval': retryInterval,
    };
  }

  factory ServerConfigModel.defaultConfig() => const ServerConfigModel(
        host: '192.168.1.199',
        port: 1880,
        useSecureConnection: false,
        connectionTimeout: 5,
        retryInterval: 30,
      );

  factory ServerConfigModel.fromEntity(ServerConfig config) {
    return ServerConfigModel(
      host: config.host,
      port: config.port,
      useSecureConnection: config.useSecureConnection,
      connectionTimeout: config.connectionTimeout,
      retryInterval: config.retryInterval,
    );
  }
}
