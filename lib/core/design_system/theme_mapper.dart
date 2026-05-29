import 'package:flutter/material.dart';
import 'app_theme_model.dart';
import 'app_theme_presets.dart';
import 'hex_color.dart';
import 'remote_theme_config.dart';

class ThemeMapper {
  static AppThemeModel fromRemote(RemoteThemeConfig config) {
    final base = AppThemePresets.fromKey(config.preset);

    return base.copyWith(
      splashImageUrl: config.splashImageUrl,
      background: HexColor.tryParse(config.background),
      surface: HexColor.tryParse(config.surface),
      primary: HexColor.tryParse(config.primary),
      secondary: HexColor.tryParse(config.secondary),
      accent: HexColor.tryParse(config.accent),
      textPrimary: HexColor.tryParse(config.textPrimary),
      textSecondary: HexColor.tryParse(config.textSecondary),
      overlayDark: HexColor.tryParse(config.overlayDark),
      overlayLight: HexColor.tryParse(config.overlayLight),
    );
  }

  static ThemeData toThemeData(AppThemeModel model) {
    final isDark = model.key.contains('dark');

    // Forziamo il nero per gli input come richiesto, mantenendo la flessibilità per il resto
    final inputTextColor = Colors.black;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: model.primary,
        primary: model.primary,
        secondary: model.secondary,
        tertiary: model.accent,
        surface: model.surface,
        background: model.background,
        brightness: isDark ? Brightness.dark : Brightness.light,
        // Questo aiuta a forzare il colore del testo in alcuni widget Material
        onSurface: isDark ? model.textPrimary : Colors.black,
      ),
      scaffoldBackgroundColor: model.background,
      appBarTheme: AppBarTheme(
        backgroundColor: model.background,
        foregroundColor: model.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: model.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: model.primary, width: 2),
        ),
        // Force black for all label/hint states
        labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        floatingLabelStyle: TextStyle(color: model.primary, fontWeight: FontWeight.bold),
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.4)),
        prefixIconColor: model.primary,
        suffixIconColor: model.primary,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: model.textPrimary),
        headlineMedium: TextStyle(color: model.textPrimary),
        titleLarge: TextStyle(color: model.textPrimary),
        // titleMedium e bodyLarge sono usati dai TextField. Li forziamo neri.
        titleMedium: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        bodyLarge: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        // Per il testo generico dell'app usiamo bodyMedium
        bodyMedium: TextStyle(color: model.textPrimary),
        bodySmall: TextStyle(color: model.textSecondary),
        labelLarge: TextStyle(color: model.textPrimary),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: model.primary,
        selectionColor: model.primary.withOpacity(0.3),
        selectionHandleColor: model.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: model.primary,
          foregroundColor: isDark ? Colors.black : Colors.white,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: model.primary,
          foregroundColor: isDark ? Colors.black : Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: model.primary),
          foregroundColor: model.primary,
        ),
      ),
    );
  }
}