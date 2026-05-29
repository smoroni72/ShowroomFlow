import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/runway_model.dart';
import '../../auth/auth_provider.dart';
import '../../tenant/tenant_provider.dart';

final runwayProvider =
FutureProvider.family<List<RunwayLook>, String>((ref, brandId) async {
  final tenantId = ref.watch(tenantProvider);

  if (tenantId == null || tenantId.isEmpty) {
    return [];
  }

  final db = FirebaseFirestore.instance;

  /// trova stagione pubblicata
  final seasonSnap = await db
      .collection('tenants')
      .doc(tenantId)
      .collection("brands")
      .doc(brandId)
      .collection("seasons")
      .where("published", isEqualTo: true)
      .limit(1)
      .get();

  if (seasonSnap.docs.isEmpty) return [];

  final seasonId = seasonSnap.docs.first.id;

  /// carica runway
  final runwaySnap = await db
      .collection('tenants')
      .doc(tenantId)
      .collection("brands")
      .doc(brandId)
      .collection("seasons")
      .doc(seasonId)
      .collection("runway")
      .orderBy("order")
      .get();

  return runwaySnap.docs
      .map((doc) => RunwayLook.fromFirestore(doc.id, doc.data()))
      .toList();
});