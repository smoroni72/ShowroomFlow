import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';

final selectedVariantProvider =
StateProvider.family<Variant?, String>((ref, productId) => null);