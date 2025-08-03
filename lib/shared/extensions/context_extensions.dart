// Extensions utiles pour BuildContext
// Fournit des raccourcis pour accéder aux thèmes, navigation, dimensions, etc.

import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  /// === THÈME ET COULEURS ===

  /// Accès rapide au thème
  ThemeData get theme => Theme.of(this);

  /// Accès aux couleurs du thème
  ColorScheme get colors => theme.colorScheme;

  /// Accès à la typographie
  TextTheme get textStyles => theme.textTheme;

  /// Vérifie si le mode sombre est activé
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Vérifie si le mode clair est activé
  bool get isLightMode => theme.brightness == Brightness.light;

  /// === DIMENSIONS ET RESPONSIVE ===

  /// Accès aux informations sur l'écran
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Taille de l'écran
  Size get screenSize => mediaQuery.size;

  /// Largeur de l'écran
  double get screenWidth => screenSize.width;

  /// Hauteur de l'écran
  double get screenHeight => screenSize.height;

  /// Insets (safe area, clavier, etc.)
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// Padding de sécurité (notch, etc.)
  EdgeInsets get viewPadding => mediaQuery.viewPadding;

  /// Vérifie si l'écran est petit (mobile)
  bool get isSmallScreen => screenWidth < 600;

  /// Vérifie si l'écran est moyen (tablette)
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 1200;

  /// Vérifie si l'écran est grand (desktop)
  bool get isLargeScreen => screenWidth >= 1200;

  /// Vérifie si l'orientation est portrait
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  /// Vérifie si l'orientation est paysage
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  /// Hauteur disponible (sans clavier, barres système)
  double get availableHeight =>
      screenHeight - viewInsets.bottom - viewPadding.top - viewPadding.bottom;

  /// Largeur disponible
  double get availableWidth =>
      screenWidth - viewPadding.left - viewPadding.right;

  /// === NAVIGATION ===

  /// Accès au navigateur
  NavigatorState get navigator => Navigator.of(this);

  /// Navigation vers une nouvelle page
  Future<T?> push<T>(Route<T> route) => navigator.push(route);

  /// Navigation avec remplacement
  Future<T?> pushReplacement<T, TO>(Route<T> route, {TO? result}) =>
      navigator.pushReplacement(route, result: result);

  /// Navigation avec suppression de toutes les pages précédentes
  Future<T?> pushAndRemoveUntil<T>(Route<T> route, RoutePredicate predicate) =>
      navigator.pushAndRemoveUntil(route, predicate);

  /// Retour en arrière
  void pop<T>([T? result]) => navigator.pop(result);

  /// Vérifie si on peut revenir en arrière
  bool get canPop => navigator.canPop();

  /// Retour jusqu'à une condition
  void popUntil(RoutePredicate predicate) => navigator.popUntil(predicate);

  /// === LOCALISATION ===

  /// Code de langue actuel
  String get languageCode => Localizations.localeOf(this).languageCode;

  /// Locale actuel
  Locale get locale => Localizations.localeOf(this);

  /// === FOCUS ET CLAVIER ===

  /// Accès au gestionnaire de focus
  FocusScopeNode get focusScope => FocusScope.of(this);

  /// Retire le focus (ferme le clavier)
  void unfocus() => focusScope.unfocus();

  /// Vérifie si le clavier est visible
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  /// === SCAFFOLD ET SNACKBAR ===

  /// Accès au ScaffoldMessenger
  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);

  /// Affiche un SnackBar
  void showSnackBar(SnackBar snackBar) =>
      scaffoldMessenger.showSnackBar(snackBar);

  /// Affiche un SnackBar simple avec message
  void showMessage(
    String message, {
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
      ),
    );
  }

  /// Affiche un message de succès
  void showSuccess(String message) {
    showMessage(
      message,
      backgroundColor: colors.primary,
      textColor: colors.onPrimary,
    );
  }

  /// Affiche un message d'erreur
  void showError(String message) {
    showMessage(
      message,
      backgroundColor: colors.error,
      textColor: colors.onError,
    );
  }

  /// Affiche un message d'avertissement
  void showWarning(String message) {
    showMessage(
      message,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
    );
  }

  /// === DIALOGS ===

  /// Affiche une boîte de dialogue
  Future<T?> showCustomDialog<T>(Widget dialog) {
    return showDialog<T>(context: this, builder: (context) => dialog);
  }

  /// Affiche une boîte de dialogue de confirmation
  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
  }) {
    return showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => pop(false), child: Text(cancelText)),
          TextButton(onPressed: () => pop(true), child: Text(confirmText)),
        ],
      ),
    );
  }

  /// === UTILITAIRES ===

  /// Vérifie si un widget est monté
  bool get mounted => true; // Dans un BuildContext, on est toujours monté

  /// Formate un pourcentage de l'écran
  double widthPercent(double percent) => screenWidth * (percent / 100);
  double heightPercent(double percent) => screenHeight * (percent / 100);

  /// Responsive values basé sur la taille d'écran
  T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    if (isLargeScreen && desktop != null) return desktop;
    if (isMediumScreen && tablet != null) return tablet;
    return mobile;
  }

  /// Padding responsive
  EdgeInsets get responsivePadding {
    return EdgeInsets.symmetric(
      horizontal: responsive(mobile: 16.0, tablet: 24.0, desktop: 32.0),
    );
  }

  /// Margin responsive
  EdgeInsets get responsiveMargin {
    return EdgeInsets.symmetric(
      horizontal: responsive(mobile: 8.0, tablet: 16.0, desktop: 24.0),
    );
  }
}
