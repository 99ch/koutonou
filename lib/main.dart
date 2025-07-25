import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core imports
import 'core/theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/user_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/providers/cache_provider.dart';

// Test page
import 'test_core_page_simple.dart';

void main() {
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
        title: 'Koutonou - Test Architecture Core',
        debugShowCheckedModeBanner: false,

        // Application du thème
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,

        // Page de test comme home
        home: const TestCorePage(),
      ),
    );
  }
}
