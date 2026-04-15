import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/connectivity_provider.dart';

final showroomProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final isOnline = await ref.watch(connectivityProvider.future);

    final source = isOnline ? Source.server : Source.cache;

    final doc = await FirebaseFirestore.instance
        .collection('app_config')
        .doc('showroom')
        .get(GetOptions(source: source));

    final data = doc.data();

    print("🏬 SHOWROOM DATA: $data");
    print("🌐 ONLINE: $isOnline");

    return data ?? {};
  } catch (e) {
    print("❌ SHOWROOM ERROR: $e");

    // 🔥 fallback sicuro
    return {};
  }
});