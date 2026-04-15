import 'package:flutter/material.dart';
class AnimatedCatalogItem extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedCatalogItem({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  State<AnimatedCatalogItem> createState() => _AnimatedCatalogItemState();
}

class _AnimatedCatalogItemState extends State<AnimatedCatalogItem>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  late Animation<double> opacity;
  late Animation<double> scale;

  static final Map<int, int> _delayMap = {};

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );

    scale = Tween(
        begin: 1.04 + ((widget.index % 3) * 0.01)
        , end: 1.0
    ).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
    );

    /// 🔥 RANDOM STABILE
    _delayMap.putIfAbsent(widget.index, () {
      final random = (widget.index * 37) % 10; // pseudo-random stabile
      return random * 70;
    });

    final delay = _delayMap[widget.index]!;

    Future.delayed(Duration(milliseconds: delay), () {
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
    return FadeTransition(
      opacity: opacity,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, child) {
          return Transform.scale(
            scale: scale.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}