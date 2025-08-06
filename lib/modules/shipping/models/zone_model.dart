import '../../../core/models/base_model.dart';

/// Represents a shipping zone in PrestaShop
class Zone extends BaseModel {
  final String name;
  final bool active;

  Zone({super.id, required this.name, this.active = true});

  @override
  List<Object?> get props => [id, name, active];

  /// Factory constructor from JSON
  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name']?.toString() ?? '',
      active: json['active'] == '1' || json['active'] == true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'name': name,
      'active': active ? '1' : '0',
    };

    if (id != null) json['id'] = id.toString();

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
  Zone copyWith({int? id, String? name, bool? active}) {
    return Zone(
      id: id ?? this.id,
      name: name ?? this.name,
      active: active ?? this.active,
    );
  }

  // Business logic methods
  bool get isActive => active;
  bool get isInactive => !active;
}
