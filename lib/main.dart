// main.dart
// Entry point of the Koutonou application. Initializes the app with MaterialApp,
// sets up themes, providers, and navigation. Ensures secure initialization by loading
// environment variables and handling authentication state.

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:koutonou/core/providers/auth_provider.dart';
import 'package:koutonou/core/theme.dart';
import 'package:koutonou/core/utils/constants.dart';
import 'package:koutonou/core/utils/logger.dart';
import 'package:provider/provider.dart';

// Temporary placeholders for views (to be implemented in modules)
class LoginView extends StatelessWidget {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Center(child: Text('Login View (Placeholder)')),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Home View (Placeholder)')),
    );
  }
}

class ProductListView extends StatelessWidget {
  const ProductListView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: const Center(child: Text('Product List View (Placeholder)')),
    );
  }
}

class CartView extends StatelessWidget {
  const CartView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: const Center(child: Text('Cart View (Placeholder)')),
    );
  }
}

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

  // Initialize logger
  final logger = AppLogger();
  logger.info('Starting Koutonou application');

  runApp(const KoutonouApp());
}

class KoutonouApp extends StatelessWidget {
  const KoutonouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Initialize AuthProvider and call its initialize method
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
      ],
      child: MaterialApp(
        title: 'Koutonou',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Use system theme (light/dark)
        // Define navigation routes
        routes: {
          AppConstants.homeRoute: (context) => const HomeView(),
          AppConstants.loginRoute: (context) => const LoginView(),
          AppConstants.productListRoute: (context) => const ProductListView(),
          AppConstants.cartRoute: (context) => const CartView(),
        },
        // Determine initial route based on authentication state
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            if (authProvider.isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            return authProvider.isLoggedIn
                ? const HomeView()
                : const LoginView();
          },
        ),
      ),
    );
  }
}