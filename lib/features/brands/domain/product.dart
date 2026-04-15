import 'product_behavior.dart';
import 'variant.dart';

class Product {
  final String id;
  final String brandId;
  final String categoryId;

  final String code;       // codice articolo
  final String name;
  final String description;

  final double basePrice;

  final List<String> images;
  final String? videoUrl;

  final ProductBehavior behavior;
  final List<Variant> variants;

  const Product({
    required this.id,
    required this.brandId,
    required this.categoryId,
    required this.code,
    required this.name,
    required this.description,
    required this.basePrice,
    this.images = const [],
    this.videoUrl,
    this.behavior = ProductBehavior.variant,
    this.variants = const [],
  });
}