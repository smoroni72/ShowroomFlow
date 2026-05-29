import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'brand_model.dart';

import '../auth/auth_provider.dart';
import '../tenant/tenant_provider.dart';

final brandsProvider = StreamProvider<List<Brand>>((ref) {
  // Ascoltiamo il tenantId configurato localmente sul dispositivo
  final tenantId = ref.watch(tenantProvider);

  if (tenantId == null || tenantId.isEmpty) {
    print("🚨 [DEBUG BRANDS] Nessun TenantId configurato sul dispositivo.");
    return Stream.value(<Brand>[]);
  }

  print("🚨 [DEBUG BRANDS] Caricamento brand per TenantId: '$tenantId'");

  return FirebaseFirestore.instance
      .collection('tenants')
      .doc(tenantId)
      .collection('brands')
      .orderBy('order')
      .snapshots()
      .map((snapshot) {
    final list = snapshot.docs.map((doc) => Brand.fromFirestore(doc)).toList();
    print("🚨 [DEBUG BRANDS] Ricevuti ${list.length} brand dal database per tenant '$tenantId'");
    return list;
  });
});

final publishedBrandsProvider = Provider<AsyncValue<List<Brand>>>((ref) {
  final brandsAsync = ref.watch(brandsProvider);

  return brandsAsync.whenData((brands) {
    if (brands.isEmpty) {
      print("🚨 [DEBUG FILTER] Lista brand originale vuota.");
      return [];
    }

    final filtered = brands.where((b) {
      final isPub = b.hasPublishedSeasons == true;
      return isPub;
    }).toList();

    print("🚨 [DEBUG FILTER] Filtraggio completato: ${filtered.length}/${brands.length} brand pubblicati.");
    return filtered;
  });
});
