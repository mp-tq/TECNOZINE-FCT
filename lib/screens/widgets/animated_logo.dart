import 'package:flutter/material.dart';

class AnimatedLogo extends StatelessWidget {
  final AnimationController controller;

  const AnimatedLogo({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: controller.value * 0.2, // Rotación leve
          child: Transform.translate(
            offset: Offset(0, controller.value * -10), // Rebote
            child: Image.asset(
              'images/logo.png',
              width: 100,
              height: 100,
            ),
          ),
        );
      },
    );
  }
}