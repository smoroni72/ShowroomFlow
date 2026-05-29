import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider che gestisce il tenantId (azienda) corrente.
/// All'avvio carica il valore salvato localmente.
final tenantProvider = StateNotifierProvider<TenantNotifier, String?>((ref) {
  return TenantNotifier()..init();
});

class TenantNotifier extends StateNotifier<String?> {
  TenantNotifier() : super(null);

  static const _key = 'selected_tenant_id';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key);
    print("🏢 TENANT: Loaded from storage: '$state'");
  }

  Future<void> setTenant(String tenantId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, tenantId);
    state = tenantId;
    print("🏢 TENANT: Set to '$tenantId' and saved.");
  }

  Future<void> clearTenant() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = null;
    print("🏢 TENANT: Cleared.");
  }
}
