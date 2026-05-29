import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/theme_provider.dart';
import '../../core/widgets/product_image.dart';
import '../auth/auth_provider.dart';
import '../auth/login_screen.dart';
import 'brand_home_screen.dart';
import 'brand_home_screen_new.dart';
import 'brand_model.dart';
import 'brand_provider.dart';
import 'coming_soon_screen.dart';
import '../profile/screens/profile_screen.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/design_system/app_theme_model.dart';

class BrandScreen extends ConsumerWidget {
  const BrandScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print("🎨 [BRAND SCREEN] Building BrandScreen...");

    ref.listen(remoteThemeProvider, (previous, next) {
      next.whenData((theme) {
        print("🎨 [BRAND SCREEN] Remote theme updated.");
        ref.read(appThemeProvider.notifier).state = theme;
      });
    });

    final theme = ref.watch(appThemeProvider);
    final brandsAsync = ref.watch(publishedBrandsProvider);
    final tenantId = ref.watch(tenantIdProvider);

    print("🏢 [BRAND SCREEN] Current TenantId: '$tenantId'");

    return Scaffold(
      backgroundColor: theme.background,
      drawer: const AppDrawer(),
      body: brandsAsync.when(
        data: (brands) {
          print("✅ [BRAND SCREEN] Brands loaded: ${brands.length}");
          if (brands.isEmpty) {
            return const ComingSoonScreen();
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: theme.background,
                expandedHeight: 120,
                floating: true,
                pinned: true,
                elevation: 0,
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.menu, color: theme.textPrimary),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    "Brand",
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final brand = brands[index];
                      final rawHeader = brand.coverImage.isNotEmpty
                          ? brand.coverImage
                          : brand.logoUrl;
                      final headerImage = rawHeader.startsWith('/')
                          ? "https://fashion-app-ed9d3.web.app$rawHeader"
                          : rawHeader;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _PressableCard(
                          onTap: () async {
                            final provider = headerImage.startsWith('http')
                                ? NetworkImage(headerImage)
                                : AssetImage(headerImage) as ImageProvider;

                            await precacheImage(provider, context).catchError((_) {});

                            if (context.mounted) {
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
                            }
                          },
                          child: _BrandCardInner(
                            brand: brand,
                            theme: theme,
                            headerImage: headerImage,
                          ),
                        ),
                      );
                    },
                    childCount: brands.length,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(
            color: theme.primary,
            strokeWidth: 3,
          ),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded, size: 48, color: theme.accent),
                const SizedBox(height: 16),
                Text(
                  "Errore nel caricamento: $e",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandCardInner extends StatelessWidget {
  final Brand brand;
  final AppThemeModel theme;
  final String headerImage;

  const _BrandCardInner({
    required this.brand,
    required this.theme,
    required this.headerImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 1.5,
              child: Hero(
                tag: 'brand_cover_${brand.id}',
                child: ProductImage(
                  image: headerImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (brand.logoUrl.isNotEmpty)
                        Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ProductImage(image: brand.logoUrl, fit: BoxFit.contain),
                        ),
                      if (brand.logoUrl.isNotEmpty) const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          brand.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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