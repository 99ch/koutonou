/// Modèle OrderPayment pour PrestaShop API
/// Représente un paiement de commande avec tous ses attributs
class OrderPayment {
  final int? id;
  final String? orderReference;
  final int idCurrency;
  final double amount;
  final String? paymentMethod;
  final double? conversionRate;
  final String? transactionId;
  final String? cardNumber;
  final String? cardBrand;
  final String? cardExpiration;
  final String? cardHolder;
  final DateTime? dateAdd;

  const OrderPayment({
    this.id,
    this.orderReference,
    required this.idCurrency,
    required this.amount,
    this.paymentMethod,
    this.conversionRate,
    this.transactionId,
    this.cardNumber,
    this.cardBrand,
    this.cardExpiration,
    this.cardHolder,
    this.dateAdd,
  });

  /// Crée un OrderPayment à partir de la réponse JSON de PrestaShop
  factory OrderPayment.fromPrestaShopJson(Map<String, dynamic> json) {
    return OrderPayment(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      orderReference: json['order_reference']?.toString(),
      idCurrency: int.tryParse(json['id_currency']?.toString() ?? '0') ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      paymentMethod: json['payment_method']?.toString(),
      conversionRate: double.tryParse(
        json['conversion_rate']?.toString() ?? '0',
      ),
      transactionId: json['transaction_id']?.toString(),
      cardNumber: json['card_number']?.toString(),
      cardBrand: json['card_brand']?.toString(),
      cardExpiration: json['card_expiration']?.toString(),
      cardHolder: json['card_holder']?.toString(),
      dateAdd: DateTime.tryParse(json['date_add']?.toString() ?? ''),
    );
  }

  /// Convertit l'OrderPayment en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'id_currency': idCurrency.toString(),
      'amount': amount.toString(),
    };

    if (orderReference != null) json['order_reference'] = orderReference;
    if (paymentMethod != null) json['payment_method'] = paymentMethod;
    if (conversionRate != null)
      json['conversion_rate'] = conversionRate.toString();
    if (transactionId != null) json['transaction_id'] = transactionId;
    if (cardNumber != null) json['card_number'] = cardNumber;
    if (cardBrand != null) json['card_brand'] = cardBrand;
    if (cardExpiration != null) json['card_expiration'] = cardExpiration;
    if (cardHolder != null) json['card_holder'] = cardHolder;

    return json;
  }

  /// Copie cet OrderPayment avec des modifications
  OrderPayment copyWith({
    int? id,
    String? orderReference,
    int? idCurrency,
    double? amount,
    String? paymentMethod,
    double? conversionRate,
    String? transactionId,
    String? cardNumber,
    String? cardBrand,
    String? cardExpiration,
    String? cardHolder,
    DateTime? dateAdd,
  }) {
    return OrderPayment(
      id: id ?? this.id,
      orderReference: orderReference ?? this.orderReference,
      idCurrency: idCurrency ?? this.idCurrency,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      conversionRate: conversionRate ?? this.conversionRate,
      transactionId: transactionId ?? this.transactionId,
      cardNumber: cardNumber ?? this.cardNumber,
      cardBrand: cardBrand ?? this.cardBrand,
      cardExpiration: cardExpiration ?? this.cardExpiration,
      cardHolder: cardHolder ?? this.cardHolder,
      dateAdd: dateAdd ?? this.dateAdd,
    );
  }

  @override
  String toString() =>
      'OrderPayment(id: $id, amount: $amount, method: $paymentMethod)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderPayment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
