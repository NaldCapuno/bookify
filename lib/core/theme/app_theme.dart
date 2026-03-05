import 'package:flutter/material.dart';

/// Custom extension to add a 'warning' color slot to the theme.
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color warning;

  AppColorsExtension({required this.warning});

  @override
  ThemeExtension<AppColorsExtension> copyWith({Color? warning}) {
    return AppColorsExtension(warning: warning ?? this.warning);
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(warning: Color.lerp(warning, other.warning, t)!);
  }
}

extension ThemeColors on BuildContext {
  Color get warning =>
      Theme.of(this).extension<AppColorsExtension>()?.warning ?? Colors.orange;
}

/// Central app theme. Use [AppTheme.light] and [AppTheme.dark] in MaterialApp.
class AppTheme {
  AppTheme._();

  // Light theme palette
  static const Color _primary = Color(0xFF1A1C1E);
  static const Color _onPrimary = Colors.white;
  static const Color _secondary = Color(0xFF232D3F);
  static const Color _onSecondary = Colors.white;
  static const Color _surface = Colors.white;
  static const Color _onSurface = Color(0xFF1A1C1E);
  static const Color _surfaceContainerHighest = Color(0xFFF2F4F7);
  static const Color _onSurfaceVariant = Color(0xFF6C757D);
  static const Color _outline = Color(0xFFE0E0E0);
  static const Color _outlineVariant = Color(0xFFE5E7EB);
  static const Color _tertiary = Color(0xFF3B4FFF);
  static const Color _onTertiary = Colors.white;
  static const Color _error = Colors.red;
  static const Color _onError = Colors.white;

  static ColorScheme get _lightScheme => ColorScheme.light(
    primary: _primary,
    onPrimary: _onPrimary,
    secondary: _secondary,
    onSecondary: _onSecondary,
    tertiary: _tertiary,
    onTertiary: _onTertiary,
    surface: _surface,
    onSurface: _onSurface,
    surfaceContainerHighest: _surfaceContainerHighest,
    onSurfaceVariant: _onSurfaceVariant,
    outline: _outline,
    outlineVariant: _outlineVariant,
    error: _error,
    onError: _onError,
  );

  // Dark theme palette
  static const Color _darkPrimary = Color(0xFFDADCE0);
  static const Color _darkOnPrimary = Color(0xFF202124);
  static const Color _darkSecondary = Color(0xFF5F6368);
  static const Color _darkOnSecondary = Colors.white;
  static const Color _darkSurface = Color(0xFF202124);
  static const Color _darkOnSurface = Color(0xFFE8EAED);
  static const Color _darkSurfaceContainerHighest = Color(0xFF292A2D);
  static const Color _darkOnSurfaceVariant = Color(0xFF9AA0A6);
  static const Color _darkOutline = Color(0xFF5F6368);
  static const Color _darkOutlineVariant = Color(0xFF3C4043);
  static const Color _darkTertiary = Color(0xFF8AB4F8);
  static const Color _darkOnTertiary = Colors.black;
  static const Color _darkError = Color(0xFFCF6679); // red.shade400
  static const Color _darkOnError = Colors.black;

  static ColorScheme get _darkScheme => ColorScheme.dark(
    primary: _darkPrimary,
    onPrimary: _darkOnPrimary,
    secondary: _darkSecondary,
    onSecondary: _darkOnSecondary,
    tertiary: _darkTertiary,
    onTertiary: _darkOnTertiary,
    surface: _darkSurface,
    onSurface: _darkOnSurface,
    surfaceContainerHighest: _darkSurfaceContainerHighest,
    onSurfaceVariant: _darkOnSurfaceVariant,
    outline: _darkOutline,
    outlineVariant: _darkOutlineVariant,
    error: _darkError,
    onError: _darkOnError,
  );

  static TextTheme _textTheme(ColorScheme scheme) {
    final onSurface = scheme.onSurface;
    final onSurfaceVariant = scheme.onSurfaceVariant;
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: onSurface,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: onSurface,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: onSurface),
      bodyMedium: TextStyle(fontSize: 14, color: onSurface),
      bodySmall: TextStyle(fontSize: 12, color: onSurfaceVariant),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: scheme.onPrimary,
      ),
    );
  }

  static ThemeData _buildTheme(ColorScheme scheme) {
    final base = ThemeData.from(colorScheme: scheme);
    final isDark = scheme.brightness == Brightness.dark;

    return base.copyWith(
      useMaterial3: true,
      // --- ADDED THE EXTENSION HERE ---
      extensions: [
        AppColorsExtension(
          warning: isDark ? const Color(0xFFFFB74D) : const Color(0xFFF57C00),
        ),
      ],
      textTheme: _textTheme(scheme),
      scaffoldBackgroundColor: scheme.surfaceContainerHighest,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainerHighest,
        elevation: 1,
        centerTitle: false,
        titleTextStyle: _textTheme(scheme).headlineLarge,
        iconTheme: IconThemeData(color: scheme.primary),
      ),
      cardTheme: CardThemeData(
        color: isDark ? scheme.surfaceContainerHighest : scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? scheme.surfaceContainerHighest : scheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
      ),
      dividerTheme: DividerThemeData(color: scheme.outline),
    );
  }

  static ThemeData get light => _buildTheme(_lightScheme);
  static ThemeData get dark => _buildTheme(_darkScheme);
}
