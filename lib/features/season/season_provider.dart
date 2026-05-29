import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_provider.dart';
import '../tenant/tenant_provider.dart';
import 'season_model.dart';

final activeSeasonProvider =
FutureProvider.family<SeasonModel?, String>((ref, brandId) async {
  final tenantId = ref.watch(tenantProvider);

  print("🔍 ACTIVE SEASON - brandId: $brandId, tenantId: $tenantId");

  if (tenantId == null || tenantId.isEmpty) {
    return null;
  }

  final snapshot = await FirebaseFirestore.instance
      .collection('tenants')
      .doc(tenantId)
      .collection('brands')
      .doc(brandId)
      .collection('seasons')
      .orderBy('order', descending: false)
      .get();

  print("📥 ACTIVE SEASON - total found: ${snapshot.docs.length}");

  if (snapshot.docs.isEmpty) return null;

  for (final doc in snapshot.docs) {
    final data = doc.data();
    final season = SeasonModel.fromMap(doc.id, data);

    final isPublished = data['published'] == true || data['published'] == 'true';

    if (isPublished) {
      return season;
    }
  }

  print("⚠️ NO PUBLISHED SEASON FOUND for brand $brandId");
  return null;
});