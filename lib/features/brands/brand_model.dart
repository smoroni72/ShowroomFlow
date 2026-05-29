import 'package:cloud_firestore/cloud_firestore.dart';

class Brand {
  final String id;
  final String name;
  final String logoUrl;
  final String coverImage;
  final String description;
  final int order;
  final bool hasPublishedSeasons;

  const Brand({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.coverImage,
    required this.description,
    required this.order,
    this.hasPublishedSeasons = false,
  });

  factory Brand.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Supporto per vari tipi di valore (bool, stringa) per flessibilità
    final rawPublished = data['hasPublishedSeasons'];
    final bool hasPublished = rawPublished == true || rawPublished == 'true';

    return Brand(
      id: doc.id,
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      coverImage: data['coverImage'] ?? '',
      description: data['description'] ?? '',
      order: data['order'] ?? 0,
      hasPublishedSeasons: hasPublished,
    );
  }
}