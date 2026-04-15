import 'package:fashion_app/features/products/screens/product_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/product_image.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../widgets/animated_editorial_item.dart';
import '../widgets/product_catalog_card.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  final String brandId;
  final String categoryId;
  final String categoryName;
  final String? categoryImage;

  const ProductListScreen({
    super.key,
    required this.brandId,
    required this.categoryId,
    required this.categoryName,
    this.categoryImage,
  });

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  String selectedCategory = "all";
  late int globalIndex;
  String? _lastPrefetchKey;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.categoryId;
  }

  String getCategoryImage(String categoryId, List<Product> products) {
    try {
      final product = products.firstWhere(
            (p) =>
        p.categoryId == categoryId &&
            p.categoryCover != null &&
            p.categoryCover!.isNotEmpty,
      );

      return product.categoryCover!;
    } catch (_) {
      // 🔥 fallback intelligente: usa immagine prodotto reale
      return products
          .firstWhere((p) => p.categoryId == categoryId)
          .displayImage;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsProvider(widget.brandId));

    return productsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text("Errore: $e")),
      ),
      data: (allProducts) {
        final categories = {
          "all": "Tutti",
          for (var p in allProducts)
            p.categoryId: _categoryName(p.categoryId)
        };

        final products = selectedCategory == "all"
            ? allProducts
            : allProducts
            .where((p) => p.categoryId == selectedCategory)
            .toList();

        final prefetchKey = "${widget.brandId}_$selectedCategory";

        if (_lastPrefetchKey != prefetchKey) {
          _lastPrefetchKey = prefetchKey;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            final int limit = products.length < 10 ? products.length : 10;

            for (int i = 0; i < limit; i++) {
              final img = products[i].displayImage;

              if (img.startsWith('http')) {
                precacheImage(
                  NetworkImage(img),
                  context,
                );
              }
            }
          });
        }

        final user = FirebaseAuth.instance.currentUser;
        final isLogged = user != null && user.emailVerified;

        return Scaffold(
          backgroundColor: const Color(0xFFFFFFFF),
          body: CustomScrollView(
            slivers: [
              /// HERO
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                title: Text(widget.categoryName),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag:
                        "category_${widget.brandId}_${widget.categoryId}",
                        child: ProductImage(
                          image: widget.categoryImage?.isNotEmpty == true
                              ? widget.categoryImage!
                              : "assets/images/category_placeholder.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.center,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// CHIP
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                  child: Wrap(
                    spacing: 10,
                    children: categories.entries.map((entry) {
                      return _categoryChip(entry.key, entry.value);
                    }).toList(),
                  ),
                ),
              ),

              /// 🔥 LAYOUT EDITORIALE
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    _buildSections(products, isLogged),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  List<Widget> _buildSections(List<Product> products, bool isLogged) {
    final sections = <Widget>[];

    int i = 0;
    final shownCategories = <String>{};

    while (i < products.length) {
      final current = products[i];
      final categoryId = current.categoryId;

      /// 🔥 BLOCCO EDITORIALE (prima volta categoria)
      if (!shownCategories.contains(categoryId)) {
        final sameCategoryProducts = <Product>[];

        sameCategoryProducts.add(products[i]);

        if (i + 1 < products.length &&
            products[i + 1].categoryId == categoryId) {
          sameCategoryProducts.add(products[i + 1]);
        }

        sections.add(_buildEditorialGroup(
          categoryId: categoryId,
          title: current.category ?? widget.categoryName,
          products: sameCategoryProducts,
          allProducts: products,
          isLogged: isLogged,
        ));

        shownCategories.add(categoryId);
        i += sameCategoryProducts.length;
        continue;
      }

      /// 🔥 MASONRY PACK (compattiamo)
      final pack = products.skip(i).take(4).toList();

      sections.add(_buildMasonryPack(pack, isLogged));

      i += pack.length;
    }

    return sections;
  }

  /// =========================
  /// 🔥 BLOCCO EDITORIALE WRAPPER
  /// =========================
  ///
  Widget _buildEditorialGroup({
    required String categoryId,
    required String title,
    required List<Product> products,
    required List<Product> allProducts,
    required bool isLogged,
  }) {
    final image = getCategoryImage(categoryId, allProducts);

    /// alternanza automatica
    final isReverse = categoryId.hashCode % 2 == 0;

    return isReverse
        ? _editorialCategoryBlockReverse(
      image: image,
      title: title,
      products: products,
      isLogged: isLogged,
    )
        : _editorialCategoryBlock(
      image: image,
      title: title,
      products: products,
      isLogged: isLogged,
    );
  }

  /// =========================
  /// 🔥 MASORY COMPATTA
  /// =========================
  ///
  Widget _buildMasonryPack(List<Product> items, bool isLogged) {
    if (items.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final product = items[index];

          return ProductCatalogCard(
            product: product,
            isLogged: isLogged,
          );
        },
      ),
    );
  }
  /// =========================
  /// 🔥 BLOCCO EDITORIALE
  /// =========================
  ///
  Widget _editorialCategoryBlock({
    required String image,
    required String title,
    required List<Product> products,
    required bool isLogged,
  }) {
    if (products.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        height: 320, // 🔥 blocco pieno
        child: Row(
          children: [

            /// 📸 IMMAGINE CATEGORIA
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [

                    /// IMMAGINE
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return OverflowBox(
                          maxHeight: constraints.maxHeight * 1.2,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ProductImage(
                              image: image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),

                    /// 🔥 OFFSET (effetto editoriale)
                    Transform.translate(
                      offset: const Offset(0, -30),
                      child: Container(),
                    ),

                    /// GRADIENT
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

                    /// TITOLO
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Text(
                        title.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            /// 🧥 PRODOTTI
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Expanded(
                    child: ProductCatalogCard(
                      product: products[0],
                      isLogged: isLogged,
                    ),
                  ),
                  if (products.length > 1) ...[
                    const SizedBox(height: 12),
                    Expanded(
                      child: ProductCatalogCard(
                        product: products[1],
                        isLogged: isLogged,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  /// =========================
  /// 🔥 BLOCCO EDITORIALE REVERSE
  /// =========================
  ///
  Widget _editorialCategoryBlockReverse({
    required String image,
    required String title,
    required List<Product> products,
    required bool isLogged,
  }) {
    if (products.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SizedBox(
        height: 420,
        child: Row(
          children: [

            /// 🧥 CARD A SINISTRA
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Expanded(
                    child: ProductCatalogCard(
                      product: products[0],
                      isLogged: isLogged,
                    ),
                  ),
                  if (products.length > 1) ...[
                    const SizedBox(height: 12),
                    Expanded(
                      child: ProductCatalogCard(
                        product: products[1],
                        isLogged: isLogged,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            /// 📸 IMMAGINE A DESTRA (più dominante)
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [

                    LayoutBuilder(
                      builder: (context, constraints) {
                        return OverflowBox(
                          maxHeight: constraints.maxHeight * 1.2,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ProductImage(
                              image: image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),

                    /// 🔥 OFFSET PIÙ FORTE
                    Transform.translate(
                      offset: const Offset(0, -40),
                      child: Container(),
                    ),

                    /// GRADIENT
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black.withOpacity(0.65),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                    /// TITOLO
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Text(
                        title.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
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
  /// =========================
  /// 🔥 BLOCCO A
  /// =========================

  Widget _blockA(Product p1, Product p2, Product p3, bool isLogged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: SizedBox(
                height: 320,
                child: AnimatedEditorialItem(
                  index: globalIndex++, // 🔥 QUI
                  child: ProductCatalogCard(product: p1, isLogged: isLogged),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Expanded(
                    child: AnimatedEditorialItem(
                      index: globalIndex++,
                      child: ProductCatalogCard(product: p2, isLogged: isLogged),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: AnimatedEditorialItem(
                      index: globalIndex++,
                      child: ProductCatalogCard(product: p3, isLogged: isLogged),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// 🔥 BLOCCO C (2 colonne)
  /// =========================

  Widget _blockC(Product p1, Product p2, bool isLogged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: AnimatedEditorialItem(
              index: globalIndex++,
              child: ProductCatalogCard(product: p1, isLogged: isLogged),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: AnimatedEditorialItem(
            index: globalIndex++,
            child: ProductCatalogCard(product: p2, isLogged: isLogged),
           ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// 🔥 SINGLE
  /// =========================

  Widget _single(Product p, bool isLogged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AnimatedEditorialItem(
        index: globalIndex++,
        child: ProductCatalogCard(
            product: p, isLogged: isLogged
        ),
      ),
    );
  }

  Widget _blockAReverse(Product p1, Product p2, Product p3, bool isLogged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Expanded(
                    child: AnimatedEditorialItem(
                      index: globalIndex++,
                      child: ProductCatalogCard(
                          product: p1, isLogged: isLogged
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: AnimatedEditorialItem(
                      index: globalIndex++,
                      child: ProductCatalogCard(
                          product: p2, isLogged: isLogged
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 6,
              child: SizedBox(
                height: 320,
                child: AnimatedEditorialItem(
                  index: globalIndex++,
                  child: ProductCatalogCard(
                      product: p3, isLogged: isLogged
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blockGrid4(
      Product p1,
      Product p2,
      Product p3,
      Product p4,
      bool isLogged,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AnimatedEditorialItem(
                  index: globalIndex++,
                  child: ProductCatalogCard(
                    product: p1, isLogged: isLogged
                                ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AnimatedEditorialItem(
                  index: globalIndex++,
                  child: ProductCatalogCard(
                    product: p2, isLogged: isLogged
                                ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: ProductCatalogCard(product: p3, isLogged: isLogged)),
              const SizedBox(width: 10),
              Expanded(child: ProductCatalogCard(product: p4, isLogged: isLogged)),
            ],
          ),
        ],
      ),
    );
  }
  /// =========================
  /// 🔥 CATEGORIA BANNER
  /// =========================

  Widget _categoryBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            ProductImage(
              image:
              "assets/images/category_placeholder.jpg", // 🔥 cambia con le tue
              height: 180,
              fit: BoxFit.cover,
            ),
            Container(
              height: 180,
              alignment: Alignment.center,
              color: Colors.black.withOpacity(0.25),
              child: const Text(
                "NUOVA COLLEZIONE",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// CHIP
  /// =========================

  Widget _categoryChip(String id, String label) {
    final isSelected = selectedCategory == id;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          selectedCategory = id;
        });
      },
    );
  }
}

String _categoryName(String id) {
  switch (id) {
    case "c1":
      return "Giacche";
    case "c2":
      return "Maglie";
    case "c3":
      return "Pantaloni";
    case "c4":
      return "Abiti";
    case "c5":
      return "Sciarpe";
    case "c6":
      return "Cappelli";
    case "c7":
      return "Guanti";
    default:
      return id;
  }
}