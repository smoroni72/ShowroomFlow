import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/product_image.dart';
import '../../auth/login_screen.dart';
import '../../visits/screens/visit_request_screen.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../../../core/providers/user_role_provider.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final Product product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String? selectedFabric;
  String? selectedColor;
  String? selectedSize;

  int currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    final fabrics = widget.product.variants
        .map((v) => v.fabric)
        .where((f) => f.isNotEmpty)
        .toSet()
        .toList();
    if (fabrics.isNotEmpty) {
      selectedFabric = fabrics.first;
      final colors = widget.product.variants
          .where((v) => v.fabric == selectedFabric)
          .map((v) => v.color)
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();
      if (colors.isNotEmpty) {
        selectedColor = colors.first;
        final sizes = widget.product.variants
            .where((v) => v.fabric == selectedFabric && v.color == selectedColor)
            .map((v) => v.size)
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList();
        if (sizes.isNotEmpty) {
          selectedSize = sizes.first;
        }
      }
    }
  }

  List<String> get availableFabrics {
    return widget.product.variants
        .map((v) => v.fabric)
        .where((f) => f.isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> get availableColors {
    if (selectedFabric == null) return [];
    return widget.product.variants
        .where((v) => v.fabric == selectedFabric)
        .map((v) => v.color)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> get availableSizes {
    if (selectedFabric == null || selectedColor == null) return [];
    return widget.product.variants
        .where((v) => v.fabric == selectedFabric && v.color == selectedColor)
        .map((v) => v.size)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
  }

  void selectFabric(String fabric) {
    setState(() {
      selectedFabric = fabric;
      selectedColor = null;
      selectedSize = null;
    });
  }

  void selectColor(String color) {
    setState(() {
      selectedColor = color;
      selectedSize = null;
    });
  }

  void selectSize(String size) {
    setState(() {
      selectedSize = size;
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final user = FirebaseAuth.instance.currentUser;
    final isLogged = user != null;
    final isVerified = (user?.emailVerified ?? false) || (user != null && user.email == 'demo@showroomflow.com');

    // Listen to user role from Firestore
    final userRoleAsync = ref.watch(userRoleProvider);
    final String? role = userRoleAsync.when(
      data: (r) => r,
      loading: () => null,
      error: (_, __) => null,
    );

    final bool showPrice = role == 'agent' || role == 'admin' || isVerified;

    // Colleziono tutte le immagini disponibili: mainImage + lista immagini (evitando duplicati)
    final galleryImages = <String>[];
    if (product.mainImage != null && product.mainImage!.isNotEmpty) {
      galleryImages.add(product.mainImage!);
    }
    for (var img in product.images) {
      if (!galleryImages.contains(img)) {
        galleryImages.add(img);
      }
    }

    // Se per qualche motivo è tutto vuoto, usiamo una stringa vuota per mostrare il fallback
    if (galleryImages.isEmpty) galleryImages.add('');

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
            Column(
              children: [
                Container(
                  height: 500, // Aumentato per capi spalla e foto verticali
                  width: double.infinity,
                  color: Theme.of(context).colorScheme.surface,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        currentImageIndex = index;
                      });
                    },
                    itemCount: galleryImages.length,
                    itemBuilder: (_, index) {
                      final img = galleryImages[index];

                      return Hero(
                        tag: "product_${product.id}",
                        child: ProductImage(
                          image: img,
                          fit: BoxFit.contain, // Manteniamo contain per non tagliare il prodotto
                          size: ImageSize.large,
                          backgroundColor: Theme.of(context).colorScheme.surface,
                        ),
                      );
                    },
                  ),
                ),
                if (galleryImages.length > 1) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: galleryImages.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, index) {
                        final isSelected = currentImageIndex == index;
                        return GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                                width: 2,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ] : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ProductImage(
                                image: galleryImages[index],
                                fit: BoxFit.cover,
                                size: ImageSize.small,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
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
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    product.code,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// PREZZO

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: !isLogged
                  ? Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Accedi per visualizzare i prezzi",
                  style: TextStyle(fontSize: 14),
                ),
              )
                  : !showPrice
                  ? Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Verifica la tua email per vedere i prezzi",
                  style: TextStyle(fontSize: 14),
                ),
              )
                  : Text(
                "€ ${product.price.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// TESSUTI / COMPOSIZIONE
            if (availableFabrics.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  selectedFabric != null
                      ? "Tessuto: $selectedFabric${(widget.product.variants.firstWhere((v) => v.fabric == selectedFabric).fabricCode?.isNotEmpty ?? false) ? ' (${widget.product.variants.firstWhere((v) => v.fabric == selectedFabric).fabricCode})' : ''}"
                      : "Scegli Tessuto",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: availableFabrics.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, index) {
                    final fabric = availableFabrics[index];
                    final isSelected = selectedFabric == fabric;

                    return GestureDetector(
                      onTap: () => selectFabric(fabric),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                            width: 2,
                          ),
                          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : null,
                        ),
                        child: Center(child: Text(fabric, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],

            /// COLORI
            if (selectedFabric != null && availableColors.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  selectedColor != null
                      ? "Colore: $selectedColor${(widget.product.variants.firstWhere((v) => v.fabric == selectedFabric && v.color == selectedColor).colorCode?.isNotEmpty ?? false) ? ' (${widget.product.variants.firstWhere((v) => v.fabric == selectedFabric && v.color == selectedColor).colorCode})' : ''}"
                      : "Scegli Colore",
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
                    final isSelected = selectedColor == color;

                    return GestureDetector(
                      onTap: () => selectColor(color),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                            width: 2,
                          ),
                          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : null,
                        ),
                        child: Center(child: Text(color, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],

            /// TAGLIE
            if (selectedColor != null && availableSizes.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Scelta Taglia",
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
                    final isSelected = selectedSize == size;

                    return GestureDetector(
                      onTap: () => selectSize(size),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
                            width: 2,
                          ),
                          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.05) : null,
                        ),
                        child: Center(child: Text(size, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal))),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),
            ],

            /// COMPOSIZIONE GENERALE (Se presente nel prodotto)
            if (product.composition != null && product.composition!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ulteriori dettagli",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.composition!,
                      style: const TextStyle(height: 1.4),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 50),

            /// PRODOTTI CORRELATI (Cross Selling)
            _buildRelatedProducts(context),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedProducts(BuildContext context) {
    // Recuperiamo tutti i prodotti tramite il provider (usando productsProvider con la brandId)
    final productsState = ref.watch(productsProvider(widget.product.brandId));

    return productsState.when(
      data: (allProducts) {
        // Filtriamo per categoria uguale ma ID diverso
        final related = allProducts
            .where((p) => p.categoryId == widget.product.categoryId && p.id != widget.product.id)
            .toList();

        if (related.isEmpty) return const SizedBox.shrink();

        // Prendiamo al massimo 6 suggerimenti
        final suggestions = related.length > 6 ? related.sublist(0, 6) : related;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Ti potrebbe piacere anche",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 280, // Aumentato per gestire meglio lo spazio verticale
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (_, index) {
                  final item = suggestions[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(product: item),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 160,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 3 / 4, // Aspect ratio standard per la moda
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: ProductImage(
                                  image: item.displayImage,
                                  fit: BoxFit.contain,
                                  size: ImageSize.medium,
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.name.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.code,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}