import 'package:ace_smarthome/features/settings/domain/entities/mqtt_config.dart';

class MqttConfigModel extends MqttConfig {
  const MqttConfigModel({
    required String broker,
    required int port,
    required String username,
    required String password,
    required bool useTls,
    required String clientId,
  }) : super(
          broker: broker,
          port: port,
          username: username,
          password: password,
          useTls: useTls,
          clientId: clientId,
        );

  factory MqttConfigModel.fromJson(Map<String, dynamic> json) {
    return MqttConfigModel(
      broker: json['broker'] ?? 'localhost',
      port: json['port'] ?? 1883,
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      useTls: json['useTls'] ?? false,
      clientId: json['clientId'] ??
          'ace_smarthome_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'broker': broker,
      'port': port,
      'username': username,
      'password': password,
      'useTls': useTls,
      'clientId': clientId,
    };
  }

  factory MqttConfigModel.defaultConfig() => MqttConfigModel(
        broker: 'localhost',
        port: 1883,
        username: '',
        password: '',
        useTls: false,
        clientId: 'ace_smarthome_${DateTime.now().millisecondsSinceEpoch}',
      );

  factory MqttConfigModel.fromEntity(MqttConfig config) {
    return MqttConfigModel(
      broker: config.broker,
      port: config.port,
      username: config.username,
      password: config.password,
      useTls: config.useTls,
      clientId: config.clientId,
    );
  }
}
