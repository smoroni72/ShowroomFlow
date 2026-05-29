class RemoteThemeConfig {
  final String preset;
  final String? splashImageUrl;

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
    this.splashImageUrl,
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
    final preset = (map?['preset'] as String?) ?? 'luxury';
    final splashImageUrl = map?['splashImageUrl'] as String?;
    final customColors = (preset == 'custom') ? (map?['customColors'] as Map<String, dynamic>?) : null;

    return RemoteThemeConfig(
      preset: preset,
      splashImageUrl: splashImageUrl,
      background: customColors?['background'] ?? map?['background'] as String?,
      surface: customColors?['surface'] ?? map?['surface'] as String?,
      primary: customColors?['primary'] ?? map?['primary'] as String?,
      secondary: customColors?['secondary'] ?? map?['secondary'] as String?,
      accent: customColors?['accent'] ?? map?['accent'] as String?,
      textPrimary: customColors?['text'] ?? map?['textPrimary'] as String?,
      textSecondary: customColors?['textSecondary'] ?? map?['textSecondary'] as String?,
      overlayDark: customColors?['overlayDark'] ?? map?['overlayDark'] as String?,
      overlayLight: customColors?['overlayLight'] ?? map?['overlayLight'] as String?,
    );
  }
}