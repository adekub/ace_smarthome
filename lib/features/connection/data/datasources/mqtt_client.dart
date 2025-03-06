import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ace_smarthome/core/error/exceptions.dart';
import 'package:ace_smarthome/core/utils/logger.dart';
import 'package:ace_smarthome/features/settings/domain/entities/mqtt_config.dart';
import 'package:ace_smarthome/features/settings/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

abstract class MqttClientWrapper {
  Future<bool> connect();
  void disconnect();
  bool get isConnected;
  Future<void> publishMessage(String topic, String message, {int qos = 0});
  Stream<Map<String, dynamic>> get messageStream;
}

@LazySingleton(as: MqttClientWrapper)
class MqttClientWrapperImpl implements MqttClientWrapper {
  final SettingsRepository settingsRepository;
  final AppLogger logger;

  MqttServerClient? _client;
  final StreamController<Map<String, dynamic>> _messageStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  MqttClientWrapperImpl({
    required this.settingsRepository,
    required this.logger,
  });

  @override
  Stream<Map<String, dynamic>> get messageStream =>
      _messageStreamController.stream;

  @override
  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  @override
  @override
  Future<bool> connect() async {
    try {
      final mqttConfigResult = await settingsRepository.getMqttConfig();

      return mqttConfigResult.fold(
        (failure) {
          logger.e('Failed to get MQTT config: ${failure.message}');
          return false;
        },
        (config) async {
          // แก้ไข broker URL จาก localhost เป็น IP จริง
          final updatedConfig = config.broker == 'localhost'
              ? config.copyWith(broker: '192.168.1.199')
              : config;

          // ทดลองเชื่อมต่อหลายครั้ง
          for (int retry = 0; retry < 3; retry++) {
            try {
              logger.i(
                  'Attempting to connect to MQTT broker: ${updatedConfig.broker}:${updatedConfig.port} (attempt ${retry + 1})');
              final result = await _initializeMqttClient(updatedConfig);
              if (result) {
                logger.i('Successfully connected to MQTT broker');
                return true;
              }
              await Future.delayed(Duration(seconds: 2));
            } catch (e) {
              logger.e('Error connecting to MQTT (attempt ${retry + 1}): $e');
              await Future.delayed(Duration(seconds: 2));
            }
          }

          // ถ้าเชื่อมต่อไม่สำเร็จ ให้ใช้ Dummy Mode
          logger.w(
              'Failed to connect to MQTT after 3 attempts, using dummy mode');
          _setupDummyMode();
          return false;
        },
      );
    } catch (e) {
      logger.e('Unexpected error in MQTT connect: $e');
      _setupDummyMode();
      return false;
    }
  }

// เพิ่มเมธอดใหม่สำหรับสร้าง dummy data
  void _setupDummyMode() {
    // สร้าง dummy device สำหรับทดสอบ
    Timer.periodic(Duration(seconds: 10), (timer) {
      final dummyMessage = {
        'topic': 'home/dummydevice/heartbeat',
        'payload': {
          'status': 'online',
          'timestamp': DateTime.now().millisecondsSinceEpoch
        },
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'isDummy': true
      };

      _messageStreamController.add(dummyMessage);

      // สร้าง dummy switch states ทุก 10 วินาที
      final dummySwitchMessage = {
        'topic': 'home/dummydevice/switches/status',
        'payload': {
          'states': [true, false, true, false],
          'timestamp': DateTime.now().millisecondsSinceEpoch
        },
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'isDummy': true
      };

      _messageStreamController.add(dummySwitchMessage);
    });
  }

  Future<bool> _initializeMqttClient(MqttConfig config) async {
    // Disconnect existing client if any
    disconnect();

    try {
      // Create new client
      final clientId =
          'ace_smarthome_app_${DateTime.now().millisecondsSinceEpoch}';
      _client = MqttServerClient(config.broker, clientId);

      // Set configuration
      _client!.port = config.port;
      _client!.keepAlivePeriod = 30;
      _client!.onDisconnected = _onDisconnected;
      _client!.onConnected = _onConnected;
      _client!.onSubscribed = _onSubscribed;

      // Set secure connection if needed
      if (config.useTls) {
        _client!.secure = true;
        _client!.securityContext = SecurityContext.defaultContext;
      }

      // Connect the client
      final connMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      _client!.connectionMessage = connMessage;

      try {
        await _client!.connect(config.username, config.password);
      } catch (e) {
        logger.e('Error connecting to MQTT broker: $e');
        return false;
      }

      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        logger.i('Connected to MQTT broker');

        // Setup message handling
        _client!.updates!.listen(_onMessage);

        // Subscribe to topics
        _subscribeToTopics();

        return true;
      } else {
        logger.e(
            'Failed to connect to MQTT broker: ${_client!.connectionStatus!.returnCode}');
        return false;
      }
    } catch (e) {
      logger.e('Error setting up MQTT client: $e');
      return false;
    }
  }

  void _subscribeToTopics() {
    try {
      // Subscribe to all device status topics
      _client!.subscribe('home/+/switches/status', MqttQos.atLeastOnce);
      _client!.subscribe('home/+/heartbeat', MqttQos.atLeastOnce);
    } catch (e) {
      logger.e('Error subscribing to topics: $e');
    }
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messageList) {
    for (final message in messageList) {
      try {
        final recMess = message.payload as MqttPublishMessage;
        final payload = utf8.decode(recMess.payload.message);

        // Parse payload to JSON if possible
        Map<String, dynamic> data;
        try {
          data = json.decode(payload);
        } catch (e) {
          data = {'raw': payload};
        }

        // Add topic to data
        data['topic'] = message.topic;

        // Send to stream
        _messageStreamController.add(data);
      } catch (e) {
        logger.e('Error processing message: $e');
      }
    }
  }

  void _onConnected() {
    logger.i('MQTT client connected');
  }

  void _onDisconnected() {
    logger.i('MQTT client disconnected');
  }

  void _onSubscribed(String topic) {
    logger.i('Subscription confirmed for topic $topic');
  }

  @override
  Future<void> publishMessage(String topic, String message,
      {int qos = 0}) async {
    if (!isConnected) {
      throw ServerException(message: 'MQTT client not connected');
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    try {
      _client!.publishMessage(
        topic,
        qos == 0 ? MqttQos.atMostOnce : MqttQos.atLeastOnce,
        builder.payload!,
      );
    } catch (e) {
      logger.e('Error publishing message: $e');
      throw ServerException(message: 'Failed to publish message: $e');
    }
  }

  @override
  void disconnect() {
    if (_client != null &&
        _client!.connectionStatus!.state == MqttConnectionState.connected) {
      _client!.disconnect();
    }
  }
}
