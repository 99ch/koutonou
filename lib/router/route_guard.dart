// Garde de routes pour protéger l'accès aux pages nécessitant une authentification.
// Gère les redirections, les vérifications de permissions et la logique de navigation conditionnelle.
// Intègre avec le système d'authentification pour une sécurité robuste.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koutonou/core/providers/auth_provider.dart';
import 'package:koutonou/core/utils/logger.dart';
import 'package:koutonou/router/routes.dart';

/// Garde de routes pour contrôler l'accès aux pages
class RouteGuard {
  static final AppLogger _logger = AppLogger();
  
  /// Vérifie si l'utilisateur peut accéder à une route
  static bool canAccess(BuildContext context, String route) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Loguer la tentative d'accès
    _logger.debug('Vérification d\'accès pour la route: $route');
    
    // Routes publiques toujours accessibles
    if (AppRoutes.isPublicRoute(route)) {
      _logger.debug('Route publique autorisée: $route');
      return true;
    }
    
    // Routes nécessitant une authentification
    if (AppRoutes.requiresAuth(route)) {
      final isAuthenticated = authProvider.isAuthenticated;
      _logger.debug('Route protégée - Utilisateur authentifié: $isAuthenticated');
      return isAuthenticated;
    }
    
    // Par défaut, autoriser l'accès
    return true;
  }
  
  /// Obtient la route de redirection appropriée
  static String getRedirectRoute(BuildContext context, String intendedRoute) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    _logger.info('Redirection nécessaire depuis: $intendedRoute');
    
    // Si l'utilisateur n'est pas authentifié et tente d'accéder à une route protégée
    if (AppRoutes.requiresAuth(intendedRoute) && !authProvider.isAuthenticated) {
      _logger.info('Redirection vers la page de connexion');
      return AppRoutes.login;
    }
    
    // Si l'utilisateur est authentifié et tente d'accéder aux pages d'auth
    if (authProvider.isAuthenticated && intendedRoute.startsWith('/auth/')) {
      _logger.info('Utilisateur déjà authentifié, redirection vers l\'accueil');
      return AppRoutes.home;
    }
    
    // Aucune redirection nécessaire
    return intendedRoute;
  }
  
  /// Vérifie et applique la garde de route
  static RouteGuardResult guard(BuildContext context, String route) {
    final canAccess = RouteGuard.canAccess(context, route);
    
    if (canAccess) {
      return RouteGuardResult.allow(route);
    } else {
      final redirectRoute = getRedirectRoute(context, route);
      return RouteGuardResult.redirect(redirectRoute, route);
    }
  }
  
  /// Sauvegarde la route de destination pour redirection après connexion
  static void saveIntendedRoute(String route) {
    if (AppRoutes.requiresAuth(route)) {
      _logger.debug('Sauvegarde de la route de destination: $route');
      // TODO: Sauvegarder dans le cache ou les préférences
      // CacheService().set('intended_route', route);
    }
  }
  
  /// Récupère et efface la route de destination sauvegardée
  static String? getAndClearIntendedRoute() {
    // TODO: Récupérer depuis le cache
    // final intendedRoute = CacheService().get<String>('intended_route');
    // CacheService().remove('intended_route');
    // return intendedRoute;
    return null;
  }
  
  /// Vérifie les permissions spéciales pour certaines routes
  static bool hasSpecialPermission(BuildContext context, String route) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Exemple: routes d'administration
    if (route.startsWith('/admin/')) {
      return authProvider.isAuthenticated && authProvider.user?.isAdmin == true;
    }
    
    // Exemple: routes de modération
    if (route.startsWith('/moderate/')) {
      return authProvider.isAuthenticated && 
             (authProvider.user?.isAdmin == true || authProvider.user?.isModerator == true);
    }
    
    return true;
  }
  
  /// Gère la navigation avec vérification de garde
  static Future<bool> navigateTo(BuildContext context, String route) async {
    final guardResult = guard(context, route);
    
    switch (guardResult.action) {
      case RouteGuardAction.allow:
        _logger.info('Navigation autorisée vers: $route');
        Navigator.of(context).pushNamed(route);
        return true;
        
      case RouteGuardAction.redirect:
        _logger.info('Redirection de $route vers ${guardResult.redirectRoute}');
        saveIntendedRoute(guardResult.originalRoute!);
        Navigator.of(context).pushNamedAndRemoveUntil(
          guardResult.redirectRoute!,
          (route) => false,
        );
        return false;
        
      case RouteGuardAction.block:
        _logger.warning('Accès bloqué pour la route: $route');
        // Afficher un message d'erreur ou une page d'accès refusé
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Accès non autorisé à cette page'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
    }
  }
  
  /// Navigation avec remplacement
  static Future<bool> navigateAndReplace(BuildContext context, String route) async {
    final guardResult = guard(context, route);
    
    if (guardResult.action == RouteGuardAction.allow) {
      Navigator.of(context).pushReplacementNamed(route);
      return true;
    } else if (guardResult.action == RouteGuardAction.redirect) {
      Navigator.of(context).pushReplacementNamed(guardResult.redirectRoute!);
      return false;
    }
    
    return false;
  }
}

/// Actions possibles de la garde de route
enum RouteGuardAction {
  allow,    // Autoriser l'accès
  redirect, // Rediriger vers une autre route
  block,    // Bloquer complètement l'accès
}

/// Résultat de la vérification de garde de route
class RouteGuardResult {
  final RouteGuardAction action;
  final String? redirectRoute;
  final String? originalRoute;
  final String? message;
  
  const RouteGuardResult._({
    required this.action,
    this.redirectRoute,
    this.originalRoute,
    this.message,
  });
  
  /// Créer un résultat d'autorisation
  factory RouteGuardResult.allow(String route) {
    return RouteGuardResult._(action: RouteGuardAction.allow);
  }
  
  /// Créer un résultat de redirection
  factory RouteGuardResult.redirect(String redirectTo, String originalRoute) {
    return RouteGuardResult._(
      action: RouteGuardAction.redirect,
      redirectRoute: redirectTo,
      originalRoute: originalRoute,
    );
  }
  
  /// Créer un résultat de blocage
  factory RouteGuardResult.block(String route, {String? message}) {
    return RouteGuardResult._(
      action: RouteGuardAction.block,
      originalRoute: route,
      message: message,
    );
  }
}

/// Extension pour faciliter la navigation avec garde
extension GuardedNavigation on BuildContext {
  /// Navigation avec garde intégrée
  Future<bool> pushGuarded(String route) {
    return RouteGuard.navigateTo(this, route);
  }
  
  /// Navigation avec remplacement et garde
  Future<bool> pushReplacementGuarded(String route) {
    return RouteGuard.navigateAndReplace(this, route);
  }
  
  /// Vérification simple de garde
  bool canAccess(String route) {
    return RouteGuard.canAccess(this, route);
  }
}
