import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the dream journaling application.
/// Implements the sophisticated dark reddish purple theme for a mysterious, dreamy atmosphere.
class AppTheme {
  AppTheme._();

  // Dark Reddish Purple Nighttime Color Palette

  // Core reddish purple colors
  static const Color primaryBurgundy = Color(0xFF722F37); // Deep burgundy
  static const Color wineRed = Color(0xFFA0153E); // Wine red
  static const Color darkCrimson = Color(0xFF5D0E41); // Dark crimson
  static const Color mutedPurple = Color(0xFF00224D); // Muted purple
  static const Color backgroundDarkest = Color(
    0xFF0F051F,
  ); // Deepest background

  // Accent colors
  static const Color accentRedPurple = Color(0xFFFF5F7E); // Bright red-purple
  static const Color coralRed = Color(0xFFE94560); // Coral red
  static const Color softPink = Color(0xFFF7DC6F); // Soft pink/gold

  // Card and surface colors with reddish purple tones
  static const Color cardDarkBurgundy = Color(0xFF3D1F26); // Dark burgundy card
  static const Color cardMediumPurple = Color(0xFF5D2E46); // Medium purple card
  static const Color surfaceDarkPurple = Color(0xFF722F37); // Surface color

  // Text colors for dark theme
  static const Color textWhite = Color(0xFFFFFFFF); // Pure white for headings
  static const Color textLightGray = Color(
    0xFFF5F5F7,
  ); // Brighter light gray for maximum body text readability
  static const Color textMediumGray = Color(
    0xFFE8E8EA,
  ); // Brighter medium gray for excellent secondary text visibility
  static const Color textDisabledGray = Color(
    0xFFB8B8BA,
  ); // Brighter disabled text for better contrast

  // Success, warning, and error colors
  static const Color successColor = Color(0xFF10B981); // Green
  static const Color warningColor = Color(0xFFF59E0B); // Amber
  static const Color errorColor = Color(0xFFEF4444); // Red

  // Border and divider colors with reddish tones
  static const Color borderPurple = Color(0xFF8B3A62); // Reddish purple border
  static const Color dividerPurple = Color(0xFF6B2D5C); // Purple divider

  // Legacy purple colors (kept for compatibility)
  static const Color primaryDarkPurple = primaryBurgundy;
  static const Color primaryDarkBlue = darkCrimson;
  static const Color accentPurple = accentRedPurple;
  static const Color accentPurpleLight = coralRed;
  static const Color cardDarkPurple = cardDarkBurgundy;

  /// Dark theme with sophisticated reddish purple nighttime aesthetic
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: accentRedPurple,
      onPrimary: textWhite,
      primaryContainer: primaryBurgundy,
      onPrimaryContainer: textWhite,
      secondary: coralRed,
      onSecondary: textWhite,
      secondaryContainer: cardDarkBurgundy,
      onSecondaryContainer: textLightGray,
      tertiary: softPink,
      onTertiary: primaryBurgundy,
      tertiaryContainer: cardMediumPurple,
      onTertiaryContainer: textLightGray,
      error: errorColor,
      onError: textWhite,
      surface: cardDarkBurgundy,
      onSurface: textLightGray,
      onSurfaceVariant: textMediumGray,
      outline: borderPurple,
      outlineVariant: borderPurple.withAlpha(128),
      shadow: Colors.black87,
      scrim: Colors.black87,
      inverseSurface: textWhite,
      onInverseSurface: backgroundDarkest,
      inversePrimary: primaryBurgundy,
    ),
    scaffoldBackgroundColor: backgroundDarkest,
    cardColor: cardDarkBurgundy,
    dividerColor: dividerPurple,

    // AppBar with reddish purple theme
    appBarTheme: AppBarThemeData(
      backgroundColor: primaryBurgundy,
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

    // Card theme with dark burgundy background
    cardTheme: CardThemeData(
      color: cardDarkBurgundy,
      elevation: 4,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Bottom navigation with reddish purple theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: primaryBurgundy,
      selectedItemColor: coralRed,
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

    // FAB with red-purple accent
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentRedPurple,
      foregroundColor: textWhite,
      elevation: 8,
      focusElevation: 10,
      hoverElevation: 10,
      highlightElevation: 14,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    // Button themes with reddish purple accents
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: textWhite,
        backgroundColor: accentRedPurple,
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
        foregroundColor: coralRed,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: BorderSide(color: coralRed, width: 1.5),
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
        foregroundColor: coralRed,
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

    // Input decoration with reddish purple theme
    inputDecorationTheme: InputDecorationThemeData(
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
        borderSide: BorderSide(color: coralRed, width: 2),
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
        color: coralRed,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Switch theme with reddish purple accents
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return coralRed;
        return textDisabledGray;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected))
          return coralRed.withAlpha(77);
        return textDisabledGray.withAlpha(77);
      }),
    ),

    // Checkbox theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return coralRed;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(textWhite),
      side: BorderSide(color: borderPurple, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Radio theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return coralRed;
        return textMediumGray;
      }),
    ),

    // Progress indicator theme
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: coralRed,
      linearTrackColor: borderPurple,
      circularTrackColor: borderPurple,
    ),

    // Slider theme
    sliderTheme: SliderThemeData(
      activeTrackColor: coralRed,
      thumbColor: coralRed,
      overlayColor: coralRed.withAlpha(51),
      inactiveTrackColor: borderPurple,
      trackHeight: 4,
    ),

    // Tab bar theme
    tabBarTheme: TabBarThemeData(
      labelColor: coralRed,
      unselectedLabelColor: textMediumGray,
      indicatorColor: coralRed,
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
      backgroundColor: cardDarkBurgundy,
      contentTextStyle: GoogleFonts.inter(
        color: textLightGray,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: coralRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 8,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: cardDarkBurgundy,
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
      appBarTheme: AppBarThemeData(
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

  /// Helper method to create gradient decoration for backgrounds with reddish purple
  static BoxDecoration createGradientBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryBurgundy, darkCrimson, backgroundDarkest],
        stops: [0.0, 0.6, 1.0],
      ),
    );
  }

  /// Helper method to create card gradient decoration with reddish purple
  static BoxDecoration createCardGradient() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [cardDarkBurgundy, cardMediumPurple],
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
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryBurgundy, darkCrimson, wineRed],
      ),
    );
  }
}
