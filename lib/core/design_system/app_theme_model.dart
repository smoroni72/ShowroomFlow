import 'package:flutter/material.dart';

class AppThemeModel {
  final String key;

  final Color background;
  final Color surface;

  final Color primary;
  final Color secondary;
  final Color accent;

  final Color textPrimary;
  final Color textSecondary;

  final Color overlayDark;
  final Color overlayLight;

  const AppThemeModel({
    required this.key,
    required this.background,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.overlayDark,
    required this.overlayLight,
  });

  AppThemeModel copyWith({
    String? key,
    Color? background,
    Color? surface,
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? textPrimary,
    Color? textSecondary,
    Color? overlayDark,
    Color? overlayLight,
  }) {
    return AppThemeModel(
      key: key ?? this.key,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      overlayDark: overlayDark ?? this.overlayDark,
      overlayLight: overlayLight ?? this.overlayLight,
    );
  }
}