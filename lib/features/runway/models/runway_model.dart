class RunwayLook {

  final String id;
  final String title;
  final String image;
  final int order;
  final List<String> products;

  RunwayLook({
    required this.id,
    required this.title,
    required this.image,
    required this.order,
    required this.products,
  });

  factory RunwayLook.fromFirestore(String id, Map<String, dynamic> data) {

    return RunwayLook(
      id: id,
      title: data["title"] ?? "",
      image: data["image"] ?? "",
      order: data["order"] ?? 0,
      products: List<String>.from(data["products"] ?? []),
    );
  }
}