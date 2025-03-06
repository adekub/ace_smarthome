import 'dart:async';
import 'package:ace_smarthome/features/connection/data/datasources/mqtt_client.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

@injectable
class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  final Connectivity connectivity;
  final MqttClientWrapper mqttClient;

  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  StreamSubscription<Map<String, dynamic>>? _mqttSubscription;

  ConnectionBloc({
    required this.connectivity,
    required this.mqttClient,
  }) : super(ConnectionInitial()) {
    on<InitConnection>(_onInitConnection);
    on<MonitorConnection>(_onMonitorConnection);
    on<ConnectionChanged>(_onConnectionChanged);
    on<MqttMessageReceived>(_onMqttMessageReceived);
    on<ConnectMqtt>(_onConnectMqtt);
    on<DisconnectMqtt>(_onDisconnectMqtt);
  }

  Future<void> _onInitConnection(
    InitConnection event,
    Emitter<ConnectionState> emit,
  ) async {
    final connectivityResult = await connectivity.checkConnectivity();
    final bool hasConnectivity = connectivityResult != ConnectivityResult.none;

    if (hasConnectivity) {
      emit(ConnectionOnline());
      add(ConnectMqtt());
    } else {
      emit(ConnectionOffline());
    }
  }

  Future<void> _onMonitorConnection(
    MonitorConnection event,
    Emitter<ConnectionState> emit,
  ) async {
    // Cancel existing subscriptions
    await _connectivitySubscription?.cancel();
    await _mqttSubscription?.cancel();

    // Initialize connection
    add(InitConnection());

    // Set up connectivity stream
    _connectivitySubscription =
        connectivity.onConnectivityChanged.listen((result) {
      add(ConnectionChanged(
          hasConnectivity: result != ConnectivityResult.none));
    });

    // Set up MQTT message stream
    _mqttSubscription = mqttClient.messageStream.listen((message) {
      add(MqttMessageReceived(message: message));
    });
  }

  Future<void> _onConnectionChanged(
    ConnectionChanged event,
    Emitter<ConnectionState> emit,
  ) async {
    if (event.hasConnectivity) {
      emit(ConnectionOnline());
      add(ConnectMqtt());
    } else {
      emit(ConnectionOffline());
    }
  }

  Future<void> _onMqttMessageReceived(
    MqttMessageReceived event,
    Emitter<ConnectionState> emit,
  ) async {
    // Current state remains the same, we're just processing the message
    // The message is available to other blocs via the MQTT client's messageStream
  }

  Future<void> _onConnectMqtt(
    ConnectMqtt event,
    Emitter<ConnectionState> emit,
  ) async {
    if (state is ConnectionOnline) {
      emit(ConnectionConnecting());

      final connected = await mqttClient.connect();

      if (connected) {
        emit(ConnectionConnected());
      } else {
        emit(ConnectionOnline());
      }
    }
  }

  Future<void> _onDisconnectMqtt(
    DisconnectMqtt event,
    Emitter<ConnectionState> emit,
  ) async {
    mqttClient.disconnect();

    if (state is ConnectionConnected) {
      emit(ConnectionOnline());
    }
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    _mqttSubscription?.cancel();
    mqttClient.disconnect();
    return super.close();
  }
}

// Connection Event
abstract class ConnectionEvent extends Equatable {
  const ConnectionEvent();

  @override
  List<Object> get props => [];
}

class InitConnection extends ConnectionEvent {}

class MonitorConnection extends ConnectionEvent {}

class ConnectionChanged extends ConnectionEvent {
  final bool hasConnectivity;

  const ConnectionChanged({required this.hasConnectivity});

  @override
  List<Object> get props => [hasConnectivity];
}

class MqttMessageReceived extends ConnectionEvent {
  final Map<String, dynamic> message;

  const MqttMessageReceived({required this.message});

  @override
  List<Object> get props => [message];
}

class ConnectMqtt extends ConnectionEvent {}

class DisconnectMqtt extends ConnectionEvent {}

// Connection State
abstract class ConnectionState extends Equatable {
  const ConnectionState();

  @override
  List<Object> get props => [];
}

class ConnectionInitial extends ConnectionState {}

class ConnectionOnline extends ConnectionState {}

class ConnectionOffline extends ConnectionState {}

class ConnectionConnecting extends ConnectionState {}

class ConnectionConnected extends ConnectionState {}
