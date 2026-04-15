import 'dart:math';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
class ClothMotion extends StatelessWidget {
  final Widget child;
  final VideoPlayerController controller;
  final double intensity;

  const ClothMotion({
    super.key,
    required this.child,
    required this.controller,
    this.intensity = 1,
  });

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {

        if (!controller.value.isInitialized) return child!;

        final t = controller.value.position.inMilliseconds / 1000;

        /// ciclo passo ~0.8s
        final walk = sin(t * 2 * pi * 1.2);

        return Transform.translate(
          offset: Offset(
            walk * 1.5 * intensity,
            walk * 3 * intensity,
          ),
          child: Transform.rotate(
            angle: walk * 0.015 * intensity,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}