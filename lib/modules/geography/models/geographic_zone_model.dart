import '../../../core/models/base_model.dart';

/// Represents a geographical zone in PrestaShop
class GeographicZone extends BaseModel {
  final String name;
  final bool active;
  final DateTime? dateAdd;
  final DateTime? dateUpd;

  GeographicZone({
    super.id,
    required this.name,
    this.active = true,
    this.dateAdd,
    this.dateUpd,
  });

  @override
  List<Object?> get props => [id, name, active, dateAdd, dateUpd];

  /// Factory constructor from JSON
  factory GeographicZone.fromJson(Map<String, dynamic> json) {
    return GeographicZone(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
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
    buffer.writeln('  <zone>');

    if (id != null) buffer.writeln('    <id><![CDATA[$id]]></id>');
    buffer.writeln('    <name><![CDATA[$name]]></name>');
    buffer.writeln('    <active><![CDATA[${active ? '1' : '0'}]]></active>');

    buffer.writeln('  </zone>');
    buffer.writeln('</prestashop>');
    return buffer.toString();
  }

  /// Create a copy with modified fields
  GeographicZone copyWith({
    int? id,
    String? name,
    bool? active,
    DateTime? dateAdd,
    DateTime? dateUpd,
  }) {
    return GeographicZone(
      id: id ?? this.id,
      name: name ?? this.name,
      active: active ?? this.active,
      dateAdd: dateAdd ?? this.dateAdd,
      dateUpd: dateUpd ?? this.dateUpd,
    );
  }

  /// Business logic methods
  bool get isActive => active;
  String get displayName => name;
}
