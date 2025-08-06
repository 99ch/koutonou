/// Modèle OrderHistory pour PrestaShop API
/// Représente l'historique d'une commande avec tous ses attributs
class OrderHistory {
  final int? id;
  final int? idEmployee;
  final int idOrderState;
  final int idOrder;
  final DateTime? dateAdd;

  const OrderHistory({
    this.id,
    this.idEmployee,
    required this.idOrderState,
    required this.idOrder,
    this.dateAdd,
  });

  /// Crée un OrderHistory à partir de la réponse JSON de PrestaShop
  factory OrderHistory.fromPrestaShopJson(Map<String, dynamic> json) {
    return OrderHistory(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idEmployee: int.tryParse(json['id_employee']?.toString() ?? '0'),
      idOrderState:
          int.tryParse(json['id_order_state']?.toString() ?? '0') ?? 0,
      idOrder: int.tryParse(json['id_order']?.toString() ?? '0') ?? 0,
      dateAdd: DateTime.tryParse(json['date_add']?.toString() ?? ''),
    );
  }

  /// Convertit l'OrderHistory en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'id_order_state': idOrderState.toString(),
      'id_order': idOrder.toString(),
    };

    if (idEmployee != null) json['id_employee'] = idEmployee.toString();

    return json;
  }

  /// Copie cet OrderHistory avec des modifications
  OrderHistory copyWith({
    int? id,
    int? idEmployee,
    int? idOrderState,
    int? idOrder,
    DateTime? dateAdd,
  }) {
    return OrderHistory(
      id: id ?? this.id,
      idEmployee: idEmployee ?? this.idEmployee,
      idOrderState: idOrderState ?? this.idOrderState,
      idOrder: idOrder ?? this.idOrder,
      dateAdd: dateAdd ?? this.dateAdd,
    );
  }

  @override
  String toString() =>
      'OrderHistory(id: $id, idOrder: $idOrder, idOrderState: $idOrderState)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderHistory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
