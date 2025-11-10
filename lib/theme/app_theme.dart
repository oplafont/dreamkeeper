import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the dream journaling application.
/// Implements the sophisticated dark purple theme matching the "REMember your nights, decode your days" design.
class AppTheme {
  AppTheme._();

  // Dark Purple Nighttime Color Palette - Matching Reference Design

  // Core dark purple and blue gradient colors from reference
  static const Color primaryDarkPurple = Color(
    0xFF2D1B69,
  ); // Deep purple from reference
  static const Color primaryDarkBlue = Color(0xFF1A0B3D); // Dark blue gradient
  static const Color backgroundDarkest = Color(
    0xFF0F051F,
  ); // Deepest background
  static const Color accentPurple = Color(0xFF8B5CF6); // Purple accent
  static const Color accentPurpleLight = Color(
    0xFFA855F7,
  ); // Lighter purple accent

  // Card and surface colors
  static const Color cardDarkPurple = Color(0xFF1E1B4B); // Dark card background
  static const Color cardMediumPurple = Color(
    0xFF312E81,
  ); // Medium card background
  static const Color surfaceDarkPurple = Color(0xFF2D1B69); // Surface color

  // Text colors for dark theme
  static const Color textWhite = Color(0xFFFFFFFF); // Pure white for headings
  static const Color textLightGray = Color(
    0xFFE5E7EB,
  ); // Light gray for body text
  static const Color textMediumGray = Color(
    0xFFD1D5DB,
  ); // Medium gray for secondary text
  static const Color textDisabledGray = Color(0xFF9CA3AF); // Disabled text

  // Success, warning, and error colors adapted for dark theme
  static const Color successColor = Color(0xFF10B981); // Green
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color errorColor = Color(0xFFEF4444); // Red

  // Border and divider colors
  static const Color borderPurple = Color(0xFF4C1D95); // Purple border
  static const Color dividerPurple = Color(0xFF3730A3); // Purple divider

  /// Dark theme with sophisticated purple nighttime aesthetic
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: accentPurple,
      onPrimary: textWhite,
      primaryContainer: primaryDarkPurple,
      onPrimaryContainer: textWhite,
      secondary: accentPurpleLight,
      onSecondary: textWhite,
      secondaryContainer: cardDarkPurple,
      onSecondaryContainer: textLightGray,
      tertiary: accentPurpleLight,
      onTertiary: textWhite,
      tertiaryContainer: cardMediumPurple,
      onTertiaryContainer: textLightGray,
      error: errorColor,
      onError: textWhite,
      surface: cardDarkPurple,
      onSurface: textLightGray,
      onSurfaceVariant: textMediumGray,
      outline: borderPurple,
      outlineVariant: borderPurple.withAlpha(128),
      shadow: Colors.black87,
      scrim: Colors.black87,
      inverseSurface: textWhite,
      onInverseSurface: backgroundDarkest,
      inversePrimary: primaryDarkPurple,
    ),
    scaffoldBackgroundColor: backgroundDarkest,
    cardColor: cardDarkPurple,
    dividerColor: dividerPurple,

    // AppBar with dark gradient theme
    appBarTheme: AppBarTheme(
      backgroundColor: primaryDarkPurple,
      foregroundColor: textWhite,
      elevation: 0,
      shadowColor: Colors.black54,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textWhite,
        letterSpacing: 0.15,
      ),
      iconTheme: IconThemeData(color: textWhite),
      actionsIconTheme: IconThemeData(color: textWhite),
    ),

    // Card theme with dark purple background
    cardTheme: CardTheme(
      color: cardDarkPurple,
      elevation: 4,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Bottom navigation with dark theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: primaryDarkPurple,
      selectedItemColor: accentPurpleLight,
      unselectedItemColor: textMediumGray,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),

    // FAB with purple accent
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentPurple,
      foregroundColor: textWhite,
      elevation: 8,
      focusElevation: 10,
      hoverElevation: 10,
      highlightElevation: 14,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    // Button themes with purple accents
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: textWhite,
        backgroundColor: accentPurple,
        elevation: 4,
        shadowColor: Colors.black54,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: accentPurpleLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: BorderSide(color: accentPurpleLight, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentPurpleLight,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Typography with white and gray text
    textTheme: _buildDarkTextTheme(),

    // Input decoration with dark purple theme
    inputDecorationTheme: InputDecorationTheme(
      fillColor: cardMediumPurple,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: borderPurple, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: borderPurple, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: accentPurpleLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: errorColor, width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        color: textMediumGray,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: textDisabledGray,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: GoogleFonts.inter(
        color: accentPurpleLight,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Switch theme with purple accents
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentPurpleLight;
        }
        return textDisabledGray;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentPurpleLight.withAlpha(77);
        }
        return textDisabledGray.withAlpha(77);
      }),
    ),

    // Checkbox theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentPurpleLight;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(textWhite),
      side: BorderSide(color: borderPurple, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Radio theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return accentPurpleLight;
        }
        return textMediumGray;
      }),
    ),

    // Progress indicator theme
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: accentPurpleLight,
      linearTrackColor: borderPurple,
      circularTrackColor: borderPurple,
    ),

    // Slider theme
    sliderTheme: SliderThemeData(
      activeTrackColor: accentPurpleLight,
      thumbColor: accentPurpleLight,
      overlayColor: accentPurpleLight.withAlpha(51),
      inactiveTrackColor: borderPurple,
      trackHeight: 4,
    ),

    // Tab bar theme
    tabBarTheme: TabBarTheme(
      labelColor: accentPurpleLight,
      unselectedLabelColor: textMediumGray,
      indicatorColor: accentPurpleLight,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Tooltip theme
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: cardMediumPurple,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderPurple),
      ),
      textStyle: GoogleFonts.inter(
        color: textLightGray,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // SnackBar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cardDarkPurple,
      contentTextStyle: GoogleFonts.inter(
        color: textLightGray,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: accentPurpleLight,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 8,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: cardDarkPurple,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    ),
  );

  /// Light theme (minimal - app focuses on dark theme)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1), // Indigo
        brightness: Brightness.light,
        primary: const Color(0xFF6366F1),
        secondary: const Color(0xFF8B5CF6), // Purple
        tertiary: const Color(0xFF06B6D4), // Cyan
        surface: const Color(0xFFFAFAFA),
        background: const Color(0xFFFFFBFE),
        error: const Color(0xFFDC2626),
      ),
      scaffoldBackgroundColor: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1E293B), // Dark slate
          Color(0xFF334155), // Slate
          Color(0xFF475569), // Lighter slate
        ],
      ).colors.first, // Use first color as fallback
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      textTheme: TextTheme(
        // Headlines
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F2937),
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F2937),
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F2937),
        ),

        // Titles
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1F2937),
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1F2937),
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF1F2937),
        ),

        // Body text
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF374151),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF374151),
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF6B7280),
        ),

        // Labels
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF374151),
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF6B7280),
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  /// Helper method to build dark text theme
  static TextTheme _buildDarkTextTheme() {
    return TextTheme(
      // Display styles
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: textWhite,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: textWhite,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: textWhite,
        letterSpacing: 0,
        height: 1.22,
      ),

      // Headline styles
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textWhite,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textWhite,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textWhite,
        letterSpacing: 0,
        height: 1.33,
      ),

      // Title styles
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textWhite,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textLightGray,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textLightGray,
        letterSpacing: 0.1,
        height: 1.43,
      ),

      // Body styles
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textLightGray,
        letterSpacing: 0.5,
        height: 1.50,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textMediumGray,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMediumGray,
        letterSpacing: 0.4,
        height: 1.33,
      ),

      // Label styles
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textLightGray,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textMediumGray,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textDisabledGray,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  /// Helper method to build light text theme (minimal)
  static TextTheme _buildLightTextTheme() {
    return GoogleFonts.interTextTheme();
  }

  /// Helper method to create gradient decoration for backgrounds
  static BoxDecoration createGradientBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryDarkPurple, primaryDarkBlue, backgroundDarkest],
        stops: [0.0, 0.6, 1.0],
      ),
    );
  }

  /// Helper method to create card gradient decoration
  static BoxDecoration createCardGradient() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [cardDarkPurple, cardMediumPurple],
        stops: [0.0, 1.0],
      ),
      borderRadius: BorderRadius.circular(16.0),
      border: Border.all(color: borderPurple.withAlpha(77), width: 1),
    );
  }

  /// Helper method to get success color
  static Color getSuccessColor() => successColor;

  /// Helper method to get warning color
  static Color getWarningColor() => warningColor;

  /// Helper method to get error color
  static Color getErrorColor() => errorColor;

  /// Helper method to get accent purple color
  static Color getAccentPurple() => accentPurple;

  /// Helper method to get accent purple light color
  static Color getAccentPurpleLight() => accentPurpleLight;

  static BoxDecoration get dreamEntryGradient {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1E293B), // Dark slate
          Color(0xFF334155), // Slate
          Color(0xFF475569), // Lighter slate
        ],
      ),
    );
  }
}
