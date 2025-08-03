// Boîtes de dialogue personnalisées
// Fournit des dialogs cohérents avec le design system

import 'package:flutter/material.dart';
import '../extensions/extensions.dart';
import 'app_button.dart';

/// Types de dialogues
enum DialogType { info, success, warning, error, confirmation, custom }

/// Dialogue personnalisé
class CustomDialog extends StatelessWidget {
  final DialogType type;
  final String? title;
  final String? message;
  final Widget? content;
  final List<DialogAction>? actions;
  final bool dismissible;
  final IconData? icon;
  final Color? iconColor;

  const CustomDialog({
    super.key,
    this.type = DialogType.info,
    this.title,
    this.message,
    this.content,
    this.actions,
    this.dismissible = true,
    this.icon,
    this.iconColor,
  });

  /// Dialogue d'information
  const CustomDialog.info({
    super.key,
    required this.title,
    required this.message,
    this.actions,
    this.dismissible = true,
  }) : type = DialogType.info,
       content = null,
       icon = Icons.info_outline,
       iconColor = null;

  /// Dialogue de succès
  const CustomDialog.success({
    super.key,
    required this.title,
    required this.message,
    this.actions,
    this.dismissible = true,
  }) : type = DialogType.success,
       content = null,
       icon = Icons.check_circle_outline,
       iconColor = null;

  /// Dialogue d'avertissement
  const CustomDialog.warning({
    super.key,
    required this.title,
    required this.message,
    this.actions,
    this.dismissible = true,
  }) : type = DialogType.warning,
       content = null,
       icon = Icons.warning_amber_outlined,
       iconColor = null;

  /// Dialogue d'erreur
  const CustomDialog.error({
    super.key,
    required this.title,
    required this.message,
    this.actions,
    this.dismissible = true,
  }) : type = DialogType.error,
       content = null,
       icon = Icons.error_outline,
       iconColor = null;

  /// Dialogue de confirmation
  const CustomDialog.confirmation({
    super.key,
    required this.title,
    required this.message,
    this.actions,
    this.dismissible = true,
  }) : type = DialogType.confirmation,
       content = null,
       icon = Icons.help_outline,
       iconColor = null;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: context.responsive(
            mobile: context.screenWidth * 0.9,
            tablet: 400,
            desktop: 450,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            if (title != null || message != null || content != null) ...[
              const SizedBox(height: 16),
              _buildContent(context),
            ],
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildActions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if (icon == null && title == null) return const SizedBox.shrink();

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 28, color: iconColor ?? _getTypeColor(context)),
          const SizedBox(width: 12),
        ],
        if (title != null) ...[
          Expanded(
            child: Text(
              title!,
              style: context.textStyles.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        if (dismissible) ...[
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            iconSize: 20,
          ),
        ],
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (content != null) return content!;

    if (message != null) {
      return Text(
        message!,
        style: context.textStyles.bodyLarge,
        textAlign: TextAlign.left,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActions(BuildContext context) {
    if (actions == null || actions!.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: actions!.map((action) {
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: AppButton(
            text: action.text,
            onPressed: action.onPressed != null
                ? () {
                    action.onPressed!();
                    if (action.closeDialog) {
                      Navigator.of(context).pop();
                    }
                  }
                : null,
            type: action.isPrimary ? AppButtonType.primary : AppButtonType.text,
            size: AppButtonSize.medium,
          ),
        );
      }).toList(),
    );
  }

  Color _getTypeColor(BuildContext context) {
    switch (type) {
      case DialogType.info:
        return context.colors.primary;
      case DialogType.success:
        return Colors.green;
      case DialogType.warning:
        return Colors.orange;
      case DialogType.error:
        return context.colors.error;
      case DialogType.confirmation:
        return context.colors.primary;
      case DialogType.custom:
        return context.colors.onSurface;
    }
  }

  /// Méthode statique pour afficher le dialogue
  static Future<T?> show<T>(BuildContext context, CustomDialog dialog) {
    return showDialog<T>(
      context: context,
      barrierDismissible: dialog.dismissible,
      builder: (context) => dialog,
    );
  }

  /// Méthode pour afficher un dialogue de confirmation simple
  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirmer',
    String cancelText = 'Annuler',
  }) {
    return show<bool>(
      context,
      CustomDialog.confirmation(
        title: title,
        message: message,
        actions: [
          DialogAction(
            text: cancelText,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          DialogAction(
            text: confirmText,
            isPrimary: true,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }

  /// Méthode pour afficher un dialogue d'erreur simple
  static Future<void> showError(
    BuildContext context, {
    String title = 'Erreur',
    required String message,
  }) {
    return show<void>(
      context,
      CustomDialog.error(
        title: title,
        message: message,
        actions: [DialogAction(text: 'OK', isPrimary: true, onPressed: () {})],
      ),
    );
  }

  /// Méthode pour afficher un dialogue de succès simple
  static Future<void> showSuccess(
    BuildContext context, {
    String title = 'Succès',
    required String message,
  }) {
    return show<void>(
      context,
      CustomDialog.success(
        title: title,
        message: message,
        actions: [DialogAction(text: 'OK', isPrimary: true, onPressed: () {})],
      ),
    );
  }
}

/// Action pour les dialogues
class DialogAction {
  final String text;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final bool closeDialog;

  const DialogAction({
    required this.text,
    this.onPressed,
    this.isPrimary = false,
    this.closeDialog = true,
  });
}

/// Dialogue de chargement
class LoadingDialog extends StatelessWidget {
  final String? message;
  final bool dismissible;

  const LoadingDialog({super.key, this.message, this.dismissible = false});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: context.textStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Affiche un dialogue de chargement
  static Future<void> show(
    BuildContext context, {
    String? message,
    bool dismissible = false,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) =>
          LoadingDialog(message: message, dismissible: dismissible),
    );
  }

  /// Ferme le dialogue de chargement
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

/// Bottom Sheet personnalisé
class CustomBottomSheet extends StatelessWidget {
  final String? title;
  final Widget content;
  final List<DialogAction>? actions;
  final bool showDragHandle;
  final double? maxHeight;

  const CustomBottomSheet({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.showDragHandle = true,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? context.screenHeight * 0.9,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDragHandle) ...[
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: context.textStyles.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: context.colors.outline),
          ],
          Flexible(
            child: Padding(padding: const EdgeInsets.all(24), child: content),
          ),
          if (actions != null && actions!.isNotEmpty) ...[
            Divider(height: 1, color: context.colors.outline),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!.map((action) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: AppButton(
                      text: action.text,
                      onPressed: action.onPressed != null
                          ? () {
                              action.onPressed!();
                              if (action.closeDialog) {
                                Navigator.of(context).pop();
                              }
                            }
                          : null,
                      type: action.isPrimary
                          ? AppButtonType.primary
                          : AppButtonType.text,
                      size: AppButtonSize.medium,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Affiche le bottom sheet
  static Future<T?> show<T>(
    BuildContext context,
    CustomBottomSheet bottomSheet,
  ) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => bottomSheet,
    );
  }
}
