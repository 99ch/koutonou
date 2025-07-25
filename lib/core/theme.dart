/// theme.dart
/// Defines light and dark themes for the Koutonou application, ensuring consistent
/// styling across the UI. Uses Material Design principles and complies with accessibility
/// guidelines (e.g., sufficient contrast). Integrates with AppConstants for standardized
/// values like padding and elevation.

import 'package:flutter/material.dart';
import 'package:koutonou/core/utils/constants.dart';

class AppTheme {
  /// Light theme configuration
  static final ThemeData lightTheme = ThemeData(
    /// Primary color scheme
    primarySwatch: Colors.blue,
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      surface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black87,
      error: Colors.red,
    ),
    /// App bar styling
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: AppConstants.cardElevation,
    ),
    /// Card styling
    cardTheme: const CardThemeData(
      elevation: AppConstants.cardElevation,
      margin: EdgeInsets.all(AppConstants.defaultPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
    ),
    /// Text styling
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
    ),
    /// Button styling
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding * 2,
          vertical: AppConstants.defaultPadding,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    ),
    /// Input field styling
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.all(AppConstants.defaultPadding),
    ),
    /// Ensure accessibility (e.g., sufficient contrast)
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  /// Dark theme configuration
  static final ThemeData darkTheme = ThemeData(
    /// Primary color scheme
    primarySwatch: Colors.blue,
    colorScheme: const ColorScheme.dark(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
      surface: Colors.grey,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white70,
      error: Colors.redAccent,
    ),
    /// App bar styling
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: AppConstants.cardElevation,
    ),
    /// Card styling
    cardTheme: const CardThemeData(
      elevation: AppConstants.cardElevation,
      margin: EdgeInsets.all(AppConstants.defaultPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
    ),
    /// Text styling
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white70),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
    ),
    /// Button styling
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding * 2,
          vertical: AppConstants.defaultPadding,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    ),
    /// Input field styling
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.all(AppConstants.defaultPadding),
    ),
    /// Ensure accessibility
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}