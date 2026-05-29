import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_drawer.dart';
import 'package:fashion_app/features/products/models/product_model.dart';
import '../../core/widgets/product_image.dart';
import '../auth/login_screen.dart';
import '../products/providers/product_provider.dart';
import '../visits/screens/visit_request_screen.dart';
import 'outfit_preview_screen.dart';
import '../../core/design_system/theme_provider.dart';

class VetrinaScreen extends ConsumerStatefulWidget {
  final String brandId;
  final List<Product>? initialProducts;

  const VetrinaScreen({
    super.key,
    required this.brandId,
    this.initialProducts,
  });

  @override
  ConsumerState<VetrinaScreen> createState() => _VetrinaScreenState();
}

class _VetrinaScreenState extends ConsumerState<VetrinaScreen> {
  Product? selectedOuterwear;
  Product? selectedTop;
  Product? selectedBottom;
  Product? selectedDress;
  Product? selectedHat;
  Product? selectedScarf;
  Product? selectedGloves;

  int _previewTick = 0;

  @override
  void initState() {
    super.initState();

    if (widget.initialProducts != null) {

      for (var p in widget.initialProducts!) {

        switch (p.layer) {

          case ProductLayer.outerwear:
            selectedOuterwear = p;
            break;

          case ProductLayer.top:
            selectedTop = p;
            break;

          case ProductLayer.bottom:
            selectedBottom = p;
            break;

          case ProductLayer.dress:
            selectedDress = p;
            break;

          case ProductLayer.hat:
            selectedHat = p;
            break;

          case ProductLayer.scarf:
            selectedScarf = p;
            break;

          case ProductLayer.gloves:
            selectedGloves = p;
            break;

          default:
            break;
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final productsAsync = ref.watch(productsProvider(widget.brandId));

    return productsAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text("Simula Vetrina")),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text("Simula Vetrina")),
        body: Center(child: Text("Errore: $e")),
      ),
      data: (allProducts) {
        final canProceed =
            selectedOuterwear != null ||
                selectedTop != null ||
                selectedBottom != null ||
                selectedDress != null ||
                selectedHat != null ||
                selectedScarf != null ||
                selectedGloves != null;

        final hasAnySelection = canProceed;

        void openPreview() {
          if (!canProceed) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OutfitPreviewScreen(
                selectedProducts: [
                  if (selectedOuterwear != null) selectedOuterwear!,
                  if (selectedTop != null) selectedTop!,
                  if (selectedBottom != null) selectedBottom!,
                  if (selectedDress != null) selectedDress!,
                  if (selectedHat != null) selectedHat!,
                  if (selectedScarf != null) selectedScarf!,
                  if (selectedGloves != null) selectedGloves!,
                ],
              ),
            ),
          );
        }

        void resetSelection() {
          setState(() {
            selectedOuterwear = null;
            selectedTop = null;
            selectedBottom = null;
            selectedDress = null;
            selectedHat = null;
            selectedScarf = null;
            selectedGloves = null;
            _previewTick++;
          });
        }

        Future<void> _handleVisitRequest() async {

          final user = FirebaseAuth.instance.currentUser;

          /// SE NON LOGGATO → LOGIN
          if (user == null) {

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

          /// SE LOGGATO → APRI RICHIESTA VISITA

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VisitRequestScreen(
                brandId: widget.brandId,
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: theme.background,
          drawer: const AppDrawer(),
          appBar: AppBar(
            title: const Text("Simula Vetrina"),
            backgroundColor: theme.background,
            foregroundColor: theme.textPrimary,
            elevation: 0,
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.background,
                boxShadow: [
                  BoxShadow(
                    color: theme.overlayDark.withOpacity(0.08),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: canProceed ? openPreview : null,
                      child: const Text("Guarda come viene"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: canProceed ? _handleVisitRequest : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.accent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text("Richiedi visita"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: canProceed ? openPreview : null,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.overlayDark.withOpacity(0.08),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Outfit selezionato",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: theme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 115,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _PreviewColumn(
                                  label: "Capospalla",
                                  product: selectedOuterwear,
                                  theme: theme,
                                ),
                                const SizedBox(width: 8),
                                _PreviewColumn(
                                  label: "Top",
                                  product: selectedTop,
                                  theme: theme,
                                ),
                                const SizedBox(width: 8),
                                _PreviewColumn(
                                  label: "Bottom",
                                  product: selectedBottom,
                                  theme: theme,
                                ),
                                const SizedBox(width: 8),
                                _PreviewColumn(
                                  label: "Dress",
                                  product: selectedDress,
                                  theme: theme,
                                ),
                                const SizedBox(width: 8),
                                _PreviewColumn(
                                  label: "Hat",
                                  product: selectedHat,
                                  theme: theme,
                                ),
                                const SizedBox(width: 8),
                                _PreviewColumn(
                                  label: "Scarf",
                                  product: selectedScarf,
                                  theme: theme,
                                ),
                                const SizedBox(width: 8),
                                _PreviewColumn(
                                  label: "Gloves",
                                  product: selectedGloves,
                                  theme: theme,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  canProceed
                                      ? "✔ Outfit completo – Tocca per preview"
                                      : "Completa la selezione per la preview",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.textSecondary,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: hasAnySelection ? resetSelection : null,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  minimumSize: const Size(0, 30),
                                  tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  "Reset",
                                  style: TextStyle(
                                    color: theme.accent,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 10, bottom: 12),
                    child: Column(
                      children: [
                        _buildHorizontalSelectorIfExists(
                          title: "Outerwear",
                          layer: ProductLayer.outerwear,
                          selected: selectedOuterwear,
                          onSelected: (p) => setState(() {
                            selectedOuterwear = p;
                            _previewTick++;
                          }),
                          allProducts: allProducts,
                          theme: theme,
                        ),
                        _buildHorizontalSelectorIfExists(
                          title: "Top",
                          layer: ProductLayer.top,
                          selected: selectedTop,
                          onSelected: (p) => setState(() {
                            selectedTop = p;
                            selectedDress = null;
                            _previewTick++;
                          }),
                          allProducts: allProducts,
                          theme: theme,
                        ),
                        _buildHorizontalSelectorIfExists(
                          title: "Bottom",
                          layer: ProductLayer.bottom,
                          selected: selectedBottom,
                          onSelected: (p) => setState(() {
                            selectedBottom = p;
                            selectedDress = null;
                            _previewTick++;
                          }),
                          allProducts: allProducts,
                          theme: theme,
                        ),
                        _buildHorizontalSelectorIfExists(
                          title: "Dress",
                          layer: ProductLayer.dress,
                          selected: selectedDress,
                          onSelected: (p) => setState(() {
                            selectedDress = p;
                            selectedTop = null;
                            selectedBottom = null;
                            _previewTick++;
                          }),
                          allProducts: allProducts,
                          theme: theme,
                        ),
                        _buildHorizontalSelectorIfExists(
                          title: "Hat",
                          layer: ProductLayer.hat,
                          selected: selectedHat,
                          onSelected: (p) => setState(() {
                            selectedHat = p;
                            _previewTick++;
                          }),
                          allProducts: allProducts,
                          theme: theme,
                        ),
                        _buildHorizontalSelectorIfExists(
                          title: "Scarf",
                          layer: ProductLayer.scarf,
                          selected: selectedScarf,
                          onSelected: (p) => setState(() {
                            selectedScarf = p;
                            _previewTick++;
                          }),
                          allProducts: allProducts,
                          theme: theme,
                        ),
                        _buildHorizontalSelectorIfExists(
                          title: "Gloves",
                          layer: ProductLayer.gloves,
                          selected: selectedGloves,
                          onSelected: (p) => setState(() {
                            selectedGloves = p;
                            _previewTick++;
                          }),
                          allProducts: allProducts,
                          theme: theme,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHorizontalSelectorIfExists({
    required String title,
    required ProductLayer layer,
    required Product? selected,
    required Function(Product) onSelected,
    required List<Product> allProducts,
    required dynamic theme,
  }) {
    final products = allProducts.where((p) => p.layer == layer).toList();

    if (products.isEmpty) return const SizedBox.shrink();

    return _buildHorizontalSelector(
      title: title,
      layer: layer,
      selected: selected,
      onSelected: onSelected,
      allProducts: allProducts,
      theme: theme,
    );
  }

  Widget _buildHorizontalSelector({
    required String title,
    required ProductLayer layer,
    required Product? selected,
    required Function(Product) onSelected,
    required List<Product> allProducts,
    required dynamic theme,
  }) {
    final products = allProducts.where((p) => p.layer == layer).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              final isSelected = selected?.id == product.id;

              return GestureDetector(
                onTap: () => onSelected(product),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? theme.accent
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ProductImage(
                            image: product.outfitImage,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          left: 6,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.code,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _PreviewColumn extends StatelessWidget {
  final String label;
  final Product? product;
  final dynamic theme;

  const _PreviewColumn({
    required this.label,
    required this.product,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: theme.surface,
                child: product == null
                    ?  Center(
                  child: Icon(Icons.add, color: theme.textSecondary),
                )
                    : Stack(
                  children: [
                    Positioned.fill(
                      child: Hero(
                        tag: 'preview_${product!.id}',
                        child: ProductImage(
                          image: product!.outfitImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product!.code,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}