class Category {
  final String id;
  final String brandId;
  final String name;
  final String? imageUrl;
  final int order;

  const Category({
    required this.id,
    required this.brandId,
    required this.name,
    this.imageUrl,
    this.order = 0,
  });
}