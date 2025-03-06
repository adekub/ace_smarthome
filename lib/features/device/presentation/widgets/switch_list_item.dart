import 'package:flutter/material.dart';
import 'package:ace_smarthome/features/device/domain/entities/device.dart';
import 'package:intl/intl.dart';

class SwitchListItem extends StatelessWidget {
  final Device device;
  final int switchIndex;
  final VoidCallback onToggle;
  final VoidCallback onScheduleTap;
  final VoidCallback onLongPress;

  const SwitchListItem({
    Key? key,
    required this.device,
    required this.switchIndex,
    required this.onToggle,
    required this.onScheduleTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSwitchOn = device.switchStates[switchIndex];
    final bool hasSchedule = device.schedules.containsKey(switchIndex);
    final schedule = hasSchedule ? device.schedules[switchIndex] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Material(
        color: Theme.of(context).cardColor,
        child: InkWell(
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Icon representing switch state
                Icon(
                  isSwitchOn ? Icons.toggle_on : Icons.toggle_off,
                  color: isSwitchOn
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  size: 28,
                ),
                const SizedBox(width: 16),

                // Switch name and schedule info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.switchNames[switchIndex],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (hasSchedule && schedule != null && schedule.isEnabled)
                        Row(
                          children: [
                            Icon(Icons.schedule,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _formatSchedule(schedule),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Schedule button with indicator
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.schedule,
                        color: hasSchedule &&
                                schedule != null &&
                                schedule.isEnabled
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                      onPressed: onScheduleTap,
                    ),
                    if (hasSchedule && schedule != null && schedule.isEnabled)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),

                // Switch
                Switch(
                  value: isSwitchOn,
                  onChanged: (_) => onToggle(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatSchedule(Schedule schedule) {
    if (!schedule.isEnabled) return 'Disabled';

    try {
      // Format time to make it more readable
      String onTime = _formatTime(schedule.onTime);
      String offTime = _formatTime(schedule.offTime);

      return 'On: $onTime, Off: $offTime${schedule.isDaily ? ' (Daily)' : ''}';
    } catch (e) {
      return 'On: ${schedule.onTime}, Off: ${schedule.offTime}';
    }
  }

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);

        final period = hour >= 12 ? 'PM' : 'AM';
        hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

        return '$hour:${minute.toString().padLeft(2, '0')} $period';
      }
      return timeStr;
    } catch (e) {
      return timeStr;
    }
  }
}
