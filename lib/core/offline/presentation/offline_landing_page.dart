import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/connectivity_service.dart';
import '../../../core/offline/offline_guard_provider.dart';
import '../../../core/providers/showroom_provider.dart';

class OfflineLandingPage extends ConsumerStatefulWidget {
  const OfflineLandingPage({super.key});

  @override
  ConsumerState<OfflineLandingPage> createState() =>
      _OfflineLandingPageState();
}

class _OfflineLandingPageState
    extends ConsumerState<OfflineLandingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _imageOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _ctaOpacity;

  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _imageOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
    );

    _textOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.8)),
    );

    _ctaOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0)),
    );

    _textSlide = Tween(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final showroomAsync = ref.watch(showroomProvider);

    final showroomName = showroomAsync.maybeWhen(
      data: (data) => data['name'] ?? 'Showroom',
      orElse: () => 'Showroom',
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          /// 📸 BACKGROUND IMAGE (fade-in)
          Positioned.fill(
            child: FadeTransition(
              opacity: _imageOpacity,
              child: Image.asset(
                'assets/images/studio.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// 🌑 OVERLAY
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.75),
                  ],
                ),
              ),
            ),
          ),

          /// ✨ CONTENT
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _textOpacity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// TITOLO
                          Text(
                            showroomName,
                            style:
                            theme.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.6,
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// SUBTITLE EDITORIALE
                          Text(
                            "La collezione non è disponibile offline.\nRiconnettiti per accedere allo showroom.",
                            style:
                            theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.7),
                              height: 1.5,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  /// CTA
                  FadeTransition(
                    opacity: _ctaOpacity,
                    child: GestureDetector(
                      onTap: () async {
                        final isOnline =
                        await ConnectivityService.isOnline();

                        if (isOnline) {
                          ref.invalidate(offlineGuardProvider);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          "Riprova",
                          style:
                          theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 56),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}