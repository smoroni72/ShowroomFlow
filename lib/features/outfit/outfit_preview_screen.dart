import 'package:fashion_app/features/outfit/screens/runway_preview_screen.dart';
import 'package:fashion_app/features/outfit/screens/runway_video_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:fashion_app/features/products/models/product_model.dart';

import '../../core/widgets/product_image.dart';

enum PreviewMode { outfit, editorial }

enum AnchorType { head, neck, shoulder, waist }

class LayerConfig {
  final AnchorType anchor;
  final double anchorOffset;
  final double widthRatio;
  final int zIndex;

  const LayerConfig({
    required this.anchor,
    required this.anchorOffset,
    required this.widthRatio,
    required this.zIndex,
  });
}

const layerConfigs = {
  ProductLayer.hat: LayerConfig(
    anchor: AnchorType.head,
    anchorOffset: -0.02,
    widthRatio: 0.35,
    zIndex: 10,
  ),
  ProductLayer.scarf: LayerConfig(
    anchor: AnchorType.neck,
    anchorOffset: 0.00,
    widthRatio: 0.45,
    zIndex: 9,
  ),
  ProductLayer.outerwear: LayerConfig(
    anchor: AnchorType.shoulder,
    anchorOffset: 0.02,
    widthRatio: 0.80,
    zIndex: 6,
  ),
  ProductLayer.top: LayerConfig(
    anchor: AnchorType.shoulder,
    anchorOffset: 0.05,
    widthRatio: 0.72,
    zIndex: 5,
  ),
  ProductLayer.dress: LayerConfig(
    anchor: AnchorType.neck,
    anchorOffset: 0.03,
    widthRatio: 0.75,
    zIndex: 5,
  ),
  ProductLayer.bottom: LayerConfig(
    anchor: AnchorType.waist,
    anchorOffset: 0.00,
    widthRatio: 0.75,
    zIndex: 4,
  ),
  ProductLayer.gloves: LayerConfig(
    anchor: AnchorType.waist,
    anchorOffset: 0.15,
    widthRatio: 0.50,
    zIndex: 8,
  ),
};

enum SilhouetteType {
  female,
  male,
}

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
    final hasMale = widget.selectedProducts
        .any((p) => p.gender == ProductGender.male);
    if (hasMale) {
      return SilhouetteType.male;
    }
    return SilhouetteType.female;
  }

  // SilhouetteType silhouette = SilhouetteType.female;

  List<Product> get effectiveProducts {
    final hasDress = widget.selectedProducts
        .any((p) => p.layer == ProductLayer.dress);

    if (!hasDress) return widget.selectedProducts;

    return widget.selectedProducts.where((p) {
      return p.layer != ProductLayer.top &&
          p.layer != ProductLayer.bottom;
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
      if (mounted) {
        _fabController.forward();
      }
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

            /// Background
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.9,
                    center: const Alignment(0, -0.15),
                    colors: [
                      Colors.grey.shade900,
                      Colors.black,
                    ],
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

            /// Content
            Positioned.fill(
              top: 72,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: mode == PreviewMode.outfit
                    ? _OutfitMode(
                  products: effectiveProducts,
                  topOpacity: topOpacity,
                  silhouetteType: silhouetteType,
                  onOpacityChanged: (v) {
                    setState(() => topOpacity = v);
                  },
                )
                    : _EditorialMode(
                  products: effectiveProducts,
                  silhouetteType: silhouetteType,
                ),
              ),
            ),

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
                    builder: (_) => RunwayVideoPreviewScreen(
                      products: widget.selectedProducts,
                    ),
                  ),
                );

              },
              icon: Image.asset(
                "assets/images/floatingButton.png",
                width: 20,
                color: Colors.black,
              ),
              label: const Text(
                "Passerella",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}


////////////////////////////////////////////////////////////
/// OUTFIT MODE (SILHOUETTE)
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
    final outerwear =
        products.where((p) => p.layer == ProductLayer.outerwear).firstOrNull;
    final top =
        products.where((p) => p.layer == ProductLayer.top).firstOrNull;
    final bottom =
        products.where((p) => p.layer == ProductLayer.bottom).firstOrNull;
    final dress =
        products.where((p) => p.layer == ProductLayer.dress).firstOrNull;
    final hat =
        products.where((p) => p.layer == ProductLayer.hat).firstOrNull;
    final scarf =
        products.where((p) => p.layer == ProductLayer.scarf).firstOrNull;
    final gloves =
        products.where((p) => p.layer == ProductLayer.gloves).firstOrNull;

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
                      silhouetteType == SilhouetteType.male
                          ? 'assets/images/silhouette_uomo.png'
                          : 'assets/images/silhouette_donna.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  /// BOTTOM
                  if (!hasDress && bottom != null)
                    Positioned(
                      top: h * 0.39,
                      left: w * 0.22,
                      child: _HeroCloth(
                        tag: 'preview_${bottom.id}',
                        imageUrl: bottom.outfitImage,
                        width: w * 0.58,
                      ),
                    ),

                  /// DRESS
                  if (hasDress)
                    Positioned(
                      top: h * 0.13,
                      left: w * 0.28,
                      child: _HeroCloth(
                        tag: 'preview_${dress.id}',
                        imageUrl: dress.outfitImage,
                        width: w * 0.45,
                      ),
                    ),

                  /// OUTERWEAR
                  if (outerwear != null)
                    Positioned(
                      top: h * 0.13,
                      child: _HeroCloth(
                        tag: 'preview_${outerwear.id}',
                        imageUrl: outerwear.outfitImage,
                        width: w * 0.45,
                        highlight: top != null,
                      ),
                    ),

                  /// TOP
                  if (!hasDress && top != null)
                    Positioned(
                      top: h * 0.14,
                      child: Opacity(
                        opacity: outerwear != null ? topOpacity : 1.0,
                        child: _HeroCloth(
                          tag: 'preview_${top.id}',
                          imageUrl: top.outfitImage,
                          width: w * 0.42,
                          highlight: outerwear != null,
                        ),
                      ),
                    ),

                  if (outerwear != null && top != null)
                    Positioned(
                      right: 30,
                      top: h * 0.28,
                      bottom: h * 0.28,
                      child: Column(
                        children: [

                          /// LABEL
                          Text(
                            "Top",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 8),

                          /// SLIDER
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

                          /// VALORE (opzionale ma bello)
                          Text(
                            "${(topOpacity * 100).round()}%",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),

                  /// HAT
                  if (hat != null)
                    Positioned(
                      top: h * -0.055,
                      left: w * 0.27,
                      child: _HeroCloth(
                        tag: 'preview_${hat.id}',
                        imageUrl: hat.outfitImage,
                        width: w * 0.48,
                      ),
                    ),

                  /// SCARF
                  if (scarf != null)
                    Positioned(
                      top: h * 0.13,
                      child: _HeroCloth(
                        tag: 'preview_${scarf.id}',
                        imageUrl: scarf.outfitImage,
                        width: w * 0.46,
                      ),
                    ),

                  /// GLOVES
                  if (gloves != null)
                    Positioned(
                      top: h * 0.45,
                      right: w * 0.05,
                      child: _HeroCloth(
                        tag: 'preview_${gloves.id}',
                        imageUrl: gloves.outfitImage,
                        width: w * 0.55,
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
/// EDITORIAL MODE (SIDE COMPOSITION)
////////////////////////////////////////////////////////////

class _EditorialMode extends StatelessWidget {
  final List<Product> products;
  final SilhouetteType silhouetteType;

  const _EditorialMode({
    required this.products,
    required this.silhouetteType,
  });

  @override
  Widget build(BuildContext context) {
    final outerwear =
        products.where((p) => p.layer == ProductLayer.outerwear).firstOrNull;
    final top =
        products.where((p) => p.layer == ProductLayer.top).firstOrNull;
    final bottom =
        products.where((p) => p.layer == ProductLayer.bottom).firstOrNull;
    final dress =
        products.where((p) => p.layer == ProductLayer.dress).firstOrNull;
    final hat =
        products.where((p) => p.layer == ProductLayer.hat).firstOrNull;
    final scarf =
        products.where((p) => p.layer == ProductLayer.scarf).firstOrNull;
    final gloves =
        products.where((p) => p.layer == ProductLayer.gloves).firstOrNull;

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
            clipBehavior: Clip.none,
            children: [
        
              Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: 0.96,
                  alignment: Alignment.bottomCenter,
                  child: Image.asset(
                    silhouetteType == SilhouetteType.male
                        ? 'assets/images/silhouette_uomo.png'
                        : 'assets/images/silhouette_donna.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
        
              if (outerwear != null)
                Positioned(
                  top: h * 0.18,
                  left: w * 0.05,
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 3,
                    child: _HeroCloth(
                      tag: 'preview_${outerwear.id}',
                      imageUrl: outerwear.outfitImage,
                      width: w * 0.45,
                      shadow: false,
                    ),
                  ),
                ),
        

        
              if (bottom != null)
                Positioned(
                  top: h * 0.39,
                  right: w * 0.00,
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 3,
                    child: _HeroCloth(
                      tag: 'preview_${bottom.id}',
                      imageUrl: bottom.outfitImage,
                      width: w * 0.58,
                      shadow: false,
                    ),
                  ),
                ),

              if (top != null)
                Positioned(
                  top: h * 0.18,
                  right: w * 0.05,
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 3,
                    child: _HeroCloth(
                      tag: 'preview_${top.id}',
                      imageUrl: top.outfitImage,
                      width: w * 0.42,
                      shadow: false,
                    ),
                  ),
                ),

              if (dress != null)
                Positioned(
                  top: h * 0.17,
                  right: w * 0.05,
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 3,
                    child: _HeroCloth(
                      tag: 'preview_${dress.id}',
                      imageUrl: dress.outfitImage,
                      width: w * 0.45,
                      shadow: false,
                    ),
                  ),
                ),

              if (hat != null)
                Positioned(
                  top: h * -0.02,
                  left: w * 0.10,
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 3,
                    child: _HeroCloth(
                      tag: 'preview_${hat.id}',
                      imageUrl: hat.outfitImage,
                      width: w * 0.48,
                      shadow: false,
                    ),
                  ),
                ),
        
              if (scarf != null)
                Positioned(
                  top: h * 0.15,
                  right: w * 0.08,
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 3,
                    child: _HeroCloth(
                      tag: 'preview_${scarf.id}',
                      imageUrl: scarf.outfitImage,
                      width: w * 0.46,
                      shadow: false,
                    ),
                  ),
                ),
        
              if (gloves != null)
                Positioned(
                  top: h * 0.45,
                  right: w * 0.01,
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 3,
                    child: _HeroCloth(
                      tag: 'preview_${gloves.id}',
                      imageUrl: gloves.outfitImage,
                      width: w * 0.55,
                      shadow: false,
                    ),
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
/// SILHOUETTE
////////////////////////////////////////////////////////////

class _SoftSilhouette extends StatelessWidget {
  const _SoftSilhouette({super.key});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.96,
      alignment: Alignment.bottomCenter,
      child: Opacity(
        opacity: 0.7,
        child: Image.asset(
          silhouetteAsset(SilhouetteType.female),
          fit: BoxFit.contain,
          color: Colors.grey.shade50,
          colorBlendMode: BlendMode.modulate,
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// HERO IMAGE
////////////////////////////////////////////////////////////

class _HeroCloth extends StatelessWidget {
  final String tag;
  final String imageUrl;
  final double width;
  final bool highlight;
  final bool shadow;

  const _HeroCloth({
    required this.tag,
    required this.imageUrl,
    required this.width,
    this.highlight = false,
    this.shadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final image = ProductImage(
      image: imageUrl,
      fit: BoxFit.contain,
    );

    return Hero(
      tag: tag,
      child: SizedBox(
        width: width,
        child: Stack(
          alignment: Alignment.center,
          children: [

            /// GLOW dietro il capo
            if (highlight)
              Container(
                width: width * 0.9,
                height: width * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

            /// OMBRA morbida corpo
            if (shadow)
              Positioned(
                bottom: -10,
                child: Container(
                  width: width * 0.7,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: -10,
                      )
                    ],
                  ),
                ),
              ),

            /// IMMAGINE CAPO
            image,
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// FLOAT ANIMATION
////////////////////////////////////////////////////////////
class _FloatingLayer extends StatelessWidget {
  final Widget child;
  final int delayMs;

  const _FloatingLayer({
    required this.child,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 18, end: 0),
      duration: Duration(milliseconds: 380 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (_, v, c) {
        return Opacity(
          opacity: (1 - (v / 18)).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, v),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}

////////////////////////////////////////////////////////////
/// FOOTER
////////////////////////////////////////////////////////////

class _FooterRecap extends StatelessWidget {
  final List<Product> products;

  const _FooterRecap({
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final codes = products.map((e) => e.code).join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Text(
        codes.isEmpty
            ? "Seleziona i capi per vedere l’outfit"
            : codes,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
////////////////////////////////////////////////////////////
/// UI ELEMENTS (unchanged)
////////////////////////////////////////////////////////////

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  final PreviewMode mode;
  final ValueChanged<PreviewMode> onChanged;

  const _ModeSwitch({
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModePill(
            label: "Outfit",
            selected: mode == PreviewMode.outfit,
            onTap: () => onChanged(PreviewMode.outfit),
          ),
          _ModePill(
            label: "Editorial",
            selected: mode == PreviewMode.editorial,
            onTap: () => onChanged(PreviewMode.editorial),
          ),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color:
              selected ? Colors.black : Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}