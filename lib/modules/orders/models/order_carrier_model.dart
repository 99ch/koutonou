/// Modèle pour les transporteurs des commandes PrestaShop
class OrderCarrier {
  final int? id;
  final String name;
  final String? url;
  final bool active;
  final bool deleted;
  final double? shippingHandling;
  final bool isFree;
  final String? shippingExternal;
  final bool needRange;
  final String? externalModuleName;
  final double? shippingMethod;
  final int position;
  final double? maxWidth;
  final double? maxHeight;
  final double? maxDepth;
  final double? maxWeight;
  final double? grade;
  final DateTime? dateAdd;
  final DateTime? dateUpd;

  const OrderCarrier({
    this.id,
    required this.name,
    this.url,
    this.active = true,
    this.deleted = false,
    this.shippingHandling,
    this.isFree = false,
    this.shippingExternal,
    this.needRange = false,
    this.externalModuleName,
    this.shippingMethod,
    this.position = 0,
    this.maxWidth,
    this.maxHeight,
    this.maxDepth,
    this.maxWeight,
    this.grade,
    this.dateAdd,
    this.dateUpd,
  });

  /// Crée un OrderCarrier à partir de la réponse JSON de PrestaShop
  factory OrderCarrier.fromJson(Map<String, dynamic> json) {
    return OrderCarrier(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      name: json['name']?.toString() ?? '',
      url: json['url']?.toString(),
      active: json['active']?.toString() == '1',
      deleted: json['deleted']?.toString() == '1',
      shippingHandling: double.tryParse(
        json['shipping_handling']?.toString() ?? '0',
      ),
      isFree: json['is_free']?.toString() == '1',
      shippingExternal: json['shipping_external']?.toString(),
      needRange: json['need_range']?.toString() == '1',
      externalModuleName: json['external_module_name']?.toString(),
      shippingMethod: double.tryParse(
        json['shipping_method']?.toString() ?? '0',
      ),
      position: int.tryParse(json['position']?.toString() ?? '0') ?? 0,
      maxWidth: double.tryParse(json['max_width']?.toString() ?? '0'),
      maxHeight: double.tryParse(json['max_height']?.toString() ?? '0'),
      maxDepth: double.tryParse(json['max_depth']?.toString() ?? '0'),
      maxWeight: double.tryParse(json['max_weight']?.toString() ?? '0'),
      grade: double.tryParse(json['grade']?.toString() ?? '0'),
      dateAdd: DateTime.tryParse(json['date_add']?.toString() ?? ''),
      dateUpd: DateTime.tryParse(json['date_upd']?.toString() ?? ''),
    );
  }

  /// Convertit l'OrderCarrier en format JSON pour PrestaShop
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id.toString(),
      'name': name,
      if (url != null) 'url': url,
      'active': active ? '1' : '0',
      'deleted': deleted ? '1' : '0',
      if (shippingHandling != null)
        'shipping_handling': shippingHandling.toString(),
      'is_free': isFree ? '1' : '0',
      if (shippingExternal != null) 'shipping_external': shippingExternal,
      'need_range': needRange ? '1' : '0',
      if (externalModuleName != null)
        'external_module_name': externalModuleName,
      if (shippingMethod != null) 'shipping_method': shippingMethod.toString(),
      'position': position.toString(),
      if (maxWidth != null) 'max_width': maxWidth.toString(),
      if (maxHeight != null) 'max_height': maxHeight.toString(),
      if (maxDepth != null) 'max_depth': maxDepth.toString(),
      if (maxWeight != null) 'max_weight': maxWeight.toString(),
      if (grade != null) 'grade': grade.toString(),
    };
  }

  /// Copie ce OrderCarrier avec des modifications
  OrderCarrier copyWith({
    int? id,
    String? name,
    String? url,
    bool? active,
    bool? deleted,
    double? shippingHandling,
    bool? isFree,
    String? shippingExternal,
    bool? needRange,
    String? externalModuleName,
    double? shippingMethod,
    int? position,
    double? maxWidth,
    double? maxHeight,
    double? maxDepth,
    double? maxWeight,
    double? grade,
    DateTime? dateAdd,
    DateTime? dateUpd,
  }) {
    return OrderCarrier(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      active: active ?? this.active,
      deleted: deleted ?? this.deleted,
      shippingHandling: shippingHandling ?? this.shippingHandling,
      isFree: isFree ?? this.isFree,
      shippingExternal: shippingExternal ?? this.shippingExternal,
      needRange: needRange ?? this.needRange,
      externalModuleName: externalModuleName ?? this.externalModuleName,
      shippingMethod: shippingMethod ?? this.shippingMethod,
      position: position ?? this.position,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      maxDepth: maxDepth ?? this.maxDepth,
      maxWeight: maxWeight ?? this.maxWeight,
      grade: grade ?? this.grade,
      dateAdd: dateAdd ?? this.dateAdd,
      dateUpd: dateUpd ?? this.dateUpd,
    );
  }

  @override
  String toString() => 'OrderCarrier(id: $id, name: $name, active: $active)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderCarrier && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
