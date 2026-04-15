import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedEditorialItem extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedEditorialItem({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<AnimatedEditorialItem> createState() => _AnimatedEditorialItemState();
}

class _AnimatedEditorialItemState extends State<AnimatedEditorialItem>
    with TickerProviderStateMixin {

  late AnimationController entranceController;
  // late AnimationController floatController;

  late Animation<double> scale;
  late Animation<double> opacity;

  final random = Random();

  @override
  void initState() {
    super.initState();

    /// 🎬 ENTRATA (bubble)
    entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    scale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 1.04)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.04, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
    ]).animate(entranceController);

    opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: entranceController, curve: Curves.easeOut),
    );


    /// 🎲 DELAY RANDOM (molto leggero)
    final delay = random.nextInt(120) + (widget.index * 18);

    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) entranceController.forward();
    });
  }

  @override
  void dispose() {
    entranceController.dispose();
    // floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: entranceController,
      builder: (_, child) {
        return Opacity(
          opacity: opacity.value,
          child: Transform.scale(
            scale: scale.value * 0.9968,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}