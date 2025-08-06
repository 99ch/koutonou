import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme.dart';
import 'modules/products/providers/product_provider.dart';
import 'modules/categories/providers/category_provider.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement de PRODUCTION uniquement
  try {
    await dotenv.load(fileName: ".env");
    print('=== DEBUG MAIN.DART ===');
    print('Fichier .env chargé avec succès');
    print('PRESTASHOP_BASE_URL: ${dotenv.env['PRESTASHOP_BASE_URL']}');
    print('PRESTASHOP_API_KEY: ${dotenv.env['PRESTASHOP_API_KEY']}');
    print('Toutes les variables: ${dotenv.env}');
    print('=== END DEBUG MAIN.DART ===');
  } catch (e) {
    debugPrint('Erreur lors du chargement du .env de production: $e');
    throw Exception('ERREUR CRITIQUE: Fichier .env non chargé: $e');
  }

  runApp(const KoutonouApp());
}

class KoutonouApp extends StatelessWidget {
  const KoutonouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: MaterialApp(
        title: 'Koutonou - Boutique E-commerce',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      ),
    );
  }
}
