import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'dart:ui';
import 'dart:convert';
import '../../products/models/product_model.dart';
import '../../../../core/design_system/theme_provider.dart';
import '../../../../core/widgets/product_image.dart';
import '../../../../core/network/gemini_service.dart';
import '../../../../core/providers/user_role_provider.dart';

class DigitalShowroomScreen extends ConsumerStatefulWidget {
  final List<Product> products;

  const DigitalShowroomScreen({
    super.key,
    required this.products,
  });

  @override
  ConsumerState<DigitalShowroomScreen> createState() => _DigitalShowroomScreenState();
}

class _DigitalShowroomScreenState extends ConsumerState<DigitalShowroomScreen> {
  String? _aiInsight;
  Map<String, String> _productInsights = {};
  bool _isLoadingAi = true;

  // Advanced AI State
  bool _isAnalyzing = false;
  Map<String, dynamic>? _smartMerchandising;
  Product? _analyzedProduct;

  @override
  void initState() {
    super.initState();
    _generateInitialInsights();
  }

  Future<void> _generateInitialInsights() async {
    try {
      final service = GeminiFashionService();

      final response = await Dio(BaseOptions(
        baseUrl: kIsWeb ? Uri.base.origin : '',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      )).post(
        '/api/gemini/collection-insights',
        data: {
          'products': widget.products.map((p) => {
            'id': p.id,
            'name': p.name,
            'category': p.category,
          }).toList(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        setState(() {
          _aiInsight = data['globalPitch'];
          _productInsights = (data['individualInsights'] as Map).cast<String, String>();
          _isLoadingAi = false;
        });
      } else {
        throw Exception("Server error");
      }
    } catch (e) {
      debugPrint("❌ Error fetching initial insights: $e");
      setState(() {
        _aiInsight = "Una selezione curata che esprime eleganza e contemporaneità.";
        _isLoadingAi = false;
      });
    }
  }

  Future<void> _showAIAssistant(Product product) async {
    setState(() {
      _isAnalyzing = true;
      _analyzedProduct = product;
    });

    final service = GeminiFashionService();

    final result = await service.getSmartMerchandising(
      targetProduct: product,
      collection: widget.products,
    );

    setState(() {
      _isAnalyzing = false;
      _smartMerchandising = result;
    });

    if (mounted) {
      _showStylistPanel(context, product);
    }
  }

  void _showStylistPanel(BuildContext context, Product product) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Color(0xFF151515),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 30),
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFFBC4A8C), size: 24),
                  SizedBox(width: 12),
                  Text(
                    "AI SALES ASSISTANT",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Pitch Column
              const Text("STRATEGIA DI VENDITA", style: TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(
                _smartMerchandising?['pitch'] ?? "Caricamento...",
                style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5, fontWeight: FontWeight.w300),
              ),

              const SizedBox(height: 30),

              // Cross-sell Section
              const Text("LOOK CONSIGLIATI (CROSS-SELL)", style: TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: (_smartMerchandising?['matchingIds'] as List? ?? []).map((id) {
                    final p = widget.products.firstWhere((p) => p.id == id, orElse: () => product);
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ProductImage(image: p.outfitImage, size: ImageSize.small),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 10), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const Spacer(),

              // Styling Tip
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFBC4A8C).withOpacity(0.1),
                  border: Border.all(color: const Color(0xFFBC4A8C).withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Color(0xFFBC4A8C)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _smartMerchandising?['stylingTip'] ?? "",
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              /// HEADER
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 70, 24, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("FW24 COLLECTION", style: TextStyle(color: Colors.white30, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 4)),
                              SizedBox(height: 4),
                              Text("DIGITAL SHOWROOM", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w200, letterSpacing: 2)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 60),

                      // Hero Pitch
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white10), bottom: BorderSide(color: Colors.white10))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("COLLECTION SYNOPSIS", style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 2)),
                            const SizedBox(height: 16),
                            if (_isLoadingAi)
                              const LinearProgressIndicator(backgroundColor: Colors.transparent, color: Colors.white10, minHeight: 1)
                            else
                              Text(_aiInsight ?? "", style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6, fontWeight: FontWeight.w300, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// PRODUCT LIST
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final product = widget.products[index];
                      final user = FirebaseAuth.instance.currentUser;
                      final userRoleAsync = ref.watch(userRoleProvider);
                      final String? role = userRoleAsync.when(data: (r) => r, loading: () => null, error: (_, __) => null);

                      final isLogged = user != null;
                      final isVerified = (user?.emailVerified ?? false) || (user != null && user.email == 'demo@showroomflow.com');
                      final showPrice = role == 'agent' || role == 'admin' || isVerified;

                      final insight = _productInsights[product.id];

                      // --- RIPRISTINO LOGICA DATI TECNICI ---
                      final fabricsList = product.variants
                          .map((v) => v.fabricCode != null && v.fabricCode!.isNotEmpty ? "${v.fabric} (${v.fabricCode})" : v.fabric)
                          .where((f) => f.isNotEmpty)
                          .toSet()
                          .toList();

                      if (fabricsList.isEmpty && product.composition != null && product.composition!.isNotEmpty) {
                        fabricsList.add(product.composition!);
                      }

                      final Map<String, Set<String>> colorMap = {};
                      for (final v in product.variants) {
                        final colorKey = v.colorCode != null && v.colorCode!.isNotEmpty
                            ? "${v.color} (${v.colorCode})"
                            : v.color;
                        if (colorKey.isNotEmpty) {
                          colorMap.putIfAbsent(colorKey, () => {}).add(v.size);
                        }
                      }

                      final colorsWithSizes = colorMap.entries.map((e) {
                        final sortedSizes = e.value.toList()..sort();
                        return "${e.key}\n${sortedSizes.join(" · ")}";
                      }).toList();
                      // ---------------------------------------

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Immagine con Button IA
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                Hero(
                                  tag: "showroom_${product.id}",
                                  child: Container(
                                    width: double.infinity,
                                    height: 500,
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(2)),
                                    child: ProductImage(image: product.outfitImage, fit: BoxFit.contain, size: ImageSize.large),
                                  ),
                                ),
                                // INTERACTIVE AI BUTTON
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: GestureDetector(
                                    onTap: () => _showAIAssistant(product),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, spreadRadius: 2)],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.auto_awesome, color: Color(0xFFBC4A8C), size: 16),
                                          const SizedBox(width: 8),
                                          Text(
                                            _isAnalyzing && _analyzedProduct?.id == product.id ? "ANALISI..." : "CHIEDI ALLO STYLISTA",
                                            style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Info Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(product.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 1)),
                                      const SizedBox(height: 4),
                                      Text(product.category?.toUpperCase() ?? "CAPO", style: TextStyle(color: theme.accent, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                                    ],
                                  ),
                                ),
                                if (insight != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border.all(color: Colors.white10)),
                                    child: Text(insight, style: const TextStyle(color: Colors.white60, fontSize: 10, fontStyle: FontStyle.italic)),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Description
                            if (product.description != null && product.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: Text(
                                  product.description!,
                                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5, fontWeight: FontWeight.w300),
                                ),
                              ),

                            // --- RIPRISTINO COLONNE TECNICHE ---
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _specListColumn("TESSUTI", fabricsList)),
                                const SizedBox(width: 40),
                                Expanded(flex: 2, child: _specListColumn("COLORI & TAGLIE", colorsWithSizes)),
                                if (isLogged) ...[
                                  const SizedBox(width: 20),
                                  Expanded(
                                      child: _specListColumn(
                                          "PREZZO",
                                          ["€ ${product.price.toStringAsFixed(2)}"]
                                      )
                                  ),
                                ] else if (isLogged && !showPrice) ...[
                                  const SizedBox(width: 20),
                                  Expanded(
                                      child: _specListColumn(
                                          "INFO",
                                          ["VERIFICA EMAIL"]
                                      )
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: widget.products.length,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _specListColumn(String label, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white30, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            item.toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w400, height: 1.3),
          ),
        )).toList(),
      ],
    );
  }
}
