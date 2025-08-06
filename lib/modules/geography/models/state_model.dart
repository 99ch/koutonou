import '../../../core/models/base_model.dart';

/// Represents a state/province in PrestaShop
class State extends BaseModel {
  final int idZone;
  final int idCountry;
  final String isoCode;
  final String name;
  final bool active;
  final DateTime? dateAdd;
  final DateTime? dateUpd;

  State({
    super.id,
    required this.idZone,
    required this.idCountry,
    required this.isoCode,
    required this.name,
    this.active = true,
    this.dateAdd,
    this.dateUpd,
  });

  @override
  List<Object?> get props => [
    id,
    idZone,
    idCountry,
    isoCode,
    name,
    active,
    dateAdd,
    dateUpd,
  ];

  /// Factory constructor from JSON
  factory State.fromJson(Map<String, dynamic> json) {
    return State(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      idZone: int.tryParse(json['id_zone']?.toString() ?? '0') ?? 0,
      idCountry: int.tryParse(json['id_country']?.toString() ?? '0') ?? 0,
      isoCode: json['iso_code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      active: json['active'] == '1' || json['active'] == true,
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
      'id_country': idCountry.toString(),
      'iso_code': isoCode,
      'name': name,
      'active': active ? '1' : '0',
    };

    if (id != null) json['id'] = id.toString();
    if (dateAdd != null) json['date_add'] = dateAdd!.toIso8601String();
    if (dateUpd != null) json['date_upd'] = dateUpd!.toIso8601String();

    return json;
  }

  /// Convert to XML for PrestaShop API
  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">');
    buffer.writeln('  <state>');

    if (id != null) buffer.writeln('    <id><![CDATA[$id]]></id>');
    buffer.writeln('    <id_zone><![CDATA[$idZone]]></id_zone>');
    buffer.writeln('    <id_country><![CDATA[$idCountry]]></id_country>');
    buffer.writeln('    <iso_code><![CDATA[$isoCode]]></iso_code>');
    buffer.writeln('    <name><![CDATA[$name]]></name>');
    buffer.writeln('    <active><![CDATA[${active ? '1' : '0'}]]></active>');

    buffer.writeln('  </state>');
    buffer.writeln('</prestashop>');
    return buffer.toString();
  }

  /// Create a copy with modified fields
  State copyWith({
    int? id,
    int? idZone,
    int? idCountry,
    String? isoCode,
    String? name,
    bool? active,
    DateTime? dateAdd,
    DateTime? dateUpd,
  }) {
    return State(
      id: id ?? this.id,
      idZone: idZone ?? this.idZone,
      idCountry: idCountry ?? this.idCountry,
      isoCode: isoCode ?? this.isoCode,
      name: name ?? this.name,
      active: active ?? this.active,
      dateAdd: dateAdd ?? this.dateAdd,
      dateUpd: dateUpd ?? this.dateUpd,
    );
  }

  /// Business logic methods
  bool get isActive => active;
  String get displayName => name;
  String get fullDisplayName => '$name ($isoCode)';
}
