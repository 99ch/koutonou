// Définition simplifiée des routes pour l'application Koutonou Production.
// Routes essentielles pour une boutique e-commerce PrestaShop.

/// Définition des routes essentielles de l'application
class AppRoutes {
  // Routes racines
  static const String root = '/';
  static const String home = '/home';

  // Routes des produits (principales)
  static const String products = '/products';
  static const String productDetail = '/products/:id';
  static const String productSearch = '/products/search';

  // Routes des catégories
  static const String categories = '/categories';
  static const String categoryDetail = '/categories/:id';
  static const String categoryCreate = '/categories/create';
  static const String categoryEdit = '/categories/:id/edit';

  // Routes de recherche
  static const String search = '/search';

  // Routes d'erreur
  static const String notFound = '/404';
  static const String error = '/error';

  /// Méthodes utilitaires pour générer des routes avec paramètres

  /// Génère la route pour le détail d'un produit
  static String productDetailRoute(String productId) {
    return productDetail.replaceAll(':id', productId);
  }

  /// Génère la route pour le détail d'une catégorie
  static String categoryDetailRoute(String categoryId) {
    return categoryDetail.replaceAll(':id', categoryId);
  }

  /// Génère la route pour éditer une catégorie
  static String categoryEditRoute(String categoryId) {
    return categoryEdit.replaceAll(':id', categoryId);
  }

  /// Retourne le titre de la page pour une route donnée
  static String getPageTitle(String route) {
    final cleanPath = route.split('?').first;

    if (cleanPath == root || cleanPath == home) return 'Accueil';
    if (cleanPath.startsWith('/products/')) return 'Produits';
    if (cleanPath.startsWith('/categories/')) return 'Catégories';
    if (cleanPath == search) return 'Recherche';

    return 'Koutonou';
  }

  /// Liste des routes essentielles
  static List<String> get allRoutes => [
    root,
    home,
    products,
    productDetail,
    productSearch,
    categories,
    categoryDetail,
    categoryCreate,
    categoryEdit,
    search,
    notFound,
    error,
  ];
}
