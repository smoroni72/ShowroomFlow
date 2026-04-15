import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/theme_provider.dart';
import '../../../core/widgets/product_image.dart';
import '../models/product_model.dart';
import '../screens/product_detail_screen.dart';

class FeaturedProductsCarousel extends ConsumerWidget {
  final String title;
  final List<Product> products;

  const FeaturedProductsCarousel({
    super.key,
    required this.title,
    required this.products,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    if (products.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// TITLE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 12),

        /// HORIZONTAL LIST
        SizedBox(
          height: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = products[index];

              return _ProductCard(
                product: product,
                theme: theme,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final dynamic theme;

  const _ProductCard({
    required this.product,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final image = product.displayImage;

    final user = FirebaseAuth.instance.currentUser;
    final isLogged = user != null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// IMAGE
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ProductImage(
                  image: image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// NAME
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 4),

            /// PRICE / LOGIN
            isLogged
                ? Text(
              "€ ${product.price.toStringAsFixed(2)}",
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 13,
              ),
            )
                : Text(
              "Accedi per vedere i prezzi",
              style: TextStyle(
                fontSize: 12,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}