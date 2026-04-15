import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hasLocalDataProvider = FutureProvider<bool>((ref) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('showroom') // ⚠️ usa una collection SEMPRE presente
        .limit(1)
        .get(const GetOptions(source: Source.cache));

    // return snapshot.docs.isNotEmpty;
    return false;
  } catch (_) {
    return false;
  }
});