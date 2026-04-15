import 'package:flutter/material.dart';
import '../models/product_model.dart';

class Info extends StatelessWidget {
  final Product product;
  final bool isLogged;

  const Info({
    super.key,
    required this.product,
    required this.isLogged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            product.code,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            isLogged
                ? (product.price != null ? "€ ${product.price}" : "-")
                : "Accedi per vedere i prezzi",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}