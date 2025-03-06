import 'package:ace_smarthome/features/connection/presentation/bloc/connection_bloc.dart';
import 'package:ace_smarthome/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter/material.dart' hide ConnectionState;
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  // Server config controllers
  late TextEditingController _serverHostController;
  late TextEditingController _serverPortController;
  late TextEditingController _timeoutController;
  late TextEditingController _retryController;

  // MQTT config controllers
  late TextEditingController _mqttBrokerController;
  late TextEditingController _mqttPortController;
  late TextEditingController _mqttUsernameController;
  late TextEditingController _mqttPasswordController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with current settings
    final currentState = context.read<SettingsBloc>().state;

    // Server config
    _serverHostController =
        TextEditingController(text: currentState.serverConfig.host);
    _serverPortController =
        TextEditingController(text: currentState.serverConfig.port.toString());
    _timeoutController = TextEditingController(
        text: currentState.serverConfig.connectionTimeout.toString());
    _retryController = TextEditingController(
        text: currentState.serverConfig.retryInterval.toString());

    // MQTT config
    _mqttBrokerController =
        TextEditingController(text: currentState.mqttConfig.broker);
    _mqttPortController =
        TextEditingController(text: currentState.mqttConfig.port.toString());
    _mqttUsernameController =
        TextEditingController(text: currentState.mqttConfig.username);
    _mqttPasswordController =
        TextEditingController(text: currentState.mqttConfig.password);
  }

  @override
  void dispose() {
    // Dispose controllers
    _serverHostController.dispose();
    _serverPortController.dispose();
    _timeoutController.dispose();
    _retryController.dispose();
    _mqttBrokerController.dispose();
    _mqttPortController.dispose();
    _mqttUsernameController.dispose();
    _mqttPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          // Update controllers if settings change externally
          _serverHostController.text = state.serverConfig.host;
          _serverPortController.text = state.serverConfig.port.toString();
          _timeoutController.text =
              state.serverConfig.connectionTimeout.toString();
          _retryController.text = state.serverConfig.retryInterval.toString();

          _mqttBrokerController.text = state.mqttConfig.broker;
          _mqttPortController.text = state.mqttConfig.port.toString();
          _mqttUsernameController.text = state.mqttConfig.username;
          _mqttPasswordController.text = state.mqttConfig.password;
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Theme Settings
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appearance',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<SettingsBloc, SettingsState>(
                        builder: (context, state) {
                          return SwitchListTile(
                            title: const Text('Dark Mode'),
                            subtitle: const Text('Enable dark theme'),
                            value: state.themeMode == ThemeMode.dark,
                            onChanged: (value) {
                              context.read<SettingsBloc>().add(ToggleTheme());
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Server Settings
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Server Configuration',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed: _saveServerConfig,
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _serverHostController,
                        decoration: const InputDecoration(
                          labelText: 'Server Host',
                          hintText: 'e.g. 192.168.1.100',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Server host is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _serverPortController,
                        decoration: const InputDecoration(
                          labelText: 'Server Port',
                          hintText: 'e.g. 1880',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Server port is required';
                          }
                          final port = int.tryParse(value);
                          if (port == null || port <= 0 || port > 65535) {
                            return 'Port must be between 1 and 65535';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _timeoutController,
                              decoration: const InputDecoration(
                                labelText: 'Timeout (s)',
                                hintText: 'e.g. 5',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _retryController,
                              decoration: const InputDecoration(
                                labelText: 'Retry Interval (s)',
                                hintText: 'e.g. 30',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<SettingsBloc, SettingsState>(
                        builder: (context, state) {
                          return SwitchListTile(
                            title: const Text('Use HTTPS'),
                            subtitle: const Text('Enable secure connection'),
                            value: state.serverConfig.useSecureConnection,
                            onChanged: (value) {
                              final newConfig = state.serverConfig.copyWith(
                                useSecureConnection: value,
                              );
                              context.read<SettingsBloc>().add(
                                    UpdateServerConfig(config: newConfig),
                                  );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // MQTT Settings
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'MQTT Configuration',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed: _saveMqttConfig,
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _mqttBrokerController,
                        decoration: const InputDecoration(
                          labelText: 'MQTT Broker',
                          hintText: 'e.g. broker.hivemq.com',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'MQTT broker is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _mqttPortController,
                        decoration: const InputDecoration(
                          labelText: 'MQTT Port',
                          hintText: 'e.g. 1883',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'MQTT port is required';
                          }
                          final port = int.tryParse(value);
                          if (port == null || port <= 0 || port > 65535) {
                            return 'Port must be between 1 and 65535';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _mqttUsernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username (optional)',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _mqttPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Password (optional)',
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<SettingsBloc, SettingsState>(
                        builder: (context, state) {
                          return SwitchListTile(
                            title: const Text('Use TLS/SSL'),
                            subtitle: const Text('Enable secure connection'),
                            value: state.mqttConfig.useTls,
                            onChanged: (value) {
                              final newConfig = state.mqttConfig.copyWith(
                                useTls: value,
                              );
                              context.read<SettingsBloc>().add(
                                    UpdateMqttConfig(config: newConfig),
                                  );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<ConnectionBloc, ConnectionState>(
                        builder: (context, state) {
                          final bool isConnected = state is ConnectionConnected;

                          return Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: isConnected
                                      ? () {
                                          context.read<ConnectionBloc>().add(
                                                DisconnectMqtt(),
                                              );
                                        }
                                      : () {
                                          context.read<ConnectionBloc>().add(
                                                ConnectMqtt(),
                                              );
                                        },
                                  icon: Icon(
                                    isConnected ? Icons.link_off : Icons.link,
                                  ),
                                  label: Text(
                                    isConnected ? 'Disconnect' : 'Connect',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isConnected
                                        ? Colors.red
                                        : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Connection Status
              BlocBuilder<ConnectionBloc, ConnectionState>(
                builder: (context, state) {
                  String status = 'Unknown';
                  Color statusColor = Colors.grey;

                  if (state is ConnectionInitial) {
                    status = 'Initializing...';
                    statusColor = Colors.grey;
                  } else if (state is ConnectionOffline) {
                    status = 'Offline - No Internet Connection';
                    statusColor = Colors.red;
                  } else if (state is ConnectionOnline) {
                    status = 'Online - Not Connected to MQTT';
                    statusColor = Colors.orange;
                  } else if (state is ConnectionConnecting) {
                    status = 'Connecting to MQTT...';
                    statusColor = Colors.blue;
                  } else if (state is ConnectionConnected) {
                    status = 'Connected to MQTT';
                    statusColor = Colors.green;
                  }

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connection Status',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                status,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveServerConfig() {
    if (_formKey.currentState?.validate() ?? false) {
      final host = _serverHostController.text;
      final port = int.tryParse(_serverPortController.text) ?? 1880;
      final timeout = int.tryParse(_timeoutController.text) ?? 5;
      final retry = int.tryParse(_retryController.text) ?? 30;

      final currentConfig = context.read<SettingsBloc>().state.serverConfig;
      final newConfig = currentConfig.copyWith(
        host: host,
        port: port,
        connectionTimeout: timeout,
        retryInterval: retry,
      );

      context.read<SettingsBloc>().add(UpdateServerConfig(config: newConfig));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server settings saved')),
      );
    }
  }

  void _saveMqttConfig() {
    if (_formKey.currentState?.validate() ?? false) {
      final broker = _mqttBrokerController.text;
      final port = int.tryParse(_mqttPortController.text) ?? 1883;
      final username = _mqttUsernameController.text;
      final password = _mqttPasswordController.text;

      final currentConfig = context.read<SettingsBloc>().state.mqttConfig;
      final newConfig = currentConfig.copyWith(
        broker: broker,
        port: port,
        username: username,
        password: password,
      );

      context.read<SettingsBloc>().add(UpdateMqttConfig(config: newConfig));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('MQTT settings saved')),
      );

      // Reconnect if connected
      final connectionState = context.read<ConnectionBloc>().state;
      if (connectionState is ConnectionConnected) {
        context.read<ConnectionBloc>().add(DisconnectMqtt());
        context.read<ConnectionBloc>().add(ConnectMqtt());
      }
    }
  }
}
