// Widget pour afficher du contenu HTML de manière sécurisée et stylisée
// Utilisé pour les descriptions de produits et autres contenus riches

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class HtmlContent extends StatelessWidget {
  final String? htmlData;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? defaultTextStyle;
  final Map<String, Style>? customStyles;
  final bool shrinkWrap;

  const HtmlContent({
    super.key,
    required this.htmlData,
    this.maxLines,
    this.overflow,
    this.defaultTextStyle,
    this.customStyles,
    this.shrinkWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    if (htmlData == null || htmlData!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    // Nettoyer le HTML pour éviter les problèmes d'affichage
    final cleanHtml = _cleanHtml(htmlData!);

    return Html(
      data: cleanHtml,
      shrinkWrap: shrinkWrap,
      style: _getDefaultStyles(context)..addAll(customStyles ?? {}),
      onLinkTap: (url, attributes, element) {
        // Gérer les clics sur les liens si nécessaire
        // Pour l'instant, on ne fait rien pour des raisons de sécurité
      },
    );
  }

  /// Nettoie le HTML pour un affichage optimal
  String _cleanHtml(String html) {
    // Supprimer les styles inline qui peuvent casser l'affichage
    String cleaned = html.replaceAll(RegExp(r'style="[^"]*"'), '');

    // Supprimer les attributs de classe qui peuvent causer des problèmes
    cleaned = cleaned.replaceAll(RegExp(r'class="[^"]*"'), '');

    // Supprimer les spans vides
    cleaned = cleaned.replaceAll(RegExp(r'<span[^>]*></span>'), '');

    // Nettoyer les espaces multiples
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    return cleaned.trim();
  }

  /// Styles par défaut pour le HTML
  Map<String, Style> _getDefaultStyles(BuildContext context) {
    final theme = Theme.of(context);

    return {
      "body": Style(
        margin: Margins.zero,
        padding: HtmlPaddings.zero,
        fontSize: FontSize(defaultTextStyle?.fontSize ?? 14),
        color: defaultTextStyle?.color ?? theme.textTheme.bodyMedium?.color,
        fontFamily: defaultTextStyle?.fontFamily,
        maxLines: maxLines,
        textOverflow: overflow ?? TextOverflow.visible,
      ),
      "p": Style(
        margin: Margins.only(bottom: 8),
        fontSize: FontSize(defaultTextStyle?.fontSize ?? 14),
        lineHeight: const LineHeight(1.4),
      ),
      "h1": Style(
        fontSize: FontSize(24),
        fontWeight: FontWeight.bold,
        margin: Margins.only(bottom: 12, top: 8),
        color: theme.colorScheme.primary,
      ),
      "h2": Style(
        fontSize: FontSize(20),
        fontWeight: FontWeight.bold,
        margin: Margins.only(bottom: 10, top: 8),
        color: theme.colorScheme.primary,
      ),
      "h3": Style(
        fontSize: FontSize(18),
        fontWeight: FontWeight.w600,
        margin: Margins.only(bottom: 8, top: 6),
        color: theme.colorScheme.primary,
      ),
      "ul": Style(margin: Margins.only(left: 16, bottom: 8)),
      "ol": Style(margin: Margins.only(left: 16, bottom: 8)),
      "li": Style(
        margin: Margins.only(bottom: 4),
        fontSize: FontSize(defaultTextStyle?.fontSize ?? 14),
        lineHeight: const LineHeight(1.3),
      ),
      "strong": Style(fontWeight: FontWeight.bold),
      "b": Style(fontWeight: FontWeight.bold),
      "em": Style(fontStyle: FontStyle.italic),
      "i": Style(fontStyle: FontStyle.italic),
      "a": Style(
        color: theme.colorScheme.primary,
        textDecoration: TextDecoration.underline,
      ),
      "span": Style(fontSize: FontSize(defaultTextStyle?.fontSize ?? 14)),
      "div": Style(margin: Margins.only(bottom: 4)),
    };
  }
}

/// Widget spécialisé pour les descriptions de produits courtes
class ProductShortDescription extends StatelessWidget {
  final String? description;
  final int maxLines;
  final TextStyle? textStyle;

  const ProductShortDescription({
    super.key,
    required this.description,
    this.maxLines = 2,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (description == null || description!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return HtmlContent(
      htmlData: description,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      defaultTextStyle: textStyle ?? Theme.of(context).textTheme.bodySmall,
      customStyles: {
        "body": Style(maxLines: maxLines, textOverflow: TextOverflow.ellipsis),
        "p": Style(
          margin: Margins.zero,
          maxLines: maxLines,
          textOverflow: TextOverflow.ellipsis,
        ),
        "ul": Style(margin: Margins.zero, maxLines: maxLines),
        "li": Style(
          margin: Margins.zero,
          maxLines: 1,
          textOverflow: TextOverflow.ellipsis,
        ),
      },
    );
  }
}

/// Widget spécialisé pour les descriptions complètes de produits
class ProductFullDescription extends StatelessWidget {
  final String? description;
  final TextStyle? textStyle;

  const ProductFullDescription({
    super.key,
    required this.description,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (description == null || description!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return HtmlContent(
      htmlData: description,
      defaultTextStyle: textStyle ?? Theme.of(context).textTheme.bodyMedium,
      customStyles: {
        "ul": Style(margin: Margins.only(left: 12, bottom: 12)),
        "li": Style(margin: Margins.only(bottom: 6), display: Display.listItem),
      },
    );
  }
}
