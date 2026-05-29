import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FcmService {
  static Future<void> syncToken([String? token]) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final actualToken = token ?? await FirebaseMessaging.instance.getToken();
    if (actualToken == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      String? tenantId = prefs.getString('selected_tenant_id');

      if (tenantId == null || tenantId.isEmpty) {
        // Fallback: cerca nel root users_admin
        final adminDoc = await FirebaseFirestore.instance
            .collection('users_admin')
            .doc(user.uid)
            .get();
        if (adminDoc.exists) {
          tenantId = adminDoc.data()?['tenantId'] as String?;
        }
      }

      if (tenantId != null && tenantId.isNotEmpty) {
        // Sincronizza nel tenant specifico
        await FirebaseFirestore.instance
            .collection('tenants')
            .doc(tenantId)
            .collection('users')
            .doc(user.uid)
            .set({
          'fcmToken': actualToken,
          'lastLogin': FieldValue.serverTimestamp(),
          'email': user.email ?? "",
          'displayName': user.displayName ?? "",
        }, SetOptions(merge: true));
        print("✅ FCM Service: Token synced for tenant $tenantId");
      } else {
        // Sincronizza nel root come backup
        await FirebaseFirestore.instance
            .collection('users_admin')
            .doc(user.uid)
            .set({
          'fcmToken': actualToken,
          'lastLogin': FieldValue.serverTimestamp(),
          'email': user.email ?? "",
        }, SetOptions(merge: true));
        print("✅ FCM Service: Token synced in root (no tenant)");
      }
    } catch (e) {
      print("❌ FCM Service: Error syncing token: $e");
    }
  }
}