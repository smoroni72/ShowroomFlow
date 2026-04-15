import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../season/season_provider.dart';
import '../../../core/cache/image_cache_service.dart';
import '../../season/season_cache_service.dart';
import '../models/product_model.dart';

final productsProvider =
StreamProvider.family<List<Product>, String>((ref, brandId) async* {
  final firestore = FirebaseFirestore.instance;

  final season = await ref.watch(activeSeasonProvider(brandId).future);

  if (season == null) {
    debugPrint("⚠️ productsProvider: nessuna stagione attiva per $brandId");
    yield <Product>[];
    return;
  }

  final changed = await SeasonCacheService.isSeasonChanged(season.id);

  if (changed) {
    debugPrint("🔄 STAGIONE CAMBIATA → reset cache immagini");
    await SeasonCacheService.saveSeason(season.id);
    await ImageCacheService.clearCache();
  }

  yield* firestore
      .collection('products')
      .where('brandId', isEqualTo: brandId)
      .where('seasonId', isEqualTo: season.id)
      .where('visible', isEqualTo: true)
      .snapshots()
      .map((snapshot) {
    debugPrint(
      "📦 productsProvider snapshot: ${snapshot.docs.length} prodotti per $brandId / ${season.id}",
    );

    return snapshot.docs
        .map((doc) => Product.fromFirestore(doc))
        .toList();
  });
});