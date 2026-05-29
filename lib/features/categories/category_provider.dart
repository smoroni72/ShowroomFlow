import 'package:fashion_app/features/tenant/tenant_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import 'domain/category.dart';

final categoryProvider =
StreamProvider.family<List<Category>, String>((ref, brandId) {
  final tenantId = ref.watch(tenantProvider);
  if (tenantId == null || tenantId.isEmpty) {
    return Stream.value([]);
  }

  return FirebaseFirestore.instance
      .collection('tenants')
      .doc(tenantId)
      .collection('categories')
      .where('brandId', isEqualTo: brandId)
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => Category.fromFirestore(doc.id, doc.data())).toList());
});

