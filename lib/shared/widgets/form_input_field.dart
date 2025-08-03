// Champ de saisie personnalisé avec validation intégrée
// Utilise les validators et extensions pour une expérience cohérente

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../extensions/extensions.dart';
import '../utils/utils.dart';

/// Types de champs de saisie
enum InputFieldType {
  text,
  email,
  password,
  phone,
  number,
  url,
  multiline,
  search,
}

/// Champ de saisie personnalisé
class FormInputField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final InputFieldType type;
  final TextEditingController? controller;
  final String? initialValue;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final bool enabled;
  final bool readOnly;
  final bool required;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final EdgeInsets? contentPadding;
  final BorderRadius? borderRadius;

  const FormInputField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.type = InputFieldType.text,
    this.controller,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.maxLength,
    this.maxLines,
    this.minLines,
    this.textInputAction,
    this.inputFormatters,
    this.focusNode,
    this.contentPadding,
    this.borderRadius,
  });

  /// Constructeur pour email
  const FormInputField.email({
    super.key,
    this.label = 'Email',
    this.hint = 'Saisissez votre email',
    this.helperText,
    this.controller,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.focusNode,
    this.contentPadding,
    this.borderRadius,
  }) : type = InputFieldType.email,
       prefixIcon = Icons.email_outlined,
       suffixIcon = null,
       onSuffixIconTap = null,
       maxLength = null,
       maxLines = 1,
       minLines = null,
       textInputAction = TextInputAction.next,
       inputFormatters = null;

  /// Constructeur pour mot de passe
  const FormInputField.password({
    super.key,
    this.label = 'Mot de passe',
    this.hint = 'Saisissez votre mot de passe',
    this.helperText,
    this.controller,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.focusNode,
    this.contentPadding,
    this.borderRadius,
  }) : type = InputFieldType.password,
       prefixIcon = Icons.lock_outlined,
       suffixIcon = null, // Sera géré dans le build
       onSuffixIconTap = null,
       maxLength = null,
       maxLines = 1,
       minLines = null,
       textInputAction = TextInputAction.done,
       inputFormatters = null;

  /// Constructeur pour téléphone
  const FormInputField.phone({
    super.key,
    this.label = 'Téléphone',
    this.hint = 'Saisissez votre numéro',
    this.helperText,
    this.controller,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.focusNode,
    this.contentPadding,
    this.borderRadius,
  }) : type = InputFieldType.phone,
       prefixIcon = Icons.phone_outlined,
       suffixIcon = null,
       onSuffixIconTap = null,
       maxLength = 14,
       maxLines = 1,
       minLines = null,
       textInputAction = TextInputAction.next,
       inputFormatters = null;

  /// Constructeur pour recherche
  const FormInputField.search({
    super.key,
    this.label,
    this.hint = 'Rechercher...',
    this.helperText,
    this.controller,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.focusNode,
    this.contentPadding,
    this.borderRadius,
  }) : type = InputFieldType.search,
       prefixIcon = Icons.search,
       suffixIcon = Icons.clear,
       onSuffixIconTap = null, // Sera géré dans le build
       maxLength = null,
       maxLines = 1,
       minLines = null,
       textInputAction = TextInputAction.search,
       inputFormatters = null;

  @override
  State<FormInputField> createState() => _FormInputFieldState();
}

class _FormInputFieldState extends State<FormInputField> {
  late TextEditingController _controller;
  bool _obscureText = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);

    // Écouter les changements pour la validation en temps réel
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    if (widget.onChanged != null) {
      widget.onChanged!(_controller.text);
    }

    // Validation en temps réel si il y a eu une erreur
    if (_hasError && widget.validator != null) {
      final error = widget.validator!(_controller.text);
      if (mounted) {
        setState(() {
          _hasError = error != null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: context.textStyles.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (widget.required) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(
                    color: context.colors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: _controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          obscureText: widget.type == InputFieldType.password
              ? _obscureText
              : false,
          keyboardType: _getKeyboardType(),
          textInputAction:
              widget.textInputAction ?? _getDefaultTextInputAction(),
          inputFormatters: widget.inputFormatters ?? _getInputFormatters(),
          maxLength: widget.maxLength,
          maxLines:
              widget.maxLines ??
              (widget.type == InputFieldType.multiline ? null : 1),
          minLines: widget.minLines,
          validator: (value) {
            String? error;

            // Validation required
            if (widget.required) {
              error = Validators.required(value);
              if (error != null) {
                _hasError = true;
                return error;
              }
            }

            // Validation par type
            error = _getTypeValidator()(value);
            if (error != null) {
              _hasError = true;
              return error;
            }

            // Validation personnalisée
            if (widget.validator != null) {
              error = widget.validator!(value);
              if (error != null) {
                _hasError = true;
                return error;
              }
            }

            _hasError = false;
            return null;
          },
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon)
                : null,
            suffixIcon: _buildSuffixIcon(),
            contentPadding:
                widget.contentPadding ?? _getDefaultPadding(context),
            border: _getBorder(context),
            enabledBorder: _getBorder(context),
            focusedBorder: _getFocusedBorder(context),
            errorBorder: _getErrorBorder(context),
            focusedErrorBorder: _getErrorBorder(context),
            filled: true,
            fillColor: context.colors.surface,
          ),
        ),
      ],
    );
  }

  /// Construit l'icône de fin selon le type
  Widget? _buildSuffixIcon() {
    if (widget.type == InputFieldType.password) {
      return IconButton(
        icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    if (widget.type == InputFieldType.search && _controller.text.isNotEmpty) {
      return IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          _controller.clear();
          if (widget.onChanged != null) {
            widget.onChanged!('');
          }
        },
      );
    }

    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(widget.suffixIcon),
        onPressed: widget.onSuffixIconTap,
      );
    }

    return null;
  }

  /// Détermine le type de clavier
  TextInputType _getKeyboardType() {
    switch (widget.type) {
      case InputFieldType.email:
        return TextInputType.emailAddress;
      case InputFieldType.phone:
        return TextInputType.phone;
      case InputFieldType.number:
        return TextInputType.number;
      case InputFieldType.url:
        return TextInputType.url;
      case InputFieldType.multiline:
        return TextInputType.multiline;
      default:
        return TextInputType.text;
    }
  }

  /// Action par défaut selon le type
  TextInputAction _getDefaultTextInputAction() {
    switch (widget.type) {
      case InputFieldType.search:
        return TextInputAction.search;
      case InputFieldType.multiline:
        return TextInputAction.newline;
      default:
        return TextInputAction.next;
    }
  }

  /// Formateurs d'entrée selon le type
  List<TextInputFormatter>? _getInputFormatters() {
    switch (widget.type) {
      case InputFieldType.number:
        return [FilteringTextInputFormatter.digitsOnly];
      case InputFieldType.phone:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-\(\)\+]')),
          LengthLimitingTextInputFormatter(14),
        ];
      default:
        return null;
    }
  }

  /// Validateur selon le type
  String? Function(String?) _getTypeValidator() {
    switch (widget.type) {
      case InputFieldType.email:
        return Validators.email;
      case InputFieldType.phone:
        return Validators.phoneNumber;
      case InputFieldType.url:
        return Validators.url;
      case InputFieldType.number:
        return Validators.numeric;
      default:
        return (value) => null;
    }
  }

  /// Padding par défaut responsive
  EdgeInsets _getDefaultPadding(BuildContext context) {
    return context.responsive(
      mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      tablet: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      desktop: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    );
  }

  /// Bordure normale
  OutlineInputBorder _getBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      borderSide: BorderSide(color: context.colors.outline, width: 1),
    );
  }

  /// Bordure en focus
  OutlineInputBorder _getFocusedBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      borderSide: BorderSide(color: context.colors.primary, width: 2),
    );
  }

  /// Bordure d'erreur
  OutlineInputBorder _getErrorBorder(BuildContext context) {
    return OutlineInputBorder(
      borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
      borderSide: BorderSide(color: context.colors.error, width: 2),
    );
  }
}
