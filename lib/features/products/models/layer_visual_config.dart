import 'package:fashion_app/features/products/models/product_model.dart';

class LayerVisualConfig {
  final double offsetY;
  final double scale;
  final double height;

  const LayerVisualConfig({
    required this.offsetY,
    required this.scale,
    required this.height,
  });
}

const layerVisuals = {

  ProductLayer.dress: LayerVisualConfig(
    offsetY: 0,
    scale: 1.0,
    height: 360,
  ),

  ProductLayer.outerwear: LayerVisualConfig(
    offsetY: 20,
    scale: 1.05,
    height: 300,
  ),

  ProductLayer.bottom: LayerVisualConfig(
    offsetY: 10,
    scale: 1.05,
    height: 360,
  ),

  ProductLayer.top: LayerVisualConfig(
    offsetY: 40,
    scale: 1.08,
    height: 240,
  ),

  ProductLayer.scarf: LayerVisualConfig(
    offsetY: 70,
    scale: 1.40,
    height: 200,
  ),

  ProductLayer.gloves: LayerVisualConfig(
    offsetY: 80,
    scale: 1.1,
    height: 200,
  ),

  ProductLayer.hat: LayerVisualConfig(
    offsetY: 90,
    scale: 1.65,
    height: 200,
  ),
};