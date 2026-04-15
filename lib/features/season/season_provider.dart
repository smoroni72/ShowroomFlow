import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'season_model.dart';

final activeSeasonProvider =
FutureProvider.family<SeasonModel?, String>((ref, brandId) async {

  final snapshot = await FirebaseFirestore.instance
      .collection('brands')
      .doc(brandId)
      .collection('seasons')
      .orderBy('order', descending: false)
      .get();

  if (snapshot.docs.isEmpty) return null;

  /// 🔥 trova stagione pubblicata
  for (final doc in snapshot.docs) {
    final season = SeasonModel.fromMap(doc.id, doc.data());

    if (season.published) {
      return season;
    }
  }

  return null;
});