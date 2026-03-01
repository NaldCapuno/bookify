import 'package:flutter/material.dart';

/// App-specific colors that don't map to standard ColorScheme roles.
/// Access via: Theme.of(context).extension<AppColors>()!
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.reportPrimaryText,
    required this.reportSecondaryText,
    required this.reportDivider,
    required this.surfaceContainer,
    required this.cardBorder,
    required this.reportBackgroundGrey,
    required this.accentBlue,
  });

  final Color reportPrimaryText;
  final Color reportSecondaryText;
  final Color reportDivider;
  final Color surfaceContainer;
  final Color cardBorder;
  final Color reportBackgroundGrey;
  final Color accentBlue;

  /// Legacy aliases for migration from reports_color.dart
  Color get primaryText => reportPrimaryText;
  Color get secondaryText => reportSecondaryText;
  Color get backgroundGrey => reportBackgroundGrey;
  Color get dividerColor => reportDivider;

  static const AppColors light = AppColors(
    reportPrimaryText: Color(0xFF001F3F),
    reportSecondaryText: Color(0xFF6C757D),
    reportDivider: Color(0xFFE0E0E0),
    surfaceContainer: Color(0xFFF8F9FA),
    cardBorder: Color(0xFFE5E7EB),
    reportBackgroundGrey: Color(0xFFF5F6F8),
    accentBlue: Color(0xFF003366),
  );

  static const AppColors dark = AppColors(
    reportPrimaryText: Color(0xFFE8EAED),
    reportSecondaryText: Color(0xFF9AA0A6),
    reportDivider: Color(0xFF3C4043),
    surfaceContainer: Color(0xFF202124),
    cardBorder: Color(0xFF5F6368),
    reportBackgroundGrey: Color(0xFF292A2D),
    accentBlue: Color(0xFF8AB4F8),
  );

  @override
  AppColors copyWith({
    Color? reportPrimaryText,
    Color? reportSecondaryText,
    Color? reportDivider,
    Color? surfaceContainer,
    Color? cardBorder,
    Color? reportBackgroundGrey,
    Color? accentBlue,
  }) {
    return AppColors(
      reportPrimaryText: reportPrimaryText ?? this.reportPrimaryText,
      reportSecondaryText: reportSecondaryText ?? this.reportSecondaryText,
      reportDivider: reportDivider ?? this.reportDivider,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      cardBorder: cardBorder ?? this.cardBorder,
      reportBackgroundGrey: reportBackgroundGrey ?? this.reportBackgroundGrey,
      accentBlue: accentBlue ?? this.accentBlue,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      reportPrimaryText: Color.lerp(reportPrimaryText, other.reportPrimaryText, t)!,
      reportSecondaryText: Color.lerp(reportSecondaryText, other.reportSecondaryText, t)!,
      reportDivider: Color.lerp(reportDivider, other.reportDivider, t)!,
      surfaceContainer: Color.lerp(surfaceContainer, other.surfaceContainer, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      reportBackgroundGrey: Color.lerp(reportBackgroundGrey, other.reportBackgroundGrey, t)!,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
    );
  }
}

/// Central app theme. Use [AppTheme.light] in MaterialApp.
class AppTheme {
  AppTheme._();

  static const Color _primary = Color(0xFF1A1C1E);
  static const Color _secondary = Color(0xFF232D3F);
  static const Color _surfaceContainerHighest = Color(0xFFF2F4F7);
  static const Color _outline = Color(0xFFE0E0E0);
  static const Color _outlineVariant = Color(0xFFE5E7EB);
  static const Color _tertiary = Color(0xFF3B4FFF);

  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: _primary,
      onPrimary: Colors.white,
      secondary: _secondary,
      onSecondary: Colors.white,
      tertiary: _tertiary,
      onTertiary: Colors.white,
      surface: Colors.white,
      onSurface: _primary,
      surfaceContainerHighest: _surfaceContainerHighest,
      onSurfaceVariant: const Color(0xFF6C757D),
      outline: _outline,
      outlineVariant: _outlineVariant,
      error: Colors.red,
      onError: Colors.white,
    );

    final textTheme = TextTheme(
      headlineLarge: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: _primary,
      ),
      headlineMedium: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: _primary,
      ),
      titleLarge: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: _primary,
      ),
      titleMedium: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: _primary,
      ),
      titleSmall: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: _primary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: _primary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: _primary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      extensions: const [AppColors.light],
      scaffoldBackgroundColor: _surfaceContainerHighest,
      appBarTheme: AppBarTheme(
        backgroundColor: _surfaceContainerHighest,
        elevation: 1,
        centerTitle: false,
        titleTextStyle: textTheme.headlineLarge ?? const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _primary),
        iconTheme: const IconThemeData(color: _primary),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.black.withOpacity(0.08)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surfaceContainerHighest,
        selectedItemColor: _primary,
        unselectedItemColor: Colors.grey,
      ),
      dividerTheme: const DividerThemeData(
        color: _outline,
      ),
    );
  }

  // Dark theme constants
  static const Color _darkPrimary = Color(0xFFDADCE0);
  static const Color _darkOnPrimary = Color(0xFF202124);
  static const Color _darkSecondary = Color(0xFF5F6368);
  static const Color _darkSurface = Color(0xFF202124);
  static const Color _darkSurfaceContainerHighest = Color(0xFF292A2D);
  static const Color _darkOutline = Color(0xFF5F6368);
  static const Color _darkOutlineVariant = Color(0xFF3C4043);
  static const Color _darkTertiary = Color(0xFF8AB4F8);

  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      primary: _darkPrimary,
      onPrimary: _darkOnPrimary,
      secondary: _darkSecondary,
      onSecondary: Colors.white,
      tertiary: _darkTertiary,
      onTertiary: Colors.black,
      surface: _darkSurface,
      onSurface: const Color(0xFFE8EAED),
      surfaceContainerHighest: _darkSurfaceContainerHighest,
      onSurfaceVariant: const Color(0xFF9AA0A6),
      outline: _darkOutline,
      outlineVariant: _darkOutlineVariant,
      error: Colors.red.shade400,
      onError: Colors.black,
    );

    final textTheme = TextTheme(
      headlineLarge: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE8EAED),
      ),
      headlineMedium: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE8EAED),
      ),
      titleLarge: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE8EAED),
      ),
      titleMedium: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE8EAED),
      ),
      titleSmall: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE8EAED),
      ),
      bodyLarge: const TextStyle(
        fontSize: 16,
        color: Color(0xFFE8EAED),
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        color: Color(0xFFE8EAED),
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: colorScheme.onSurfaceVariant,
      ),
      labelLarge: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF202124),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      extensions: const [AppColors.dark],
      scaffoldBackgroundColor: _darkSurfaceContainerHighest,
      appBarTheme: AppBarTheme(
        backgroundColor: _darkSurfaceContainerHighest,
        elevation: 1,
        centerTitle: false,
        titleTextStyle: textTheme.headlineLarge,
        iconTheme: const IconThemeData(color: _darkPrimary),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF292A2D),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: _darkOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _darkOutlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF292A2D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkOutlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkSurfaceContainerHighest,
        selectedItemColor: _darkPrimary,
        unselectedItemColor: Color(0xFF9AA0A6),
      ),
      dividerTheme: const DividerThemeData(
        color: _darkOutline,
      ),
    );
  }
}
