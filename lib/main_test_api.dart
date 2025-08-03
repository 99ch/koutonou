import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'prestashop_api_test_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
    print('✅ Environment variables loaded successfully');
  } catch (e) {
    print('❌ Failed to load .env file: $e');
  }

  runApp(const PrestashopTestApp());
}

class PrestashopTestApp extends StatelessWidget {
  const PrestashopTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrestaShop API Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PrestashopApiTestPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
