// constants.dart
// Defines global constants for the Koutonou application, ensuring secure and
// consistent configurations for API, navigation, and UI. Sensitive data like API
// keys and URLs are loaded from .env file to prevent hardcoding.

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // API configuration
  // Base URLs loaded from .env file for local and production environments
  static String get apiBaseUrlLocal => dotenv.env['API_BASE_URL_LOCAL'] ?? 'http://localhost:8080/prestashop/proxy.php';
  static String get apiBaseUrlProd => dotenv.env['API_BASE_URL_PROD'] ?? 'https://marketplace.koutonou.com/';
  
  // API key loaded from .env file (never hardcoded)
  static String get apiKey => dotenv.env['API_KEY'] ?? 'YOUR_PRESTASHOP_API_KEY';
  
  // Timeout for API requests in milliseconds (30 seconds)
  static const int apiTimeout = 30000;
  
  // Flag to determine if the app is in debug mode (controls logging)
  static const bool isDebugMode = bool.fromEnvironment('dart.vm.product') == false;

  // Pagination settings
  static const int defaultLimit = 20; // Default number of items per page
  static const int defaultOffset = 0; // Default starting offset for pagination
  
  // Navigation routes
  static const String homeRoute = '/'; // Home screen route
  static const String loginRoute = '/login'; // Login screen route
  static const String productListRoute = '/products'; // Product list screen route
  static const String cartRoute = '/cart'; // Cart screen route
  
  // UI constants
  static const double defaultPadding = 16.0; // Default padding for widgets
  static const double cardElevation = 4.0; // Default elevation for card widgets
}