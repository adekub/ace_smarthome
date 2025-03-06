import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ace_smarthome/features/device/domain/entities/device.dart';
import 'package:ace_smarthome/features/device/presentation/bloc/device_bloc.dart';
import 'package:uuid/uuid.dart';

class AddDeviceBottomSheet extends StatefulWidget {
  const AddDeviceBottomSheet({Key? key}) : super(key: key);

  @override
  State<AddDeviceBottomSheet> createState() => _AddDeviceBottomSheetState();
}

class _AddDeviceBottomSheetState extends State<AddDeviceBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _deviceIdController = TextEditingController();
  final TextEditingController _switchesController =
      TextEditingController(text: '1');

  IconData _selectedIcon = Icons.devices;

  // List of available icons
  final List<IconData> _availableIcons = [
    Icons.lightbulb,
    Icons.tv,
    Icons.ac_unit,
    Icons.kitchen,
    Icons.toys,
    Icons.computer,
    Icons.router,
    Icons.videogame_asset,
    Icons.microwave,
    Icons.security,
    Icons.smartphone,
    Icons.laptop,
    Icons.tablet,
    Icons.speaker,
    Icons.router,
    Icons.camera_alt,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _deviceIdController.dispose();
    _switchesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Device',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Device name field
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Device Name',
                hintText: 'E.g. Living Room Lights',
                prefixIcon: Icon(Icons.edit),
              ),
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            // Device ID field
            TextField(
              controller: _deviceIdController,
              decoration: const InputDecoration(
                labelText: 'Device ID',
                hintText: 'Device unique identifier',
                prefixIcon: Icon(Icons.vpn_key),
              ),
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 16),

            // Number of switches field
            TextField(
              controller: _switchesController,
              decoration: const InputDecoration(
                labelText: 'Number of Switches',
                hintText: 'Enter a number',
                prefixIcon: Icon(Icons.power_settings_new),
              ),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
            ),

            const SizedBox(height: 24),

            // Icon selection
            Text(
              'Select Icon',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            // Icon grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: _availableIcons.length,
              itemBuilder: (context, index) {
                final IconData iconData = _availableIcons[index];
                final bool isSelected = _selectedIcon == iconData;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIcon = iconData;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2)
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      iconData,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                      size: 24,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Add button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addDevice,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add Device',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _addDevice() {
    // Validate inputs
    final name = _nameController.text.trim();
    final deviceID = _deviceIdController.text.trim();
    final numberOfSwitches = int.tryParse(_switchesController.text) ?? 1;

    if (name.isEmpty || deviceID.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device Name and Device ID are required'),
        ),
      );
      return;
    }

    // Create device
    final device = Device(
      id: const Uuid().v4(),
      name: name,
      icon: _selectedIcon,
      deviceID: deviceID,
      numberOfSwitches: numberOfSwitches,
      switchStates: List.filled(numberOfSwitches, false),
      switchNames: List.generate(
        numberOfSwitches,
        (index) => 'Switch ${index + 1}',
      ),
      schedules: {},
    );

    // Add device
    context.read<DeviceBloc>().add(AddDeviceEvent(device: device));

    // Close sheet
    Navigator.pop(context);
  }
}
