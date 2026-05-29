import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../tenant/tenant_provider.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final userProfileProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return Stream.value(null);

  final localTenantId = ref.watch(tenantProvider);

  // Creiamo uno stream che controlla prima users_admin e poi il tenant specifico
  return FirebaseFirestore.instance
      .collection('users_admin')
      .doc(authUser.uid)
      .snapshots()
      .asyncMap((adminDoc) async {
    if (adminDoc.exists) {
      print("👤 USER_PROFILE: Trovato in users_admin root");
      return adminDoc.data();
    }

    // Se non è un admin globale, cerchiamo nel tenant selezionato
    if (localTenantId != null && localTenantId.isNotEmpty) {
      final tenantUserDoc = await FirebaseFirestore.instance
          .collection('tenants')
          .doc(localTenantId)
          .collection('users')
          .doc(authUser.uid)
          .get();

      if (tenantUserDoc.exists) {
        print("👤 USER_PROFILE: Trovato nel tenant $localTenantId");
        return tenantUserDoc.data();
      }
    }

    // Fallback: ricerca globale se il tenantId locale non aiuta
    final groupSearch = await FirebaseFirestore.instance
        .collectionGroup('users')
        .where('uid', isEqualTo: authUser.uid)
        .limit(1)
        .get();

    if (groupSearch.docs.isNotEmpty) {
      final doc = groupSearch.docs.first;
      print("👤 USER_PROFILE: Trovato tramite ricerca globale");
      return doc.data();
    }

    print("⚠️ USER_PROFILE: Utente non trovato nelle collezioni autorizzate");
    return null;
  });
});

/// Provider che restituisce il tenantId corrente dell'applicazione.
/// Priorità:
/// 1. Il tenantId del profilo utente (se loggato)
/// 2. Il tenantId configurato localmente sul dispositivo (fallback per utenti non loggati)
final tenantIdProvider = Provider<String?>((ref) {
  final profile = ref.watch(userProfileProvider).value;
  final userTenantId = profile?['tenantId'] as String?;

  if (userTenantId != null && userTenantId.isNotEmpty) {
    return userTenantId;
  }

  return ref.watch(tenantProvider);
});
