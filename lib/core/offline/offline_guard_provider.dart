import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/connectivity_provider.dart';
import '../network/connectivity_service.dart';
import 'cache_check_provider.dart';

final offlineGuardProvider = FutureProvider<bool>((ref) async {
  // Verifichiamo la connessione in modo asincrono ma senza bloccare eccessivamente
  final isOnline = ref.watch(connectivityProvider).valueOrNull ?? true;

  // Non usiamo .future per evitare di forzare lo stato loading se non necessario
  final hasCache = ref.watch(hasLocalDataProvider).valueOrNull ?? false;

  final isOffline = !isOnline;

  return isOffline && !hasCache;
});