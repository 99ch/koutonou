// Définition de toutes les routes de l'application Koutonou.
// Centralise les chemins de navigation pour une maintenance facile et une navigation type-safe.
// Supporte les routes paramétrées et les deep links.

/// Définition de toutes les routes de l'application
class AppRoutes {
  // Routes racines
  static const String root = '/';
  static const String home = '/home';
  static const String splash = '/splash';

  // Routes d'authentification
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';

  // Routes de l'utilisateur
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';
  static const String addresses = '/profile/addresses';
  static const String addAddress = '/profile/addresses/add';
  static const String editAddress = '/profile/addresses/:id/edit';

  // Routes des produits
  static const String products = '/products';
  static const String productDetail = '/products/:id';
  static const String productSearch = '/products/search';
  static const String productsByCategory = '/categories/:categoryId/products';

  // Routes des catégories
  static const String categories = '/categories';
  static const String categoryDetail = '/categories/:id';

  // Routes du panier
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String checkoutShipping = '/checkout/shipping';
  static const String checkoutPayment = '/checkout/payment';
  static const String checkoutConfirmation = '/checkout/confirmation';

  // Routes des commandes
  static const String orders = '/orders';
  static const String orderDetail = '/orders/:id';
  static const String orderTracking = '/orders/:id/tracking';

  // Routes des favoris
  static const String favorites = '/favorites';
  static const String wishlist = '/wishlist';

  // Routes de recherche
  static const String search = '/search';
  static const String searchResults = '/search/results';

  // Routes de support
  static const String support = '/support';
  static const String contactUs = '/support/contact';
  static const String faq = '/support/faq';
  static const String helpCenter = '/support/help';

  // Routes de notifications
  static const String notifications = '/notifications';
  static const String notificationDetail = '/notifications/:id';

  // Routes administratives
  static const String about = '/about';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';

  // Routes d'erreur
  static const String notFound = '/404';
  static const String error = '/error';

  /// Méthodes utilitaires pour générer des routes avec paramètres

  /// Génère la route pour le détail d'un produit
  static String productDetailRoute(String productId) {
    return productDetail.replaceAll(':id', productId);
  }

  /// Génère la route pour les produits d'une catégorie
  static String productsByCategoryRoute(String categoryId) {
    return productsByCategory.replaceAll(':categoryId', categoryId);
  }

  /// Génère la route pour le détail d'une catégorie
  static String categoryDetailRoute(String categoryId) {
    return categoryDetail.replaceAll(':id', categoryId);
  }

  /// Génère la route pour le détail d'une commande
  static String orderDetailRoute(String orderId) {
    return orderDetail.replaceAll(':id', orderId);
  }

  /// Génère la route pour le suivi d'une commande
  static String orderTrackingRoute(String orderId) {
    return orderTracking.replaceAll(':id', orderId);
  }

  /// Génère la route pour l'édition d'une adresse
  static String editAddressRoute(String addressId) {
    return editAddress.replaceAll(':id', addressId);
  }

  /// Génère la route pour le détail d'une notification
  static String notificationDetailRoute(String notificationId) {
    return notificationDetail.replaceAll(':id', notificationId);
  }

  /// Vérifie si une route nécessite une authentification
  static bool requiresAuth(String route) {
    const authRequiredRoutes = [
      profile,
      editProfile,
      addresses,
      addAddress,
      cart,
      checkout,
      orders,
      favorites,
      wishlist,
      notifications,
    ];

    return authRequiredRoutes.contains(route) ||
        route.startsWith('/profile/') ||
        route.startsWith('/orders/') ||
        route.startsWith('/checkout/') ||
        route.startsWith('/notifications/');
  }

  /// Vérifie si une route est publique (accessible sans authentification)
  static bool isPublicRoute(String route) {
    const publicRoutes = [
      root,
      home,
      splash,
      login,
      register,
      forgotPassword,
      resetPassword,
      verifyEmail,
      products,
      categories,
      search,
      searchResults,
      support,
      contactUs,
      faq,
      helpCenter,
      about,
      privacyPolicy,
      termsOfService,
      notFound,
      error,
    ];

    return publicRoutes.contains(route) ||
        route.startsWith('/products/') ||
        route.startsWith('/categories/') ||
        route.startsWith('/search/') ||
        route.startsWith('/support/') ||
        route.startsWith('/auth/');
  }

  /// Obtient le nom de la route à partir du path
  static String getRouteName(String path) {
    // Supprimer les paramètres de query
    final cleanPath = path.split('?').first;

    // Routes spéciales
    if (cleanPath == root || cleanPath == home) return 'Accueil';
    if (cleanPath.startsWith('/auth/')) return 'Authentification';
    if (cleanPath.startsWith('/profile/')) return 'Profil';
    if (cleanPath.startsWith('/products/')) return 'Produits';
    if (cleanPath.startsWith('/categories/')) return 'Catégories';
    if (cleanPath.startsWith('/orders/')) return 'Commandes';
    if (cleanPath.startsWith('/checkout/')) return 'Commande';
    if (cleanPath.startsWith('/support/')) return 'Support';

    // Routes simples
    switch (cleanPath) {
      case cart:
        return 'Panier';
      case favorites:
        return 'Favoris';
      case wishlist:
        return 'Liste de souhaits';
      case search:
        return 'Recherche';
      case notifications:
        return 'Notifications';
      case settings:
        return 'Paramètres';
      case about:
        return 'À propos';
      case privacyPolicy:
        return 'Politique de confidentialité';
      case termsOfService:
        return 'Conditions d\'utilisation';
      default:
        return 'Koutonou';
    }
  }

  /// Liste de toutes les routes pour la validation
  static List<String> get allRoutes => [
    root,
    home,
    splash,
    login,
    register,
    forgotPassword,
    resetPassword,
    verifyEmail,
    profile,
    editProfile,
    settings,
    addresses,
    addAddress,
    editAddress,
    products,
    productDetail,
    productSearch,
    productsByCategory,
    categories,
    categoryDetail,
    cart,
    checkout,
    checkoutShipping,
    checkoutPayment,
    checkoutConfirmation,
    orders,
    orderDetail,
    orderTracking,
    favorites,
    wishlist,
    search,
    searchResults,
    support,
    contactUs,
    faq,
    helpCenter,
    notifications,
    notificationDetail,
    about,
    privacyPolicy,
    termsOfService,
    notFound,
    error,
  ];
}
