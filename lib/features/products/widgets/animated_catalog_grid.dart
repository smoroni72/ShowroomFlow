import 'package:fashion_app/features/products/widgets/product_catalog_card.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
class AnimatedCatalogGrid extends StatefulWidget {
  final List<Product> products;
  final bool isLogged;

  const AnimatedCatalogGrid({
    super.key,
    required this.products,
    required this.isLogged,
  });

  @override
  State<AnimatedCatalogGrid> createState() => _AnimatedCatalogGridState();
}

class _AnimatedCatalogGridState extends State<AnimatedCatalogGrid>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  bool showGrid = false;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550), // 🔥 più corta = più smooth
    );

    controller.forward();

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          showGrid = true; // 👉 switch reale
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    /// 🔥 DOPO ANIMAZIONE → SOLO GRID
    if (showGrid) {
      return MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        itemCount: widget.products.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (_, i) {
          final p = widget.products[i];

          return ProductCatalogCard(
            product: p,
            isLogged: widget.isLogged,
          );
        },
      );
    }

    /// 🔥 PRIMA → SOLO STACK (leggero)
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {

        final progress = Curves.easeOutCubic.transform(controller.value);

        return Stack(
          alignment: Alignment.center,
          children: widget.products.take(6).toList().asMap().entries.map((entry) {

            final i = entry.key;
            final p = entry.value;

            final dx = (i % 2 == 0 ? -1 : 1) * (20 + i * 3);
            final dy = 30.0 + i * 5;

            return Transform.translate(
              offset: Offset(
                dx * (1 - progress),
                dy * (1 - progress),
              ),
              child: Transform.scale(
                scale: 1 - (i * 0.05 * (1 - progress)),
                child: Transform.rotate(
                  angle: ((i % 5) - 2) * 0.04 * (1 - progress),
                  child: Opacity(
                    opacity: 1 - progress * 0.9,
                    child: ProductCatalogCard(
                      product: p,
                      isLogged: widget.isLogged,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}