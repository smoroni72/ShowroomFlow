import 'package:fashion_app/features/products/screens/product_list_screen_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/theme_provider.dart';
import '../../core/widgets/product_image.dart';
import '../outfit/vetrina_screen.dart';
import '../products/models/product_model.dart';
import '../products/providers/product_provider.dart';
import '../products/widgets/featured_products_carousel.dart';
import '../runway/screens/runway_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BrandHomeScreenNew extends ConsumerStatefulWidget {
  final String brandId;
  final String brandName;
  final String coverImage;
  final String logoUrl;
  final String description;

  const BrandHomeScreenNew({
    super.key,
    required this.brandId,
    required this.brandName,
    required this.coverImage,
    required this.logoUrl,
    required this.description,
  });

  @override
  ConsumerState<BrandHomeScreenNew> createState() => _BrandHomeScreenNewState();
}

class _BrandHomeScreenNewState extends ConsumerState<BrandHomeScreenNew> {
  final ScrollController _scrollController = ScrollController();
  bool _didPrecache = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _openCatalog({
    required BuildContext context,
    required String categoryId,
    required String categoryName,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductListScreenNew(
          brandId: widget.brandId,
          categoryId: categoryId,
          categoryName: categoryName,
        ),
      ),
    );
  }

  void _openRunway(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RunwayScreen(brandId: widget.brandId),
      ),
    );
  }

  void _openVetrina(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VetrinaScreen(brandId: widget.brandId),
      ),
    );
  }

  ImageProvider _imageProvider(String image) {
    if (image.startsWith('http')) return NetworkImage(image);
    return AssetImage(image);
  }

  void _precacheAssetsIfNeeded(
      BuildContext context,
      String heroImage,
      List<_BrandCategoryItem> categories,
      List<Product> products, // 👈 NUOVO
      ) {
    if (_didPrecache) return;
    _didPrecache = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      /// HERO
      precacheImage(_imageProvider(heroImage), context);

      /// CATEGORIE
      for (final item in categories.take(10)) {
        if (item.image.isNotEmpty) {
          precacheImage(_imageProvider(item.image), context);
        }
      }

      /// 🔥 PRODOTTI (NUOVO)
      for (final product in products.take(50)) {
        final url = product.displayImage;

        if (url.isNotEmpty && url.startsWith('http')) {
          precacheImage(
            CachedNetworkImageProvider(url),
            context,
          ).catchError((_) {});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = ref.watch(appThemeProvider);
    final productsAsync = ref.watch(productsProvider(widget.brandId));

    final headerImage =
    widget.coverImage.isNotEmpty ? widget.coverImage : widget.logoUrl;

    return Scaffold(
      backgroundColor: appTheme.background,
      bottomNavigationBar: _BottomEditorialActions(
        theme: appTheme,
        onCatalogTap: () => _openCatalog(
          context: context,
          categoryId: 'all',
          categoryName: 'Catalogo',
        ),
        onRunwayTap: () => _openRunway(context),
        onVetrinaTap: () => _openVetrina(context),
      ),
      body: productsAsync.when(
        loading: () {
          debugPrint("⏳ productsAsync loading: ${widget.brandId}");
          return _BrandHomeLoadingState(
            brandId: widget.brandId,
            brandName: widget.brandName,
            headerImage: headerImage,
            logoUrl: widget.logoUrl,
          );
        },
        error: (error, stack) {
          return _BrandHomeErrorState(
            theme: appTheme,
            brandName: widget.brandName,
            headerImage: headerImage,
            message: 'Errore nel caricamento del brand: $error',
            onRetry: () => ref.invalidate(productsProvider(widget.brandId)),
          );
        },
        data: (products) {
          debugPrint("✅ BrandHome products: ${products.length}");
          for (final p in products.take(5)) {
            debugPrint("🧾 ${p.code} -> ${p.displayImage}");
          }
          final visibleProducts = products
              .where((p) => p.visible)
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));

          final categories = _buildCategoryItems(visibleProducts);

          final featuredProducts = visibleProducts
              .where((p) => p.featured)
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));

          _precacheAssetsIfNeeded(
            context,
            headerImage,
            categories,
            visibleProducts, // 👈 NUOVO
          );

          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _BrandHeroSliver(
                theme: appTheme,
                brandId: widget.brandId,
                brandName: widget.brandName,
                description: widget.description,
                headerImage: headerImage,
                logoUrl: widget.logoUrl,
                onCatalogTap: () => _openCatalog(
                  context: context,
                  categoryId: 'all',
                  categoryName: 'Catalogo',
                ),
                onRunwayTap: () => _openRunway(context),
              ),

              SliverToBoxAdapter(
                child: _BrandIntroBlock(
                  theme: appTheme,
                  brandName: widget.brandName,
                  description: widget.description,
                  onExploreTap: () => _openCatalog(
                    context: context,
                    categoryId: 'all',
                    categoryName: 'Catalogo',
                  ),
                ),
              ),

              if (categories.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    theme: appTheme,
                    eyebrow: 'Edit',
                    title: 'Categorie selezionate',
                    subtitle:
                    'Una navigazione editoriale pensata per entrare subito nelle linee prodotto più rilevanti.',
                  ),
                ),
                SliverToBoxAdapter(
                  child: _EditorialCategoriesSection(
                    theme: appTheme,
                    items: categories,
                    brandId: widget.brandId,
                    onCategoryTap: (item) {
                      _openCatalog(
                        context: context,
                        categoryId: item.categoryId,
                        categoryName: item.title,
                      );
                    },
                  ),
                ),
              ],

              if (featuredProducts.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    theme: appTheme,
                    eyebrow: 'Featured',
                    title: 'Collezione in evidenza',
                    subtitle:
                    'Una selezione curata dei prodotti chiave del brand.',
                  ),
                ),
                SliverToBoxAdapter(
                  child: FeaturedProductsCarousel(
                    title: '',
                    products: featuredProducts,
                  ),
                ),
              ],

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  child: _BrandClosingBanner(
                    theme: appTheme,
                    brandName: widget.brandName,
                    onPrimaryTap: () => _openVetrina(context),
                    onSecondaryTap: () => _openRunway(context),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<_BrandCategoryItem> _buildCategoryItems(List<Product> products) {
    final Map<String, Product> firstProductByCategory = {};

    for (final product in products) {
      if (!firstProductByCategory.containsKey(product.categoryId)) {
        firstProductByCategory[product.categoryId] = product;
      }
    }

    final items = <_BrandCategoryItem>[];

    for (final entry in firstProductByCategory.entries) {
      final categoryId = entry.key;
      final product = entry.value;
      final image = _getCategoryImage(categoryId, products);

      if (image.isEmpty) continue;

      items.add(
        _BrandCategoryItem(
          categoryId: categoryId,
          title: (product.category ?? product.categoryId).trim(),
          image: image,
          categoryCover: product.categoryCover,
        ),
      );
    }

    return items;
  }

  String _getCategoryImage(String categoryId, List<Product> products) {
    final categoryProducts =
    products.where((p) => p.categoryId == categoryId).toList();

    if (categoryProducts.isEmpty) return '';

    final coverCandidates = categoryProducts
        .where((p) {
      final cover = (p.categoryCover ?? '').trim();
      return cover.isNotEmpty && cover.startsWith('http');
    })
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    if (coverCandidates.isNotEmpty) {
      return coverCandidates.first.categoryCover!;
    }

    categoryProducts.sort((a, b) => a.order.compareTo(b.order));
    return categoryProducts.first.displayImage;
  }
}

class _BrandHeroSliver extends StatelessWidget {
  final dynamic theme;
  final String brandId;
  final String brandName;
  final String description;
  final String headerImage;
  final String logoUrl;
  final VoidCallback onCatalogTap;
  final VoidCallback onRunwayTap;

  const _BrandHeroSliver({
    required this.theme,
    required this.brandId,
    required this.brandName,
    required this.description,
    required this.headerImage,
    required this.logoUrl,
    required this.onCatalogTap,
    required this.onRunwayTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: theme.background,
      foregroundColor: Colors.white,
      pinned: true,
      stretch: true,
      elevation: 0,
      expandedHeight: 560,
      titleSpacing: 0,
      title: Text(
        brandName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        stretchModes: const [
          StretchMode.zoomBackground,
          // StretchMode.blurBackground,
          StretchMode.fadeTitle,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'brand_cover_$brandId',
              child: ProductImage(
                image: headerImage,
                fit: BoxFit.cover,
              ),
            ),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.overlayDark.withOpacity(0.18),
                    theme.overlayDark.withOpacity(0.28),
                    theme.overlayDark.withOpacity(0.72),
                    theme.overlayDark.withOpacity(0.94),
                  ],
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // _HeroBrandBadge(
                    //   logoUrl: logoUrl,
                    //   brandName: brandName,
                    // ),
                    const Spacer(),
                    Text(
                      brandName.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        height: 1.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Text(
                        _sanitizeDescription(description),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _EditorialPrimaryButton(
                          label: 'Scopri la collezione',
                          onTap: onCatalogTap,
                        ),
                        _EditorialSecondaryButton(
                          label: 'Guarda il Lookbook',
                          onTap: onRunwayTap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _sanitizeDescription(String value) {
    final text = value.trim();
    if (text.isEmpty || text.toLowerCase() == 'coming') {
      return 'Scopri collezioni, categorie e contenuti visuali del brand in un’esperienza immersiva e orientata alla vendita.';
    }
    return text;
  }
}

class _HeroBrandBadge extends StatelessWidget {
  final String logoUrl;
  final String brandName;

  const _HeroBrandBadge({
    required this.logoUrl,
    required this.brandName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withOpacity(0.14),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(
            child: Container(
              width: 34,
              height: 34,
              color: Colors.white,
              child: ProductImage(
                image: logoUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            brandName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandIntroBlock extends StatelessWidget {
  final dynamic theme;
  final String brandName;
  final String description;
  final VoidCallback onExploreTap;

  const _BrandIntroBlock({
    required this.theme,
    required this.brandName,
    required this.description,
    required this.onExploreTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = description.trim().isEmpty || description.trim() == 'coming'
        ? 'Una narrazione visiva del brand, con accesso immediato a catalogo, categorie e contenuti chiave.'
        : description.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.overlayDark.withOpacity(0.06),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Brand story',
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              brandName,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 26,
                height: 1.1,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              text,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 15,
                height: 1.7,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onExploreTap,
              style: TextButton.styleFrom(
                foregroundColor: theme.textPrimary,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Vedi tutti i prodotti',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final dynamic theme;
  final String eyebrow;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.theme,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 24,
              height: 1.1,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}


class _EditorialCategoriesSection extends StatefulWidget {
  final dynamic theme;
  final List<_BrandCategoryItem> items;
  final String brandId;
  final ValueChanged<_BrandCategoryItem> onCategoryTap;

  const _EditorialCategoriesSection({
    required this.theme,
    required this.items,
    required this.brandId,
    required this.onCategoryTap,
  });

  @override
  State<_EditorialCategoriesSection> createState() =>
      _EditorialCategoriesSectionState();
}

class _EditorialCategoriesSectionState
    extends State<_EditorialCategoriesSection> {
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    _startLoop();
  }

  void _startLoop() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted || widget.items.isEmpty) return;

      setState(() {
        _activeIndex = (_activeIndex + 1) % widget.items.length;
      });

      _startLoop();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final featured = widget.items.first;
          final secondary = widget.items.skip(1).toList();

          return Column(
            children: [
              _EditorialCategoryCard(
                theme: widget.theme,
                brandId: widget.brandId,
                item: featured,
                width: width,
                height: 320,
                featured: true,
                isActive: _activeIndex == 0,
                onTap: () => widget.onCategoryTap(featured),
              ),
              if (secondary.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: secondary.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;

                    return _EditorialCategoryCard(
                      theme: widget.theme,
                      brandId: widget.brandId,
                      item: item,
                      width: (width - 14) / 2,
                      height: 220,
                      featured: false,
                      isActive: _activeIndex == index + 1,
                      onTap: () => widget.onCategoryTap(item),
                    );
                  }).toList(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
class _EditorialCategoryCard extends StatelessWidget {
  final dynamic theme;
  final String brandId;
  final _BrandCategoryItem item;
  final double width;
  final double height;
  final bool featured;
  final bool isActive;
  final VoidCallback onTap;

  const _EditorialCategoryCard({
    required this.theme,
    required this.brandId,
    required this.item,
    required this.width,
    required this.height,
    required this.featured,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(featured ? 26 : 22);

    return SizedBox(
      width: width,
      height: height,
      child: GestureDetector(
        onTap: onTap,

        child: TweenAnimationBuilder<double>(
          tween: Tween(
            begin: 1,
            end: isActive ? 1.035 : 1,
          ),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeInOutCubic,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: child,
            );
          },

          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              fit: StackFit.expand,
              children: [

                /// 🔥 PARALLAX (vecchio style)
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0,
                    end: isActive ? -10 : 0,
                  ),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeInOut,
                  builder: (context, offset, child) {
                    return Transform.translate(
                      offset: Offset(0, offset),
                      child: child,
                    );
                  },
                  child: Hero(
                    tag: 'category_${brandId}_${item.categoryId}',
                    child: ProductImage(
                      image: item.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                /// GRADIENT
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.overlayDark.withOpacity(0.08),
                        theme.overlayDark.withOpacity(0.20),
                        theme.overlayDark.withOpacity(0.74),
                      ],
                    ),
                  ),
                ),

                /// 🔥 SHINE (automatico come prima)
                if (isActive)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: -1, end: 2),
                    duration: const Duration(milliseconds: 1600),
                    curve: Curves.easeInOut,
                    builder: (context, value, child) {
                      return Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(value * 250, 0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.25),
                                  Colors.transparent,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                /// TESTO
                Positioned(
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        featured ? 'Featured category' : 'Category',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.title.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: featured ? 26 : 18,
                          height: 1.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: featured ? 1.2 : 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Esplora',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandClosingBanner extends StatelessWidget {
  final dynamic theme;
  final String brandName;
  final VoidCallback onPrimaryTap;
  final VoidCallback onSecondaryTap;

  const _BrandClosingBanner({
    required this.theme,
    required this.brandName,
    required this.onPrimaryTap,
    required this.onSecondaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.overlayDark.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next step',
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Continua l’esperienza $brandName',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 24,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Passa alla vetrina per una visione commerciale immediata oppure consulta il runway per una lettura più fashion e d’immagine.',
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(
                onPressed: onPrimaryTap,
                child: const Text('Vai alla vetrina'),
              ),
              OutlinedButton(
                onPressed: onSecondaryTap,
                child: const Text('Ispirati con il runway'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomEditorialActions extends StatelessWidget {
  final dynamic theme;
  final VoidCallback onCatalogTap;
  final VoidCallback onRunwayTap;
  final VoidCallback onVetrinaTap;

  const _BottomEditorialActions({
    required this.theme,
    required this.onCatalogTap,
    required this.onRunwayTap,
    required this.onVetrinaTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        decoration: BoxDecoration(
          color: theme.background.withOpacity(0.96),
          border: Border(
            top: BorderSide(
              color: theme.overlayDark.withOpacity(0.08),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCatalogTap,
                child: const Text('Catalogo'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: onRunwayTap,
                child: const Text('Runway'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: onVetrinaTap,
                child: const Text('Vetrina'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandHomeLoadingState extends ConsumerWidget {
  final String brandId;
  final String brandName;
  final String headerImage;
  final String logoUrl;

  const _BrandHomeLoadingState({
    required this.brandId,
    required this.brandName,
    required this.headerImage,
    required this.logoUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          backgroundColor: theme.background,
          foregroundColor: Colors.white,
          pinned: true,
          expandedHeight: 560,
          title: Text(brandName),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'brand_cover_$brandId',
                  child: ProductImage(
                    image: headerImage,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  color: theme.overlayDark.withOpacity(0.50),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: List.generate(
                5,
                    (index) => Container(
                  height: index == 0 ? 140 : 110,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BrandHomeErrorState extends StatelessWidget {
  final dynamic theme;
  final String brandName;
  final String headerImage;
  final String message;
  final VoidCallback onRetry;

  const _BrandHomeErrorState({
    required this.theme,
    required this.brandName,
    required this.headerImage,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ProductImage(
            image: headerImage,
            fit: BoxFit.cover,
          ),
          Container(color: theme.overlayDark.withOpacity(0.78)),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        brandName,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: onRetry,
                        child: const Text('Riprova'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorialPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _EditorialPrimaryButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EditorialSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _EditorialSecondaryButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withOpacity(0.6)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BrandCategoryItem {
  final String categoryId;
  final String title;
  final String image;
  final String? categoryCover;

  const _BrandCategoryItem({
    required this.categoryId,
    required this.title,
    required this.image,
    this.categoryCover,
  });
}