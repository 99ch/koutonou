import '../../../core/models/base_model.dart';

/// Represents a country in PrestaShop
class Country extends BaseModel {
  final int idZone;
  final int? idCurrency;
  final int? callPrefix;
  final String isoCode;
  final bool active;
  final bool containsStates;
  final bool needIdentificationNumber;
  final bool? needZipCode;
  final String? zipCodeFormat;
  final bool displayTaxLabel;
  final Map<String, String> name;
  final DateTime? dateAdd;
  final DateTime? dateUpd;

  Country({
    super.id,
    required this.idZone,
    this.idCurrency,
    this.callPrefix,
    required this.isoCode,
    this.active = true,
    required this.containsStates,
    required this.needIdentificationNumber,
    this.needZipCode,
    this.zipCodeFormat,
    required this.displayTaxLabel,
    this.name = const {},
    this.dateAdd,
    this.dateUpd,
  });

  @override
  List<Object?> get props => [
    id,
    idZone,
    idCurrency,
    callPrefix,
    isoCode,
    active,
    containsStates,
    needIdentificationNumber,
    needZipCode,
    zipCodeFormat,
    displayTaxLabel,
    name,
    dateAdd,
    dateUpd,
  ];

  /// Factory constructor from JSON
  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      idZone: int.tryParse(json['id_zone']?.toString() ?? '0') ?? 0,
      idCurrency: json['id_currency'] != null
          ? int.tryParse(json['id_currency'].toString())
          : null,
      callPrefix: json['call_prefix'] != null
          ? int.tryParse(json['call_prefix'].toString())
          : null,
      isoCode: json['iso_code']?.toString() ?? '',
      active: json['active'] == '1' || json['active'] == true,
      containsStates:
          json['contains_states'] == '1' || json['contains_states'] == true,
      needIdentificationNumber:
          json['need_identification_number'] == '1' ||
          json['need_identification_number'] == true,
      needZipCode: json['need_zip_code'] != null
          ? (json['need_zip_code'] == '1' || json['need_zip_code'] == true)
          : null,
      zipCodeFormat: json['zip_code_format']?.toString(),
      displayTaxLabel:
          json['display_tax_label'] == '1' || json['display_tax_label'] == true,
      name: _parseNameFromJson(json['name']),
      dateAdd: json['date_add'] != null
          ? DateTime.tryParse(json['date_add'])
          : null,
      dateUpd: json['date_upd'] != null
          ? DateTime.tryParse(json['date_upd'])
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id_zone': idZone.toString(),
      'iso_code': isoCode,
      'active': active ? '1' : '0',
      'contains_states': containsStates ? '1' : '0',
      'need_identification_number': needIdentificationNumber ? '1' : '0',
      'display_tax_label': displayTaxLabel ? '1' : '0',
      'name': name,
    };

    if (id != null) json['id'] = id.toString();
    if (idCurrency != null) json['id_currency'] = idCurrency.toString();
    if (callPrefix != null) json['call_prefix'] = callPrefix.toString();
    if (needZipCode != null) json['need_zip_code'] = needZipCode! ? '1' : '0';
    if (zipCodeFormat != null) json['zip_code_format'] = zipCodeFormat;
    if (dateAdd != null) json['date_add'] = dateAdd!.toIso8601String();
    if (dateUpd != null) json['date_upd'] = dateUpd!.toIso8601String();

    return json;
  }

  /// Convert to XML for PrestaShop API
  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">');
    buffer.writeln('  <country>');

    if (id != null) buffer.writeln('    <id><![CDATA[$id]]></id>');
    buffer.writeln('    <id_zone><![CDATA[$idZone]]></id_zone>');
    if (idCurrency != null) {
      buffer.writeln('    <id_currency><![CDATA[$idCurrency]]></id_currency>');
    }
    if (callPrefix != null) {
      buffer.writeln('    <call_prefix><![CDATA[$callPrefix]]></call_prefix>');
    }
    buffer.writeln('    <iso_code><![CDATA[$isoCode]]></iso_code>');
    buffer.writeln('    <active><![CDATA[${active ? '1' : '0'}]]></active>');
    buffer.writeln(
      '    <contains_states><![CDATA[${containsStates ? '1' : '0'}]]></contains_states>',
    );
    buffer.writeln(
      '    <need_identification_number><![CDATA[${needIdentificationNumber ? '1' : '0'}]]></need_identification_number>',
    );
    if (needZipCode != null) {
      buffer.writeln(
        '    <need_zip_code><![CDATA[${needZipCode! ? '1' : '0'}]]></need_zip_code>',
      );
    }
    if (zipCodeFormat != null) {
      buffer.writeln(
        '    <zip_code_format><![CDATA[$zipCodeFormat]]></zip_code_format>',
      );
    }
    buffer.writeln(
      '    <display_tax_label><![CDATA[${displayTaxLabel ? '1' : '0'}]]></display_tax_label>',
    );

    // Multilingual name field
    if (name.isNotEmpty) {
      buffer.writeln('    <name>');
      name.forEach((langId, value) {
        buffer.writeln(
          '      <language id="$langId"><![CDATA[$value]]></language>',
        );
      });
      buffer.writeln('    </name>');
    }

    buffer.writeln('  </country>');
    buffer.writeln('</prestashop>');
    return buffer.toString();
  }

  /// Create a copy with modified fields
  Country copyWith({
    int? id,
    int? idZone,
    int? idCurrency,
    int? callPrefix,
    String? isoCode,
    bool? active,
    bool? containsStates,
    bool? needIdentificationNumber,
    bool? needZipCode,
    String? zipCodeFormat,
    bool? displayTaxLabel,
    Map<String, String>? name,
    DateTime? dateAdd,
    DateTime? dateUpd,
  }) {
    return Country(
      id: id ?? this.id,
      idZone: idZone ?? this.idZone,
      idCurrency: idCurrency ?? this.idCurrency,
      callPrefix: callPrefix ?? this.callPrefix,
      isoCode: isoCode ?? this.isoCode,
      active: active ?? this.active,
      containsStates: containsStates ?? this.containsStates,
      needIdentificationNumber:
          needIdentificationNumber ?? this.needIdentificationNumber,
      needZipCode: needZipCode ?? this.needZipCode,
      zipCodeFormat: zipCodeFormat ?? this.zipCodeFormat,
      displayTaxLabel: displayTaxLabel ?? this.displayTaxLabel,
      name: name ?? this.name,
      dateAdd: dateAdd ?? this.dateAdd,
      dateUpd: dateUpd ?? this.dateUpd,
    );
  }

  // Helper methods
  static Map<String, String> _parseNameFromJson(dynamic nameData) {
    final Map<String, String> nameMap = {};

    if (nameData is Map<String, dynamic>) {
      if (nameData.containsKey('language')) {
        final languages = nameData['language'];
        if (languages is List) {
          for (final lang in languages) {
            if (lang is Map<String, dynamic>) {
              final id = lang['attrs']?['id'] ?? lang['id'];
              final value = lang['value'] ?? lang.toString();
              if (id != null) {
                nameMap[id.toString()] = value.toString();
              }
            }
          }
        }
      } else {
        nameData.forEach((key, value) {
          nameMap[key] = value.toString();
        });
      }
    } else if (nameData is String && nameData.isNotEmpty) {
      nameMap['1'] = nameData;
    }

    return nameMap;
  }

  /// Business logic methods
  bool get isActive => active;
  bool get hasStates => containsStates;
  bool get requiresIdentificationNumber => needIdentificationNumber;
  bool get requiresZipCode => needZipCode ?? false;
  bool get shouldDisplayTaxLabel => displayTaxLabel;
  bool get hasCallPrefix => callPrefix != null;
  bool get hasCurrency => idCurrency != null;
  bool get hasZipCodeFormat =>
      zipCodeFormat != null && zipCodeFormat!.isNotEmpty;

  String getNameForLanguage(String languageId) {
    return name[languageId] ?? name['1'] ?? '';
  }

  String get displayName => getNameForLanguage('1');
}
