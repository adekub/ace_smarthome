import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ConnectionStatusBanner extends StatelessWidget {
  final bool isConnected;
  final String message;

  const ConnectionStatusBanner({
    Key? key,
    required this.isConnected,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isConnected ? Colors.green : Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: color.withOpacity(0.8),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.wifi : Icons.wifi_off,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          if (!isConnected)
            TextButton(
              onPressed: () {
                // Can be connected to a bloc event to retry connection
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 14),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Retry'),
            ),
        ],
      ),
    ).animate().slideY(
          begin: -1.0,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutBack,
        );
  }
}
