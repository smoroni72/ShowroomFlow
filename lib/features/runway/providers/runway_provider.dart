import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/runway_model.dart';

final runwayProvider =
FutureProvider.family<List<RunwayLook>, String>((ref, brandId) async {

  final db = FirebaseFirestore.instance;

  /// trova stagione pubblicata
  final seasonSnap = await db
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