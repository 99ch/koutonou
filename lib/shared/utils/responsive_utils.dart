// Utilitaires pour la gestion responsive
// Fournit des classes et méthodes pour créer des interfaces adaptatives

import 'package:flutter/material.dart';

/// Énumération des tailles d'écran
enum ScreenSize { mobile, tablet, desktop }

/// Classe utilitaire pour la gestion responsive
class ResponsiveUtils {
  // Breakpoints par défaut
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  /// Obtient la taille d'écran actuelle
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return ScreenSize.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenSize.tablet;
    } else {
      return ScreenSize.desktop;
    }
  }

  /// Vérifie si l'écran est mobile
  static bool isMobile(BuildContext context) {
    return getScreenSize(context) == ScreenSize.mobile;
  }

  /// Vérifie si l'écran est tablette
  static bool isTablet(BuildContext context) {
    return getScreenSize(context) == ScreenSize.tablet;
  }

  /// Vérifie si l'écran est desktop
  static bool isDesktop(BuildContext context) {
    return getScreenSize(context) == ScreenSize.desktop;
  }

  /// Retourne une valeur selon la taille d'écran
  static T valueForScreen<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.mobile:
        return mobile;
    }
  }

  /// Calcule le nombre de colonnes pour une grille responsive
  static int getGridColumns(
    BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
  }) {
    return valueForScreen(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );
  }

  /// Calcule le padding responsive
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    return valueForScreen(
      context,
      mobile: mobile ?? const EdgeInsets.all(16),
      tablet: tablet ?? const EdgeInsets.all(24),
      desktop: desktop ?? const EdgeInsets.all(32),
    );
  }

  /// Calcule la taille de police responsive
  static double getResponsiveFontSize(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    return valueForScreen(
      context,
      mobile: mobile ?? 14,
      tablet: tablet ?? 16,
      desktop: desktop ?? 18,
    );
  }

  /// Calcule la largeur maximale pour le contenu
  static double getContentMaxWidth(BuildContext context) {
    return valueForScreen(
      context,
      mobile: double.infinity,
      tablet: 800,
      desktop: 1200,
    );
  }

  /// Obtient les dimensions d'écran
  static Size getScreenDimensions(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  /// Calcule un pourcentage de la largeur d'écran
  static double widthPercent(BuildContext context, double percent) {
    return MediaQuery.of(context).size.width * (percent / 100);
  }

  /// Calcule un pourcentage de la hauteur d'écran
  static double heightPercent(BuildContext context, double percent) {
    return MediaQuery.of(context).size.height * (percent / 100);
  }

  /// Vérifie si l'orientation est portrait
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Vérifie si l'orientation est paysage
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Obtient la densité de pixels
  static double getPixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  /// Vérifie si l'écran a une haute densité
  static bool isHighDensity(BuildContext context) {
    return getPixelRatio(context) > 2.0;
  }

  /// Calcule la taille d'icône responsive
  static double getIconSize(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    return valueForScreen(
      context,
      mobile: mobile ?? 24,
      tablet: tablet ?? 28,
      desktop: desktop ?? 32,
    );
  }

  /// Calcule l'espacement responsive
  static double getSpacing(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    return valueForScreen(
      context,
      mobile: mobile ?? 8,
      tablet: tablet ?? 12,
      desktop: desktop ?? 16,
    );
  }
}

/// Widget responsive qui adapte son contenu selon la taille d'écran
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveUtils.valueForScreen(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}

/// Builder responsive qui fournit la taille d'écran au builder
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSize screenSize) builder;

  const ResponsiveBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveUtils.getScreenSize(context);
    return builder(context, screenSize);
  }
}

/// Layout responsive avec sidebar
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? sidebar;
  final bool showSidebarOnTablet;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.sidebar,
    this.showSidebarOnTablet = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = ResponsiveUtils.getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.desktop:
        if (sidebar != null && desktop != null) {
          return Row(
            children: [
              sidebar!,
              Expanded(child: desktop!),
            ],
          );
        }
        return desktop ?? tablet ?? mobile;

      case ScreenSize.tablet:
        if (showSidebarOnTablet && sidebar != null && tablet != null) {
          return Row(
            children: [
              sidebar!,
              Expanded(child: tablet!),
            ],
          );
        }
        return tablet ?? mobile;

      case ScreenSize.mobile:
        return mobile;
    }
  }
}

/// Mixin pour ajouter des capacités responsive aux widgets
mixin ResponsiveMixin<T extends StatefulWidget> on State<T> {
  ScreenSize get screenSize => ResponsiveUtils.getScreenSize(context);
  bool get isMobile => ResponsiveUtils.isMobile(context);
  bool get isTablet => ResponsiveUtils.isTablet(context);
  bool get isDesktop => ResponsiveUtils.isDesktop(context);
  bool get isPortrait => ResponsiveUtils.isPortrait(context);
  bool get isLandscape => ResponsiveUtils.isLandscape(context);

  U valueForScreen<U>({required U mobile, U? tablet, U? desktop}) {
    return ResponsiveUtils.valueForScreen(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}
