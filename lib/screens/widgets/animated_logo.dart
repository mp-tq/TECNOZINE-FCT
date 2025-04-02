import 'package:flutter/material.dart';

class AnimatedLogo extends StatelessWidget {
  final AnimationController controller;

  const AnimatedLogo({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
      child: Image.asset(
        'assets/smartphone_logo.png', // Ruta de tu imagen
        width: 100,
        height: 100,
      ),
    );
  }
}