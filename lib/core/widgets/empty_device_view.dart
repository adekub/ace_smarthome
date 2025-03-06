import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';  // ถ้ายังไม่มีไฟล์ animation ให้ comment ส่วนนี้ไว้ก่อน

class EmptyDeviceView extends StatelessWidget {
  final String message;

  const EmptyDeviceView({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // เพิ่มบรรทัดนี้!
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // แทนที่ Lottie animation ด้วย Icon ธรรมดา
            Icon(
              Icons.devices_other,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ),
            // ถ้ามีไฟล์ animation ให้ใช้โค้ดนี้แทน
            /*
            Lottie.asset(
              'assets/animations/empty-devices.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            */
            const SizedBox(height: 16),
            Text(
              'No Devices Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
