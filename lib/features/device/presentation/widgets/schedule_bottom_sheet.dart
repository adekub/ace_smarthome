import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ace_smarthome/features/device/domain/entities/device.dart';
import 'package:ace_smarthome/features/device/presentation/bloc/device_bloc.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final Device device;
  final int switchIndex;
  final Schedule? schedule;

  const ScheduleBottomSheet({
    Key? key,
    required this.device,
    required this.switchIndex,
    this.schedule,
  }) : super(key: key);

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  late bool _isEnabled;
  late bool _isDaily;
  TimeOfDay? _onTime;
  TimeOfDay? _offTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    // Initialize with existing schedule if available
    if (widget.schedule != null) {
      _isEnabled = widget.schedule!.isEnabled;
      _isDaily = widget.schedule!.isDaily;

      // Parse time strings
      if (widget.schedule!.onTime.isNotEmpty) {
        final parts = widget.schedule!.onTime.split(':');
        if (parts.length >= 2) {
          _onTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }

      if (widget.schedule!.offTime.isNotEmpty) {
        final parts = widget.schedule!.offTime.split(':');
        if (parts.length >= 2) {
          _offTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }
    } else {
      _isEnabled = false;
      _isDaily = true;
      _onTime = null;
      _offTime = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeviceBloc, DeviceState>(
      listenWhen: (previous, current) {
        // Only respond to state changes that happened after pressing save
        return _isSaving &&
            (current is DeviceLoaded ||
                current is DeviceOperationSuccess ||
                current is DeviceOperationError);
      },
      listener: (context, state) {
        if (state is DeviceLoaded || state is DeviceOperationSuccess) {
          // When save is complete, reset saving flag and close the sheet
          setState(() => _isSaving = false);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Schedule saved successfully')),
          );
        } else if (state is DeviceOperationError) {
          // On error, reset flag but keep the sheet open
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(24),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.switchIndex == -1
                      ? 'Schedule All Switches'
                      : 'Schedule ${widget.device.switchNames[widget.switchIndex]}',
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

            // Current schedule info (new!)
            if (widget.schedule != null && widget.schedule!.isEnabled)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Current Schedule',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ON: ${_formatTimeOfDay(_onTime)} • OFF: ${_formatTimeOfDay(_offTime)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      widget.schedule!.isDaily ? 'Repeats daily' : 'Runs once',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Enable switch
            SwitchListTile(
              title: const Text('Enable Schedule'),
              subtitle: const Text('Turn scheduling on or off'),
              value: _isEnabled,
              onChanged: (value) {
                setState(() {
                  _isEnabled = value;
                });
              },
              secondary: Icon(
                Icons.power_settings_new,
                color: _isEnabled
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),

            // Daily repeat switch
            SwitchListTile(
              title: const Text('Repeat Daily'),
              subtitle: const Text('Schedule repeats every day'),
              value: _isDaily,
              onChanged: _isEnabled
                  ? (value) {
                      setState(() {
                        _isDaily = value;
                      });
                    }
                  : null,
              secondary: Icon(
                Icons.repeat,
                color: _isEnabled && _isDaily
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ),

            const Divider(height: 32),

            // Time selection
            if (_isEnabled) ...[
              // On time
              ListTile(
                leading: Icon(
                  Icons.wb_sunny_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('ON Time'),
                subtitle: _onTime != null
                    ? Text(_onTime!.format(context))
                    : const Text('Not set'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _onTime ?? TimeOfDay.now(),
                  );

                  if (time != null) {
                    setState(() {
                      _onTime = time;
                    });
                  }
                },
              ),

              // Off time
              ListTile(
                leading: Icon(
                  Icons.nightlight_round,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text('OFF Time'),
                subtitle: _offTime != null
                    ? Text(_offTime!.format(context))
                    : const Text('Not set'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _offTime ?? TimeOfDay.now(),
                  );

                  if (time != null) {
                    setState(() {
                      _offTime = time;
                    });
                  }
                },
              ),
            ],

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveSchedule,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Schedule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Delete button (only shown for existing schedules)
            if (widget.schedule != null && widget.schedule!.isEnabled)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isSaving ? null : _deleteSchedule,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    foregroundColor: Colors.red,
                  ),
                  child: Text(
                    _isSaving ? 'Processing...' : 'Delete Schedule',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _saveSchedule() {
    if (_isEnabled && (_onTime == null || _offTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both ON and OFF times'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final schedule = Schedule(
      onTime: _onTime != null ? '${_onTime!.hour}:${_onTime!.minute}' : '',
      offTime: _offTime != null ? '${_offTime!.hour}:${_offTime!.minute}' : '',
      isEnabled: _isEnabled,
      isDaily: _isDaily,
    );

    context.read<DeviceBloc>().add(
          SetScheduleEvent(
            deviceId: widget.device.id,
            switchIndex: widget.switchIndex,
            schedule: schedule,
          ),
        );
  }

  void _deleteSchedule() {
    setState(() {
      _isSaving = true;
    });

    final schedule = Schedule(
      onTime: '',
      offTime: '',
      isEnabled: false,
      isDaily: true,
    );

    context.read<DeviceBloc>().add(
          SetScheduleEvent(
            deviceId: widget.device.id,
            switchIndex: widget.switchIndex,
            schedule: schedule,
          ),
        );
  }

  // Helper to format TimeOfDay or handle null
  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return 'Not set';

    final period = time.hour < 12 ? 'AM' : 'PM';
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }
}
