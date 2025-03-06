import 'package:equatable/equatable.dart';

class MqttConfig extends Equatable {
  final String broker;
  final int port;
  final String username;
  final String password;
  final bool useTls;
  final String clientId;

  const MqttConfig({
    required this.broker,
    required this.port,
    required this.username,
    required this.password,
    required this.useTls,
    required this.clientId,
  });

  factory MqttConfig.defaultConfig() => MqttConfig(
        broker: '192.168.1.199', // เปลี่ยนจาก localhost เป็น IP ที่แน่นอน
        port: 1883,
        username: '',
        password: '',
        useTls: false,
        clientId: 'acecom_smart_home_${DateTime.now().millisecondsSinceEpoch}',
      );

  MqttConfig copyWith({
    String? broker,
    int? port,
    String? username,
    String? password,
    bool? useTls,
    String? clientId,
  }) {
    return MqttConfig(
      broker: broker ?? this.broker,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      useTls: useTls ?? this.useTls,
      clientId: clientId ?? this.clientId,
    );
  }

  @override
  List<Object?> get props => [
        broker,
        port,
        username,
        password,
        useTls,
        clientId,
      ];
}
