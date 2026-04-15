import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'domain/category.dart';

final categoryProvider =
Provider.family<List<Category>, String>((ref, brandId) {
  final allCategories = [
    Category(id: 'c1', brandId: '1', name: 'Giacche'),
    Category(id: 'c2', brandId: '1', name: 'Pantaloni'),
    Category(id: 'c3', brandId: '2', name: 'Maglieria'),
    Category(id: 'c4', brandId: '2', name: 'Camicie'),
    Category(id: 'c5', brandId: '3', name: 'Piumini'),
  ];

  return allCategories.where((c) => c.brandId == brandId).toList();
});