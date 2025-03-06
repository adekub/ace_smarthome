import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ace_smarthome/features/device/domain/entities/device.dart';
import 'package:ace_smarthome/features/device/presentation/bloc/device_bloc.dart';

class RenameSwitchDialog extends StatefulWidget {
  final Device device;
  final int switchIndex;

  const RenameSwitchDialog({
    Key? key,
    required this.device,
    required this.switchIndex,
  }) : super(key: key);

  @override
  State<RenameSwitchDialog> createState() => _RenameSwitchDialogState();
}

class _RenameSwitchDialogState extends State<RenameSwitchDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.device.switchNames[widget.switchIndex],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rename Switch'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Switch Name',
          hintText: 'Enter a name for this switch',
        ),
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => _renameSwitch(),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _renameSwitch() {
    final newName = _nameController.text.trim();

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Switch name cannot be empty'),
        ),
      );
      return;
    }

    // Create new switch names list
    final List<String> newSwitchNames = List.from(widget.device.switchNames);
    newSwitchNames[widget.switchIndex] = newName;

    // Update device
    final updatedDevice = widget.device.copyWith(switchNames: newSwitchNames);

    context.read<DeviceBloc>().add(UpdateDeviceEvent(device: updatedDevice));

    Navigator.pop(context);
  }
}
