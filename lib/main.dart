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

      _debugLog('Création de l\'AuthProvider...');
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
        title: 'Koutonou - E-commerce Platform',
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

        GoRoute(
          path: '/orders',
          name: 'orders',
          builder: (context, state) {
            _debugLog('Construction de OrdersPage');
            return const OrdersPage();
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

// Pages principales de l'application

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koutonou'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.person),
            tooltip: 'Profil',
          ),
          IconButton(
            onPressed: () => context.go('/cart'),
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Panier',
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store,
              size: 120,
              color: Colors.blue,
            ),
            SizedBox(height: 24),
            Text(
              'Bienvenue sur Koutonou',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Votre marketplace e-commerce moderne',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 32),
            // TODO: Ajouter des widgets pour navigation vers produits, catégories, etc.
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Produits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Catégories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Compte',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/products');
              break;
            case 2:
              // TODO: Implémenter les catégories
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Catégories - À venir')),
              );
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
      ),
    );
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
            const Icon(Icons.login, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Connexion',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            // TODO: Ajouter formulaire de connexion
            ElevatedButton(
              onPressed: () async {
                await Provider.of<SimpleAuthProvider>(
                  context,
                  listen: false,
                ).login('user@koutonou.com', 'password');
                if (context.mounted) {
                  context.go('/home');
                }
              },
              child: const Text('Connexion Demo'),
            ),
            const SizedBox(height: 16),
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
            const Icon(Icons.person_add, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Inscription',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            // TODO: Ajouter formulaire d'inscription
            const Text('Formulaire d\'inscription à implémenter'),
            const SizedBox(height: 24),
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

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produits')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 80, color: Colors.orange),
            SizedBox(height: 24),
            Text(
              'Catalogue Produits',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Module produits à implémenter'),
            // TODO: Implémenter le catalogue produits
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
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart, size: 80, color: Colors.purple),
            SizedBox(height: 24),
            Text(
              'Mon Panier',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Panier vide - Module à implémenter'),
            // TODO: Implémenter la gestion du panier
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
            const Icon(Icons.person, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Mon Profil',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            // TODO: Afficher informations utilisateur
            Consumer<SimpleAuthProvider>(
              builder: (context, auth, child) {
                return Column(
                  children: [
                    Text('Connecté: ${auth.isLoggedIn ? "Oui" : "Non"}'),
                    if (auth.isLoggedIn) ...[
                      const SizedBox(height: 16),
                      Text('Email: ${auth.userEmail ?? "Non défini"}'),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () async {
                          await auth.logout();
                          if (context.mounted) {
                            context.go('/auth/login');
                          }
                        },
                        child: const Text('Se déconnecter'),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Commandes')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.green),
            SizedBox(height: 24),
            Text(
              'Mes Commandes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Aucune commande - Module à implémenter'),
            // TODO: Implémenter l'historique des commandes
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
            const Icon(Icons.error, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Page non trouvée',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('La page demandée n\'existe pas.'),
            const SizedBox(height: 32),
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

/// AuthProvider simple pour l'authentification
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

  /// Initialise le provider
  Future<void> initialize() async {
    _debugLog('SimpleAuthProvider initialisé');
  }

  /// Connexion
  Future<void> login(String email, String password) async {
    _debugLog('Connexion: $email');
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Simuler un délai de connexion
      await Future.delayed(const Duration(milliseconds: 800));

      _userData = {
        'id': 1,
        'email': email,
        'name': 'Utilisateur Koutonou',
        'role': 'customer',
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

  /// Déconnexion
  Future<void> logout() async {
    _debugLog('Déconnexion');
    _isLoggedIn = false;
    _userData = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Inscription
  Future<void> signup(Map<String, dynamic> customerData) async {
    _debugLog('Inscription');
    await login(customerData['email'], 'password');
  }
}
