import 'dart:async';

import 'package:fashion_app/features/products/screens/product_list_screen_new.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/product_image.dart';
import '../outfit/vetrina_screen.dart';
import '../products/models/product_model.dart';
import '../products/providers/product_provider.dart';
import '../products/screens/product_list_screen.dart';
import '../products/widgets/featured_products_carousel.dart';
import '../runway/screens/runway_screen.dart';

class BrandHomeScreen extends ConsumerStatefulWidget {
  final String brandId;
  final String brandName;
  final String coverImage;
  final String logoUrl;
  final String description;

  const BrandHomeScreen({
    super.key,
    required this.brandId,
    required this.brandName,
    required this.coverImage,
    required this.logoUrl,
    required this.description,
  });

  @override
  ConsumerState<BrandHomeScreen> createState() => _BrandHomeScreenState();
}

class _BrandHomeScreenState extends ConsumerState<BrandHomeScreen> {

  int _activeCategory = 0;
  Timer? _zoomTimer;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _zoomTimer = Timer.periodic(
      const Duration(seconds: 2),
          (_) {
        setState(() {
          _activeCategory++;
        });
      },
    );
  }

  @override
  void dispose() {
    _zoomTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final headerImage =
    widget.coverImage.isNotEmpty ? widget.coverImage : widget.logoUrl;

    final productsAsync =
    ref.watch(productsProvider(widget.brandId));

    return Scaffold(

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: Row(
            children: [

              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        // builder: (_) => ProductListScreen(
                        //   brandId: widget.brandId,
                        //   categoryId: "all",
                        //   categoryName: "Catalogo",
                        // ),
                        builder: (_) => ProductListScreenNew(
                          brandId: widget.brandId,
                          categoryId: "all",
                          categoryName: "Catalogo",
                        ),
                      ),
                    );
                  },
                  child: const Text("Catalogo"),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            RunwayScreen(brandId: widget.brandId),
                      ),
                    );
                  },
                  child: const Text("Runway"),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            VetrinaScreen(brandId: widget.brandId),
                      ),
                    );
                  },
                  child: const Text("Vetrina"),
                ),
              ),

            ],
          ),
        ),
      ),

      body: CustomScrollView(
        slivers: [

          /// HERO con parallax
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 300,
            title: Text(widget.brandName),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [

                  Hero(
                    tag: 'brand_cover_${widget.brandId}',
                    child: ProductImage(
                      image: headerImage,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.black87,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// LOGO + NOME
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [

                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: ProductImage(
                        image: widget.logoUrl,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Text(
                      widget.brandName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// DESCRIZIONE
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.description,
                style:
                Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),

          /// CATEGORIE titolo
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Categorie",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),

          /// CATEGORIE stile editoriale Zara
          SliverToBoxAdapter(
            child: productsAsync.when(

              loading: () => const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                    child: CircularProgressIndicator()),
              ),

              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text("Errore: $e"),
              ),

              data: (products) {

                final visibleProducts =
                products.where((p) => p.visible).toList();

                visibleProducts.sort(
                        (a, b) => a.order.compareTo(b.order));

                final Map<String, Product> categories = {};

                for (var p in visibleProducts) {
                  if (!categories.containsKey(p.categoryId)) {
                    categories[p.categoryId] = p;
                  }
                }

                final list = categories.values.toList();

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {

                      final width = constraints.maxWidth;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(list.length, (index) {

                          final product = list[index];

                          final isActive =
                              index == (_activeCategory % list.length);

                          final bool isHero = index == 0;

                          final double cardWidth =
                          isHero ? width : (width - 12) / 2;

                          return SizedBox(
                            width: cardWidth,
                            height: isHero ? 180 : 150,

                            child: TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: 1,
                                end: isActive ? 1.03 : 1,
                              ),
                              duration: const Duration(milliseconds: 900),
                              curve: Curves.easeInOut,
                              builder: (context, value, child) {

                                return Transform.scale(
                                  scale: value,
                                  child: child,
                                );
                              },
                              child: _categoryCard(
                                context,
                                title: product.category ?? product.categoryId,
                                image: getCategoryImage(product.categoryId, visibleProducts),
                                categoryId: product.categoryId,
                                categoryCover: product.categoryCover,
                                isActive: isActive,
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 30)),

          /// FEATURED
          SliverToBoxAdapter(
            child: productsAsync.when(

              loading: () => const SizedBox(),

              error: (_, __) => const SizedBox(),

              data: (products) {

                final featuredProducts = products
                    .where((p) => p.featured && p.visible)
                    .toList();

                if (featuredProducts.isEmpty) {
                  return const SizedBox();
                }

                return FeaturedProductsCarousel(
                  title: "Collezione in evidenza",
                  products: featuredProducts,
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _categoryCard(
      BuildContext context, {
        required String title,
        required String image,
        required String categoryId,
        String? categoryCover,
        required bool isActive,
      }) {

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductListScreen(
              brandId: widget.brandId,
              categoryId: categoryId,
              categoryName: title,
              categoryImage: categoryCover,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: TweenAnimationBuilder<double>(
          tween: Tween(
            begin: 1,
            end: isActive ? 1.03 : 1,
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
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: isActive ? -8 : 0,
                    ),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeInOut,
                    builder: (context, offset, child) {

                      return Transform.translate(
                        offset: Offset(0, offset),
                        child: child,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Hero(
                        tag: "category_${widget.brandId}_$categoryId",
                        child: AspectRatio(
                          aspectRatio: 1.2,
                          child: ProductImage(
                            image: image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ),
                  ),
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
                              width: 80,
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
            
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.center,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
            
                  Positioned(
                    left: 14,
                    bottom: 14,
                    child: Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    )
                  ),
                ],
              ),
            ),
        ),
      ),
    );
  }

  String getCategoryImage(String categoryId, List<Product> products) {

    final categoryProducts =
    products.where((p) => p.categoryId == categoryId).toList();

    if (categoryProducts.isEmpty) {
      return '';
    }

    final candidates = categoryProducts
        .where((p) => (p.categoryCover ?? '').isNotEmpty)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    if (candidates.isNotEmpty) {
      return candidates.first.categoryCover!;
    }

    categoryProducts.sort((a, b) => a.order.compareTo(b.order));
    return categoryProducts.first.displayImage;
  }
}