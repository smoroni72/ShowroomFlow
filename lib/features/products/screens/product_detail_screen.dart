import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/product_image.dart';
import '../../auth/login_screen.dart';
import '../../visits/screens/visit_request_screen.dart';
import '../models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {

  Variant? selectedVariant;

  List<String> get availableColors {
    return widget.product.variants
        .map((v) => v.color)
        .toSet()
        .toList();
  }

  List<String> get availableSizes {
    return widget.product.variants
        .where((v) =>
    selectedVariant == null || v.color == selectedVariant!.color)
        .map((v) => v.size)
        .toSet()
        .toList();
  }

  void selectColor(String color) {
    final variant =
    widget.product.variants.firstWhere((v) => v.color == color);
    setState(() {
      selectedVariant = variant;
    });
  }

  void selectSize(String size) {
    final variant = widget.product.variants.firstWhere(
          (v) =>
      v.size == size &&
          (selectedVariant == null || v.color == selectedVariant!.color),
    );

    setState(() {
      selectedVariant = variant;
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final user = FirebaseAuth.instance.currentUser;
    final isLogged = user != null && user.emailVerified;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [

              /// RICHIEDI VISITA
              Expanded(
                child: OutlinedButton(
                  onPressed: () async  {

                    /// SE NON LOGGATO → LOGIN
                    if (!isLogged) {

                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      );

                      if (result == true) {
                        setState(() {});
                      }

                      return;
                    }

                    /// SE LOGGATO → RICHIESTA VISITA
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VisitRequestScreen(
                          brandId: product.brandId,
                        ),
                      ),
                    );

                  },
                  child: Text(
                    isLogged
                        ? "Richiedi visita"
                        : "Accedi per la visita",
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// RIASSORTISCI
              Expanded(
                child: FilledButton(
                  onPressed: isLogged
                      ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Riassortimento richiesto"),
                      ),
                    );
                  }
                      : null, // DISABILITATO
                  child: const Text("Riassortisci"),
                ),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// IMMAGINI PRODOTTO
            SizedBox(
              height: 420,
              child: PageView.builder(
                itemCount: product.images.length,
                itemBuilder: (_, index) {
                  final img = product.images[index];

                  return Hero(
                    tag: "product_${product.id}",
                    child: ProductImage(
                      image: img,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            /// NOME + CODICE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    product.code,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// PREZZO

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: user == null
                  ? Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Accedi per visualizzare i prezzi",
                  style: TextStyle(fontSize: 14),
                ),
              )
                  : !user.emailVerified
                  ? Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Verifica la tua email per vedere i prezzi",
                  style: TextStyle(fontSize: 14),
                ),
              )
                  : Text(
                "€ ${product.price.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// COLORI
            if (product.variants.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Colori",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: availableColors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, index) {
                    final color = availableColors[index];
                    final isSelected =
                        selectedVariant?.color == color;

                    return GestureDetector(
                      onTap: () => selectColor(color),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Text(color),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],

            /// TAGLIE
            if (product.variants.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Taglie",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: availableSizes.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, index) {
                    final size = availableSizes[index];
                    final isSelected =
                        selectedVariant?.size == size;

                    return GestureDetector(
                      onTap: () => selectSize(size),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                            width: 2,
                          ),
                        ),
                        child: Text(size),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],

            /// COMPOSIZIONE (mock ora)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    "Composizione",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "75% lana merinos extrafine\n25% seta",
                    style: TextStyle(height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}