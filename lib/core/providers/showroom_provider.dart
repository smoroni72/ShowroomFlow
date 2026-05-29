import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_provider.dart';
import '../../features/tenant/tenant_provider.dart';
import '../network/connectivity_provider.dart';

final showroomProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final isOnline = ref.watch(connectivityProvider).valueOrNull ?? true;
    final tenantId = ref.watch(tenantProvider);

    final source = isOnline ? Source.server : Source.cache;
    DocumentSnapshot<Map<String, dynamic>> doc;

    if (tenantId != null && tenantId.isNotEmpty) {
      print("🏬 Fetching showroom for tenant: $tenantId");
      doc = await FirebaseFirestore.instance
          .collection('tenants')
          .doc(tenantId)
          .collection('app_config')
          .doc('showroom')
          .get(GetOptions(source: source));
    } else {
      print("🏬 Fetching global showroom");
      doc = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('showroom')
          .get(GetOptions(source: source));
    }

    return doc.data() ?? {};
  } catch (e) {
    print("❌ SHOWROOM ERROR: $e");
    return {};
  }
});