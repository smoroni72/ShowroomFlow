import 'package:flutter/material.dart';
import 'app_theme_model.dart';
import 'app_theme_presets.dart';
import 'hex_color.dart';
import 'remote_theme_config.dart';

class ThemeMapper {
  static AppThemeModel fromRemote(RemoteThemeConfig config) {
    final base = AppThemePresets.fromKey(config.preset);

    return base.copyWith(
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
}