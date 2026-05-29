import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_provider.dart';

final userRoleProvider = StreamProvider<String?>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) => Stream.value(profile?['role'] as String?),
    loading: () => const Stream.empty(),
    error: (_, __) => Stream.value(null),
  );
});
