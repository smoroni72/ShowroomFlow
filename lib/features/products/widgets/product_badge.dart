import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductBadge  extends StatelessWidget {
  final ProductLayer layer;

  const ProductBadge ({super.key, required this.layer});

  @override
  Widget build(BuildContext context) {

    final label = switch (layer) {
      ProductLayer.outerwear => "Outerwear",
      ProductLayer.top => "Top",
      ProductLayer.bottom => "Bottom",
      ProductLayer.dress => "Dress",
      ProductLayer.hat => "Hat",
      ProductLayer.scarf => "Scarf",
      ProductLayer.gloves => "Gloves",
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}