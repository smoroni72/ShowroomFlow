import 'package:fashion_app/core/widgets/product_image.dart';
import 'package:fashion_app/features/products/models/product_model.dart';
import 'package:fashion_app/features/products/providers/product_provider.dart';
import 'package:fashion_app/features/products/screens/product_detail_screen.dart';
import 'package:fashion_app/features/products/widgets/product_catalog_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/design_system/theme_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductListScreenNew extends ConsumerWidget {
  final String brandId;
  final String categoryId;
  final String categoryName;
  final String? categoryImage;

  const ProductListScreenNew({
    super.key,
    required this.brandId,
    required this.categoryId,
    required this.categoryName,
    this.categoryImage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final productsAsync = ref.watch(productsProvider(brandId));

    return productsAsync.when(
      loading: () => Scaffold(
        backgroundColor: theme.background,
        body: Center(
          child: CircularProgressIndicator(
            color: theme.textPrimary,
          ),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: theme.background,
        body: Center(
          child: Text(
            "Errore: $e",
            style: TextStyle(
              color: theme.textSecondary,
            ),
          ),
        ),
      ),
      data: (products) {

        WidgetsBinding.instance.addPostFrameCallback((_) {
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

        final filteredProducts = categoryId == "all"
            ? products
            : products.where((p) => p.categoryId == categoryId).toList();

        final grouped = _groupByCategory(filteredProducts);
        final isLogged =
            FirebaseAuth.instance.currentUser?.emailVerified ?? false;

        return Scaffold(
          backgroundColor: theme.background,
          body: CustomScrollView(
            slivers: [
              _buildHero(context, theme),

              /// 🔥 SEZIONI
              SliverList(
                delegate: SliverChildListDelegate(
                  _buildSections(grouped, isLogged, theme),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// =========================
  /// HERO
  /// =========================
  Widget _buildHero(BuildContext context, dynamic theme) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      stretch: true,
      backgroundColor: theme.background,
      foregroundColor: Colors.white,
      elevation: 0,

      title: Text(
        categoryName,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),

      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
          StretchMode.fadeTitle,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [

            /// IMAGE
            Hero(
              tag: "category_$brandId$categoryId",
              child: ProductImage(
                image: categoryImage?.isNotEmpty == true
                    ? categoryImage!
                    : "assets/images/category_placeholder.jpg",
                fit: BoxFit.cover,
              ),
            ),

            /// GRADIENT (più ricco, stile editoriale)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.overlayDark.withOpacity(0.15),
                    theme.overlayDark.withOpacity(0.35),
                    theme.overlayDark.withOpacity(0.75),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// GROUP
  /// =========================
  Map<String, List<Product>> _groupByCategory(List<Product> products) {
    final map = <String, List<Product>>{};
    for (final p in products) {
      map.putIfAbsent(p.categoryId, () => []).add(p);
    }
    return map;
  }

  /// =========================
  /// SECTIONS
  /// =========================
  List<Widget> _buildSections(
      Map<String, List<Product>> grouped,
      bool isLogged,
      dynamic theme,
      ) {
    final sections = <Widget>[];

    final entries = grouped.entries.toList();

    for (int index = 0; index < entries.length; index++) {
      final entry = entries[index];

      final categoryId = entry.key;
      final items = entry.value;

      final title = items.first.category ?? categoryId;
      final image = _getCategoryImage(categoryId, items);

      /// 🔥 ALTERNANZA EDITORIALE
      final isEven = index % 2 == 0;

      if (isEven) {
        /// 👉 BLOCCO SPLIT (immagine + testo)
        sections.add(
          EditorialHeaderBlock(
            title: title,
            image: image,
            reverse: index % 4 == 0,
            theme: theme,// alterna anche il lato
          ),
        );
      } else {
        /// 👉 BLOCCO FULL BLEED (cover)
        sections.add(
          EditorialCategoryFullBleed(
            title: title,
            image: image,
            theme: theme,
          ),
        );
      }

      /// 🔥 GRID PRODOTTI
      final gridItems = List<Product>.from(items);

      Product? lastOdd;
      if (gridItems.length.isOdd) {
        lastOdd = gridItems.removeLast();
      }

      sections.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: ProductMasonrySection(
            products: gridItems,
            isLogged: isLogged,
          ),
        ),
      );

      /// 🔥 PRODOTTO DISPARI (card larga)
      if (lastOdd != null) {
        sections.add(
          ProductFullWidthCard(
            product: lastOdd,
            isLogged: isLogged,
          ),
        );
      }
    }

    return sections;
  }

  /// =========================
  /// CATEGORY IMAGE
  /// =========================
  String _getCategoryImage(String categoryId, List<Product> products) {
    try {
      final product = products.firstWhere(
            (p) =>
        p.categoryId == categoryId &&
            p.categoryCover != null &&
            p.categoryCover!.isNotEmpty,
      );
      return product.categoryCover!;
    } catch (_) {
      return products.first.displayImage;
    }
  }
}

/// =======================================================
/// 🔥 HEADER EDITORIALE (FULL WIDTH + OFFSET)
/// =======================================================

class EditorialHeaderBlock extends StatelessWidget {
  final String image;
  final String title;
  final bool reverse;
  final dynamic theme;

  const EditorialHeaderBlock({
    super.key,
    required this.image,
    required this.title,
    this.reverse = false,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: Row(
        children: reverse
            ? [
          _buildText(reverse),
          const SizedBox(width: 16),
          _buildImage(reverse),
        ]
            : [
          _buildImage(reverse),
          const SizedBox(width: 16),
          _buildText(reverse),
        ],
      ),
    );
  }

  Widget _buildImage(bool reverse) {
    return Expanded(
      flex: 6,
      child: ClipRect(
        child: Transform.translate(
          offset: reverse
              ? const Offset(40, 0)
              : const Offset(-40, 0),
          child: OverflowBox(
            maxWidth: double.infinity,
            alignment: Alignment.center,
            child: AspectRatio(
              aspectRatio: 0.8,
              child: ProductImage(
                image: image,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildText(bool reverse) {
    return Expanded(
      flex: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
          reverse ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment:
              reverse ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                title.toUpperCase(),
                textAlign: reverse ? TextAlign.right : TextAlign.left,
                style: TextStyle(
                color: theme.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
              ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Una selezione pensata per valorizzare il punto vendita. "
                  "Linee contemporanee e combinazioni versatili per la stagione.",
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================================================
/// 🔥 GRID PRODOTTI
/// =======================================================

class ProductMasonrySection extends StatelessWidget {
  final List<Product> products;
  final bool isLogged;

  const ProductMasonrySection({
    super.key,
    required this.products,
    required this.isLogged,
  });

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCatalogCard(
          product: products[index],
          isLogged: isLogged,
        );
      },
    );
  }
}



/// =======================================================
/// 🔥 FULL BLEED CATEGORIA (DISPARI)
/// =======================================================
class EditorialCategoryFullBleed extends StatelessWidget {
  final String image;
  final String title;
  final dynamic theme;

  const EditorialCategoryFullBleed({
    super.key,
    required this.image,
    required this.title,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 460,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ProductImage(
            image: image,
            fit: BoxFit.cover,
          ),

          /// gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.center,
                colors: [
                  theme.overlayDark.withOpacity(0.75),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          /// titolo + testo
          Positioned(
            left: 24,
            bottom: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Selezione della collezione pensata per il punto vendita.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
/// =======================================================
/// 🔥 FULL WIDTH PRODOTTO (DISPARI)
/// =======================================================


class ProductFullWidthCard extends StatelessWidget {
  final Product product;
  final bool isLogged;

  const ProductFullWidthCard({
    super.key,
    required this.product,
    required this.isLogged,
  });

  @override
  Widget build(BuildContext context) {
    final heroTag = "product_${product.id}"; // 🔥 usa lo stesso delle altre card

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        },
        child: SizedBox(
          height: 300,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                /// 🔥 HERO IMAGE
                Hero(
                  tag: heroTag,
                  child: ProductImage(
                    image: product.displayImage,
                    fit: BoxFit.cover,
                  ),
                ),

                /// overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                Positioned(
                  left: 16,
                  bottom: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.code,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        product.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!isLogged)
                        const Text(
                          "Login per il prezzo",
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
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