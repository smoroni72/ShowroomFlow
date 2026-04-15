import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'category_provider.dart';
import 'package:fashion_app/features/products/screens/product_list_screen.dart';

class CategoryScreen extends ConsumerWidget {
  final String brandId;
  final String brandName;

  const CategoryScreen({
    super.key,
    required this.brandId,
    required this.brandName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider(brandId));

    return Scaffold(
      appBar: AppBar(
        title: Text(brandName),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          return ListTile(
            title: Text(category.name),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductListScreen(
                    brandId: brandId,
                    categoryId: category.id,
                    categoryName: category.name,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}