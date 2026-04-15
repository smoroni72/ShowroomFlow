import 'package:cloud_firestore/cloud_firestore.dart';

class Variant {
  final String id;
  final String size;
  final String color;

  const Variant({
    required this.id,
    required this.size,
    required this.color,
  });
}

enum ProductLayer {
  outerwear,
  top,
  bottom,
  dress,
  hat,
  scarf,
  gloves,
}

enum ProductGender {
  male,
  female,
  unisex,
}

class Product {
  final String id;
  final String brandId;
  final String? category;
  final String categoryId;
  final String code;
  final String name;
  final double price;

  /// immagini catalogo
  final List<String> images;
  /// immagine principale
  final String? mainImage;
  /// immagine Cover brand home screen
  final String? categoryCover;
  /// video prodotto (catalogo)
  final String? videoUrl;

  /// varianti prodotto
  final List<Variant> variants;

  /// layer per outfit
  final ProductLayer? layer;

  /// immagine scontornata per outfit
  final String? outfitImageUrl;
  final String? description;
  final String? composition;
  final String? season;
  final String? collection;
  final bool featured;
  final bool hero;
  final int order;
  final ProductGender gender;
  final bool visible;

  const Product({
    required this.id,
    required this.brandId,
    this.category,
    required this.categoryId,
    required this.code,
    required this.name,
    required this.price,
    this.images = const [],
    this.mainImage,
    this.categoryCover,
    this.videoUrl,
    this.variants = const [],
    this.layer,
    this.outfitImageUrl,
    this.description,
    this.composition,
    this.season,
    this.collection,
    this.featured = false,
    this.hero = false,
    this.order = 0,
    required this.gender,
    required this.visible,
  });

  bool get hasVariants => variants.isNotEmpty;

  /// immagine da mostrare nell'app
  String get displayImage {

    if (mainImage != null && mainImage!.isNotEmpty) {
      return mainImage!;
    }

    if (images.isNotEmpty) {
      return images.first;
    }

    return '';
  }

  /// immagine per outfit / vetrina
  String get outfitImage =>
      outfitImageUrl ?? displayImage;

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Product(
      id: doc.id,
      brandId: data['brandId'] ?? '',
      category: data['category'] ?? '',
      categoryId: data['categoryId'] ?? '',
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] is num)
          ? (data['price'] as num).toDouble()
          : 0.0,
      images: List<String>.from(data['images'] ?? []),
      mainImage: data['mainImage'],
      categoryCover: data['categoryCover'] as String?,
      videoUrl: data['videoUrl'],
      variants: (data['variants'] as List<dynamic>? ?? [])
          .map(
            (v) => Variant(
          id: v['id'] ?? '',
          size: v['size'] ?? '',
          color: v['color'] ?? '',
        ),
      )
          .toList(),
      layer: data['layer'] != null ? _mapLayer(data['layer']) : null,
      outfitImageUrl: data['outfitImageUrl'],
      description: data['description'],
      composition: data['composition'],
      season: data['season'],
      collection: data['collection'],
      featured: data['featured'] ?? false,
      hero: data['hero'] ?? false,
      order: data['order'] ?? 0,
      gender: _mapGender(data['gender']),
      visible: data['visible'] ?? true,
    );
  }

  static ProductLayer _mapLayer(String? value) {
    switch (value) {
      case 'outerwear':
        return ProductLayer.outerwear;
      case 'top':
        return ProductLayer.top;
      case 'bottom':
        return ProductLayer.bottom;
      case 'dress':
        return ProductLayer.dress;
      case 'hat':
        return ProductLayer.hat;
      case 'scarf':
        return ProductLayer.scarf;
      case 'gloves':
        return ProductLayer.gloves;
      default:
        return ProductLayer.top;
    }
  }

  static ProductGender _mapGender(String? value) {
    switch (value) {
      case 'male':
        return ProductGender.male;
      case 'female':
        return ProductGender.female;
      case 'unisex':
        return ProductGender.unisex;
      default:
        return ProductGender.unisex;
    }
  }
}