import 'package:flutter/material.dart' hide ConnectionState; // <--- แก้ตรงนี้
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ace_smarthome/features/device/domain/entities/device.dart';
import 'package:ace_smarthome/features/device/presentation/bloc/device_bloc.dart';
import 'package:ace_smarthome/features/device/presentation/widgets/device_card.dart';
import 'package:ace_smarthome/features/device/presentation/widgets/add_device_bottom_sheet.dart';
import 'package:ace_smarthome/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:ace_smarthome/features/connection/presentation/bloc/connection_bloc.dart';
import 'package:ace_smarthome/core/widgets/animated_app_bar.dart';
import 'package:ace_smarthome/core/widgets/theme_toggle.dart';
import 'package:ace_smarthome/core/widgets/empty_device_view.dart';
import 'package:ace_smarthome/core/widgets/connection_status_banner.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Start connection monitoring
    context.read<DeviceBloc>().add(StartConnectionMonitoringEvent());
    context.read<ConnectionBloc>().add(MonitorConnection());
  }

  @override
  void dispose() {
    _animationController.dispose();
    context.read<DeviceBloc>().add(StopConnectionMonitoringEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Connection status banner shows when offline
            BlocBuilder<ConnectionBloc, ConnectionState>(
              builder: (context, state) {
                if (state is ConnectionOffline) {
                  return const ConnectionStatusBanner(
                    isConnected: false,
                    message: 'You are offline. Some features may be limited.',
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Animated app bar
            AnimatedAppBar(
              title: 'AceCom SmartHome',
              animationController: _animationController,
              actions: [
                // Theme toggle button
                ThemeToggle(
                  onToggle: () {
                    context.read<SettingsBloc>().add(ToggleTheme());
                  },
                  isDarkMode: context.read<SettingsBloc>().state.themeMode ==
                      ThemeMode.dark,
                ),

                // Add device button
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const AddDeviceBottomSheet(),
                    );
                  },
                ),
              ],
            ),

            // Main content area with device list
            Expanded(
              child: BlocBuilder<DeviceBloc, DeviceState>(
                builder: (context, state) {
                  if (state is DeviceLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is DeviceLoaded) {
                    final devices = state.devices;

                    if (devices.isEmpty) {
                      return const EmptyDeviceView(
                        message:
                            'No devices added yet. Tap the + button to add a device.',
                      );
                    }

                    return _buildDeviceGrid(devices);
                  } else if (state is DeviceError) {
                    return Center(
                      child: Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.security), label: 'Security'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          // TODO: Implement navigation to other tabs
        },
      ),
    );
  }

  Widget _buildDeviceGrid(List<Device> devices) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the number of columns based on width
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

        return RefreshIndicator(
          onRefresh: () async {
            context.read<DeviceBloc>().add(LoadDevices());
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return DeviceCard(device: device);
            },
          ),
        );
      },
    );
  }
}
