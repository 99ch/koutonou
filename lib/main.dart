import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Core imports
import 'core/theme.dart';
import 'core/providers/simple_providers.dart';

// Localization imports
import 'localization/app_localizations.dart';
import 'localization/localization_service.dart';
import 'localization/localization_test_page.dart';

// Test pages
import 'test_core_page_simple.dart';
import 'shared_widgets_test_page.dart';
import 'mvp_generation_test_page.dart';
import 'mvp_frontend_demo.dart';

/// Helper pour les logs de debug (seulement en mode debug)
void _debugLog(String message) {
  if (kDebugMode) {
    debugPrint(message);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: '.env');
    _debugLog('Environment variables loaded successfully');
  } catch (e) {
    _debugLog('Failed to load .env file: $e');
    // Continue without .env file - will use defaults
  }

  // Gestion globale des erreurs
  FlutterError.onError = (FlutterErrorDetails details) {
    // En production, on pourrait envoyer à un service de monitoring
    debugPrint('Erreur Flutter: ${details.exception}');
  };

  try {
    // Initialiser la localisation
    await LocalizationService().initialize();

    runApp(const KoutonouApp());
  } catch (e, stackTrace) {
    debugPrint('Erreur lors de l\'initialisation: $e');
    debugPrint('Stack: $stackTrace');

    // Application de fallback en cas d'erreur
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Erreur d\'initialisation'),
                const SizedBox(height: 8),
                Text('$e'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class KoutonouApp extends StatefulWidget {
  const KoutonouApp({super.key});

  @override
  State<KoutonouApp> createState() => _KoutonouAppState();
}

class _KoutonouAppState extends State<KoutonouApp> {
  SimpleAuthProvider? _authProvider;
  GoRouter? _router;
  bool _isInitialized = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    try {
      _debugLog('Initialisation asynchrone...');

      // Petit délai pour s'assurer que le contexte est prêt
      await Future.delayed(const Duration(milliseconds: 100));

      _debugLog('Création de l\'AuthProvider simple...');
      // Créer une version simplifiée de l'AuthProvider pour les tests
      _authProvider = SimpleAuthProvider();
      _debugLog('AuthProvider créé');

      _debugLog('Création du router...');
      _router = _createRouter();
      _debugLog('Router créé');

      setState(() {
        _isInitialized = true;
      });

      _debugLog('Initialisation terminée avec succès');
    } catch (e, stackTrace) {
      _debugLog('Erreur dans l\'initialisation: $e');
      _debugLog('Stack: $stackTrace');
      setState(() {
        _initError = e.toString();
      });
    }
  }

  GoRouter _createRouter() {
    _debugLog('Création du router...');
    return GoRouter(
      initialLocation: '/home',
      debugLogDiagnostics: kDebugMode,
      errorBuilder: (context, state) {
        _debugLog('Erreur de route: ${state.error}');
        return const ErrorPage();
      },
      redirect: (context, state) {
        try {
          final location = state.fullPath;
          _debugLog('Redirection check pour: $location');

          // Si AuthProvider n'est pas encore initialisé, pas de redirection
          if (_authProvider == null) {
            _debugLog('AuthProvider non initialisé, pas de redirection');
            return null;
          }

          // Routes protégées - rediriger si non connecté
          if (_requiresAuth(location) && !_authProvider!.isLoggedIn) {
            _debugLog('Route protégée, redirection vers login');
            return '/auth/login';
          }

          // Routes d'authentification - rediriger si déjà connecté
          if (location!.startsWith('/auth/') && _authProvider!.isLoggedIn) {
            _debugLog('Déjà connecté, redirection vers home');
            return '/home';
          }

          _debugLog('Pas de redirection nécessaire');
          return null;
        } catch (e) {
          _debugLog('Erreur dans redirect: $e');
          return '/home'; // Fallback sécurisé
        }
      },
      refreshListenable: _authProvider,
      routes: _buildRoutes(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Affichage de chargement pendant l'initialisation
    if (!_isInitialized) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_initError == null) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text('Initialisation...'),
                ] else ...[
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Erreur d\'initialisation'),
                  const SizedBox(height: 8),
                  Text(_initError!),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // Application normale une fois initialisée
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider!),
        ChangeNotifierProvider(create: (_) => SimpleUserProvider()),
        ChangeNotifierProvider(create: (_) => SimpleNotificationProvider()),
        ChangeNotifierProvider(create: (_) => SimpleCacheProvider()),
      ],
      child: MaterialApp.router(
        title: 'Koutonou - Architecture Modulaire',
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

        // Configuration du router
        routerConfig: _router!,
      ),
    );
  }

  /// Vérifie si une route nécessite une authentification
  bool _requiresAuth(String? location) {
    if (location == null) return false;
    return location.startsWith('/cart') ||
        location.startsWith('/orders') ||
        location.startsWith('/profile');
  }

  /// Construit les routes
  List<RouteBase> _buildRoutes() {
    _debugLog('Construction des routes...');
    try {
      return [
        // Route racine
        GoRoute(
          path: '/',
          redirect: (context, state) {
            _debugLog('Redirection racine vers /home');
            return '/home';
          },
        ),

        // Route d'accueil
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) {
            _debugLog('Construction de HomePage');
            return const HomePage();
          },
        ),

        // Routes d'authentification
        GoRoute(
          path: '/auth/login',
          name: 'login',
          builder: (context, state) {
            _debugLog('Construction de LoginPage');
            return const LoginPage();
          },
        ),

        GoRoute(
          path: '/auth/register',
          name: 'register',
          builder: (context, state) {
            _debugLog('Construction de RegisterPage');
            return const RegisterPage();
          },
        ),

        // Routes de test
        GoRoute(
          path: '/test/core',
          name: 'test-core',
          builder: (context, state) {
            _debugLog('Construction de TestCorePage');
            return const TestCorePage();
          },
        ),

        GoRoute(
          path: '/test/localization',
          name: 'test-localization',
          builder: (context, state) {
            _debugLog('Construction de LocalizationTestPage');
            return const LocalizationTestPage();
          },
        ),

        GoRoute(
          path: '/test/routing',
          name: 'test-routing',
          builder: (context, state) {
            _debugLog('Construction de RoutingTestPage');
            return const RoutingTestPage();
          },
        ),

        GoRoute(
          path: '/test/mvp-generation',
          name: 'test-mvp-generation',
          builder: (context, state) {
            _debugLog('Construction de MvpGenerationTestPage');
            return const MvpGenerationTestPage();
          },
        ),

        // Routes principales
        GoRoute(
          path: '/products',
          name: 'products',
          builder: (context, state) {
            _debugLog('Construction de ProductsPage');
            return const ProductsPage();
          },
        ),

        GoRoute(
          path: '/cart',
          name: 'cart',
          builder: (context, state) {
            _debugLog('Construction de CartPage');
            return const CartPage();
          },
        ),

        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) {
            _debugLog('Construction de ProfilePage');
            return const ProfilePage();
          },
        ),

        // Route de test pour les widgets partagés
        GoRoute(
          path: '/test/widgets',
          name: 'test-widgets',
          builder: (context, state) {
            _debugLog('Construction de SharedWidgetsTestPage');
            return const SharedWidgetsTestPage();
          },
        ),
      ];
    } catch (e, stackTrace) {
      _debugLog('Erreur lors de la construction des routes: $e');
      _debugLog('Stack: $stackTrace');
      rethrow;
    }
  }
}

// Pages temporaires pour les tests

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
    const RoutingTestPage(),
    const MvpFrontendDemo(),
  ];

  @override
  void initState() {
    super.initState();
    _debugLog('HomePage initialisée');
  }

  @override
  Widget build(BuildContext context) {
    _debugLog('HomePage build() appelé - index: $_selectedIndex');
    try {
      return Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            _debugLog('Navigation vers onglet: $index');
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.language),
              label: 'Localisation',
            ),
            NavigationDestination(icon: Icon(Icons.build), label: 'Core Test'),
            NavigationDestination(
              icon: Icon(Icons.route),
              label: 'Router Test',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart),
              label: 'MVP Demo',
            ),
          ],
        ),
      );
    } catch (e) {
      _debugLog('Erreur dans HomePage build: $e');
      return Scaffold(body: Center(child: Text('Erreur: $e')));
    }
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Page de Connexion'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<SimpleAuthProvider>(
                  context,
                  listen: false,
                ).login('test@example.com', 'password');
                if (context.mounted) {
                  context.go('/home');
                }
              },
              child: const Text('Se connecter (Demo)'),
            ),
            TextButton(
              onPressed: () => context.go('/auth/register'),
              child: const Text('Créer un compte'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Page d\'Inscription'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/auth/login'),
              child: const Text('Retour à la connexion'),
            ),
          ],
        ),
      ),
    );
  }
}

class RoutingTestPage extends StatelessWidget {
  const RoutingTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Router')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Navigation Tests',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            _buildNavigationSection('Authentification', [
              _NavigationButton('Connexion', () => context.go('/auth/login')),
              _NavigationButton(
                'Inscription',
                () => context.go('/auth/register'),
              ),
            ]),

            _buildNavigationSection('Pages principales', [
              _NavigationButton('Produits', () => context.go('/products')),
              _NavigationButton('Panier', () => context.go('/cart')),
              _NavigationButton('Profil', () => context.go('/profile')),
            ]),

            _buildNavigationSection('Tests', [
              _NavigationButton('Core Test', () => context.go('/test/core')),
              _NavigationButton(
                'Localisation Test',
                () => context.go('/test/localization'),
              ),
              _NavigationButton(
                'Widgets Partagés',
                () => context.go('/test/widgets'),
              ),
              _NavigationButton(
                'Génération MVP',
                () => context.go('/test/mvp-generation'),
              ),
            ]),

            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations de route',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Route actuelle: ${GoRouterState.of(context).fullPath}',
                    ),
                    Text(
                      'Authentifié: ${Provider.of<SimpleAuthProvider>(context).isLoggedIn}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationSection(String title, List<Widget> buttons) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: buttons),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _NavigationButton(this.label, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }
}

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produits')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag, size: 64),
            const SizedBox(height: 16),
            const Text('Page Produits'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panier')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart, size: 64),
            const SizedBox(height: 16),
            const Text('Page Panier (Protégée)'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 64),
            const SizedBox(height: 16),
            const Text('Page Profil (Protégée)'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<SimpleAuthProvider>(
                  context,
                  listen: false,
                ).logout();
                if (context.mounted) {
                  context.go('/auth/login');
                }
              },
              child: const Text('Se déconnecter'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('Une erreur s\'est produite'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Version simplifiée de l'AuthProvider pour les tests du router
class SimpleAuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;
  bool get hasError => _errorMessage != null;
  String? get userEmail => _userData?['email'];
  String? get userId => _userData?['id']?.toString();
  String? get userName => _userData?['name'] ?? _userData?['email'];

  /// Initialise le provider (ne fait rien pour la version simple)
  Future<void> initialize() async {
    _debugLog('SimpleAuthProvider initialisé');
    // Pas d'initialisation complexe pour les tests
  }

  /// Connexion simplifiée pour les tests
  Future<void> login(String email, String password) async {
    _debugLog('Connexion simplifiée: $email');
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Simuler un délai de connexion
      await Future.delayed(const Duration(milliseconds: 500));

      // Simuler une connexion réussie
      _userData = {
        'id': 1,
        'email': email,
        'name': 'Utilisateur Test',
        'role': 'user',
      };
      _isLoggedIn = true;
      _debugLog('Connexion réussie');
    } catch (e) {
      _debugLog('Erreur de connexion: $e');
      _errorMessage = 'Erreur de connexion';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Déconnexion simplifiée
  Future<void> logout() async {
    _debugLog('Déconnexion');
    _isLoggedIn = false;
    _userData = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Inscription simplifiée
  Future<void> signup(Map<String, dynamic> customerData) async {
    _debugLog('Inscription simplifiée');
    await login(customerData['email'], 'password');
  }
}
