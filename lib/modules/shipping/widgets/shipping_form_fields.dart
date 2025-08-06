import 'package:flutter/material.dart';

class ShippingFormFields {
  const ShippingFormFields._();

  // Carrier form fields
  static Widget carrierNameField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText ?? 'Entrez le nom du transporteur',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.local_shipping),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ce champ est requis';
              }
              return null;
            }
          : null,
    );
  }

  static Widget carrierDelayField({
    required TextEditingController controller,
    required String label,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText ?? 'Ex: 2-3 jours ouvrables',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.schedule),
      ),
      maxLines: 2,
    );
  }

  static Widget carrierUrlField({
    required TextEditingController controller,
    required String label,
    String? hintText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText ?? 'https://tracking.example.com/@',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.link),
      ),
      keyboardType: TextInputType.url,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final urlRegExp = RegExp(r'^https?://');
          if (!urlRegExp.hasMatch(value)) {
            return 'URL doit commencer par http:// ou https://';
          }
        }
        return null;
      },
    );
  }

  static Widget carrierPositionField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.sort),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final position = int.tryParse(value);
          if (position == null || position < 0) {
            return 'Position doit être un nombre positif';
          }
        }
        return null;
      },
    );
  }

  static Widget carrierMaxWeightField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Poids maximum en kg',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.monitor_weight),
        suffixText: 'kg',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final weight = double.tryParse(value);
          if (weight == null || weight <= 0) {
            return 'Poids doit être un nombre positif';
          }
        }
        return null;
      },
    );
  }

  static Widget carrierDimensionField({
    required TextEditingController controller,
    required String label,
    required String dimension,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: '$dimension maximum en cm',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.straighten),
        suffixText: 'cm',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final dimension = double.tryParse(value);
          if (dimension == null || dimension <= 0) {
            return '$dimension doit être un nombre positif';
          }
        }
        return null;
      },
    );
  }

  // Zone form fields
  static Widget zoneNameField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText ?? 'Entrez le nom de la zone',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.public),
      ),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ce champ est requis';
              }
              return null;
            }
          : null,
    );
  }

  // Range form fields
  static Widget rangeDelimiterField({
    required TextEditingController controller,
    required String label,
    required String unit,
    String? hintText,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
        prefixIcon: unit == 'kg'
            ? const Icon(Icons.monitor_weight)
            : const Icon(Icons.euro),
        suffixText: unit,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ce champ est requis';
              }
              final number = double.tryParse(value);
              if (number == null || number < 0) {
                return 'Doit être un nombre positif';
              }
              return null;
            }
          : null,
    );
  }

  static Widget priceField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText ?? 'Entrez le prix',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.euro),
        suffixText: '€',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ce champ est requis';
              }
              final price = double.tryParse(value);
              if (price == null || price < 0) {
                return 'Prix doit être un nombre positif';
              }
              return null;
            }
          : null,
    );
  }

  // Common form fields
  static Widget switchField({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String title,
    String? subtitle,
    IconData? icon,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Row(
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Text(title),
        ],
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
    );
  }

  static Widget dropdownField<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
    required String label,
    String? hintText,
    IconData? prefixIcon,
    bool isRequired = true,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
      validator: isRequired
          ? (value) {
              if (value == null) {
                return 'Veuillez sélectionner une option';
              }
              return null;
            }
          : null,
    );
  }

  static Widget multiSelectChipField({
    required List<String> options,
    required List<String> selectedOptions,
    required ValueChanged<List<String>> onChanged,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selectedOptions.contains(option);
              return FilterChip(
                label: Text(option),
                selected: isSelected,
                onSelected: (selected) {
                  List<String> newSelection = List.from(selectedOptions);
                  if (selected) {
                    newSelection.add(option);
                  } else {
                    newSelection.remove(option);
                  }
                  onChanged(newSelection);
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
