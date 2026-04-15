import 'package:flutter/material.dart';
import 'app_theme_model.dart';

class AppThemePresets {
  static const luxury = AppThemeModel(
    key: 'luxury',

    background: Color(0xFFF8F6F2), // leggermente crema
    surface: Color(0xFFFFFFFF),
    primary: Color(0xFF111111),
    secondary: Color(0xFF6E6E6E),
    accent: Color(0xFFC6A972), // oro fashion
    textPrimary: Color(0xFF111111),
    textSecondary: Color(0xFF7A7A7A),
    overlayDark: Color(0xAA000000),
    overlayLight: Color(0x66FFFFFF),
  );

  static const minimal = AppThemeModel(
    key: 'minimal',

    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF2F2F2),
    primary: Color(0xFF1A1A1A),
    secondary: Color(0xFF9A9A9A),
    accent: Color(0xFFE5E5E5),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF8A8A8A),
    overlayDark: Color(0x88000000),
    overlayLight: Color(0x55FFFFFF),
  );

  static const bold = AppThemeModel(
    key: 'bold',
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF4F4F4),
    primary: Color(0xFF000000),
    secondary: Color(0xFF444444),
    accent: Color(0xFFC96F4A), // terracotta fashion (non rosso app!)
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF666666),
    overlayDark: Color(0xBB000000),
    overlayLight: Color(0x66FFFFFF),
  );

  static const boldDark = AppThemeModel(
    key: 'bold_dark',

    /// 🔥 BACKGROUND (non nero puro → più elegante)
    // background: Color(0xFF0F1115), // blu-grigio profondo
    // surface: Color(0xFF1A1D23),   // layer sopra
    background: Color(0xFF302F37), // blu-grigio profondo
    surface: Color(0xFF3A3A51),
    /// 🔥 PRIMARY / SECONDARY
    primary: Color(0xFFEDEDED),   // testo chiaro
    secondary: Color(0xFF9CA3AF), // grigio freddo

    /// 🔥 ACCENT (terracotta fashion)
    accent: Color(0xFFC96F4A),

    /// 🔥 TESTO
    textPrimary: Color(0xFFEDEDED),
    textSecondary: Color(0xFF8F959E),

    /// 🔥 OVERLAY (molto importante in dark)
    overlayDark: Color(0xCC000000),
    overlayLight: Color(0x22FFFFFF),
  );

  static AppThemeModel fromKey(String? key) {
    switch (key) {
      case 'minimal':
        return minimal;
      case 'bold':
        return bold;
      case 'bold_dark':
        return boldDark;
      case 'luxury':
      default:
        return luxury;
    }
  }
}