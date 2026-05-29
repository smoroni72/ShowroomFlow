import 'dart:convert';
import 'package:dio/dio.dart';
import '../../features/products/models/product_model.dart';
import 'package:flutter/foundation.dart';

class GeminiFashionService {
  final _dio = Dio(BaseOptions(
    // DE-COMMENTA e inserisci l'URL del tuo ambiente di sviluppo se provi su Android Studio:
    // baseUrl: 'https://ais-dev-apovmxgftioqb3a6oyc46l-637716254882.europe-west2.run.app',
    baseUrl: 'https://ais-pre-apovmxgftioqb3a6oyc46l-637716254882.europe-west2.run.app',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
  ));

  GeminiFashionService([String? _]); // Mantieni per compatibilità

  /// Genera un consiglio di vendita interattivo (Upsell) e suggerisce abbinamenti (Cross-sell)
  Future<Map<String, dynamic>> getSmartMerchandising({
    required Product targetProduct,
    required List<Product> collection,
  }) async {
    try {
      // In web preview, the server is on the same origin
      final response = await _dio.post(
        '/api/gemini/analyze',
        data: {
          'targetProduct': {
            'id': targetProduct.id,
            'name': targetProduct.name,
            'category': targetProduct.category,
            'description': targetProduct.description,
          },
          'collection': collection.map((p) => {
            'id': p.id,
            'name': p.name,
            'category': p.category,
          }).toList(),
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      debugPrint("⚠️ Server ha restituito errore: ${response.statusCode}");
      return _getFallback();
    } catch (e) {
      debugPrint("❌ Errore chiamata API Gemini (Server): $e");
      return _getFallback();
    }
  }

  Map<String, dynamic> _getFallback() {
    return {
      "pitch": "Un pezzo fondamentale che definisce l'identità della nostra collezione FW24.",
      "matchingIds": [],
      "stylingTip": "Esponilo con una luce calda per esaltare la profondità dei tessuti."
    };
  }
}