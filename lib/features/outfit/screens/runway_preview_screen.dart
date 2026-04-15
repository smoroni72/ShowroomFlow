import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../products/models/product_model.dart';
import '../../../../core/widgets/product_image.dart';
import '../outfit_preview_screen.dart';

class RunwayPreviewScreen extends StatefulWidget {

  final List<Product> products;

  const RunwayPreviewScreen({
    super.key,
    required this.products,
  });

  @override
  State<RunwayPreviewScreen> createState() => _RunwayPreviewScreenState();
}

class _RunwayPreviewScreenState extends State<RunwayPreviewScreen>
    with TickerProviderStateMixin {

  double walkPosition = -220;
  double sway = 0;
  double cameraZoom = 0.9;

  late AnimationController swayController;

  @override
  void initState() {
    super.initState();

    swayController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    startWalk();
  }

  @override
  void dispose() {
    swayController.dispose();
    super.dispose();
  }

  String silhouetteAsset(SilhouetteType type) {
    switch (type) {
      case SilhouetteType.male:
        return 'assets/images/silhouette_uomo.png';
      case SilhouetteType.female:
        return 'assets/images/silhouette_donna.png';
    }
  }

  void startWalk() {

    Future.delayed(const Duration(milliseconds: 300), () {

      if (!mounted) return;

      setState(() {
        walkPosition = 120;
        cameraZoom = 1.05;
      });

      /// pausa davanti
      Future.delayed(const Duration(seconds: 4), () {

        if (!mounted) return;

        setState(() {
          cameraZoom = 1.12;
        });

        /// ritorno
        Future.delayed(const Duration(seconds: 2), () {

          if (!mounted) return;

          setState(() {
            walkPosition = -220;
            cameraZoom = 0.9;
          });

          startWalk();

        });

      });

    });
  }

  @override
  Widget build(BuildContext context) {

    Product? top;
    Product? bottom;
    Product? outer;

    for (var p in widget.products) {

      if (p.layer == ProductLayer.top) top = p;
      if (p.layer == ProductLayer.bottom) bottom = p;
      if (p.layer == ProductLayer.outerwear) outer = p;

    }

    return Scaffold(

      backgroundColor: Colors.black,

      body: Stack(

        children: [

          /// BACKGROUND RUNWAY

          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0d0d0d),
                    Color(0xFF000000),
                  ],
                ),
              ),
            ),
          ),

          /// PASSERELLA RIFLESSO

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 220,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          /// SPOTLIGHT

          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.9,
                    colors: [
                      Colors.white.withOpacity(0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// MODEL WALK

          AnimatedPositioned(

            duration: const Duration(seconds: 4),
            curve: Curves.easeInOut,

            bottom: walkPosition,
            left: 0,
            right: 0,

            child: Center(

              child: AnimatedScale(
                duration: const Duration(seconds: 4),
                scale: cameraZoom,

                child: AnimatedBuilder(

                  animation: swayController,

                  builder: (context, child) {

                    final sway = sin(swayController.value * pi * 2) * 8;

                    return Transform.translate(
                      offset: Offset(sway, 0),
                      child: child,
                    );
                  },

                  child: SizedBox(

                    width: 240,

                    child: Stack(

                      alignment: Alignment.center,

                      children: [

                        /// SILHOUETTE

                        Image.asset(
                          silhouetteAsset(SilhouetteType.female),
                          width: 180,
                        ),

                        /// BOTTOM

                        if (bottom != null)
                          ProductImage(
                            image: bottom.outfitImage,
                            fit: BoxFit.contain,
                          ),

                        /// TOP

                        if (top != null)
                          ProductImage(
                            image: top.outfitImage,
                            fit: BoxFit.contain,
                          ),

                        /// OUTERWEAR

                        if (outer != null)
                          ProductImage(
                            image: outer.outfitImage,
                            fit: BoxFit.contain,
                          ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// CLOSE BUTTON

          Positioned(
            top: 50,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

        ],
      ),
    );
  }
}