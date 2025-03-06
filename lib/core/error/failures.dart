import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message: message);
}

class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure({required String message}) : super(message: message);
}

class DeviceFailure extends Failure {
  const DeviceFailure({required String message}) : super(message: message);
}
