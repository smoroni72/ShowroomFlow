import 'package:flutter/material.dart';
class RunwayGarment extends StatefulWidget {
  final Widget child;
  final int delay;

  const RunwayGarment({
    super.key,
    required this.child,
    this.delay = 0,
  });

  @override
  State<RunwayGarment> createState() => _RunwayGarmentState();
}

class _RunwayGarmentState extends State<RunwayGarment>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  late Animation<double> scale;
  late Animation<double> opacity;
  late Animation<Offset> slide;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    final random = (DateTime.now().millisecondsSinceEpoch % 4);

    Offset begin;

    switch (random) {
      case 0:
        begin = const Offset(0, -1.5);
        break;
      case 1:
        begin = const Offset(1.5, 0);
        break;
      case 2:
        begin = const Offset(-1.5, 0);
        break;
      default:
        begin = const Offset(0, 1.5);
    }

    slide = Tween(
      begin: begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutCubic,
    ));

    scale = Tween(begin: 1.6, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
    );

    opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) controller.forward();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        return Opacity(
          opacity: opacity.value,
          child: Transform.translate(
            offset: slide.value * 100,
            child: Transform.scale(
              scale: scale.value,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}