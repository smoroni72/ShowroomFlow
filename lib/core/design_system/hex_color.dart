import 'package:flutter/material.dart';

class HexColor {
  static Color? tryParse(String? hex) {
    if (hex == null || hex.trim().isEmpty) return null;

    final buffer = StringBuffer();
    String value = hex.replaceFirst('#', '').trim();

    if (value.length == 6) {
      buffer.write('FF');
      buffer.write(value);
    } else if (value.length == 8) {
      buffer.write(value);
    } else {
      return null;
    }

    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return null;
    }
  }
}