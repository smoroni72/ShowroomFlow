class RemoteThemeConfig {
  final String preset;

  final String? background;
  final String? surface;
  final String? primary;
  final String? secondary;
  final String? accent;
  final String? textPrimary;
  final String? textSecondary;
  final String? overlayDark;
  final String? overlayLight;

  const RemoteThemeConfig({
    required this.preset,
    this.background,
    this.surface,
    this.primary,
    this.secondary,
    this.accent,
    this.textPrimary,
    this.textSecondary,
    this.overlayDark,
    this.overlayLight,
  });

  factory RemoteThemeConfig.fromMap(Map<String, dynamic>? map) {
    return RemoteThemeConfig(
      preset: (map?['preset'] as String?) ?? 'luxury',
      background: map?['background'] as String?,
      surface: map?['surface'] as String?,
      primary: map?['primary'] as String?,
      secondary: map?['secondary'] as String?,
      accent: map?['accent'] as String?,
      textPrimary: map?['textPrimary'] as String?,
      textSecondary: map?['textSecondary'] as String?,
      overlayDark: map?['overlayDark'] as String?,
      overlayLight: map?['overlayLight'] as String?,
    );
  }
}