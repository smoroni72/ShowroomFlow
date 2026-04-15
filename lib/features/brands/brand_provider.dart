import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'brand_model.dart';

final brandsProvider = StreamProvider<List<Brand>>((ref) {
  return FirebaseFirestore.instance
      .collection('brands')
      .orderBy('order')
      .snapshots()
      .map((snapshot) =>
      snapshot.docs.map((doc) => Brand.fromFirestore(doc)).toList());
});