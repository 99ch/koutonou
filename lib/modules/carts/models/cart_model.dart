import '../../../core/models/base_model.dart';

/// Represents a shopping cart in PrestaShop
class Cart extends BaseModel {
  final int? idAddressDelivery;
  final int? idAddressInvoice;
  final int idCurrency;
  final int? idCustomer;
  final int? idGuest;
  final int idLang;
  final int? idShopGroup;
  final int? idShop;
  final int? idCarrier;
  final bool recyclable;
  final bool gift;
  final String? giftMessage;
  final bool mobileTheme;
  final String? deliveryOption;
  final String? secureKey;
  final bool allowSeperatedPackage;
  final DateTime? dateAdd;
  final DateTime? dateUpd;
  final List<CartRow>? cartRows;

  Cart({
    super.id,
    this.idAddressDelivery,
    this.idAddressInvoice,
    required this.idCurrency,
    this.idCustomer,
    this.idGuest,
    required this.idLang,
    this.idShopGroup,
    this.idShop,
    this.idCarrier,
    this.recyclable = false,
    this.gift = false,
    this.giftMessage,
    this.mobileTheme = false,
    this.deliveryOption,
    this.secureKey,
    this.allowSeperatedPackage = false,
    this.dateAdd,
    this.dateUpd,
    this.cartRows,
  });

  @override
  Cart copyWith({
    int? id,
    int? idAddressDelivery,
    int? idAddressInvoice,
    int? idCurrency,
    int? idCustomer,
    int? idGuest,
    int? idLang,
    int? idShopGroup,
    int? idShop,
    int? idCarrier,
    bool? recyclable,
    bool? gift,
    String? giftMessage,
    bool? mobileTheme,
    String? deliveryOption,
    String? secureKey,
    bool? allowSeperatedPackage,
    DateTime? dateAdd,
    DateTime? dateUpd,
    List<CartRow>? cartRows,
  }) {
    return Cart(
      id: id ?? this.id,
      idAddressDelivery: idAddressDelivery ?? this.idAddressDelivery,
      idAddressInvoice: idAddressInvoice ?? this.idAddressInvoice,
      idCurrency: idCurrency ?? this.idCurrency,
      idCustomer: idCustomer ?? this.idCustomer,
      idGuest: idGuest ?? this.idGuest,
      idLang: idLang ?? this.idLang,
      idShopGroup: idShopGroup ?? this.idShopGroup,
      idShop: idShop ?? this.idShop,
      idCarrier: idCarrier ?? this.idCarrier,
      recyclable: recyclable ?? this.recyclable,
      gift: gift ?? this.gift,
      giftMessage: giftMessage ?? this.giftMessage,
      mobileTheme: mobileTheme ?? this.mobileTheme,
      deliveryOption: deliveryOption ?? this.deliveryOption,
      secureKey: secureKey ?? this.secureKey,
      allowSeperatedPackage:
          allowSeperatedPackage ?? this.allowSeperatedPackage,
      dateAdd: dateAdd ?? this.dateAdd,
      dateUpd: dateUpd ?? this.dateUpd,
      cartRows: cartRows ?? this.cartRows,
    );
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      idAddressDelivery: json['id_address_delivery'] != null
          ? int.tryParse(json['id_address_delivery'].toString())
          : null,
      idAddressInvoice: json['id_address_invoice'] != null
          ? int.tryParse(json['id_address_invoice'].toString())
          : null,
      idCurrency: int.tryParse(json['id_currency'].toString()) ?? 0,
      idCustomer: json['id_customer'] != null
          ? int.tryParse(json['id_customer'].toString())
          : null,
      idGuest: json['id_guest'] != null
          ? int.tryParse(json['id_guest'].toString())
          : null,
      idLang: int.tryParse(json['id_lang'].toString()) ?? 1,
      idShopGroup: json['id_shop_group'] != null
          ? int.tryParse(json['id_shop_group'].toString())
          : null,
      idShop: json['id_shop'] != null
          ? int.tryParse(json['id_shop'].toString())
          : null,
      idCarrier: json['id_carrier'] != null
          ? int.tryParse(json['id_carrier'].toString())
          : null,
      recyclable: _parseBool(json['recyclable']),
      gift: _parseBool(json['gift']),
      giftMessage: json['gift_message']?.toString(),
      mobileTheme: _parseBool(json['mobile_theme']),
      deliveryOption: json['delivery_option']?.toString(),
      secureKey: json['secure_key']?.toString(),
      allowSeperatedPackage: _parseBool(json['allow_seperated_package']),
      dateAdd: json['date_add'] != null
          ? DateTime.tryParse(json['date_add'].toString())
          : null,
      dateUpd: json['date_upd'] != null
          ? DateTime.tryParse(json['date_upd'].toString())
          : null,
      cartRows: json['associations']?['cart_rows'] != null
          ? (json['associations']['cart_rows'] as List)
                .map((e) => CartRow.fromJson(e))
                .toList()
          : null,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return false;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (idAddressDelivery != null) 'id_address_delivery': idAddressDelivery,
      if (idAddressInvoice != null) 'id_address_invoice': idAddressInvoice,
      'id_currency': idCurrency,
      if (idCustomer != null) 'id_customer': idCustomer,
      if (idGuest != null) 'id_guest': idGuest,
      'id_lang': idLang,
      if (idShopGroup != null) 'id_shop_group': idShopGroup,
      if (idShop != null) 'id_shop': idShop,
      if (idCarrier != null) 'id_carrier': idCarrier,
      'recyclable': recyclable ? 1 : 0,
      'gift': gift ? 1 : 0,
      if (giftMessage != null) 'gift_message': giftMessage,
      'mobile_theme': mobileTheme ? 1 : 0,
      if (deliveryOption != null) 'delivery_option': deliveryOption,
      if (secureKey != null) 'secure_key': secureKey,
      'allow_seperated_package': allowSeperatedPackage ? 1 : 0,
      if (dateAdd != null) 'date_add': dateAdd!.toIso8601String(),
      if (dateUpd != null) 'date_upd': dateUpd!.toIso8601String(),
      if (cartRows != null)
        'associations': {
          'cart_rows': cartRows!.map((e) => e.toJson()).toList(),
        },
    };
  }

  String toXml() {
    final buffer = StringBuffer();
    buffer.writeln('<prestashop xmlns:xlink="http://www.w3.org/1999/xlink">');
    buffer.writeln('  <cart>');

    if (id != null) buffer.writeln('    <id><![CDATA[$id]]></id>');
    if (idAddressDelivery != null)
      buffer.writeln(
        '    <id_address_delivery><![CDATA[$idAddressDelivery]]></id_address_delivery>',
      );
    if (idAddressInvoice != null)
      buffer.writeln(
        '    <id_address_invoice><![CDATA[$idAddressInvoice]]></id_address_invoice>',
      );
    buffer.writeln('    <id_currency><![CDATA[$idCurrency]]></id_currency>');
    if (idCustomer != null)
      buffer.writeln('    <id_customer><![CDATA[$idCustomer]]></id_customer>');
    if (idGuest != null)
      buffer.writeln('    <id_guest><![CDATA[$idGuest]]></id_guest>');
    buffer.writeln('    <id_lang><![CDATA[$idLang]]></id_lang>');
    if (idShopGroup != null)
      buffer.writeln(
        '    <id_shop_group><![CDATA[$idShopGroup]]></id_shop_group>',
      );
    if (idShop != null)
      buffer.writeln('    <id_shop><![CDATA[$idShop]]></id_shop>');
    if (idCarrier != null)
      buffer.writeln('    <id_carrier><![CDATA[$idCarrier]]></id_carrier>');
    buffer.writeln(
      '    <recyclable><![CDATA[${recyclable ? 1 : 0}]]></recyclable>',
    );
    buffer.writeln('    <gift><![CDATA[${gift ? 1 : 0}]]></gift>');
    if (giftMessage != null)
      buffer.writeln(
        '    <gift_message><![CDATA[$giftMessage]]></gift_message>',
      );
    buffer.writeln(
      '    <mobile_theme><![CDATA[${mobileTheme ? 1 : 0}]]></mobile_theme>',
    );
    if (deliveryOption != null)
      buffer.writeln(
        '    <delivery_option><![CDATA[$deliveryOption]]></delivery_option>',
      );
    if (secureKey != null)
      buffer.writeln('    <secure_key><![CDATA[$secureKey]]></secure_key>');
    buffer.writeln(
      '    <allow_seperated_package><![CDATA[${allowSeperatedPackage ? 1 : 0}]]></allow_seperated_package>',
    );
    if (dateAdd != null)
      buffer.writeln(
        '    <date_add><![CDATA[${dateAdd!.toIso8601String()}]]></date_add>',
      );
    if (dateUpd != null)
      buffer.writeln(
        '    <date_upd><![CDATA[${dateUpd!.toIso8601String()}]]></date_upd>',
      );

    if (cartRows != null && cartRows!.isNotEmpty) {
      buffer.writeln('    <associations>');
      buffer.writeln('      <cart_rows>');
      for (final row in cartRows!) {
        buffer.writeln('        <cart_row>');
        buffer.writeln(
          '          <id_product><![CDATA[${row.idProduct}]]></id_product>',
        );
        if (row.idProductAttribute != null)
          buffer.writeln(
            '          <id_product_attribute><![CDATA[${row.idProductAttribute}]]></id_product_attribute>',
          );
        if (row.idAddressDelivery != null)
          buffer.writeln(
            '          <id_address_delivery><![CDATA[${row.idAddressDelivery}]]></id_address_delivery>',
          );
        if (row.idCustomization != null)
          buffer.writeln(
            '          <id_customization><![CDATA[${row.idCustomization}]]></id_customization>',
          );
        buffer.writeln(
          '          <quantity><![CDATA[${row.quantity}]]></quantity>',
        );
        buffer.writeln('        </cart_row>');
      }
      buffer.writeln('      </cart_rows>');
      buffer.writeln('    </associations>');
    }

    buffer.writeln('  </cart>');
    buffer.writeln('</prestashop>');
    return buffer.toString();
  }

  // Business logic methods
  double get totalQuantity {
    if (cartRows == null) return 0;
    return cartRows!.fold(0, (sum, row) => sum + row.quantity);
  }

  int get totalItems {
    return cartRows?.length ?? 0;
  }

  bool get isEmpty => totalItems == 0;

  bool get isNotEmpty => !isEmpty;

  bool get hasGiftMessage =>
      gift && giftMessage != null && giftMessage!.isNotEmpty;

  List<Object?> get props => [
    id,
    idAddressDelivery,
    idAddressInvoice,
    idCurrency,
    idCustomer,
    idGuest,
    idLang,
    idShopGroup,
    idShop,
    idCarrier,
    recyclable,
    gift,
    giftMessage,
    mobileTheme,
    deliveryOption,
    secureKey,
    allowSeperatedPackage,
    dateAdd,
    dateUpd,
    cartRows,
  ];

  @override
  String toString() {
    return 'Cart{id: $id, idCustomer: $idCustomer, totalItems: $totalItems, totalQuantity: $totalQuantity}';
  }
}

/// Represents a cart row (product in cart)
class CartRow {
  final int idProduct;
  final int? idProductAttribute;
  final int? idAddressDelivery;
  final int? idCustomization;
  final int quantity;

  CartRow({
    required this.idProduct,
    this.idProductAttribute,
    this.idAddressDelivery,
    this.idCustomization,
    required this.quantity,
  });

  factory CartRow.fromJson(Map<String, dynamic> json) {
    return CartRow(
      idProduct: int.tryParse(json['id_product'].toString()) ?? 0,
      idProductAttribute: json['id_product_attribute'] != null
          ? int.tryParse(json['id_product_attribute'].toString())
          : null,
      idAddressDelivery: json['id_address_delivery'] != null
          ? int.tryParse(json['id_address_delivery'].toString())
          : null,
      idCustomization: json['id_customization'] != null
          ? int.tryParse(json['id_customization'].toString())
          : null,
      quantity: int.tryParse(json['quantity'].toString()) ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_product': idProduct,
      if (idProductAttribute != null)
        'id_product_attribute': idProductAttribute,
      if (idAddressDelivery != null) 'id_address_delivery': idAddressDelivery,
      if (idCustomization != null) 'id_customization': idCustomization,
      'quantity': quantity,
    };
  }

  @override
  String toString() {
    return 'CartRow{idProduct: $idProduct, quantity: $quantity}';
  }
}
