import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/connectivity_provider.dart';
import 'app_theme_model.dart';
import 'app_theme_presets.dart';
import 'remote_theme_config.dart';
import 'theme_mapper.dart';

final appThemeProvider = StateProvider<AppThemeModel>((ref) {
  return AppThemePresets.luxury; // fallback iniziale
});

final remoteThemeProvider = FutureProvider<AppThemeModel>((ref) async {
  try {
    final isOnline = await ref.watch(connectivityProvider.future);

    final source = isOnline ? Source.server : Source.cache;

    final snapshot = await FirebaseFirestore.instance
        .collection('app_config')
        .doc('theme')
        .get(GetOptions(source: source));

    final data = snapshot.data();

    print("🔥 FIRESTORE THEME DATA: $data");
    print("🌐 ONLINE: $isOnline");

    if (data == null) {
      return AppThemePresets.boldDark;
    }

    final config = RemoteThemeConfig.fromMap(data);

    print("🔥 PRESET LETTO: ${config.preset}");

    return ThemeMapper.fromRemote(config);

  } catch (e) {

    print("❌ THEME ERROR: $e");

    return AppThemePresets.boldDark;
  }
});