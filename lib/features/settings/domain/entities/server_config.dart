import 'package:equatable/equatable.dart';

class ServerConfig extends Equatable {
  final String host;
  final int port;
  final bool useSecureConnection;
  final int connectionTimeout;
  final int retryInterval;

  const ServerConfig({
    required this.host,
    required this.port,
    required this.useSecureConnection,
    required this.connectionTimeout,
    required this.retryInterval,
  });

  factory ServerConfig.defaultConfig() => const ServerConfig(
        host: '192.168.1.199',
        port: 1880,
        useSecureConnection: false,
        connectionTimeout: 5,
        retryInterval: 30,
      );

  ServerConfig copyWith({
    String? host,
    int? port,
    bool? useSecureConnection,
    int? connectionTimeout,
    int? retryInterval,
  }) {
    return ServerConfig(
      host: host ?? this.host,
      port: port ?? this.port,
      useSecureConnection: useSecureConnection ?? this.useSecureConnection,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      retryInterval: retryInterval ?? this.retryInterval,
    );
  }

  @override
  List<Object?> get props => [
        host,
        port,
        useSecureConnection,
        connectionTimeout,
        retryInterval,
      ];
}
