import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/connectivity_service.dart';
import '../offline/cache_check_provider.dart';
import '../providers/showroom_provider.dart';
import 'theme_provider.dart';
import '../../core/offline/offline_guard_provider.dart';
import '../../core/offline/presentation/offline_landing_page.dart';

class ThemeBootstrapper extends ConsumerStatefulWidget {
  final Widget child;

  const ThemeBootstrapper({super.key, required this.child});

  @override
  ConsumerState<ThemeBootstrapper> createState() => _ThemeBootstrapperState();
}

class _ThemeBootstrapperState extends ConsumerState<ThemeBootstrapper> {
  @override
  void initState() {
    super.initState();
    // Inizializzazione asincrona dei dati se necessario
    // Riverpod gestirà il caricamento dei provider osservando i cambiamenti
  }

  @override
  Widget build(BuildContext context) {
    // Cerchiamo di caricare il tema in background senza bloccare il build
    ref.listen(remoteThemeProvider, (previous, next) {
      next.whenData((theme) {
        if (ref.read(appThemeProvider) != theme) {
          ref.read(appThemeProvider.notifier).state = theme;
        }
      });
    });

    final offlineGuard = ref.watch(offlineGuardProvider);

    return offlineGuard.maybeWhen(
      data: (shouldShowOffline) {
        if (shouldShowOffline) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: OfflineLandingPage(),
          );
        }
        return widget.child;
      },
      orElse: () => widget.child,
    );
  }
}