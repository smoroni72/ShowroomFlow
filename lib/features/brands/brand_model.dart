import 'package:cloud_firestore/cloud_firestore.dart';

class Brand {
  final String id;
  final String name;
  final String logoUrl;
  final String coverImage;
  final String description;
  final int order;

  const Brand({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.coverImage,
    required this.description,
    required this.order,
  });

  factory Brand.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Brand(
      id: doc.id,
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      coverImage: data['coverImage'] ?? '',
      description: data['description'] ?? '',
      order: data['order'] ?? 0,
    );
  }
}