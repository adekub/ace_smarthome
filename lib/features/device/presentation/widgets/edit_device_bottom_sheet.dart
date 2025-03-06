import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ace_smarthome/features/device/domain/entities/device.dart';
import 'package:ace_smarthome/features/device/presentation/bloc/device_bloc.dart';

class EditDeviceBottomSheet extends StatefulWidget {
  final Device device;

  const EditDeviceBottomSheet({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  State<EditDeviceBottomSheet> createState() => _EditDeviceBottomSheetState();
}

class _EditDeviceBottomSheetState extends State<EditDeviceBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _deviceIdController;
  late TextEditingController _switchesController;

  late IconData _selectedIcon;

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
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.device.name);
    _deviceIdController = TextEditingController(text: widget.device.deviceID);
    _switchesController =
        TextEditingController(text: widget.device.numberOfSwitches.toString());
    _selectedIcon = widget.device.icon;
  }

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
                  'Edit Device',
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

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateDevice,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
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

  void _updateDevice() {
    // Validate inputs
    final name = _nameController.text.trim();
    final deviceID = _deviceIdController.text.trim();
    final numberOfSwitchesNew = int.tryParse(_switchesController.text) ?? 1;

    if (name.isEmpty || deviceID.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Device Name and Device ID are required'),
        ),
      );
      return;
    }

    // Adjust switch states and names if number of switches changed
    List<bool> newSwitchStates = List.from(widget.device.switchStates);
    List<String> newSwitchNames = List.from(widget.device.switchNames);

    if (numberOfSwitchesNew > widget.device.numberOfSwitches) {
      // Add new switches
      newSwitchStates.addAll(List.filled(
        numberOfSwitchesNew - widget.device.numberOfSwitches,
        false,
      ));

      newSwitchNames.addAll(List.generate(
        numberOfSwitchesNew - widget.device.numberOfSwitches,
        (index) => 'Switch ${widget.device.numberOfSwitches + index + 1}',
      ));
    } else if (numberOfSwitchesNew < widget.device.numberOfSwitches) {
      // Remove excess switches
      newSwitchStates = newSwitchStates.sublist(0, numberOfSwitchesNew);
      newSwitchNames = newSwitchNames.sublist(0, numberOfSwitchesNew);
    }

    // Update device
    final updatedDevice = widget.device.copyWith(
      name: name,
      deviceID: deviceID,
      numberOfSwitches: numberOfSwitchesNew,
      icon: _selectedIcon,
      switchStates: newSwitchStates,
      switchNames: newSwitchNames,
    );

    // Update in bloc
    context.read<DeviceBloc>().add(UpdateDeviceEvent(device: updatedDevice));

    // Close sheet
    Navigator.pop(context);
  }
}
