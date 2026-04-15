class Brand {
  final String id;
  final String name;
  final String? logoUrl;
  final bool isActive;

  const Brand({
    required this.id,
    required this.name,
    this.logoUrl,
    this.isActive = true,
  });
}