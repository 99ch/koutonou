import '../../../core/models/base_model.dart';

/// Represents a price range for shipping calculation in PrestaShop
class PriceRange extends BaseModel {
  final int idCarrier;
  final double delimiter1;
  final double delimiter2;

  PriceRange({
    super.id,
    required this.idCarrier,
    required this.delimiter1,
    required this.delimiter2,
  });

  @override
  List<Object?> get props => [id, idCarrier, delimiter1, delimiter2];

  /// Factory constructor from JSON
  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      idCarrier: int.parse(json['id_carrier'].toString()),
      delimiter1: double.parse(json['delimiter1'].toString()),
      delimiter2: double.parse(json['delimiter2'].toString()),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'id_carrier': idCarrier.toString(),
      'delimiter1': delimiter1.toString(),
      'delimiter2': delimiter2.toString(),
    };

    if (id != null) json['id'] = id.toString();

    return json;
  }

  /// Convert to XML for PrestaShop API
  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">');
    buffer.writeln('  <price_range>');

    if (id != null) buffer.writeln('    <id><![CDATA[$id]]></id>');
    buffer.writeln('    <id_carrier><![CDATA[$idCarrier]]></id_carrier>');
    buffer.writeln('    <delimiter1><![CDATA[$delimiter1]]></delimiter1>');
    buffer.writeln('    <delimiter2><![CDATA[$delimiter2]]></delimiter2>');

    buffer.writeln('  </price_range>');
    buffer.writeln('</prestashop>');
    return buffer.toString();
  }

  /// Create a copy with modified fields
  PriceRange copyWith({
    int? id,
    int? idCarrier,
    double? delimiter1,
    double? delimiter2,
  }) {
    return PriceRange(
      id: id ?? this.id,
      idCarrier: idCarrier ?? this.idCarrier,
      delimiter1: delimiter1 ?? this.delimiter1,
      delimiter2: delimiter2 ?? this.delimiter2,
    );
  }

  // Business logic methods
  double get minPrice => delimiter1 < delimiter2 ? delimiter1 : delimiter2;
  double get maxPrice => delimiter1 > delimiter2 ? delimiter1 : delimiter2;
  double get rangeSize => (delimiter2 - delimiter1).abs();
  String get rangeDescription =>
      '${minPrice.toStringAsFixed(2)}€ - ${maxPrice.toStringAsFixed(2)}€';

  bool includesPrice(double price) {
    return price >= minPrice && price <= maxPrice;
  }

  bool overlapsWith(PriceRange other) {
    return !(maxPrice < other.minPrice || minPrice > other.maxPrice);
  }
}
