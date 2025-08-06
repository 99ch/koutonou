import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Collection of form field widgets for geography module
class GeographyFormFields {
  GeographyFormFields._();

  /// Country name text field
  static Widget countryNameField({
    required TextEditingController controller,
    String? label,
    String? hint,
    bool required = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label ?? 'Nom du pays${required ? ' *' : ''}',
        hintText: hint ?? 'Entrez le nom du pays',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.flag),
      ),
      validator: validator ?? (required ? _requiredValidator : null),
      textCapitalization: TextCapitalization.words,
    );
  }

  /// ISO Code field
  static Widget isoCodeField({
    required TextEditingController controller,
    String? label,
    String? hint,
    bool required = true,
    int maxLength = 3,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label ?? 'Code ISO${required ? ' *' : ''}',
        hintText: hint ?? 'Ex: FR, US, DE',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.code),
        counterText: '',
      ),
      maxLength: maxLength,
      inputFormatters: [
        LengthLimitingTextInputFormatter(maxLength),
        FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
        UpperCaseTextFormatter(),
      ],
      validator: validator ?? (required ? _isoCodeValidator : null),
    );
  }

  /// State name field
  static Widget stateNameField({
    required TextEditingController controller,
    String? label,
    String? hint,
    bool required = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label ?? 'Nom de l\'état/province${required ? ' *' : ''}',
        hintText: hint ?? 'Entrez le nom de l\'état ou province',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.location_city),
      ),
      validator: validator ?? (required ? _requiredValidator : null),
      textCapitalization: TextCapitalization.words,
    );
  }

  /// Zone name field
  static Widget zoneNameField({
    required TextEditingController controller,
    String? label,
    String? hint,
    bool required = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label ?? 'Nom de la zone${required ? ' *' : ''}',
        hintText: hint ?? 'Entrez le nom de la zone géographique',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.public),
      ),
      validator: validator ?? (required ? _requiredValidator : null),
      textCapitalization: TextCapitalization.words,
    );
  }

  /// Zone dropdown
  static Widget zoneDropdown({
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required void Function(int?)? onChanged,
    String? label,
    String? hint,
    bool required = true,
    String? Function(int?)? validator,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label ?? 'Zone géographique${required ? ' *' : ''}',
        hintText: hint ?? 'Sélectionnez une zone',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.public),
      ),
      validator: validator ?? (required ? _dropdownValidator : null),
    );
  }

  /// Country dropdown
  static Widget countryDropdown({
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required void Function(int?)? onChanged,
    String? label,
    String? hint,
    bool required = true,
    String? Function(int?)? validator,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label ?? 'Pays${required ? ' *' : ''}',
        hintText: hint ?? 'Sélectionnez un pays',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.flag),
      ),
      validator: validator ?? (required ? _dropdownValidator : null),
    );
  }

  /// Call prefix field
  static Widget callPrefixField({
    required TextEditingController controller,
    String? label,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label ?? 'Préfixe téléphonique',
        hintText: hint ?? 'Ex: 33, 1, 44',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.phone),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      validator: validator,
    );
  }

  /// Zip code format field
  static Widget zipCodeFormatField({
    required TextEditingController controller,
    String? label,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label ?? 'Format du code postal',
        hintText: hint ?? 'Ex: NNNNN, LNNNN, NNN NNN',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.mail),
        helperText: 'N = chiffre, L = lettre',
      ),
      validator: validator,
    );
  }

  /// Active status switch
  static Widget activeSwitch({
    required bool value,
    required void Function(bool) onChanged,
    String? label,
  }) {
    return SwitchListTile(
      title: Text(label ?? 'Actif'),
      subtitle: Text(
        value ? 'Cet élément est actif' : 'Cet élément est inactif',
      ),
      value: value,
      onChanged: onChanged,
      secondary: Icon(
        value ? Icons.toggle_on : Icons.toggle_off,
        color: value ? Colors.green : Colors.grey,
      ),
    );
  }

  /// Contains states switch
  static Widget containsStatesSwitch({
    required bool value,
    required void Function(bool) onChanged,
    String? label,
  }) {
    return SwitchListTile(
      title: Text(label ?? 'Contient des états/provinces'),
      subtitle: Text(
        value
            ? 'Ce pays a des subdivisions (états, provinces, etc.)'
            : 'Ce pays n\'a pas de subdivisions',
      ),
      value: value,
      onChanged: onChanged,
      secondary: Icon(
        Icons.location_city,
        color: value ? Colors.blue : Colors.grey,
      ),
    );
  }

  /// Need identification number switch
  static Widget needIdentificationSwitch({
    required bool value,
    required void Function(bool) onChanged,
    String? label,
  }) {
    return SwitchListTile(
      title: Text(label ?? 'Numéro d\'identification requis'),
      subtitle: Text(
        value
            ? 'Un numéro d\'identification est requis pour ce pays'
            : 'Aucun numéro d\'identification requis',
      ),
      value: value,
      onChanged: onChanged,
      secondary: Icon(Icons.badge, color: value ? Colors.orange : Colors.grey),
    );
  }

  /// Need zip code switch
  static Widget needZipCodeSwitch({
    required bool value,
    required void Function(bool) onChanged,
    String? label,
  }) {
    return SwitchListTile(
      title: Text(label ?? 'Code postal requis'),
      subtitle: Text(
        value
            ? 'Un code postal est requis pour ce pays'
            : 'Aucun code postal requis',
      ),
      value: value,
      onChanged: onChanged,
      secondary: Icon(Icons.mail, color: value ? Colors.purple : Colors.grey),
    );
  }

  /// Display tax label switch
  static Widget displayTaxLabelSwitch({
    required bool value,
    required void Function(bool) onChanged,
    String? label,
  }) {
    return SwitchListTile(
      title: Text(label ?? 'Afficher le label de taxe'),
      subtitle: Text(
        value
            ? 'Le label de taxe sera affiché pour ce pays'
            : 'Le label de taxe ne sera pas affiché',
      ),
      value: value,
      onChanged: onChanged,
      secondary: Icon(Icons.receipt, color: value ? Colors.green : Colors.grey),
    );
  }

  // Validators
  static String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ce champ est requis';
    }
    return null;
  }

  static String? _isoCodeValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Le code ISO est requis';
    }
    if (value.length < 2 || value.length > 3) {
      return 'Le code ISO doit contenir 2 ou 3 caractères';
    }
    return null;
  }

  static String? _dropdownValidator(int? value) {
    if (value == null) {
      return 'Veuillez faire une sélection';
    }
    return null;
  }
}

/// Text formatter to convert input to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
