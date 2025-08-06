import '../../../core/models/base_model.dart';

/// Represents a shipping carrier in PrestaShop
class Carrier extends BaseModel {
  final bool deleted;
  final bool isModule;
  final int? idTaxRulesGroup;
  final int? idReference;
  final String name;
  final bool active;
  final bool isFree;
  final String? url;
  final bool shippingHandling;
  final bool shippingExternal;
  final bool rangeBehavior;
  final int? shippingMethod;
  final int? maxWidth;
  final int? maxHeight;
  final int? maxDepth;
  final double? maxWeight;
  final int? grade;
  final String? externalModuleName;
  final bool needRange;
  final int? position;
  final Map<String, String> delay;
  final DateTime? dateAdd;
  final DateTime? dateUpd;

  Carrier({
    super.id,
    this.deleted = false,
    this.isModule = false,
    this.idTaxRulesGroup,
    this.idReference,
    required this.name,
    this.active = true,
    this.isFree = false,
    this.url,
    this.shippingHandling = false,
    this.shippingExternal = false,
    this.rangeBehavior = true,
    this.shippingMethod,
    this.maxWidth,
    this.maxHeight,
    this.maxDepth,
    this.maxWeight,
    this.grade,
    this.externalModuleName,
    this.needRange = false,
    this.position,
    this.delay = const {},
    this.dateAdd,
    this.dateUpd,
  });

  @override
  List<Object?> get props => [
    id,
    deleted,
    isModule,
    idTaxRulesGroup,
    idReference,
    name,
    active,
    isFree,
    url,
    shippingHandling,
    shippingExternal,
    rangeBehavior,
    shippingMethod,
    maxWidth,
    maxHeight,
    maxDepth,
    maxWeight,
    grade,
    externalModuleName,
    needRange,
    position,
    delay,
    dateAdd,
    dateUpd,
  ];

  /// Factory constructor from JSON
  factory Carrier.fromJson(Map<String, dynamic> json) {
    return Carrier(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      deleted: json['deleted'] == '1' || json['deleted'] == true,
      isModule: json['is_module'] == '1' || json['is_module'] == true,
      idTaxRulesGroup: json['id_tax_rules_group'] != null
          ? int.tryParse(json['id_tax_rules_group'].toString())
          : null,
      idReference: json['id_reference'] != null
          ? int.tryParse(json['id_reference'].toString())
          : null,
      name: json['name']?.toString() ?? '',
      active: json['active'] == '1' || json['active'] == true,
      isFree: json['is_free'] == '1' || json['is_free'] == true,
      url: json['url']?.toString(),
      shippingHandling:
          json['shipping_handling'] == '1' || json['shipping_handling'] == true,
      shippingExternal:
          json['shipping_external'] == '1' || json['shipping_external'] == true,
      rangeBehavior:
          json['range_behavior'] != '0' && json['range_behavior'] != false,
      shippingMethod: json['shipping_method'] != null
          ? int.tryParse(json['shipping_method'].toString())
          : null,
      maxWidth: json['max_width'] != null
          ? int.tryParse(json['max_width'].toString())
          : null,
      maxHeight: json['max_height'] != null
          ? int.tryParse(json['max_height'].toString())
          : null,
      maxDepth: json['max_depth'] != null
          ? int.tryParse(json['max_depth'].toString())
          : null,
      maxWeight: json['max_weight'] != null
          ? double.tryParse(json['max_weight'].toString())
          : null,
      grade: json['grade'] != null
          ? int.tryParse(json['grade'].toString())
          : null,
      externalModuleName: json['external_module_name']?.toString(),
      needRange: json['need_range'] == '1' || json['need_range'] == true,
      position: json['position'] != null
          ? int.tryParse(json['position'].toString())
          : null,
      delay: _parseDelayFromJson(json['delay']),
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
      'deleted': deleted ? '1' : '0',
      'is_module': isModule ? '1' : '0',
      'name': name,
      'active': active ? '1' : '0',
      'is_free': isFree ? '1' : '0',
      'shipping_handling': shippingHandling ? '1' : '0',
      'shipping_external': shippingExternal ? '1' : '0',
      'range_behavior': rangeBehavior ? '1' : '0',
      'need_range': needRange ? '1' : '0',
      'delay': delay,
    };

    if (id != null) json['id'] = id.toString();
    if (idTaxRulesGroup != null)
      json['id_tax_rules_group'] = idTaxRulesGroup.toString();
    if (idReference != null) json['id_reference'] = idReference.toString();
    if (url != null) json['url'] = url;
    if (shippingMethod != null)
      json['shipping_method'] = shippingMethod.toString();
    if (maxWidth != null) json['max_width'] = maxWidth.toString();
    if (maxHeight != null) json['max_height'] = maxHeight.toString();
    if (maxDepth != null) json['max_depth'] = maxDepth.toString();
    if (maxWeight != null) json['max_weight'] = maxWeight.toString();
    if (grade != null) json['grade'] = grade.toString();
    if (externalModuleName != null)
      json['external_module_name'] = externalModuleName;
    if (position != null) json['position'] = position.toString();
    if (dateAdd != null) json['date_add'] = dateAdd!.toIso8601String();
    if (dateUpd != null) json['date_upd'] = dateUpd!.toIso8601String();

    return json;
  }

  /// Convert to XML for PrestaShop API
  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">');
    buffer.writeln('  <carrier>');

    if (id != null) buffer.writeln('    <id><![CDATA[$id]]></id>');
    buffer.writeln('    <deleted><![CDATA[${deleted ? '1' : '0'}]]></deleted>');
    buffer.writeln(
      '    <is_module><![CDATA[${isModule ? '1' : '0'}]]></is_module>',
    );
    if (idTaxRulesGroup != null) {
      buffer.writeln(
        '    <id_tax_rules_group><![CDATA[$idTaxRulesGroup]]></id_tax_rules_group>',
      );
    }
    if (idReference != null) {
      buffer.writeln(
        '    <id_reference><![CDATA[$idReference]]></id_reference>',
      );
    }
    buffer.writeln('    <name><![CDATA[$name]]></name>');
    buffer.writeln('    <active><![CDATA[${active ? '1' : '0'}]]></active>');
    buffer.writeln('    <is_free><![CDATA[${isFree ? '1' : '0'}]]></is_free>');
    if (url != null) {
      buffer.writeln('    <url><![CDATA[$url]]></url>');
    }
    buffer.writeln(
      '    <shipping_handling><![CDATA[${shippingHandling ? '1' : '0'}]]></shipping_handling>',
    );
    buffer.writeln(
      '    <shipping_external><![CDATA[${shippingExternal ? '1' : '0'}]]></shipping_external>',
    );
    buffer.writeln(
      '    <range_behavior><![CDATA[${rangeBehavior ? '1' : '0'}]]></range_behavior>',
    );
    if (shippingMethod != null) {
      buffer.writeln(
        '    <shipping_method><![CDATA[$shippingMethod]]></shipping_method>',
      );
    }
    if (maxWidth != null) {
      buffer.writeln('    <max_width><![CDATA[$maxWidth]]></max_width>');
    }
    if (maxHeight != null) {
      buffer.writeln('    <max_height><![CDATA[$maxHeight]]></max_height>');
    }
    if (maxDepth != null) {
      buffer.writeln('    <max_depth><![CDATA[$maxDepth]]></max_depth>');
    }
    if (maxWeight != null) {
      buffer.writeln('    <max_weight><![CDATA[$maxWeight]]></max_weight>');
    }
    if (grade != null) {
      buffer.writeln('    <grade><![CDATA[$grade]]></grade>');
    }
    if (externalModuleName != null) {
      buffer.writeln(
        '    <external_module_name><![CDATA[$externalModuleName]]></external_module_name>',
      );
    }
    buffer.writeln(
      '    <need_range><![CDATA[${needRange ? '1' : '0'}]]></need_range>',
    );
    if (position != null) {
      buffer.writeln('    <position><![CDATA[$position]]></position>');
    }

    // Multilingual delay field
    if (delay.isNotEmpty) {
      buffer.writeln('    <delay>');
      delay.forEach((langId, value) {
        buffer.writeln(
          '      <language id="$langId"><![CDATA[$value]]></language>',
        );
      });
      buffer.writeln('    </delay>');
    }

    buffer.writeln('  </carrier>');
    buffer.writeln('</prestashop>');
    return buffer.toString();
  }

  /// Create a copy with modified fields
  Carrier copyWith({
    int? id,
    bool? deleted,
    bool? isModule,
    int? idTaxRulesGroup,
    int? idReference,
    String? name,
    bool? active,
    bool? isFree,
    String? url,
    bool? shippingHandling,
    bool? shippingExternal,
    bool? rangeBehavior,
    int? shippingMethod,
    int? maxWidth,
    int? maxHeight,
    int? maxDepth,
    double? maxWeight,
    int? grade,
    String? externalModuleName,
    bool? needRange,
    int? position,
    Map<String, String>? delay,
    DateTime? dateAdd,
    DateTime? dateUpd,
  }) {
    return Carrier(
      id: id ?? this.id,
      deleted: deleted ?? this.deleted,
      isModule: isModule ?? this.isModule,
      idTaxRulesGroup: idTaxRulesGroup ?? this.idTaxRulesGroup,
      idReference: idReference ?? this.idReference,
      name: name ?? this.name,
      active: active ?? this.active,
      isFree: isFree ?? this.isFree,
      url: url ?? this.url,
      shippingHandling: shippingHandling ?? this.shippingHandling,
      shippingExternal: shippingExternal ?? this.shippingExternal,
      rangeBehavior: rangeBehavior ?? this.rangeBehavior,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      maxDepth: maxDepth ?? this.maxDepth,
      maxWeight: maxWeight ?? this.maxWeight,
      grade: grade ?? this.grade,
      externalModuleName: externalModuleName ?? this.externalModuleName,
      needRange: needRange ?? this.needRange,
      position: position ?? this.position,
      delay: delay ?? this.delay,
      dateAdd: dateAdd ?? this.dateAdd,
      dateUpd: dateUpd ?? this.dateUpd,
    );
  }

  // Helper methods
  static Map<String, String> _parseDelayFromJson(dynamic delayData) {
    final Map<String, String> delayMap = {};

    if (delayData is Map<String, dynamic>) {
      if (delayData.containsKey('language')) {
        final languages = delayData['language'];
        if (languages is List) {
          for (final lang in languages) {
            if (lang is Map<String, dynamic>) {
              final id = lang['attrs']?['id'] ?? lang['id'];
              final value = lang['value'] ?? lang.toString();
              if (id != null) {
                delayMap[id.toString()] = value.toString();
              }
            }
          }
        }
      } else {
        delayData.forEach((key, value) {
          delayMap[key] = value.toString();
        });
      }
    } else if (delayData is String && delayData.isNotEmpty) {
      delayMap['1'] = delayData;
    }

    return delayMap;
  }

  /// Business logic methods
  bool get isDeleted => deleted;
  bool get isActive => active && !deleted;
  bool get hasUrl => url != null && url!.isNotEmpty;
  bool get isFreeShipping => isFree;
  bool get isModuleBased => isModule;
  bool get hasExternalModule =>
      externalModuleName != null && externalModuleName!.isNotEmpty;
  bool get hasShippingHandling => shippingHandling;
  bool get requiresRange => needRange;
  bool get hasMaxDimensions =>
      maxWidth != null || maxHeight != null || maxDepth != null;
  bool get hasMaxWeight => maxWeight != null;

  String getDelayForLanguage(String languageId) {
    return delay[languageId] ?? delay['1'] ?? '';
  }

  /// Get shipping method name
  String get shippingMethodName {
    switch (shippingMethod) {
      case 0:
        return 'Free';
      case 1:
        return 'By weight';
      case 2:
        return 'By price';
      default:
        return 'Unknown';
    }
  }
}
