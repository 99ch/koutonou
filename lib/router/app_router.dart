// Router principal utilisant GoRouter pour une navigation moderne et type-safe.
// Gère toutes les routes de l'application avec support des deep links, redirections,
// gardes de routes et navigation déclarative. Intègre avec l'authentification.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:koutonou/core/providers/auth_provider.dart';
import 'package:koutonou/core/utils/logger.dart';
import 'package:koutonou/router/routes.dart';
import 'package:koutonou/router/route_guard.dart';

// Pages de l'application
// Note: Les imports des pages spécifiques seront ajoutés au fur et à mesure
// du développement des modules.

/// Configuration du router principal de l'application
class AppRouter {
  static final AppLogger _logger = AppLogger();
  static late final GoRouter _router;

  /// Obtient l'instance du router
  static GoRouter get router => _router;

  /// Initialise le router avec la configuration des routes
  static void initialize(BuildContext context) {
    _router = GoRouter(
      initialLocation: AppRoutes.home,
      debugLogDiagnostics: true,

      // Gestion des erreurs de route
      errorBuilder: (context, state) => ErrorPage(error: state.error),

      // Redirection globale basée sur l'état d'authentification
      redirect: (context, state) {
        return _handleGlobalRedirect(context, state);
      },

      // Listener pour les changements d'état d'authentification
      refreshListenable: Provider.of<AuthProvider>(context, listen: false),

      // Configuration des routes
      routes: _buildRoutes(),
    );

    _logger.info(
      'Router initialisé avec ${_router.configuration.routes.length} routes',
    );
  }

  /// Gère les redirections globales
  static String? _handleGlobalRedirect(
    BuildContext context,
    GoRouterState state,
  ) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final location = state.fullPath;

    _logger.debug('Redirection check pour: $location');

    // Routes de splash - rediriger selon l'état d'auth
    if (location == AppRoutes.splash) {
      if (authProvider.isLoggedIn) {
        return AppRoutes.home;
      } else {
        return AppRoutes.login;
      }
    }

    // Routes d'authentification - rediriger si déjà connecté
    if (location!.startsWith('/auth/') && authProvider.isLoggedIn) {
      return AppRoutes.home;
    }

    // Routes protégées - rediriger si non connecté
    if (AppRoutes.requiresAuth(location) && !authProvider.isLoggedIn) {
      RouteGuard.saveIntendedRouteSync(location);
      return AppRoutes.login;
    }

    return null; // Pas de redirection
  }

  /// Construit la configuration des routes
  static List<RouteBase> _buildRoutes() {
    return [
      // Route racine et accueil
      GoRoute(
        path: AppRoutes.root,
        redirect: (context, state) => AppRoutes.home,
      ),

      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // Routes d'authentification
      ..._buildAuthRoutes(),

      // Routes principales
      ..._buildMainRoutes(),

      // Routes d'erreur
      GoRoute(
        path: AppRoutes.notFound,
        name: '404',
        builder: (context, state) => const NotFoundPage(),
      ),

      GoRoute(
        path: AppRoutes.error,
        name: 'error',
        builder: (context, state) => ErrorPage(
          error: Exception(
            state.uri.queryParameters['message'] ?? 'Erreur inconnue',
          ),
        ),
      ),
    ];
  }

  /// Routes d'authentification
  static List<RouteBase> _buildAuthRoutes() {
    return [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const AuthPage(mode: AuthMode.login),
      ),

      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const AuthPage(mode: AuthMode.register),
      ),

      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) =>
            const AuthPage(mode: AuthMode.forgotPassword),
      ),
    ];
  }

  /// Routes principales de l'application
  static List<RouteBase> _buildMainRoutes() {
    return [
      // Routes des produits
      GoRoute(
        path: AppRoutes.products,
        name: 'products',
        builder: (context, state) => const PlaceholderPage(title: 'Produits'),
        routes: [
          GoRoute(
            path: ':id',
            name: 'product-detail',
            builder: (context, state) =>
                PlaceholderPage(title: 'Produit ${state.pathParameters['id']}'),
          ),
        ],
      ),

      // Routes des catégories
      GoRoute(
        path: AppRoutes.categories,
        name: 'categories',
        builder: (context, state) => const PlaceholderPage(title: 'Catégories'),
        routes: [
          GoRoute(
            path: ':id',
            name: 'category-detail',
            builder: (context, state) => PlaceholderPage(
              title: 'Catégorie ${state.pathParameters['id']}',
            ),
          ),
        ],
      ),

      // Routes du panier (protégées)
      GoRoute(
        path: AppRoutes.cart,
        name: 'cart',
        builder: (context, state) => const PlaceholderPage(title: 'Panier'),
      ),

      // Routes des commandes (protégées)
      GoRoute(
        path: AppRoutes.orders,
        name: 'orders',
        builder: (context, state) => const PlaceholderPage(title: 'Commandes'),
        routes: [
          GoRoute(
            path: ':id',
            name: 'order-detail',
            builder: (context, state) => PlaceholderPage(
              title: 'Commande ${state.pathParameters['id']}',
            ),
          ),
        ],
      ),

      // Routes du profil (protégées)
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const PlaceholderPage(title: 'Profil'),
      ),

      // Route des paramètres
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const PlaceholderPage(title: 'Paramètres'),
      ),
    ];
  }

  /// Navigation helper methods

  /// Navigue vers une route
  static void go(String location) {
    _logger.debug('Navigation vers: $location');
    _router.go(location);
  }

  /// Navigue vers une route nommée
  static void goNamed(
    String name, {
    Map<String, String>? pathParameters,
    Map<String, dynamic>? queryParameters,
  }) {
    _logger.debug('Navigation nommée vers: $name');
    _router.goNamed(
      name,
      pathParameters: pathParameters ?? {},
      queryParameters: queryParameters ?? {},
    );
  }

  /// Pousse une nouvelle route
  static void push(String location) {
    _logger.debug('Push vers: $location');
    _router.push(location);
  }

  /// Pousse une route nommée
  static void pushNamed(
    String name, {
    Map<String, String>? pathParameters,
    Map<String, dynamic>? queryParameters,
  }) {
    _logger.debug('Push nommé vers: $name');
    _router.pushNamed(
      name,
      pathParameters: pathParameters ?? {},
      queryParameters: queryParameters ?? {},
    );
  }

  /// Retour en arrière
  static void pop() {
    _logger.debug('Navigation retour');
    _router.pop();
  }

  /// Remplace la route actuelle
  static void pushReplacement(String location) {
    _logger.debug('Remplacement vers: $location');
    _router.pushReplacement(location);
  }

  /// Va à la route racine
  static void goHome() {
    go(AppRoutes.home);
  }

  /// Va à la page de connexion
  static void goLogin() {
    go(AppRoutes.login);
  }

  /// Va au profil utilisateur
  static void goProfile() {
    go(AppRoutes.profile);
  }

  /// Gère la redirection après connexion réussie
  static Future<void> handlePostLoginRedirect() async {
    final intendedRoute = await RouteGuard.getAndClearIntendedRoute();
    if (intendedRoute != null && intendedRoute != AppRoutes.login) {
      _logger.info('Redirection vers la route sauvegardée: $intendedRoute');
      go(intendedRoute);
    } else {
      _logger.info('Redirection vers l\'accueil après connexion');
      goHome();
    }
  }
}

// Pages temporaires pour les tests

/// Page d'accueil de l'application
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koutonou'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => AppRouter.goNamed('profile'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => AppRouter.goNamed('cart'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section bienvenue
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bienvenue sur Koutonou',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Votre plateforme e-commerce mobile connectée à PrestaShop',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Navigation rapide vers les principales sections
            Text(
              'Navigation rapide',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildQuickNavCard(
                  context,
                  'Produits',
                  Icons.inventory,
                  () => AppRouter.goNamed('products'),
                ),
                _buildQuickNavCard(
                  context,
                  'Catégories',
                  Icons.category,
                  () => AppRouter.goNamed('categories'),
                ),
                _buildQuickNavCard(
                  context,
                  'Commandes',
                  Icons.receipt_long,
                  () => AppRouter.goNamed('orders'),
                ),
                _buildQuickNavCard(
                  context,
                  'Paramètres',
                  Icons.settings,
                  () => AppRouter.goNamed('settings'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Produits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Panier',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              AppRouter.goHome();
              break;
            case 1:
              AppRouter.goNamed('products');
              break;
            case 2:
              AppRouter.goNamed('cart');
              break;
            case 3:
              AppRouter.goNamed('profile');
              break;
          }
        },
      ),
    );
  }

  Widget _buildQuickNavCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Page d'authentification temporaire
class AuthPage extends StatelessWidget {
  final AuthMode mode;

  const AuthPage({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    String title;
    switch (mode) {
      case AuthMode.login:
        title = 'Connexion';
        break;
      case AuthMode.register:
        title = 'Inscription';
        break;
      case AuthMode.forgotPassword:
        title = 'Mot de passe oublié';
        break;
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Page $title'),
            const SizedBox(height: 20),
            if (mode == AuthMode.login) ...[
              ElevatedButton(
                onPressed: () async {
                  // Simuler une connexion
                  await Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).login('test@example.com', 'password');

                  // Redirection intelligente après connexion
                  AppRouter.handlePostLoginRedirect();
                },
                child: const Text('Se connecter (Demo)'),
              ),
              TextButton(
                onPressed: () => AppRouter.goNamed('register'),
                child: const Text('Créer un compte'),
              ),
            ],
            if (mode == AuthMode.register) ...[
              ElevatedButton(
                onPressed: () => AppRouter.goNamed('login'),
                child: const Text('Retour à la connexion'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum AuthMode { login, register, forgotPassword }

/// Page placeholder générique
class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Page $title',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'En cours de développement...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => AppRouter.goHome(),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Page d'erreur 404
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page non trouvée')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text('404', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 8),
            const Text('Page non trouvée'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => AppRouter.goHome(),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Page d'erreur générique
class ErrorPage extends StatelessWidget {
  final Exception? error;

  const ErrorPage({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            const Text('Une erreur s\'est produite'),
            if (error != null) ...[
              const SizedBox(height: 8),
              Text(error.toString(), textAlign: TextAlign.center),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => AppRouter.goHome(),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}
