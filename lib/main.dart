import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Core imports
import 'core/theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/providers/cache_provider.dart';

// Localization imports
import 'localization/app_localizations.dart';
import 'localization/localization_service.dart';
import 'localization/localization_test_page.dart';

// Test pages
import 'test_core_page_simple.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser la localisation
  await LocalizationService().initialize();

  runApp(const KoutonouApp());
}

class KoutonouApp extends StatelessWidget {
  const KoutonouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => CacheProvider()),
      ],
      child: MaterialApp(
        title: 'Koutonou - Test Architecture',
        debugShowCheckedModeBanner: false,

        // Configuration de localisation
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: Locale(LocalizationService().currentLanguageCode),

        // Application du thème
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        // Page d'accueil avec navigation
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const LocalizationTestPage(),
    const TestCorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.language),
            label: 'Localisation',
          ),
          NavigationDestination(
            icon: const Icon(Icons.build),
            label: 'Core Test',
          ),
        ],
      ),
    );
  }
}
