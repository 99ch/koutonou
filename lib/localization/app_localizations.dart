// Classe de localisation Flutter pour l'intégration avec flutter_localizations.
// Fournit une interface standardisée pour accéder aux traductions dans les widgets.
// Compatible avec les générateurs de code intl et les outils Flutter.

import 'package:flutter/material.dart';
import 'package:koutonou/localization/localization_service.dart';

/// Délégué de localisation pour l'application Koutonou
class AppLocalizations {
  final Locale locale;
  final LocalizationService _localizationService = LocalizationService();

  AppLocalizations(this.locale);

  /// Instance courante accessible via context
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// Délégué pour la création des localisations
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Langues supportées
  static const List<Locale> supportedLocales =
      LocalizationService.supportedLocales;

  // Méthodes de traduction communes

  /// Nom de l'application
  String get appName => _localizationService.translate('app_name');

  /// Messages généraux
  String get loading => _localizationService.translate('loading');
  String get error => _localizationService.translate('error');
  String get retry => _localizationService.translate('retry');
  String get ok => _localizationService.translate('ok');
  String get cancel => _localizationService.translate('cancel');
  String get yes => _localizationService.translate('yes');
  String get no => _localizationService.translate('no');
  String get save => _localizationService.translate('save');
  String get delete => _localizationService.translate('delete');
  String get edit => _localizationService.translate('edit');
  String get add => _localizationService.translate('add');
  String get search => _localizationService.translate('search');
  String get filter => _localizationService.translate('filter');
  String get sort => _localizationService.translate('sort');
  String get refresh => _localizationService.translate('refresh');
  String get close => _localizationService.translate('close');
  String get back => _localizationService.translate('back');
  String get next => _localizationService.translate('next');
  String get previous => _localizationService.translate('previous');
  String get finish => _localizationService.translate('finish');
  String get continue_ => _localizationService.translate('continue');

  /// Navigation
  String get home => _localizationService.translate('home');
  String get products => _localizationService.translate('products');
  String get categories => _localizationService.translate('categories');
  String get cart => _localizationService.translate('cart');
  String get orders => _localizationService.translate('orders');
  String get account => _localizationService.translate('account');
  String get settings => _localizationService.translate('settings');

  /// Authentification
  String get login => _localizationService.translate('login');
  String get logout => _localizationService.translate('logout');
  String get register => _localizationService.translate('register');
  String get email => _localizationService.translate('email');
  String get password => _localizationService.translate('password');
  String get confirmPassword =>
      _localizationService.translate('confirm_password');
  String get forgotPassword =>
      _localizationService.translate('forgot_password');
  String get resetPassword => _localizationService.translate('reset_password');
  String get firstName => _localizationService.translate('first_name');
  String get lastName => _localizationService.translate('last_name');
  String get phone => _localizationService.translate('phone');
  String get address => _localizationService.translate('address');

  /// E-commerce
  String get price => _localizationService.translate('price');
  String get quantity => _localizationService.translate('quantity');
  String get total => _localizationService.translate('total');
  String get subtotal => _localizationService.translate('subtotal');
  String get shipping => _localizationService.translate('shipping');
  String get tax => _localizationService.translate('tax');
  String get discount => _localizationService.translate('discount');
  String get addToCart => _localizationService.translate('add_to_cart');
  String get removeFromCart =>
      _localizationService.translate('remove_from_cart');
  String get checkout => _localizationService.translate('checkout');
  String get orderConfirmed =>
      _localizationService.translate('order_confirmed');
  String get orderCancelled =>
      _localizationService.translate('order_cancelled');
  String get outOfStock => _localizationService.translate('out_of_stock');
  String get inStock => _localizationService.translate('in_stock');

  /// Messages d'erreur
  String get errorGeneral => _localizationService.translate('error_general');
  String get errorNetwork => _localizationService.translate('error_network');
  String get errorServerError =>
      _localizationService.translate('error_server_error');
  String get errorNotFound => _localizationService.translate('error_not_found');
  String get errorUnauthorized =>
      _localizationService.translate('error_unauthorized');
  String get errorForbidden =>
      _localizationService.translate('error_forbidden');
  String get errorTimeout => _localizationService.translate('error_timeout');
  String get errorInvalidEmail =>
      _localizationService.translate('error_invalid_email');
  String get errorInvalidPassword =>
      _localizationService.translate('error_invalid_password');
  String get errorPasswordMismatch =>
      _localizationService.translate('error_password_mismatch');
  String get errorFieldRequired =>
      _localizationService.translate('error_field_required');

  /// Messages de succès
  String get successGeneral =>
      _localizationService.translate('success_general');
  String get successSaved => _localizationService.translate('success_saved');
  String get successDeleted =>
      _localizationService.translate('success_deleted');
  String get successUpdated =>
      _localizationService.translate('success_updated');
  String get successLoggedIn =>
      _localizationService.translate('success_logged_in');
  String get successLoggedOut =>
      _localizationService.translate('success_logged_out');
  String get successRegistered =>
      _localizationService.translate('success_registered');

  /// États vides
  String get emptyCart => _localizationService.translate('empty_cart');
  String get emptyOrders => _localizationService.translate('empty_orders');
  String get emptyProducts => _localizationService.translate('empty_products');
  String get emptySearch => _localizationService.translate('empty_search');
  String get emptyFavorites =>
      _localizationService.translate('empty_favorites');

  /// Formatage avec paramètres
  String welcomeMessage(String name) => _localizationService.translate(
    'welcome_message',
    parameters: {'name': name},
  );

  String itemsInCart(int count) => _localizationService.translate(
    'items_in_cart',
    parameters: {'count': count.toString()},
  );

  String priceWithCurrency(double amount, String currency) =>
      _localizationService.translate(
        'price_with_currency',
        parameters: {'amount': amount.toString(), 'currency': currency},
      );

  String orderNumber(String number) => _localizationService.translate(
    'order_number',
    parameters: {'number': number},
  );

  /// Accès direct au service pour des traductions custom
  String translate(String key, {Map<String, dynamic>? parameters}) {
    return _localizationService.translate(key, parameters: parameters);
  }
}

/// Délégué de localisation privé
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final appLocalizations = AppLocalizations(locale);

    // S'assurer que le service est initialisé avec la bonne langue
    final localizationService = LocalizationService();
    await localizationService.changeLanguage(locale.languageCode);

    return appLocalizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Extension pour simplifier l'accès aux localisations dans les widgets
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n {
    return AppLocalizations.of(this) ?? AppLocalizations(const Locale('fr'));
  }
}
