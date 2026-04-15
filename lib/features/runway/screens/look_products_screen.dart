import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/theme_provider.dart';
import '../../../core/widgets/product_image.dart';
import '../../outfit/vetrina_screen.dart';
import '../../products/models/product_model.dart';
import '../../products/screens/product_detail_screen.dart';

class LookProductsScreen extends ConsumerStatefulWidget {
  final String brandId;
  final List<String> productIds;

  const LookProductsScreen({
    super.key,
    required this.brandId,
    required this.productIds,
  });

  @override
  ConsumerState<LookProductsScreen> createState() => _LookProductsScreenState();
}

class _LookProductsScreenState extends ConsumerState<LookProductsScreen> {
  final Random random = Random();

  final Map<String, Offset> positions = {};
  final Map<String, double> rotations = {};
  final Map<String, double> dynamicRotations = {};

  List<Product> products = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      if (widget.productIds.isEmpty) {
        if (!mounted) return;
        setState(() {
          products = [];
          isLoading = false;
        });
        return;
      }

      final snap = await FirebaseFirestore.instance
          .collection("products")
          .where(FieldPath.documentId, whereIn: widget.productIds)
          .get();

      if (!mounted) return;

      final loadedProducts = snap.docs
          .map((d) => Product.fromFirestore(d))
          .toList();

      final size = MediaQuery.of(context).size;

      final newPositions = <String, Offset>{};
      final newRotations = <String, double>{};
      final newDynamicRotations = <String, double>{};

      for (final product in loadedProducts) {
        newPositions[product.id] = Offset(
          random.nextDouble() * max(0, size.width - 210),
          random.nextDouble() * max(0, size.height - 360),
        );

        final baseRotation = (random.nextDouble() - 0.5) * 0.4;
        newRotations[product.id] = baseRotation;
        newDynamicRotations[product.id] = baseRotation;
      }

      setState(() {
        products = loadedProducts;
        positions
          ..clear()
          ..addAll(newPositions);
        rotations
          ..clear()
          ..addAll(newRotations);
        dynamicRotations
          ..clear()
          ..addAll(newDynamicRotations);
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = "Errore nel caricamento dei prodotti: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.background,
        foregroundColor: theme.textPrimary,
        elevation: 0,
        title: const Text("Look"),
      ),
      body: _buildBody(context, theme),
    );
  }

  Widget _buildBody(BuildContext context, dynamic theme) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.textPrimary,
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      );
    }

    if (products.isEmpty) {
      return Center(
        child: Text(
          "Nessun prodotto disponibile per questo look",
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 14,
          ),
        ),
      );
    }

    return Stack(
      children: [
        /// BACKGROUND
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.background,
                theme.overlayDark.withOpacity(0.08),
              ],
            ),
          ),
        ),

        /// POLAROIDS
        ...products.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;

          final pos = positions[product.id] ?? Offset.zero;
          final rot = dynamicRotations[product.id] ?? 0.0;

          return AnimatedPositioned(
            duration: Duration(milliseconds: 600 + index * 120),
            curve: Curves.easeOutBack,
            left: pos.dx,
            top: pos.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  final currentPos = positions[product.id] ?? Offset.zero;
                  positions[product.id] = currentPos + details.delta;

                  final baseRotation = rotations[product.id] ?? 0.0;
                  dynamicRotations[product.id] =
                      baseRotation + details.delta.dx * 0.006;
                });
              },
              onPanEnd: (_) {
                setState(() {
                  dynamicRotations[product.id] = rotations[product.id] ?? 0.0;
                });
              },
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 320),
                    reverseTransitionDuration:
                    const Duration(milliseconds: 220),
                    pageBuilder: (_, __, ___) => _ZoomProduct(
                      product: product,
                    ),
                    transitionsBuilder: (_, animation, __, child) {
                      return ScaleTransition(
                        scale: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Transform.rotate(
                angle: rot,
                child: TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 2100 + index * 60),
                  tween: Tween(begin: -300.0, end: 0.0),
                  curve: Curves.elasticOut,
                  builder: (_, value, child) {
                    return Transform.translate(
                      offset: Offset(0, value),
                      child: child,
                    );
                  },
                  child: _Polaroid(
                    product: product,
                    theme: theme,
                  ),
                ),
              ),
            ),
          );
        }).toList(),

        /// CTA
        Positioned(
          bottom: 30,
          left: 20,
          right: 20,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VetrinaScreen(
                    brandId: widget.brandId,
                    initialProducts: products,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: theme.textPrimary,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: theme.overlayDark.withOpacity(0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  "Prova outfit",
                  style: TextStyle(
                    color: theme.background,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    letterSpacing: 0.5,
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

class _Polaroid extends StatelessWidget {
  final Product product;
  final dynamic theme;

  const _Polaroid({
    required this.product,
    required this.theme,
  });

  static const _paperColor = Color(0xFFF5F1E8);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "product_${product.id}",
      child: Container(
        width: 210,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 36),
        decoration: BoxDecoration(
          color: _paperColor,
          borderRadius: BorderRadius.circular(4),

          /// bordo leggero per light mode
          border: Border.all(
            color: Colors.black.withOpacity(0.04),
            width: 0.8,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.22),
              blurRadius: 24,
              offset: const Offset(8, 12),
            ),
          ],
        ),
        child: Stack(
          children: [

            /// FOTO
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFFDFCF9),
                  width: 2,
                ),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: ProductImage(
                  image: product.displayImage,
                  fit: BoxFit.cover,
                  backgroundColor: Colors.white,
                ),
              ),
            ),

            /// LUCE CARTA
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomProduct extends StatefulWidget {
  final Product product;

  const _ZoomProduct({
    required this.product,
  });

  @override
  State<_ZoomProduct> createState() => _ZoomProductState();
}

class _ZoomProductState extends State<_ZoomProduct> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 900), () async {
      if (!mounted) return;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(
            product: widget.product,
          ),
        ),
      );

      if (!mounted) return;

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) Navigator.pop(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Hero(
          tag: "product_${widget.product.id}",
          child: ProductImage(
            image: widget.product.displayImage,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}