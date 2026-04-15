import 'package:flutter/material.dart';
import '../../products/models/product_model.dart';
import '../../products/screens/product_detail_screen.dart';
import '../../../core/widgets/product_image.dart';

class LookPhotoPreviewScreen extends StatelessWidget {

  final Product product;

  const LookPhotoPreviewScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: GestureDetector(

        onTap: () {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(
                product: product,
              ),
            ),
          );

        },

        child: Center(

          child: Hero(
            tag: "product_${product.id}",
            child: ProductImage(
              image: product.displayImage,
              fit: BoxFit.contain,
            ),
          ),

        ),
      ),
    );
  }
}