import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../auth/auth_provider.dart';
import '../../tenant/tenant_provider.dart';
import '../../season/season_provider.dart';
import '../../../core/cache/image_cache_service.dart';
import '../../season/season_cache_service.dart';
import '../models/product_model.dart';

final productsProvider =
StreamProvider.family<List<Product>, String>((ref, brandId) async* {
  final firestore = FirebaseFirestore.instance;
  final tenantId = ref.watch(tenantProvider);

  if (tenantId == null) {
    yield <Product>[];
    return;
  }

  final season = await ref.watch(activeSeasonProvider(brandId).future);

  if (season == null) {
    debugPrint("⚠️ season is NULL for brand: $brandId");
    yield <Product>[];
    return;
  }

  debugPrint("🔍 Querying products for Brand: $brandId, Season: ${season.id}");

  final changed = await SeasonCacheService.isSeasonChanged(season.id);
  if (changed) {
    await SeasonCacheService.saveSeason(season.id);
    await ImageCacheService.clearCache();
  }

  try {
    yield* firestore
        .collection('tenants')
        .doc(tenantId)
        .collection('products')
        .where('brandId', isEqualTo: brandId)
        .where('seasonId', isEqualTo: season.id)
        .where('visible', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) {
      debugPrint("✅ Products snapshot received: ${snapshot.docs.length} items");
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  } catch (e) {
    debugPrint("❌ CRITICAL Firestore Error (Products): $e");
    rethrow;
  }
});

final featuredProductsProvider =
StreamProvider.family<List<Product>, String>((ref, brandId) async* {
  final firestore = FirebaseFirestore.instance;
  final tenantId = ref.watch(tenantProvider);

  if (tenantId == null) {
    yield <Product>[];
    return;
  }

  final season = await ref.watch(activeSeasonProvider(brandId).future);

  if (season == null) {
    yield <Product>[];
    return;
  }

  try {
    yield* firestore
        .collection('tenants')
        .doc(tenantId)
        .collection('products')
        .where('brandId', isEqualTo: brandId)
        .where('seasonId', isEqualTo: season.id)
        .where('featured', isEqualTo: true)
        .where('visible', isEqualTo: true)
        .orderBy('order')
        .limit(12)
        .snapshots()
        .map((snapshot) {
      debugPrint("🌟 Featured snapshot: ${snapshot.docs.length} items");
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  } catch (e) {
    debugPrint("❌ CRITICAL Firestore Error (Featured): $e");
    rethrow;
  }
});

final homeCategoriesProvider =
StreamProvider.family<List<Product>, String>((ref, brandId) async* {
  final firestore = FirebaseFirestore.instance;
  final tenantId = ref.watch(tenantProvider);

  if (tenantId == null) {
    yield <Product>[];
    return;
  }

  final season = await ref.watch(activeSeasonProvider(brandId).future);

  if (season == null) {
    yield <Product>[];
    return;
  }

  yield* firestore
      .collection('tenants')
      .doc(tenantId)
      .collection('products')
      .where('brandId', isEqualTo: brandId)
      .where('seasonId', isEqualTo: season.id)
      .where('visible', isEqualTo: true)
      .orderBy('order')
      .limit(80)
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
});
