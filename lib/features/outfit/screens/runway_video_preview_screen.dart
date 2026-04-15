import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../products/models/product_model.dart';
import '../../../../core/widgets/product_image.dart';

class RunwayVideoPreviewScreen extends StatefulWidget {
  final List<Product> products;

  const RunwayVideoPreviewScreen({
    super.key,
    required this.products,
  });

  @override
  State<RunwayVideoPreviewScreen> createState() =>
      _RunwayVideoPreviewScreenState();
}

class _RunwayVideoPreviewScreenState extends State<RunwayVideoPreviewScreen> {
  VideoPlayerController? controller;

  Product? top;
  Product? bottom;
  Product? outer;
  Product? dress;
  Product? hat;
  Product? scarf;
  Product? gloves;

  List<int> delays = [];

  double flashOpacity = 0;
  double videoScale = 1;

  final glitchPoints = [
    5000,
    6500,
    8000,
    9500,
    11000,
    12500,
  ];

  static const int walkCycleMs = 1500;

  bool get hasDress => dress != null;

  @override
  void initState() {
    super.initState();

    for (var p in widget.products) {
      if (p.layer == ProductLayer.top) top = p;
      if (p.layer == ProductLayer.bottom) bottom = p;
      if (p.layer == ProductLayer.outerwear) outer = p;
      if (p.layer == ProductLayer.dress) dress = p;
      if (p.layer == ProductLayer.hat) hat = p;
      if (p.layer == ProductLayer.scarf) scarf = p;
      if (p.layer == ProductLayer.gloves) gloves = p;
    }

    final visibleItems = [
      if (!hasDress && bottom != null) bottom,
      if (hasDress && dress != null) dress,
      if (outer != null) outer,
      if (!hasDress && top != null) top,
      if (hat != null) hat,
      if (scarf != null) scarf,
      if (gloves != null) gloves,
    ].whereType<Product>().toList();

    delays = List.generate(
      visibleItems.length,
          (i) => 250 + (i * 240),
    )..shuffle();

    controller = VideoPlayerController.asset(
      "assets/runway/new_silhouette_walk_donna.mp4",
    )
      ..setLooping(false)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        controller!.play();
      });

    controller!.addListener(_videoListener);
  }

  @override
  void dispose() {
    controller?.removeListener(_videoListener);
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// VIDEO
          Positioned.fill(
            child: Center(
              child: AspectRatio(
                aspectRatio: controller!.value.aspectRatio,
                child: Stack(
                  children: [
                    AnimatedScale(
                      scale: videoScale,
                      duration: const Duration(milliseconds: 120),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: flashOpacity * 4,
                          sigmaY: flashOpacity * 4,
                        ),
                        child: VideoPlayer(controller!),
                      ),
                    ),

                    /// flash solo nell'area video
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 80),
                      opacity: flashOpacity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            radius: 0.7,
                            colors: [
                              Colors.white.withOpacity(0.35),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// CAPI SOPRA IL VIDEO
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                int i = 0;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    /// BOTTOM
                    if (!hasDress && bottom != null)
                      RunwayLayerItem(
                        controller: controller!,
                        delay: delays[i++],
                        cycleMs: walkCycleMs,
                        profile: MotionProfiles.bottom,
                        baseTop: h * 0.42,
                        baseLeft: w * 0.17,
                        width: w * 0.68,
                        imageUrl: bottom!.outfitImage,
                      ),

                    /// DRESS
                    if (hasDress && dress != null)
                      RunwayLayerItem(
                        controller: controller!,
                        delay: delays[i++],
                        cycleMs: walkCycleMs,
                        profile: MotionProfiles.dress,
                        baseTop: h * 0.235,
                        baseLeft: w * 0.22,
                        width: w * 0.55,
                        imageUrl: dress!.outfitImage,
                      ),

                    /// OUTERWEAR
                    if (outer != null)
                      RunwayLayerItem(
                        controller: controller!,
                        delay: delays[i++],
                        cycleMs: walkCycleMs,
                        profile: MotionProfiles.outerwear,
                        baseTop: h * 0.23,
                        baseLeft: (w - (w * 0.53)) / 2,
                        width: w * 0.53,
                        imageUrl: outer!.outfitImage,
                        highlight: top != null,
                      ),

                    /// TOP
                    if (!hasDress && top != null)
                      RunwayLayerItem(
                        controller: controller!,
                        delay: delays[i++],
                        cycleMs: walkCycleMs,
                        profile: MotionProfiles.top,
                        baseTop: h * 0.24,
                        baseLeft: (w - (w * 0.53)) / 2,
                        width: w * 0.53,
                        imageUrl: top!.outfitImage,
                      ),

                    /// HAT
                    if (hat != null)
                      RunwayLayerItem(
                        controller: controller!,
                        delay: delays[i++],
                        cycleMs: walkCycleMs,
                        profile: MotionProfiles.hat,
                        baseTop: h * 0.095,
                        baseLeft: w * 0.225,
                        width: w * 0.55,
                        imageUrl: hat!.outfitImage,
                      ),

                    /// SCARF
                    if (scarf != null)
                      RunwayLayerItem(
                        controller: controller!,
                        delay: delays[i++],
                        cycleMs: walkCycleMs,
                        profile: MotionProfiles.scarf,
                        baseTop: h * 0.24,
                        baseLeft: (w - (w * 0.55)) / 2,
                        width: w * 0.55,
                        imageUrl: scarf!.outfitImage,
                      ),

                    /// GLOVES
                    if (gloves != null)
                      RunwayLayerItem(
                        controller: controller!,
                        delay: delays[i++],
                        cycleMs: walkCycleMs,
                        profile: MotionProfiles.gloves,
                        baseTop: h * 0.47,
                        baseLeft: w - (w * 0.03) - (w * 0.58),
                        width: w * 0.58,
                        imageUrl: gloves!.outfitImage,
                      ),
                  ],
                );
              },
            ),
          ),

          /// CLOSE
          Positioned(
            top: 60,
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

  bool _videoEnded = false;

  void _videoListener() {
    if (controller == null || !controller!.value.isInitialized) return;

    final position = controller!.value.position.inMilliseconds;

    /// =========================
    /// 🔥 GLITCH (lasciamo tutto com'è)
    /// =========================

    bool isGlitch = false;

    for (final g in glitchPoints) {
      if ((position - g).abs() < 80) {
        isGlitch = true;
        break;
      }
    }

    if (isGlitch) {
      if (flashOpacity != 0.25 || videoScale != 1.015) {
        setState(() {
          flashOpacity = 0.25;
          videoScale = 1.015;
        });
      }
    } else {
      if (flashOpacity != 0 || videoScale != 1) {
        setState(() {
          flashOpacity = 0;
          videoScale = 1;
        });
      }
    }

    /// =========================
    /// 🔥 FINE VIDEO (NUOVO)
    /// =========================

    final isFinished =
        controller!.value.position >= controller!.value.duration &&
            !controller!.value.isPlaying;

    if (isFinished && !_videoEnded) {
      _videoEnded = true;

      if (!mounted) return;

      Navigator.pop(context);
    }
  }
}

////////////////////////////////////////////////////////////
/// PROFILI MOVIMENTO
////////////////////////////////////////////////////////////

class MotionProfile {
  final double bodyX;
  final double bodyY;
  final double lagX;
  final double lagY;
  final double breezeX;
  final double breezeY;
  final double rotation;
  final double scale;
  final double highlight;
  final double shadow;
  final double lagPhase;
  final double breezePhase;
  final Alignment rotationAlignment;

  const MotionProfile({
    required this.bodyX,
    required this.bodyY,
    required this.lagX,
    required this.lagY,
    required this.breezeX,
    required this.breezeY,
    required this.rotation,
    required this.scale,
    required this.highlight,
    required this.shadow,
    required this.lagPhase,
    required this.breezePhase,
    this.rotationAlignment = Alignment.topCenter,
  });
}

class MotionProfiles {
  static const top = MotionProfile(
    bodyX: 1.2,
    bodyY: 2.8,
    lagX: 0.8,
    lagY: 1.4,
    breezeX: 0.5,
    breezeY: 0.7,
    rotation: 0.010,
    scale: 0.004,
    highlight: 0.10,
    shadow: 0.10,
    lagPhase: -0.55,
    breezePhase: 0.35,
  );

  static const outerwear = MotionProfile(
    bodyX: 1.6,
    bodyY: 3.4,
    lagX: 1.5,
    lagY: 2.2,
    breezeX: 0.9,
    breezeY: 1.0,
    rotation: 0.016,
    scale: 0.006,
    highlight: 0.13,
    shadow: 0.14,
    lagPhase: -0.75,
    breezePhase: 0.50,
  );

  static const bottom = MotionProfile(
    bodyX: 0.8,
    bodyY: 3.6,
    lagX: 0.5,
    lagY: 1.1,
    breezeX: 0.2,
    breezeY: 0.4,
    rotation: 0.004,
    scale: 0.003,
    highlight: 0.06,
    shadow: 0.12,
    lagPhase: -0.35,
    breezePhase: 0.20,
    rotationAlignment: Alignment.topCenter,
  );

  static const dress = MotionProfile(
    bodyX: 1.0,
    bodyY: 3.2,
    lagX: 1.1,
    lagY: 2.0,
    breezeX: 0.7,
    breezeY: 0.9,
    rotation: 0.012,
    scale: 0.005,
    highlight: 0.11,
    shadow: 0.12,
    lagPhase: -0.65,
    breezePhase: 0.45,
  );

  static const scarf = MotionProfile(
    bodyX: 1.3,
    bodyY: 2.6,
    lagX: 1.9,
    lagY: 2.4,
    breezeX: 1.2,
    breezeY: 1.5,
    rotation: 0.018,
    scale: 0.004,
    highlight: 0.14,
    shadow: 0.08,
    lagPhase: -0.90,
    breezePhase: 0.70,
  );

  static const hat = MotionProfile(
    bodyX: 0.5,
    bodyY: 1.0,
    lagX: 0.3,
    lagY: 0.4,
    breezeX: 0.2,
    breezeY: 0.2,
    rotation: 0.005,
    scale: 0.002,
    highlight: 0.07,
    shadow: 0.05,
    lagPhase: -0.20,
    breezePhase: 0.15,
    rotationAlignment: Alignment.center,
  );

  static const gloves = MotionProfile(
    bodyX: 0.9,
    bodyY: 1.8,
    lagX: 0.7,
    lagY: 0.9,
    breezeX: 0.3,
    breezeY: 0.4,
    rotation: 0.008,
    scale: 0.003,
    highlight: 0.08,
    shadow: 0.09,
    lagPhase: -0.40,
    breezePhase: 0.25,
  );
}

////////////////////////////////////////////////////////////
/// WIDGET COMUNE CAPI
////////////////////////////////////////////////////////////

class RunwayLayerItem extends StatefulWidget {
  final VideoPlayerController controller;
  final int delay;
  final int cycleMs;
  final MotionProfile profile;
  final double baseTop;
  final double baseLeft;
  final double width;
  final String imageUrl;
  final bool highlight;

  const RunwayLayerItem({
    super.key,
    required this.controller,
    required this.delay,
    required this.cycleMs,
    required this.profile,
    required this.baseTop,
    required this.baseLeft,
    required this.width,
    required this.imageUrl,
    this.highlight = false,
  });

  @override
  State<RunwayLayerItem> createState() => _RunwayLayerItemState();
}

class _RunwayLayerItemState extends State<RunwayLayerItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController entryController;
  late final Animation<double> entryOpacity;
  late final Animation<double> entryScale;
  late final Animation<Offset> entrySlide;
  late final Animation<double> settleScale;

  @override
  void initState() {
    super.initState();

    entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    final r = Random().nextInt(6);

    Offset begin;
    switch (r) {
      case 0:
        begin = const Offset(0, -1.6);
        break;
      case 1:
        begin = const Offset(1.7, 0);
        break;
      case 2:
        begin = const Offset(-1.7, 0);
        break;
      case 3:
        begin = const Offset(1.2, -1.0);
        break;
      case 4:
        begin = const Offset(-1.2, -1.0);
        break;
      default:
        begin = const Offset(0, 1.3);
    }

    entryOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: const Interval(0.0, 0.45))),
        weight: 45,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 55,
      ),
    ]).animate(entryController);

    entrySlide = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: begin, end: begin * 0.18)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween(begin: begin * 0.18, end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 35,
      ),
    ]).animate(entryController);

    entryScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.85, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(entryController);

    settleScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 75,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.992)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.992, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 13,
      ),
    ]).animate(entryController);

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) entryController.forward();
    });
  }

  @override
  void dispose() {
    entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: entryController,
      builder: (_, __) {

        return AnimatedBuilder(
          animation: widget.controller,
          builder: (_, __) {
        if (!widget.controller.value.isInitialized) {
          return const SizedBox.shrink();
        }

        final ms = widget.controller.value.position.inMilliseconds;
        final phase = (ms % widget.cycleMs) / widget.cycleMs;
        final p = phase * 2 * pi;

        /// moto principale corpo
        final bodyX = sin(p) * widget.profile.bodyX;
        final bodyY = sin(p) * widget.profile.bodyY;

        /// ritardo elastico
        final lagX = sin(p + widget.profile.lagPhase) * widget.profile.lagX;
        final lagY = sin(p + widget.profile.lagPhase) * widget.profile.lagY;

        /// moto secondario tessuto
        final breezeX =
            sin((p * 0.55) + widget.profile.breezePhase) * widget.profile.breezeX;
        final breezeY =
            cos((p * 0.55) + widget.profile.breezePhase) * widget.profile.breezeY;

        /// posizione finale agganciata al corpo
        final targetTop = widget.baseTop + bodyY + lagY + breezeY;
        final targetLeft = widget.baseLeft + bodyX + lagX + breezeX;

        /// smoothing durante ingresso
        final entryProgress = entryController.value;

        /// curva morbida finale (solo ultimi 30%)
        final smooth = Curves.easeOut.transform(
          entryProgress.clamp(0.5, 1.0),
        );

        final finalTop = widget.baseTop + (targetTop - widget.baseTop) * smooth;
        final finalLeft = widget.baseLeft + (targetLeft - widget.baseLeft) * smooth;

        /// rotazione e scala reattive
        final angle = (sin(p + widget.profile.lagPhase) * widget.profile.rotation) +
            (sin((p * 0.55) + widget.profile.breezePhase) *
                widget.profile.rotation *
                0.55);

        final liveScale = 1 + (sin(p) * widget.profile.scale);

        /// luce e ombra reattive al passo
        final lightPulse = ((sin(p - pi / 6) + 1) / 2) * widget.profile.highlight;
        final shadowPulse = ((cos(p) + 1) / 2) * widget.profile.shadow;

        return Positioned(
          top: finalTop,
          left: finalLeft,
          child: Opacity(
            opacity: entryOpacity.value,
            child: Transform.translate(
              offset: entrySlide.value * 110,
              child: Transform.scale(
                scale: entryScale.value * settleScale.value * liveScale,
                child: Transform.rotate(
                  angle: angle,
                  alignment: widget.profile.rotationAlignment,
                  child: Transform.translate(
                    offset: Offset(0, -shadowPulse * 2),
                    child: SizedBox(
                      width: widget.width,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          /// glow dinamico
                          if (widget.highlight || lightPulse > 0.01)
                            Container(
                              width: widget.width * 0.92,
                              height: widget.width * 0.92,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.white.withOpacity(
                                      widget.highlight
                                          ? (0.08 + lightPulse)
                                          : lightPulse,
                                    ),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                          /// ombra dinamica
                          Positioned(
                            bottom: -10,
                            child: Container(
                              width: widget.width * (0.68 + shadowPulse * 0.25),
                              height: 26 + shadowPulse * 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      0.18 + shadowPulse * 0.45,
                                    ),
                                    blurRadius: 24 + shadowPulse * 18,
                                    spreadRadius: -10,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // luce frontale molto leggera sul capo
                          // ShaderMask(
                          //   shaderCallback: (Rect bounds) {
                          //     return LinearGradient(
                          //       begin: Alignment.topCenter,
                          //       end: Alignment.bottomCenter,
                          //       colors: [
                          //         Colors.white.withOpacity(0.10 + lightPulse * 0.55),
                          //         Colors.white.withOpacity(0.02),
                          //       ],
                          //     ).createShader(bounds);
                          //   },
                          //   blendMode: BlendMode.softLight,
                          //   child: ProductImage(
                          //     image: widget.imageUrl,
                          //     fit: BoxFit.contain,
                          //   ),
                          // ),
                          Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [

                              /// GLOW DIETRO (simula luce sul capo)
                              if (widget.highlight || lightPulse > 0.01)
                                Container(
                                  width: widget.width * 0.85,
                                  height: widget.width * 0.85,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white.withOpacity(
                                          widget.highlight
                                              ? (0.08 + lightPulse)
                                              : lightPulse,
                                        ),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),

                              /// OMBRA DINAMICA
                              Positioned(
                                bottom: -10,
                                child: Container(
                                  width: widget.width * (0.68 + shadowPulse * 0.25),
                                  height: 26 + shadowPulse * 10,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(
                                          0.25 + shadowPulse * 0.4,
                                        ),
                                        blurRadius: 30 + shadowPulse * 20,
                                        spreadRadius: -12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              /// IMMAGINE CAPO (PULITA)
                              ProductImage(
                                image: widget.imageUrl,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                          /// immagine piena
                          ProductImage(
                            image: widget.imageUrl,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  },
  );
  }
}