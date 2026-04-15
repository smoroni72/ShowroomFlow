import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/connectivity_provider.dart';
import '../network/connectivity_service.dart';
import 'cache_check_provider.dart';

final offlineGuardProvider = FutureProvider<bool>((ref) async {
  final isOnline = await ConnectivityService.isOnline();
  final hasCache = await ref.watch(hasLocalDataProvider.future);

  final isOffline = !isOnline;

  return isOffline && !hasCache;
});