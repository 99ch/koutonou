import '../../../core/models/base_model.dart';

/// Represents a delivery configuration in PrestaShop
class Delivery extends BaseModel {
  final int idCarrier;
  final int idRangePrice;
  final int idRangeWeight;
  final int idZone;
  final int? idShop;
  final int? idShopGroup;
  final double price;

  Delivery({
    super.id,
    required this.idCarrier,
    required this.idRangePrice,
    required this.idRangeWeight,
    required this.idZone,
    this.idShop,
    this.idShopGroup,
    required this.price,
  });

  @override
  List<Object?> get props => [
    id,
    idCarrier,
    idRangePrice,
    idRangeWeight,
    idZone,
    idShop,
    idShopGroup,
    price,
  ];

  /// Factory constructor from JSON
  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      idCarrier: int.parse(json['id_carrier'].toString()),
      idRangePrice: int.parse(json['id_range_price'].toString()),
      idRangeWeight: int.parse(json['id_range_weight'].toString()),
      idZone: int.parse(json['id_zone'].toString()),
      idShop: json['id_shop'] != null
          ? int.tryParse(json['id_shop'].toString())
          : null,
      idShopGroup: json['id_shop_group'] != null
          ? int.tryParse(json['id_shop_group'].toString())
          : null,
      price: double.parse(json['price'].toString()),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id_carrier': idCarrier.toString(),
      'id_range_price': idRangePrice.toString(),
      'id_range_weight': idRangeWeight.toString(),
      'id_zone': idZone.toString(),
      'price': price.toString(),
    };

    if (id != null) json['id'] = id.toString();
    if (idShop != null) json['id_shop'] = idShop.toString();
    if (idShopGroup != null) json['id_shop_group'] = idShopGroup.toString();

    return json;
  }

  /// Convert to XML for PrestaShop API
  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">');
    buffer.writeln('  <delivery>');

    if (id != null) buffer.writeln('    <id><![CDATA[$id]]></id>');
    buffer.writeln('    <id_carrier><![CDATA[$idCarrier]]></id_carrier>');
    buffer.writeln(
      '    <id_range_price><![CDATA[$idRangePrice]]></id_range_price>',
    );
    buffer.writeln(
      '    <id_range_weight><![CDATA[$idRangeWeight]]></id_range_weight>',
    );
    buffer.writeln('    <id_zone><![CDATA[$idZone]]></id_zone>');
    if (idShop != null) {
      buffer.writeln('    <id_shop><![CDATA[$idShop]]></id_shop>');
    }
    if (idShopGroup != null) {
      buffer.writeln(
        '    <id_shop_group><![CDATA[$idShopGroup]]></id_shop_group>',
      );
    }
    buffer.writeln('    <price><![CDATA[$price]]></price>');

    buffer.writeln('  </delivery>');
    buffer.writeln('</prestashop>');
    return buffer.toString();
  }

  /// Create a copy with modified fields
  Delivery copyWith({
    int? id,
    int? idCarrier,
    int? idRangePrice,
    int? idRangeWeight,
    int? idZone,
    int? idShop,
    int? idShopGroup,
    double? price,
  }) {
    return Delivery(
      id: id ?? this.id,
      idCarrier: idCarrier ?? this.idCarrier,
      idRangePrice: idRangePrice ?? this.idRangePrice,
      idRangeWeight: idRangeWeight ?? this.idRangeWeight,
      idZone: idZone ?? this.idZone,
      idShop: idShop ?? this.idShop,
      idShopGroup: idShopGroup ?? this.idShopGroup,
      price: price ?? this.price,
    );
  }

  // Business logic methods
  bool get isFree => price <= 0.0;
  String get formattedPrice => '${price.toStringAsFixed(2)}€';
}
