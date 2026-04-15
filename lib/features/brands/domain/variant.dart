class Variant {
  final String id;
  final String productId;
  final String size;
  final String color;
  final double? priceOverride;

  const Variant({
    required this.id,
    required this.productId,
    required this.size,
    required this.color,
    this.priceOverride,
  });
}