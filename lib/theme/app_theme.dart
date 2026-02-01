import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Lucidlog - AI Dream Journal
/// Theme configuration with sophisticated dark purple nighttime aesthetic
/// Tagline: "REMember your nights, decode your days."
class AppTheme {
  AppTheme._();

  // ============================================================
  // LUCIDLOG COLOR PALETTE
  // ============================================================

  // Core Background Colors
  static const Color backgroundDarkest = Color(0xFF0D0B14); // Deep space navy
  static const Color backgroundDark = Color(0xFF12101A); // Slightly lighter
  static const Color cardBackground = Color(0xFF1A1625); // Card/surface purple-tint
  static const Color cardBackgroundElevated = Color(0xFF221E2D); // Elevated cards

  // Primary Accent - Bright Purple
  static const Color primaryPurple = Color(0xFF8B5CF6); // Main accent
  static const Color primaryPurpleLight = Color(0xFFA78BFA); // Lighter variant
  static const Color primaryPurpleDark = Color(0xFF7C3AED); // Darker variant
  static const Color primaryPurpleMuted = Color(0xFF6D28D9); // Muted variant

  // Secondary Accent - Teal
  static const Color secondaryTeal = Color(0xFF06B6D4); // Cyan/Teal
  static const Color secondaryTealLight = Color(0xFF22D3EE); // Light teal
  static const Color secondaryTealDark = Color(0xFF0891B2); // Dark teal

  // Tertiary Accent - Coral
  static const Color tertiaryOrange = Color(0xFFF97316); // Coral/Orange
  static const Color tertiaryOrangeLight = Color(0xFFFB923C); // Light coral
  static const Color tertiaryOrangeDark = Color(0xFFEA580C); // Dark coral

  // Additional Accents
  static const Color accentPink = Color(0xFFEC4899); // Pink accent
  static const Color accentGreen = Color(0xFF10B981); // Success green
  static const Color accentYellow = Color(0xFFFBBF24); // Warning yellow
  static const Color accentRed = Color(0xFFEF4444); // Error red

  // Text Colors
  static const Color textWhite = Color(0xFFFFFFFF); // Pure white
  static const Color textPrimary = Color(0xFFF8FAFC); // Main text
  static const Color textSecondary = Color(0xFFCBD5E1); // Secondary text
  static const Color textMuted = Color(0xFF94A3B8); // Muted/disabled text
  static const Color textSubtle = Color(0xFF64748B); // Very subtle text

  // Border & Divider Colors
  static const Color borderDefault = Color(0xFF2D2640); // Default border
  static const Color borderSubtle = Color(0xFF1E1B2E); // Subtle border
  static const Color borderAccent = Color(0xFF8B5CF6); // Accent border
  static const Color dividerColor = Color(0xFF2D2640); // Dividers

  // Gradient Colors
  static const Color gradientStart = Color(0xFF8B5CF6); // Purple
  static const Color gradientMiddle = Color(0xFF06B6D4); // Teal
  static const Color gradientEnd = Color(0xFFF97316); // Coral

  // Status Colors
  static const Color successColor = Color(0xFF10B981); // Green
  static const Color warningColor = Color(0xFFFBBF24); // Amber
  static const Color errorColor = Color(0xFFEF4444); // Red
  static const Color infoColor = Color(0xFF06B6D4); // Teal

  // Dream Category Colors
  static const Color lucidDreamColor = Color(0xFF8B5CF6); // Purple
  static const Color nightmareColor = Color(0xFFEF4444); // Red
  static const Color recurringColor = Color(0xFFFBBF24); // Yellow
  static const Color prophericColor = Color(0xFF06B6D4); // Teal
  static const Color normalDreamColor = Color(0xFF64748B); // Gray

  // Sleep Quality Colors
  static const Color sleepExcellent = Color(0xFF10B981); // Green
  static const Color sleepGood = Color(0xFF06B6D4); // Teal
  static const Color sleepFair = Color(0xFFFBBF24); // Yellow
  static const Color sleepPoor = Color(0xFFF97316); // Orange
  static const Color sleepTerrible = Color(0xFFEF4444); // Red

  // ============================================================
  // DARK THEME (PRIMARY THEME)
  // ============================================================

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,

    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryPurple,
      onPrimary: textWhite,
      primaryContainer: primaryPurpleDark,
      onPrimaryContainer: textWhite,
      secondary: secondaryTeal,
      onSecondary: textWhite,
      secondaryContainer: secondaryTealDark,
      onSecondaryContainer: textWhite,
      tertiary: tertiaryOrange,
      onTertiary: textWhite,
      tertiaryContainer: tertiaryOrangeDark,
      onTertiaryContainer: textWhite,
      error: errorColor,
      onError: textWhite,
      surface: cardBackground,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: borderDefault,
      outlineVariant: borderSubtle,
      shadow: Colors.black87,
      scrim: Colors.black87,
      inverseSurface: textWhite,
      onInverseSurface: backgroundDarkest,
      inversePrimary: primaryPurpleDark,
    ),

    scaffoldBackgroundColor: backgroundDarkest,
    cardColor: cardBackground,
    dividerColor: dividerColor,

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textWhite,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: textWhite, size: 24),
      actionsIconTheme: const IconThemeData(color: textWhite, size: 24),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: borderSubtle, width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Bottom Navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: cardBackground,
      selectedItemColor: primaryPurple,
      unselectedItemColor: textMuted,
      elevation: 0,
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

    // Navigation Bar (Material 3)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: cardBackground,
      indicatorColor: primaryPurple.withOpacity(0.2),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: primaryPurple,
          );
        }
        return GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryPurple, size: 24);
        }
        return const IconThemeData(color: textMuted, size: 24);
      }),
    ),

    // FAB Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryPurple,
      foregroundColor: textWhite,
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 6,
      highlightElevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: textWhite,
        backgroundColor: primaryPurple,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryPurple,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        side: BorderSide(color: primaryPurple, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryPurple,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),

    // Filled Button
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: textWhite,
        backgroundColor: primaryPurple,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    ),

    // Typography
    textTheme: _buildDarkTextTheme(),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      fillColor: cardBackgroundElevated,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: borderDefault, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: borderDefault, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: primaryPurple, width: 2),
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
        color: textMuted,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: GoogleFonts.inter(
        color: textSubtle,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: GoogleFonts.inter(
        color: primaryPurple,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryPurple;
        return textMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryPurple.withOpacity(0.3);
        }
        return textSubtle.withOpacity(0.3);
      }),
    ),

    // Checkbox
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryPurple;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(textWhite),
      side: BorderSide(color: borderDefault, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Radio
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryPurple;
        return textMuted;
      }),
    ),

    // Progress Indicator
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryPurple,
      linearTrackColor: borderDefault,
      circularTrackColor: borderDefault,
    ),

    // Slider
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryPurple,
      thumbColor: primaryPurple,
      overlayColor: primaryPurple.withOpacity(0.2),
      inactiveTrackColor: borderDefault,
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
    ),

    // TabBar
    tabBarTheme: TabBarTheme(
      labelColor: primaryPurple,
      unselectedLabelColor: textMuted,
      indicatorColor: primaryPurple,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: cardBackgroundElevated,
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
      ),
      side: BorderSide(color: borderSubtle),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // Tooltip
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: cardBackgroundElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderDefault),
      ),
      textStyle: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cardBackgroundElevated,
      contentTextStyle: GoogleFonts.inter(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      actionTextColor: primaryPurple,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 8,
    ),

    // Dialog
    dialogTheme: DialogTheme(
      backgroundColor: cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      elevation: 8,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textWhite,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
    ),

    // Bottom Sheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      dragHandleColor: textMuted,
      dragHandleSize: const Size(40, 4),
    ),

    // Date Picker
    datePickerTheme: DatePickerThemeData(
      backgroundColor: cardBackground,
      headerBackgroundColor: primaryPurple,
      headerForegroundColor: textWhite,
      dayForegroundColor: WidgetStateProperty.all(textPrimary),
      todayForegroundColor: WidgetStateProperty.all(primaryPurple),
      todayBackgroundColor: WidgetStateProperty.all(Colors.transparent),
      todayBorder: BorderSide(color: primaryPurple),
      dayOverlayColor: WidgetStateProperty.all(primaryPurple.withOpacity(0.1)),
    ),

    // Time Picker
    timePickerTheme: TimePickerThemeData(
      backgroundColor: cardBackground,
      hourMinuteColor: cardBackgroundElevated,
      dialBackgroundColor: cardBackgroundElevated,
      dialHandColor: primaryPurple,
      entryModeIconColor: primaryPurple,
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: dividerColor,
      thickness: 1,
      space: 1,
    ),

    // List Tile
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      selectedTileColor: primaryPurple.withOpacity(0.1),
      iconColor: textMuted,
      textColor: textPrimary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: textSecondary,
      size: 24,
    ),

    // Primary Icon Theme
    primaryIconTheme: const IconThemeData(
      color: textWhite,
      size: 24,
    ),
  );

  // ============================================================
  // TEXT THEME
  // ============================================================

  static TextTheme _buildDarkTextTheme() {
    return TextTheme(
      // Display styles - for very large text
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: textWhite,
        letterSpacing: -1.5,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w600,
        color: textWhite,
        letterSpacing: -0.5,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        color: textWhite,
        letterSpacing: -0.25,
        height: 1.22,
      ),

      // Headline styles - for section headers
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textWhite,
        letterSpacing: -0.5,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textWhite,
        letterSpacing: -0.25,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textWhite,
        letterSpacing: -0.25,
        height: 1.33,
      ),

      // Title styles - for cards and list items
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textWhite,
        letterSpacing: -0.25,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.15,
        height: 1.50,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: -0.1,
        height: 1.43,
      ),

      // Body styles - for main content
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMuted,
        letterSpacing: 0.1,
        height: 1.33,
      ),

      // Label styles - for buttons and captions
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        letterSpacing: 0.1,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textMuted,
        letterSpacing: 0.1,
        height: 1.45,
      ),
    );
  }

  // ============================================================
  // LIGHT THEME (Minimal - app focuses on dark theme)
  // ============================================================

  static ThemeData get lightTheme {
    return darkTheme; // Always use dark theme for Lucidlog
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Create gradient background for main screens
  static BoxDecoration createGradientBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF12101A),
          backgroundDarkest,
        ],
      ),
    );
  }

  /// Create card decoration with subtle border
  static BoxDecoration createCardDecoration({
    bool elevated = false,
    bool hasAccent = false,
    Color? accentColor,
  }) {
    return BoxDecoration(
      color: elevated ? cardBackgroundElevated : cardBackground,
      borderRadius: BorderRadius.circular(16.0),
      border: Border.all(
        color: hasAccent
            ? (accentColor ?? primaryPurple).withOpacity(0.3)
            : borderSubtle,
        width: hasAccent ? 1.5 : 1,
      ),
    );
  }

  /// Create accent gradient for buttons and highlights
  static LinearGradient createAccentGradient() {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [primaryPurple, secondaryTeal],
    );
  }

  /// Create warm accent gradient
  static LinearGradient createWarmGradient() {
    return const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [tertiaryOrange, accentPink],
    );
  }

  /// Create stat card decoration
  static BoxDecoration createStatCardDecoration(Color accentColor) {
    return BoxDecoration(
      color: cardBackground,
      borderRadius: BorderRadius.circular(16.0),
      border: Border.all(
        color: accentColor.withOpacity(0.2),
        width: 1,
      ),
    );
  }

  /// Create glass morphism effect
  static BoxDecoration createGlassEffect({
    Color? borderColor,
    double borderOpacity = 0.1,
  }) {
    return BoxDecoration(
      color: cardBackground.withOpacity(0.8),
      borderRadius: BorderRadius.circular(16.0),
      border: Border.all(
        color: (borderColor ?? textWhite).withOpacity(borderOpacity),
        width: 1,
      ),
    );
  }

  /// Get color for dream mood
  static Color getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'joyful':
      case 'excited':
        return accentGreen;
      case 'calm':
      case 'peaceful':
      case 'relaxed':
        return secondaryTeal;
      case 'sad':
      case 'melancholy':
        return Color(0xFF6366F1); // Indigo
      case 'anxious':
      case 'stressed':
        return tertiaryOrange;
      case 'scared':
      case 'fearful':
        return errorColor;
      case 'confused':
        return accentYellow;
      case 'lucid':
      case 'aware':
        return primaryPurple;
      default:
        return textMuted;
    }
  }

  /// Get color for sleep quality
  static Color getSleepQualityColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'excellent':
        return sleepExcellent;
      case 'good':
        return sleepGood;
      case 'fair':
        return sleepFair;
      case 'poor':
        return sleepPoor;
      case 'terrible':
        return sleepTerrible;
      default:
        return textMuted;
    }
  }

  /// Get color for dream category
  static Color getDreamCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'lucid':
        return lucidDreamColor;
      case 'nightmare':
        return nightmareColor;
      case 'recurring':
        return recurringColor;
      case 'prophetic':
        return prophericColor;
      default:
        return normalDreamColor;
    }
  }

  // Status color getters
  static Color getSuccessColor() => successColor;
  static Color getWarningColor() => warningColor;
  static Color getErrorColor() => errorColor;
  static Color getInfoColor() => infoColor;

  // Accent color getters
  static Color getAccentPurple() => primaryPurple;
  static Color getAccentTeal() => secondaryTeal;
  static Color getAccentOrange() => tertiaryOrange;

  /// Dream entry gradient
  static BoxDecoration get dreamEntryGradient {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryPurple.withOpacity(0.15),
          secondaryTeal.withOpacity(0.10),
        ],
      ),
      borderRadius: BorderRadius.circular(16),
    );
  }

  // Legacy color aliases for backward compatibility
  static const Color primaryBurgundy = primaryPurple;
  static const Color wineRed = primaryPurpleLight;
  static const Color darkCrimson = primaryPurpleDark;
  static const Color mutedPurple = primaryPurpleMuted;
  static const Color accentRedPurple = primaryPurple;
  static const Color coralRed = tertiaryOrange;
  static const Color softPink = accentPink;
  static const Color cardDarkBurgundy = cardBackground;
  static const Color cardMediumPurple = cardBackgroundElevated;
  static const Color surfaceDarkPurple = cardBackground;
  static const Color textLightGray = textPrimary;
  static const Color textMediumGray = textSecondary;
  static const Color textDisabledGray = textMuted;
  static const Color borderPurple = borderDefault;
  static const Color dividerPurple = dividerColor;
  static const Color primaryDarkPurple = primaryPurple;
  static const Color primaryDarkBlue = primaryPurpleDark;
  static const Color accentPurple = primaryPurple;
  static const Color accentPurpleLight = primaryPurpleLight;
  static const Color cardDarkPurple = cardBackground;
}
