// Bouton personnalisé avec différents styles et variantes
// Intègre le thème de l'application et les extensions

import 'package:flutter/material.dart';
import '../extensions/extensions.dart';

/// Types de boutons disponibles
enum AppButtonType {
  primary,
  secondary,
  outlined,
  text,
  elevated,
  filled,
  tonal,
}

/// Tailles de boutons disponibles
enum AppButtonSize { small, medium, large }

/// Bouton personnalisé avec styles cohérents
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final double? elevation;
  final Widget? child;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.loading = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.elevation,
    this.child,
  });

  /// Constructeur pour bouton avec icône
  const AppButton.icon({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.loading = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.elevation,
    this.child,
  });

  /// Constructeur pour bouton de chargement
  const AppButton.loading({
    super.key,
    required this.text,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.fullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
    this.elevation,
    this.child,
  }) : loading = true,
       onPressed = null;

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle(context);
    final buttonChild = _buildButtonChild(context);

    Widget button;

    switch (type) {
      case AppButtonType.primary:
        button = ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case AppButtonType.secondary:
        button = OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case AppButtonType.outlined:
        button = OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case AppButtonType.text:
        button = TextButton(
          onPressed: loading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case AppButtonType.elevated:
        button = ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case AppButtonType.filled:
        button = FilledButton(
          onPressed: loading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
      case AppButtonType.tonal:
        button = FilledButton.tonal(
          onPressed: loading ? null : onPressed,
          style: buttonStyle,
          child: buttonChild,
        );
        break;
    }

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  /// Construit le style du bouton
  ButtonStyle _getButtonStyle(BuildContext context) {
    final padding = _getButtonPadding(context);
    final textStyle = _getTextStyle(context);

    return ButtonStyle(
      backgroundColor: backgroundColor != null
          ? WidgetStateProperty.all(backgroundColor)
          : null,
      foregroundColor: foregroundColor != null
          ? WidgetStateProperty.all(foregroundColor)
          : null,
      padding: WidgetStateProperty.all(padding),
      textStyle: WidgetStateProperty.all(textStyle),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
      elevation: elevation != null ? WidgetStateProperty.all(elevation) : null,
    );
  }

  /// Construit le contenu du bouton
  Widget _buildButtonChild(BuildContext context) {
    if (child != null) return child!;

    if (loading) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _getIconSize(),
            height: _getIconSize(),
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                foregroundColor ?? context.colors.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _getIconSize()),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }

    return Text(text);
  }

  /// Calcule le padding selon la taille
  EdgeInsets _getButtonPadding(BuildContext context) {
    if (padding != null) return padding!;

    switch (size) {
      case AppButtonSize.small:
        return context.responsive(
          mobile: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          tablet: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          desktop: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        );
      case AppButtonSize.medium:
        return context.responsive(
          mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          tablet: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          desktop: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        );
      case AppButtonSize.large:
        return context.responsive(
          mobile: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          tablet: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          desktop: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        );
    }
  }

  /// Calcule le style de texte selon la taille
  TextStyle _getTextStyle(BuildContext context) {
    switch (size) {
      case AppButtonSize.small:
        return context.textStyles.labelSmall ?? const TextStyle();
      case AppButtonSize.medium:
        return context.textStyles.labelMedium ?? const TextStyle();
      case AppButtonSize.large:
        return context.textStyles.labelLarge ?? const TextStyle();
    }
  }

  /// Calcule la taille d'icône selon la taille du bouton
  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 20;
      case AppButtonSize.large:
        return 24;
    }
  }
}

/// Bouton flottant personnalisé
class AppFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final bool mini;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.mini = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      mini: mini,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      child: Icon(icon),
    );
  }
}

/// Bouton d'icône personnalisé
class AppIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final double? size;
  final Color? color;
  final AppButtonSize buttonSize;

  const AppIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.size,
    this.color,
    this.buttonSize = AppButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size ?? _getIconSize(context);

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: iconSize),
      tooltip: tooltip,
      color: color,
    );
  }

  double _getIconSize(BuildContext context) {
    switch (buttonSize) {
      case AppButtonSize.small:
        return context.responsive(mobile: 16, tablet: 18, desktop: 20);
      case AppButtonSize.medium:
        return context.responsive(mobile: 20, tablet: 22, desktop: 24);
      case AppButtonSize.large:
        return context.responsive(mobile: 24, tablet: 26, desktop: 28);
    }
  }
}
