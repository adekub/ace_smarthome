import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ace_smarthome/features/device/domain/entities/device.dart';
import 'package:ace_smarthome/features/device/presentation/bloc/device_bloc.dart';
import 'package:ace_smarthome/features/device/presentation/widgets/switch_list_item.dart';
import 'package:ace_smarthome/features/device/presentation/widgets/schedule_bottom_sheet.dart';
import 'package:ace_smarthome/features/device/presentation/widgets/rename_switch_dialog.dart';

class DeviceDetailPage extends StatelessWidget {
  final Device device;

  const DeviceDetailPage({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min, // เพิ่มบรรทัดนี้เพื่อแก้ overflow
          children: [
            Icon(device.icon, size: 24),
            const SizedBox(width: 8),
            Flexible(
                child: Text(device.name,
                    overflow:
                        TextOverflow.ellipsis)), // ใช้ Flexible + ellipsis
          ],
        ),
        actions: [
          BlocBuilder<DeviceBloc, DeviceState>(
            builder: (context, state) {
              if (state is DeviceLoaded) {
                // แก้ไขส่วนนี้ที่เกิด error
                Device currentDevice;
                try {
                  currentDevice =
                      state.devices.firstWhere((d) => d.id == device.id);
                } catch (_) {
                  currentDevice = device;
                }

                return Badge(
                  backgroundColor:
                      currentDevice.isConnected ? Colors.green : Colors.red,
                  label: Text(
                    currentDevice.isConnected ? 'Online' : 'Offline',
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                  offset: const Offset(-12, 0),
                  child: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<DeviceBloc>().add(
                            CheckDeviceConnectionEvent(deviceId: device.id),
                          );
                    },
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<DeviceBloc, DeviceState>(
        builder: (context, state) {
          if (state is DeviceLoaded) {
            // แก้ไขส่วนนี้เช่นกัน
            Device currentDevice;
            try {
              currentDevice =
                  state.devices.firstWhere((d) => d.id == device.id);
            } catch (_) {
              currentDevice = device;
            }

            return Column(
              children: [
                // All switches control
                _buildAllSwitchesControl(context, currentDevice),

                // Divider
                const Divider(height: 1),

                // Switches list
                Expanded(
                  child: _buildSwitchesList(context, currentDevice),
                ),
              ],
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildAllSwitchesControl(BuildContext context, Device currentDevice) {
    final bool allOn = currentDevice.switchStates.every((state) => state);

    return Material(
      color: Theme.of(context).cardColor,
      elevation: 2,
      child: InkWell(
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => ScheduleBottomSheet(
              device: currentDevice,
              switchIndex: -1, // -1 for all switches
              schedule: currentDevice.schedules[-1],
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon
              Icon(
                Icons.power_settings_new,
                color:
                    allOn ? Theme.of(context).colorScheme.primary : Colors.grey,
                size: 28,
              ),
              const SizedBox(width: 16),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'All Switches',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (currentDevice.schedules.containsKey(-1))
                      Text(
                        '📅 ${_formatSchedule(currentDevice.schedules[-1]!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),

              // Switch
              Switch(
                value: allOn,
                onChanged: (value) {
                  context.read<DeviceBloc>().add(
                        ToggleAllSwitchesEvent(
                          deviceId: currentDevice.id,
                          state: value,
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

  Widget _buildSwitchesList(BuildContext context, Device currentDevice) {
    return ReorderableListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: currentDevice.numberOfSwitches,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }

        // Create new lists with reordered items
        final switchNames = List<String>.from(currentDevice.switchNames);
        final switchStates = List<bool>.from(currentDevice.switchStates);

        // Reorder the items
        final String movedName = switchNames.removeAt(oldIndex);
        final bool movedState = switchStates.removeAt(oldIndex);

        switchNames.insert(newIndex, movedName);
        switchStates.insert(newIndex, movedState);

        // Update the device
        context.read<DeviceBloc>().add(
              UpdateDeviceEvent(
                device: currentDevice.copyWith(
                  switchNames: switchNames,
                  switchStates: switchStates,
                ),
              ),
            );
      },
      itemBuilder: (context, index) {
        return SwitchListItem(
          key: ValueKey('switch-$index'),
          device: currentDevice,
          switchIndex: index,
          onToggle: () {
            context.read<DeviceBloc>().add(
                  ToggleDeviceSwitchEvent(
                    deviceId: currentDevice.id,
                    switchIndex: index,
                  ),
                );
          },
          onScheduleTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => ScheduleBottomSheet(
                device: currentDevice,
                switchIndex: index,
                schedule: currentDevice.schedules[index],
              ),
            );
          },
          onLongPress: () {
            showDialog(
              context: context,
              builder: (context) => RenameSwitchDialog(
                device: currentDevice,
                switchIndex: index,
              ),
            );
          },
        );
      },
    );
  }

  String _formatSchedule(Schedule schedule) {
    if (!schedule.isEnabled) return 'Schedule disabled';

    return 'On: ${schedule.onTime}, Off: ${schedule.offTime}${schedule.isDaily ? ' (Daily)' : ''}';
  }
}
