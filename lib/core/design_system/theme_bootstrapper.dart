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
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      print("🚀 BOOTSTRAP START");
      try {
        // 🔥 check immediato (NO provider async)
        final isOnline = await ConnectivityService.isOnline();
        print("🌐 ONLINE: $isOnline");
        final hasCache = await ref.read(hasLocalDataProvider.future);
        print("💾 HAS CACHE: $hasCache");

        final shouldShowOffline = !isOnline && !hasCache;
        print("📴 SHOULD OFFLINE: $shouldShowOffline");

        if (shouldShowOffline) {
          print("⛔ OFFLINE MODE TRIGGERED");
          if (mounted) {
            setState(() {
              _initialized = true;
            });
          }
          return;
        }

        print("🎨 LOAD THEME");
        final theme = await ref.read(remoteThemeProvider.future);
        ref.read(appThemeProvider.notifier).state = theme;

        print("🏬 LOAD SHOWROOM");
        ref.invalidate(showroomProvider);
        await ref.read(showroomProvider.future);

      } catch (e) {
        print("❌ BOOTSTRAP ERROR: $e");
      }
      print("✅ BOOTSTRAP END");
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print("🔥 OFFLINE GUARD BUILD");
    final offlineGuard = ref.watch(offlineGuardProvider);

    if (!_initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFBC4A8C),
            ),
          ),
        ),
      );
    }

    return offlineGuard.when(
      data: (shouldShowOffline) {
        print("📴 SHOULD SHOW OFFLINE: $shouldShowOffline");
        if (shouldShowOffline) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: OfflineLandingPage(),
          );
        }

        return widget.child;
      },
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFBC4A8C),
            ),
          ),
        ),
      ),
      error: (_, __) => widget.child,
    );
  }
}
