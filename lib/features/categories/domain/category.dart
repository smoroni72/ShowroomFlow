class Category {
  final String id;
  final String brandId;
  final String name;

  const Category({
    required this.id,
    required this.brandId,
    required this.name,
  });

  factory Category.fromFirestore(String id, Map<String, dynamic> data) {
    return Category(
      id: id,
      brandId: data['brandId'] ?? '',
      name: data['name'] ?? '',
    );
  }
}
