import 'package:flutter/material.dart';

class AnimatedAppBar extends StatelessWidget {
  final String title;
  final AnimationController animationController;
  final List<Widget> actions;

  const AnimatedAppBar({
    Key? key,
    required this.title,
    required this.animationController,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Animations
    final heightAnimation = Tween<double>(
      begin: 160.0,
      end: 80.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );

    final colorAnimation = ColorTween(
      begin: isDarkMode ? Colors.black87 : Color(0xFF2196F3),
      end: Colors.transparent,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, child) {
        return Container(
          height: heightAnimation.value,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: colorAnimation.value,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                offset: const Offset(0, 2),
                blurRadius: 4.0,
                spreadRadius: 0.0,
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu),
                  color: isDarkMode ? Colors.white : Colors.white,
                  onPressed: () {
                    // Implement menu functionality
                  },
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(children: actions),
              ],
            ),
          ),
        );
      },
    );
  }
}
