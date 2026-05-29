import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/runway_provider.dart';
import '../models/runway_model.dart';
import '../../../core/widgets/product_image.dart';
import 'look_products_screen.dart';
import '../../../core/design_system/theme_provider.dart';

class RunwayScreen extends ConsumerStatefulWidget {

  final String brandId;

  const RunwayScreen({
    super.key,
    required this.brandId,
  });

  @override
  ConsumerState<RunwayScreen> createState() => _RunwayScreenState();
}

class _RunwayScreenState extends ConsumerState<RunwayScreen> {

  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final runwayAsync = ref.watch(runwayProvider(widget.brandId));

    return Scaffold(
      backgroundColor: theme.background,
      body: runwayAsync.when(

        loading: () =>
            Center(
              child: CircularProgressIndicator(
                color: theme.textPrimary,
              ),
            ),

        error: (e, _) =>
            Center(
              child: Text(
                "Errore: $e",
                style: TextStyle(color: theme.textSecondary),
              ),
            ),

        data: (looks) {
          if (looks.isEmpty) {
            return const Center(
              child: Text("Runway non disponibile"),
            );
          }

          return PageView.builder(
            controller: _controller,
            scrollDirection: Axis.vertical,
            itemCount: looks.length,
            onPageChanged: (index) {
              // Precache next look image
              if (index + 1 < looks.length) {
                precacheImage(NetworkImage(looks[index+1].image), context);
              }
            },
            itemBuilder: (_, index) {
              final look = looks[index];

              return AnimatedBuilder(
                animation: _controller,
                builder: (_, child) {
                  double value = 0;
                  if (_controller.position.haveDimensions) {
                    value = index - (_controller.page ?? 0);
                    value = (value * 0.15).clamp(-1, 1);
                  }

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      /// IMAGE - Using size medium for better performance
                      Transform.translate(
                        offset: Offset(0, value * 60),
                        child: ProductImage(
                          image: look.image,
                          fit: BoxFit.cover,
                          size: ImageSize.medium,
                        ),
                      ),

                      /// GRADIENT
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.center,
                            colors: [
                              theme.overlayDark.withOpacity(0.75),
                              theme.overlayDark.withOpacity(0.25),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.35, 0.7],
                          ),
                        ),
                      ),

                      /// TITLE FADE IN
                      Positioned(
                        bottom: 140,
                        left: 24,
                        right: 24,
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 700),
                          tween: Tween(begin: 20, end: 0),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, value),
                              child: Opacity(
                                opacity: (1 - (value / 20)).clamp(0, 1),
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            look.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              height: 1.1,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.6,
                            ),
                          ),
                        ),
                      ),

                      /// BUTTON SLIDE UP
                      Positioned(
                        bottom: 60,
                        left: 24,
                        right: 24,
                        child: TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 600),
                          tween: Tween(begin: 60.0, end: 0.0),
                          builder: (_, value, child) {

                            return Transform.translate(
                              offset: Offset(0, value),
                              child: child,
                            );

                          },

                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LookProductsScreen(
                                    brandId: widget.brandId,
                                    productIds: look.products,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.92),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Center(
                                child: Text(
                                  "Scopri i capi",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white.withOpacity(0.6),
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}