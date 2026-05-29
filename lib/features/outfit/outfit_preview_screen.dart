import 'package:fashion_app/features/outfit/screens/digital_showroom_screen.dart';
import 'package:flutter/material.dart';
import 'package:fashion_app/features/products/models/product_model.dart';
import '../../core/widgets/product_image.dart';

enum PreviewMode { outfit, editorial }

enum SilhouetteType { female, male }

String silhouetteAsset(SilhouetteType type) {
  switch (type) {
    case SilhouetteType.male:
      return 'assets/images/silhouette_uomo.png';
    case SilhouetteType.female:
      return 'assets/images/silhouette_donna.png';
  }
}

extension FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

////////////////////////////////////////////////////////////
/// MAIN SCREEN
////////////////////////////////////////////////////////////

class OutfitPreviewScreen extends StatefulWidget {
  final List<Product> selectedProducts;

  const OutfitPreviewScreen({
    super.key,
    required this.selectedProducts,
  });

  @override
  State<OutfitPreviewScreen> createState() => _OutfitPreviewScreenState();
}

class _OutfitPreviewScreenState extends State<OutfitPreviewScreen>
    with SingleTickerProviderStateMixin {
  PreviewMode mode = PreviewMode.outfit;
  double topOpacity = 0.45;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  SilhouetteType get silhouetteType {
    final hasMale = widget.selectedProducts.any((p) => p.gender == ProductGender.male);
    return hasMale ? SilhouetteType.male : SilhouetteType.female;
  }

  List<Product> get effectiveProducts {
    final hasDress = widget.selectedProducts.any((p) => p.layer == ProductLayer.dress);
    if (!hasDress) return widget.selectedProducts;
    return widget.selectedProducts.where((p) {
      return p.layer != ProductLayer.top && p.layer != ProductLayer.bottom;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeOutBack,
    );
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _fabController.forward();
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            /// Background Gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.9,
                    center: const Alignment(0, -0.15),
                    colors: [Colors.grey.shade900, Colors.black],
                  ),
                ),
              ),
            ),

            /// Header
            Positioned(
              left: 12,
              right: 12,
              top: 8,
              child: Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  _ModeSwitch(
                    mode: mode,
                    onChanged: (m) => setState(() => mode = m),
                  ),
                ],
              ),
            ),

            /// Content (Outfit or Editorial)
            Positioned.fill(
              top: 72,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: mode == PreviewMode.outfit
                    ? _OutfitMode(
                  products: effectiveProducts,
                  topOpacity: topOpacity,
                  silhouetteType: silhouetteType,
                  onOpacityChanged: (v) => setState(() => topOpacity = v),
                )
                    : _EditorialMode(
                  products: effectiveProducts,
                  silhouetteType: silhouetteType,
                ),
              ),
            ),

            /// Footer recap
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _FooterRecap(products: effectiveProducts),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 55),
        child: ScaleTransition(
          scale: _fabAnimation,
          child: FadeTransition(
            opacity: _fabAnimation,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.white,
              elevation: 8,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DigitalShowroomScreen(
                      products: widget.selectedProducts,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.analytics_outlined, color: Colors.black, size: 20),
              label: const Text("Showroom Mode", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

////////////////////////////////////////////////////////////
/// OUTFIT MODE (WEARABLE ON SILHOUETTE)
////////////////////////////////////////////////////////////

class _OutfitMode extends StatelessWidget {
  final List<Product> products;
  final double topOpacity;
  final ValueChanged<double> onOpacityChanged;
  final SilhouetteType silhouetteType;

  const _OutfitMode({
    required this.products,
    required this.topOpacity,
    required this.onOpacityChanged,
    required this.silhouetteType,
  });

  @override
  Widget build(BuildContext context) {
    final outerwear = products.where((p) => p.layer == ProductLayer.outerwear).firstOrNull;
    final top = products.where((p) => p.layer == ProductLayer.top).firstOrNull;
    final bottom = products.where((p) => p.layer == ProductLayer.bottom).firstOrNull;
    final dress = products.where((p) => p.layer == ProductLayer.dress).firstOrNull;
    final hat = products.where((p) => p.layer == ProductLayer.hat).firstOrNull;
    final scarf = products.where((p) => p.layer == ProductLayer.scarf).firstOrNull;
    final gloves = products.where((p) => p.layer == ProductLayer.gloves).firstOrNull;

    final hasDress = dress != null;

    return Center(
      child: Transform.scale(
        scale: 1.15,
        child: AspectRatio(
          aspectRatio: 1500 / 2000,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  /// SILHOUETTE
                  Positioned.fill(
                    child: Image.asset(
                      silhouetteAsset(silhouetteType),
                      fit: BoxFit.contain,
                    ),
                  ),

                  /// BOTTOM
                  if (!hasDress && bottom != null)
                    Positioned(
                      top: h * 0.39,
                      left: w * 0.22,
                      child: _TransformWrapper(
                        product: bottom,
                        canvasHeight: h,
                        child: _HeroCloth(
                          tag: 'preview_${bottom.id}',
                          imageUrl: bottom.outfitImage,
                          width: w * 0.58,
                        ),
                      ),
                    ),

                  /// DRESS
                  if (hasDress)
                    Positioned(
                      top: h * 0.13,
                      left: w * 0.28,
                      child: _TransformWrapper(
                        product: dress,
                        canvasHeight: h,
                        child: _HeroCloth(
                          tag: 'preview_${dress.id}',
                          imageUrl: dress.outfitImage,
                          width: w * 0.45,
                        ),
                      ),
                    ),

                  /// OUTERWEAR
                  if (outerwear != null)
                    Positioned(
                      top: h * 0.13,
                      child: _TransformWrapper(
                        product: outerwear,
                        canvasHeight: h,
                        child: _HeroCloth(
                          tag: 'preview_${outerwear.id}',
                          imageUrl: outerwear.outfitImage,
                          width: w * 0.45,
                          highlight: top != null,
                        ),
                      ),
                    ),

                  /// TOP
                  if (!hasDress && top != null)
                    Positioned(
                      top: h * 0.14,
                      child: Opacity(
                        opacity: outerwear != null ? topOpacity : 1.0,
                        child: _TransformWrapper(
                          product: top,
                          canvasHeight: h,
                          child: _HeroCloth(
                            tag: 'preview_${top.id}',
                            imageUrl: top.outfitImage,
                            width: w * 0.42,
                            highlight: outerwear != null,
                          ),
                        ),
                      ),
                    ),

                  /// HAT
                  if (hat != null)
                    Positioned(
                      top: h * -0.055,
                      left: w * 0.27,
                      child: _TransformWrapper(
                        product: hat,
                        canvasHeight: h,
                        child: _HeroCloth(
                          tag: 'preview_${hat.id}',
                          imageUrl: hat.outfitImage,
                          width: w * 0.48,
                        ),
                      ),
                    ),

                  /// SCARF
                  if (scarf != null)
                    Positioned(
                      top: h * 0.13,
                      child: _TransformWrapper(
                        product: scarf,
                        canvasHeight: h,
                        child: _HeroCloth(
                          tag: 'preview_${scarf.id}',
                          imageUrl: scarf.outfitImage,
                          width: w * 0.46,
                        ),
                      ),
                    ),

                  /// GLOVES
                  if (gloves != null)
                    Positioned(
                      top: h * 0.45,
                      right: w * 0.05,
                      child: _TransformWrapper(
                        product: gloves,
                        canvasHeight: h,
                        child: _HeroCloth(
                          tag: 'preview_${gloves.id}',
                          imageUrl: gloves.outfitImage,
                          width: w * 0.55,
                        ),
                      ),
                    ),

                  /// OPACITY SLIDER FOR TOP/OUTERWEAR
                  if (outerwear != null && top != null)
                    Positioned(
                      right: 30,
                      top: h * 0.28,
                      bottom: h * 0.28,
                      child: Column(
                        children: [
                          const Text("Top", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Expanded(
                            child: RotatedBox(
                              quarterTurns: 3,
                              child: Slider(
                                min: 0.45,
                                max: 1.0,
                                value: topOpacity,
                                activeColor: Colors.white,
                                inactiveColor: Colors.white24,
                                onChanged: onOpacityChanged,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text("${(topOpacity * 100).round()}%", style: const TextStyle(color: Colors.white38, fontSize: 10)),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// EDITORIAL MODE
////////////////////////////////////////////////////////////

class _EditorialMode extends StatelessWidget {
  final List<Product> products;
  final SilhouetteType silhouetteType;

  const _EditorialMode({required this.products, required this.silhouetteType});

  @override
  Widget build(BuildContext context) {
    // ... (stessa logica di recupero capi)
    final outerwear = products.where((p) => p.layer == ProductLayer.outerwear).firstOrNull;
    final top = products.where((p) => p.layer == ProductLayer.top).firstOrNull;
    final bottom = products.where((p) => p.layer == ProductLayer.bottom).firstOrNull;
    final dress = products.where((p) => p.layer == ProductLayer.dress).firstOrNull;
    final hat = products.where((p) => p.layer == ProductLayer.hat).firstOrNull;
    final scarf = products.where((p) => p.layer == ProductLayer.scarf).firstOrNull;
    final gloves = products.where((p) => p.layer == ProductLayer.gloves).firstOrNull;

    return Center(
      child: Transform.scale(
        scale: 1.15,
        child: AspectRatio(
          aspectRatio: 1500 / 2000,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final h = constraints.maxHeight;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  /// SILHOUETTE - Ora identica alla versione Outfit
                  Positioned.fill(
                    child: Image.asset(
                        silhouetteAsset(silhouetteType),
                        fit: BoxFit.contain
                    ),
                  ),

                  /// ITEMS - Posizioni "Exploded" sincronizzate ma con movimento editoriale
                  if (outerwear != null)
                    _EditorialItem(top: h * 0.16, left: w * -0.05, product: outerwear, width: w * 0.45, canvasHeight: h),

                  if (bottom != null)
                    _EditorialItem(top: h * 0.42, right: w * -0.12, product: bottom, width: w * 0.58, canvasHeight: h),

                  if (top != null)
                    _EditorialItem(top: h * 0.11, right: w * -0.05, product: top, width: w * 0.42, canvasHeight: h),

                  if (dress != null)
                    _EditorialItem(top: h * 0.18, right: w * -0.08, product: dress, width: w * 0.45, canvasHeight: h),

                  if (hat != null)
                    _EditorialItem(top: h * -0.07, left: w * 0.12, product: hat, width: w * 0.48, canvasHeight: h),

                  if (scarf != null)
                    _EditorialItem(top: h * 0.09, right: w * 0.08, product: scarf, width: w * 0.46, canvasHeight: h),

                  if (gloves != null)
                    _EditorialItem(top: h * 0.48, left: w * -0.08, product: gloves, width: w * 0.55, canvasHeight: h),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EditorialItem extends StatelessWidget {
  final double top;
  final double? left;
  final double? right;
  final Product product;
  final double width;
  final double canvasHeight;

  const _EditorialItem({
    required this.top,
    this.left,
    this.right,
    required this.product,
    required this.width,
    required this.canvasHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: _TransformWrapper(
        product: product,
        canvasHeight: canvasHeight,
        child: _HeroCloth(
          tag: 'edit_${product.id}',
          imageUrl: product.outfitImage,
          width: width,
          shadow: true,
        ),
      ),
    );
  }
}


////////////////////////////////////////////////////////////
/// HELPERS & COMPONENTS
////////////////////////////////////////////////////////////

class _TransformWrapper extends StatelessWidget {
  final Product product;
  final Widget child;
  final double canvasHeight;

  const _TransformWrapper({required this.product, required this.child, required this.canvasHeight});

  @override
  Widget build(BuildContext context) {
    // Normalizzazione Y (su 2000 unità)
    final double normalizedY = product.outfitYOffset * (canvasHeight / 2000);

    // Normalizzazione X (su 1500 unità, che è la larghezza della nostra griglia)
    // Usiamo canvasHeight * (1500/2000) per trovare la larghezza logica attuale
    final double canvasWidth = canvasHeight * (1500 / 2000);
    final double normalizedX = product.outfitXOffset * (canvasWidth / 1500);

    return Transform.translate(
      offset: Offset(normalizedX, normalizedY), // Ora usa anche normalizedX
      child: Transform.scale(
        scale: product.outfitScale,
        child: child,
      ),
    );
  }
}

class _HeroCloth extends StatelessWidget {
  final String tag;
  final String imageUrl;
  final double width;
  final bool highlight;
  final bool shadow;

  const _HeroCloth({required this.tag, required this.imageUrl, required this.width, this.highlight = false, this.shadow = true});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: SizedBox(
        width: width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (highlight)
              Container(
                width: width * 0.9,
                height: width * 0.9,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Colors.white12, Colors.transparent])),
              ),
            if (shadow)
              Positioned(
                bottom: -10,
                child: Container(
                  width: width * 0.7,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 30, spreadRadius: -10)],
                  ),
                ),
              ),
            ProductImage(
              image: imageUrl,
              fit: BoxFit.contain,
              size: ImageSize.medium,
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterRecap extends StatelessWidget {
  final List<Product> products;
  const _FooterRecap({required this.products});

  @override
  Widget build(BuildContext context) {
    final codes = products.map((e) => e.code).join(' · ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        codes.isEmpty ? "Seleziona i capi per vedere l’outfit" : codes,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle, border: Border.all(color: Colors.white12)),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  final PreviewMode mode;
  final ValueChanged<PreviewMode> onChanged;
  const _ModeSwitch({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModePill(label: "Outfit", selected: mode == PreviewMode.outfit, onTap: () => onChanged(PreviewMode.outfit)),
          _ModePill(label: "Editorial", selected: mode == PreviewMode.editorial, onTap: () => onChanged(PreviewMode.editorial)),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModePill({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(color: selected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(label, style: TextStyle(color: selected ? Colors.black : Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }
}