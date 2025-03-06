import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ace_smarthome/features/device/domain/entities/device.dart';
import 'package:ace_smarthome/features/device/presentation/bloc/device_bloc.dart';
import 'package:ace_smarthome/features/device/presentation/pages/device_detail_page.dart';
import 'package:ace_smarthome/features/device/presentation/widgets/edit_device_bottom_sheet.dart';

class DeviceCard extends StatelessWidget {
  final Device device;

  const DeviceCard({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Hero(
      tag: 'device-${device.id}',
      child: GestureDetector(
        onTap: () {
          if (device.isConnected) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DeviceDetailPage(device: device),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${device.name} is not connected. Please check the connection.'),
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () {
                    context.read<DeviceBloc>().add(
                          CheckDeviceConnectionEvent(deviceId: device.id),
                        );
                  },
                ),
              ),
            );
          }
        },
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Card content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon with connection status
                    Stack(
                      children: [
                        Icon(
                          device.icon,
                          size: 32,
                          color: colorScheme.primary,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: device.isConnected
                                  ? Colors.green
                                  : Colors.red,
                              border: Border.all(
                                color: Theme.of(context).cardColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Switch status summary
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Device name
                        Text(
                          device.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        // Active switches count
                        Text(
                          '${device.switchStates.where((state) => state).length}/${device.numberOfSwitches} active',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Menu button
              Positioned(
                top: 4,
                right: 4,
                child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    switch (value) {
                      case 'Edit':
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) =>
                              EditDeviceBottomSheet(device: device),
                        );
                        break;
                      case 'Delete':
                        _showDeleteConfirmation(context);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return {
                      'Edit': Icons.edit,
                      'Delete': Icons.delete,
                    }.entries.map((entry) {
                      return PopupMenuItem<String>(
                        value: entry.key,
                        child: Row(
                          children: [
                            Icon(
                              entry.value,
                              size: 20,
                              color: entry.key == 'Delete' ? Colors.red : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              entry.key,
                              style: TextStyle(
                                color:
                                    entry.key == 'Delete' ? Colors.red : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms, delay: 50.ms).slideY(
              begin: 0.1,
              end: 0,
              duration: 300.ms,
              curve: Curves.easeOutQuad,
            ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Device'),
          content: Text('Are you sure you want to delete ${device.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<DeviceBloc>().add(
                      DeleteDeviceEvent(deviceId: device.id),
                    );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
