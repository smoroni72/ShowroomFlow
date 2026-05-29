import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.1),
      highlightColor: Colors.grey.withOpacity(0.2),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class BrandHomeSkeleton extends StatelessWidget {
  const BrandHomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Skeleton
          const ShimmerLoader(
            width: double.infinity,
            height: 560,
            borderRadius: BorderRadius.zero,
          ),

          const SizedBox(height: 28),

          // Brand Story Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ShimmerLoader(
              width: double.infinity,
              height: 180,
              borderRadius: BorderRadius.circular(24),
            ),
          ),

          const SizedBox(height: 32),

          // Section Header Skeleton
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLoader(width: 80, height: 12),
                SizedBox(height: 12),
                ShimmerLoader(width: 200, height: 28),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Categories Grid Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ShimmerLoader(
                  width: double.infinity,
                  height: 320,
                  borderRadius: BorderRadius.circular(26),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ShimmerLoader(
                        width: double.infinity,
                        height: 220,
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ShimmerLoader(
                        width: double.infinity,
                        height: 220,
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class ProductDetailSkeleton extends StatelessWidget {
  const ProductDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerLoader(
            width: double.infinity,
            height: 600,
            borderRadius: BorderRadius.zero,
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoader(width: 120, height: 14),
                const SizedBox(height: 12),
                const ShimmerLoader(width: 240, height: 32),
                const SizedBox(height: 16),
                const ShimmerLoader(width: 80, height: 24),
                const SizedBox(height: 32),
                const ShimmerLoader(width: double.infinity, height: 100),
                const SizedBox(height: 32),
                Row(
                  children: List.generate(3, (i) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ShimmerLoader(width: double.infinity, height: 48, borderRadius: BorderRadius.circular(12)),
                    ),
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CatalogSkeleton extends StatelessWidget {
  const CatalogSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ShimmerLoader(
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 12),
            const ShimmerLoader(width: 80, height: 12),
            const SizedBox(height: 6),
            const ShimmerLoader(width: 120, height: 16),
          ],
        ),
      ),
    );
  }
}
