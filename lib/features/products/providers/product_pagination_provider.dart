import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../../season/season_provider.dart';
import '../../auth/auth_provider.dart';
import '../../tenant/tenant_provider.dart';

class ProductPaginationState {
  final List<Product> products;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  ProductPaginationState({
    required this.products,
    required this.isLoading,
    required this.hasMore,
    this.error,
  });

  ProductPaginationState copyWith({
    List<Product>? products,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return ProductPaginationState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class ProductPaginationNotifier extends StateNotifier<ProductPaginationState> {
  final String tenantId;
  final String brandId;
  final String categoryId;
  final String? seasonId;

  DocumentSnapshot? _lastDocument;
  bool _isFetching = false;

  ProductPaginationNotifier({
    required this.tenantId,
    required this.brandId,
    required this.categoryId,
    this.seasonId,
  }) : super(ProductPaginationState(products: [], isLoading: true, hasMore: true)) {
    fetchNextPage();
  }

  Future<void> fetchNextPage() async {
    if (_isFetching || !state.hasMore || seasonId == null) return;

    _isFetching = true;
    state = state.copyWith(isLoading: true);

    try {
      var query = FirebaseFirestore.instance
          .collection('tenants')
          .doc(tenantId)
          .collection('products')
          .where('brandId', isEqualTo: brandId)
          .where('seasonId', isEqualTo: seasonId)
          .where('visible', isEqualTo: true);

      if (categoryId != "all") {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      // Ora usiamo l'ordinamento professionale server-side
      query = query.orderBy('order').limit(25);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        state = state.copyWith(isLoading: false, hasMore: false);
      } else {
        _lastDocument = snapshot.docs.last;
        final newProducts = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();

        state = state.copyWith(
          products: [...state.products, ...newProducts],
          isLoading: false,
          hasMore: snapshot.docs.length == 25,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    } finally {
      _isFetching = false;
    }
  }

  Future<void> refresh() async {
    _lastDocument = null;
    state = ProductPaginationState(products: [], isLoading: true, hasMore: true);
    await fetchNextPage();
  }
}

final paginatedProductsProvider = StateNotifierProvider.family<ProductPaginationNotifier, ProductPaginationState, String>((ref, arg) {
  final parts = arg.split(':');
  final brandId = parts[0];
  final categoryId = parts[1];

  final tenantId = ref.watch(tenantProvider) ?? '';

  final seasonAsync = ref.watch(activeSeasonProvider(brandId));

  return ProductPaginationNotifier(
    tenantId: tenantId,
    brandId: brandId,
    categoryId: categoryId,
    seasonId: seasonAsync.value?.id,
  );
});
