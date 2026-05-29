import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/connectivity_provider.dart';
import 'app_theme_model.dart';
import 'app_theme_presets.dart';
import 'remote_theme_config.dart';
import 'theme_mapper.dart';

import '../../features/auth/auth_provider.dart';
import '../../features/tenant/tenant_provider.dart';

final appThemeProvider = StateProvider<AppThemeModel>((ref) {
  return AppThemePresets.luxury; // fallback iniziale
});

final remoteThemeProvider = FutureProvider<AppThemeModel>((ref) async {
  try {
    // 1. Leggiamo lo stato della connessione
    final isOnline = ref.watch(connectivityProvider).valueOrNull ?? true;

    // 2. Leggiamo il tenantId configurato localmente
    final tenantId = ref.watch(tenantProvider);

    final source = isOnline ? Source.server : Source.cache;
    DocumentSnapshot<Map<String, dynamic>> snapshot;

    if (tenantId != null && tenantId.isNotEmpty) {
      print("🎨 Fetching theme for tenant: $tenantId");
      snapshot = await FirebaseFirestore.instance
          .collection('tenants')
          .doc(tenantId)
          .collection('app_config')
          .doc('theme')
          .get(GetOptions(source: source));
    } else {
      print("🎨 Fetching global theme (no tenantId)");
      snapshot = await FirebaseFirestore.instance
          .collection('app_config')
          .doc('theme')
          .get(GetOptions(source: source));
    }

    final data = snapshot.data();
    if (data == null) return AppThemePresets.luxury;

    final config = RemoteThemeConfig.fromMap(data);
    return ThemeMapper.fromRemote(config);

  } catch (e) {
    print("❌ REMOTE THEME ERROR: $e");
    return AppThemePresets.luxury;
  }
});