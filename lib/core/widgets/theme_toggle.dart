import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ThemeToggle extends StatelessWidget {
  final bool isDarkMode;
  final Function onToggle;

  const ThemeToggle({
    Key? key,
    required this.isDarkMode,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onToggle(),
      child: Container(
        width: 70,
        height: 36,
        padding: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.blue[900] : Colors.grey[300],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedAlign(
              duration: Duration(milliseconds: 300),
              alignment:
                  isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: Center(
                  child: Icon(
                    isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                    size: 20,
                    color: isDarkMode ? Colors.blue[900] : Colors.orange,
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
            duration: 300.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }
}
