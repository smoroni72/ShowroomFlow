import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/theme_provider.dart';
import '../../core/widgets/product_image.dart';
import '../auth/login_screen.dart';
import 'brand_home_screen.dart';
import 'brand_home_screen_new.dart';
import 'brand_provider.dart';
import '../profile/screens/profile_screen.dart';

class BrandScreen extends ConsumerWidget {
  const BrandScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(remoteThemeProvider, (previous, next) {
      next.whenData((theme) {
        ref.read(appThemeProvider.notifier).state = theme;
      });
    });

    final theme = ref.watch(appThemeProvider);
    final brandsAsync = ref.watch(brandsProvider);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        foregroundColor: theme.textPrimary,
        titleTextStyle: TextStyle(
          color: theme.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(
          color: theme.textPrimary,
        ),
        title: Text(
          "Brands",
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [

          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {

              final user = FirebaseAuth.instance.currentUser;

              if (user == null) {

                /// NON LOGGATO → LOGIN
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                );

              } else {

                /// LOGGATO → PROFILO
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );

              }

            },
          ),

        ],
      ),
      body: brandsAsync.when(
        data: (brands) {

          if (brands.isEmpty) {
            return const Center(child: Text("Nessun brand disponibile"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: brands.length,
            itemBuilder: (context, index) {

              final brand = brands[index];

              final headerImage =
              brand.coverImage.isNotEmpty
                  ? brand.coverImage
                  : brand.logoUrl;

              /// simulazione stato (poi useremo backend)
              final bool available = brand.description != "coming";

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),

                child: _PressableCard(
                  onTap: () async {
                    debugPrint("🟢 TAP BRAND: ${brand.name} / ${brand.id}");

                    if (!available) return;

                    final provider = headerImage.startsWith('http')
                        ? NetworkImage(headerImage)
                        : AssetImage(headerImage) as ImageProvider;

                    precacheImage(provider, context).catchError((e) {
                      debugPrint("❌ brand hero precache error: $e");
                    });

                    Navigator.push(
                      context,
                      _fadeRoute(
                        BrandHomeScreenNew(
                          brandId: brand.id,
                          brandName: brand.name,
                          coverImage: brand.coverImage,
                          logoUrl: brand.logoUrl,
                          description: brand.description,
                        ),
                      ),
                    );
                  },

                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),

                    child: Stack(
                      children: [

                        Container(
                          color: theme.overlayLight.withOpacity(0.03),
                        ),
                        /// IMAGE
                        AspectRatio(
                          aspectRatio: 1.4,
                          child: Hero(
                            tag: 'brand_cover_${brand.id}',
                            child: ProductImage(
                              image: headerImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        /// GRADIENT
                        Positioned.fill(
                          child: Container(
                            decoration:  BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.center,
                                colors: [
                                  theme.overlayDark,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.center,
                                colors: [
                                  theme.overlayLight.withOpacity(0.15),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        /// BADGE STATUS
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: available
                                  ? theme.overlayDark.withOpacity(0.85)
                                  : theme.surface.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              available ? "Disponibile" : "Coming soon",
                              style: TextStyle(
                                color: available
                                    ? Colors.white
                                    : theme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),

                        /// BRAND NAME
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          child: Text(
                            brand.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },

        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 4,
          itemBuilder: (_, __) => Container(
            height: 180,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: theme.surface,
            ),
          ),
        ),

        error: (e, _) => Center(
          child: Text(
            "Errore: $e",
            style: TextStyle(color: theme.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _PressableCard extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onTap;

  const _PressableCard({
    required this.child,
    required this.onTap,
  });

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {

  bool _pressed = false;
  bool _busy = false;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),

      onTap: () async {

        if (_busy) return;

        setState(() => _busy = true);

        try {
          await widget.onTap();
        } finally {
          if (mounted) setState(() => _busy = false);
        }
      },

      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

Route _fadeRoute(Widget page) {

  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 220),
    reverseTransitionDuration: const Duration(milliseconds: 180),

    pageBuilder: (_, animation, __) =>
        FadeTransition(opacity: animation, child: page),
  );
}