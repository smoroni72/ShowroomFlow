import 'package:flutter/material.dart';
import '../../../core/widgets/product_image.dart';
import '../models/layer_visual_config.dart';
import '../screens/product_detail_screen.dart';
import '../widgets/product_badge.dart';
import '../widgets/info.dart';
import '../models/product_model.dart';

class ProductCatalogCard extends StatelessWidget {
  final Product product;
  final bool isLogged;

  const ProductCatalogCard({
    super.key,
    required this.product,
    required this.isLogged,
  });


  static const pastelColors = [
    Color(0xFFD7CFC8),
    Color(0xFF96BED3),
    Color(0xFF9C9E9A),
    Color(0xFF2C3E55),
    Color(0xFFE6F4EA),
    Color(0xFF5D553F),
    Color(0xFF719867),
  ];



  Color getPastelColor(String id) {
    final index = id.hashCode % pastelColors.length;
    return pastelColors[index.abs()];
  }

  double _getElevation(Product product) {
    switch (product.layer) {
      case ProductLayer.dress:
        return 15; // 🔥 protagonista
      case ProductLayer.outerwear:
        return 13;
      case ProductLayer.top:
        return 11;
      case ProductLayer.bottom:
        return 12;
      case ProductLayer.scarf:
      case ProductLayer.hat:
      case ProductLayer.gloves:
        return 9; // più leggeri
      case null:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = layerVisuals[product.layer]!;
    final bgColor = getPastelColor(product.id).withOpacity(0.25);
    final isAccessory = product.layer == ProductLayer.hat ||
        product.layer == ProductLayer.gloves ||
        product.layer == ProductLayer.scarf;

    return Hero(
      tag: "product_${product.id}",

        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Material(
            elevation:  _getElevation(product) * 0.7,
            shadowColor: Colors.black.withOpacity(0.25),
            borderRadius: BorderRadius.circular(18),

            child: AnimatedScale(
              scale: 1,
              duration: const Duration(milliseconds: 120),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(18),
              
                child: Container(
                  height: config.height,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(18),
              
                    /// 🔥 NUOVA SHADOW (più visibile)
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 20,
                        spreadRadius: -6,
                        offset: const Offset(0, 12),
                      ),
                    ],
              
                    /// 🔥 BORDO INVISIBILE (super importante)
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                      width: 0.6,
                    ),
                  ),
                  child: Stack(
                    children: [
                      /// IMMAGINE
                      Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            isAccessory ? config.offsetY * 0.6 : config.offsetY,
                          ),
                          child: Transform.scale(
                            scale: config.scale,
                            child: ProductImage(
                              image: product.displayImage,
                              fit: isAccessory ? BoxFit.contain : BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
              
                      /// LUCE
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.10),
                                Colors.transparent,
                                Colors.black.withOpacity(0.25),
                              ],
                            ),
                          ),
                        ),
                      ),
              
                      /// BADGE
                      Positioned(
                        left: 12,
                        right: 12,
                        bottom: 60,
                        child: ProductBadge(layer: product.layer!),
                      ),
              
                      /// INFO
                      Positioned(
                        left: 8,
                        right: 8,
                        bottom: 8,
                        child: Info(
                          product: product,
                          isLogged: isLogged,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

    );
  }
}