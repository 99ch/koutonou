// Provides comprehensive theming for the Koutonou application.
// Includes light/dark themes, custom color schemes, typography, and component styles
// specifically designed for e-commerce with West African cultural elements.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Main theme configuration class
class AppTheme {
  // Prevent instantiation
  AppTheme._();

  /// Primary brand colors inspired by West African culture
  static const Color primaryColor = Color(0xFF1B4332); // Deep forest green
  static const Color primaryVariant = Color(0xFF2D5A3D); // Medium forest green
  static const Color secondaryColor = Color(0xFFFF8500); // Vibrant orange
  static const Color secondaryVariant = Color(0xFFE6720A); // Dark orange

  /// Accent colors for highlights and CTAs
  static const Color accentColor = Color(0xFFFFD60A); // Golden yellow
  static const Color successColor = Color(0xFF52B788); // Fresh green
  static const Color warningColor = Color(0xFFFFB700); // Amber
  static const Color errorColor = Color(0xFFDC2626); // Red
  static const Color infoColor = Color(0xFF0284C7); // Blue

  /// Neutral colors for backgrounds and text
  static const Color backgroundColor = Color(0xFFFAFAFA); // Very light gray
  static const Color surfaceColor = Color(0xFFFFFFFF); // Pure white
  static const Color cardColor = Color(0xFFF8F9FA); // Light gray
  static const Color dividerColor = Color(0xFFE5E5E5); // Medium gray

  /// Text colors
  static const Color primaryTextColor = Color(0xFF1F2937); // Dark gray
  static const Color secondaryTextColor = Color(0xFF6B7280); // Medium gray
  static const Color hintTextColor = Color(0xFF9CA3AF); // Light gray
  static const Color onPrimaryTextColor = Color(0xFFFFFFFF); // White

  /// Shadow colors
  static const Color shadowColor = Color(0x1A000000); // 10% black
  static const Color elevationShadow = Color(0x0F000000); // 6% black

  /// Product category colors (for visual distinction)
  static const Map<String, Color> categoryColors = {
    'electronics': Color(0xFF3B82F6), // Blue
    'fashion': Color(0xFFEC4899), // Pink
    'beauty': Color(0xFF8B5CF6), // Purple
    'home': Color(0xFF10B981), // Emerald
    'sports': Color(0xFFF59E0B), // Amber
    'books': Color(0xFF6366F1), // Indigo
    'food': Color(0xFFEF4444), // Red
    'default': primaryColor,
  };

  /// Light Theme Configuration
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color Scheme (Fixed deprecations)
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      primaryContainer: Color(0xFFE8F5E8),
      secondary: secondaryColor,
      secondaryContainer: Color(0xFFFFE8CC),
      surface: surfaceColor,
      surfaceContainerHighest: cardColor,
      error: errorColor,
      onPrimary: onPrimaryTextColor,
      onSecondary: onPrimaryTextColor,
      onSurface: primaryTextColor,
      onError: onPrimaryTextColor,
      outline: dividerColor,
      shadow: shadowColor,
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: surfaceColor,
      foregroundColor: primaryTextColor,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: TextStyle(
        color: primaryTextColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: primaryTextColor, size: 24),
    ),

    // Navigation Bar Theme (Fixed MaterialState deprecation)
    navigationBarTheme: NavigationBarThemeData(
      elevation: 8,
      backgroundColor: surfaceColor,
      indicatorColor: primaryColor.withValues(alpha: 0.1),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: primaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
        }
        return const TextStyle(
          color: secondaryTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primaryColor, size: 24);
        }
        return const IconThemeData(color: secondaryTextColor, size: 24);
      }),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      elevation: 2,
      color: surfaceColor,
      surfaceTintColor: Colors.transparent,
      shadowColor: elevationShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryTextColor,
        elevation: 2,
        shadowColor: elevationShadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.25,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      labelStyle: const TextStyle(
        color: secondaryTextColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(
        color: hintTextColor,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondaryColor,
      foregroundColor: onPrimaryTextColor,
      elevation: 4,
      shape: CircleBorder(),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: cardColor,
      selectedColor: primaryColor.withValues(alpha: 0.1),
      disabledColor: dividerColor,
      labelStyle: const TextStyle(
        color: primaryTextColor,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: const TextStyle(
        color: primaryColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surfaceColor,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceColor,
      elevation: 8,
      shadowColor: elevationShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: const TextStyle(
        color: primaryTextColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: secondaryTextColor,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
    ),

    // Switch Theme (Fixed MaterialState deprecation)
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return Colors.grey[300];
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primaryColor.withValues(alpha: 0.3);
        }
        return Colors.grey[400];
      }),
    ),

    // Typography
    textTheme: _buildTextTheme(Brightness.light),
  );

  /// Dark Theme Configuration
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Color Scheme (Fixed deprecations)
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF4ADE80), // Lighter green for dark mode
      primaryContainer: Color(0xFF1B4332),
      secondary: secondaryColor,
      secondaryContainer: Color(0xFF7C2D12),
      surface: Color(0xFF1F2937),
      surfaceContainerHighest: Color(0xFF374151),
      error: Color(0xFFF87171),
      onPrimary: Color(0xFF000000),
      onSecondary: onPrimaryTextColor,
      onSurface: Color(0xFFF9FAFB),
      onError: Color(0xFF000000),
      outline: Color(0xFF4B5563),
      shadow: Color(0x33000000),
    ),

    // App Bar Theme (Dark)
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFF1F2937),
      foregroundColor: Color(0xFFF9FAFB),
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: Color(0xFFF9FAFB),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: Color(0xFFF9FAFB), size: 24),
    ),

    // Navigation Bar Theme (Dark) - Fixed MaterialState deprecation
    navigationBarTheme: NavigationBarThemeData(
      elevation: 8,
      backgroundColor: Color(0xFF1F2937),
      indicatorColor: Color(0xFF4ADE80).withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: Color(0xFF4ADE80),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
        }
        return const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Color(0xFF4ADE80), size: 24);
        }
        return const IconThemeData(color: Color(0xFF9CA3AF), size: 24);
      }),
    ),

    // Card Theme (Dark)
    cardTheme: CardThemeData(
      elevation: 2,
      color: const Color(0xFF1F2937),
      surfaceTintColor: Colors.transparent,
      shadowColor: const Color(0x33000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Typography (Dark)
    textTheme: _buildTextTheme(Brightness.dark),
  );

  /// Build custom text theme
  static TextTheme _buildTextTheme(Brightness brightness) {
    final Color textColor = brightness == Brightness.light
        ? primaryTextColor
        : const Color(0xFFF9FAFB);
    final Color secondaryText = brightness == Brightness.light
        ? secondaryTextColor
        : const Color(0xFFD1D5DB);

    return TextTheme(
      // Display styles
      displayLarge: TextStyle(
        color: textColor,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.8,
        height: 1.3,
      ),
      displaySmall: TextStyle(
        color: textColor,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        height: 1.3,
      ),

      // Headline styles
      headlineLarge: TextStyle(
        color: textColor,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
        height: 1.4,
      ),
      headlineMedium: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
      ),
      headlineSmall: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
      ),

      // Title styles
      titleLarge: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      titleMedium: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.3,
      ),

      // Body styles
      bodyLarge: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: secondaryText,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.4,
      ),

      // Label styles
      labelLarge: TextStyle(
        color: textColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        color: textColor,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.3,
      ),
      labelSmall: TextStyle(
        color: secondaryText,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.2,
      ),
    );
  }
}

// Custom theme extensions for e-commerce specific styling
class ECommerceTheme {
  // Product card styling
  static const BoxDecoration productCardDecoration = BoxDecoration(
    color: AppTheme.surfaceColor,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    boxShadow: [
      BoxShadow(
        color: AppTheme.elevationShadow,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );

  // Price styling
  static const TextStyle priceTextStyle = TextStyle(
    color: AppTheme.primaryColor,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  static const TextStyle discountPriceStyle = TextStyle(
    color: AppTheme.secondaryTextColor,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    decoration: TextDecoration.lineThrough,
  );

  // Badge styling
  static const BoxDecoration saleBadgeDecoration = BoxDecoration(
    color: AppTheme.errorColor,
    borderRadius: BorderRadius.all(Radius.circular(6)),
  );

  static const BoxDecoration newBadgeDecoration = BoxDecoration(
    color: AppTheme.successColor,
    borderRadius: BorderRadius.all(Radius.circular(6)),
  );

  // Rating styling
  static const Color ratingStarColor = AppTheme.accentColor;
  static const Color ratingStarDisabledColor = AppTheme.dividerColor;

  // Category color helper
  static Color getCategoryColor(String category) {
    return AppTheme.categoryColors[category.toLowerCase()] ??
        AppTheme.categoryColors['default']!;
  }

  // Animation durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Common spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Common border radius
  static const double borderRadiusS = 8.0;
  static const double borderRadiusM = 12.0;
  static const double borderRadiusL = 16.0;
  static const double borderRadiusXL = 24.0;
}
