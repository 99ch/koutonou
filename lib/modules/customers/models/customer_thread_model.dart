/// Modèle CustomerThread pour PrestaShop API
/// Représente un fil de discussion de service client
class CustomerThread {
  final int? id;
  final int idLang;
  final int? idShop;
  final int? idCustomer;
  final int? idOrder;
  final int? idProduct;
  final int idContact;
  final String? email;
  final String token;
  final String? status;
  final DateTime? dateAdd;
  final DateTime? dateUpd;
  final List<int>? customerMessageIds; // Associations avec les messages

  const CustomerThread({
    this.id,
    required this.idLang,
    this.idShop,
    this.idCustomer,
    this.idOrder,
    this.idProduct,
    required this.idContact,
    this.email,
    required this.token,
    this.status,
    this.dateAdd,
    this.dateUpd,
    this.customerMessageIds,
  });

  /// Crée un CustomerThread à partir de la réponse JSON de PrestaShop
  factory CustomerThread.fromPrestaShopJson(Map<String, dynamic> json) {
    // Parse les associations de messages
    List<int>? parseMessageIds;
    if (json['associations'] != null) {
      final associations = json['associations'] as Map<String, dynamic>;
      if (associations['customer_messages'] != null) {
        final messagesData = associations['customer_messages'];
        if (messagesData['customer_message'] is List) {
          final messagesList = messagesData['customer_message'] as List;
          parseMessageIds = messagesList
              .map((message) => int.tryParse(message['id']?.toString() ?? '0'))
              .where((id) => id != null && id > 0)
              .cast<int>()
              .toList();
        } else if (messagesData['customer_message'] is Map) {
          final messageData =
              messagesData['customer_message'] as Map<String, dynamic>;
          final messageId = int.tryParse(messageData['id']?.toString() ?? '0');
          if (messageId != null && messageId > 0) {
            parseMessageIds = [messageId];
          }
        }
      }
    }

    return CustomerThread(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idLang: int.tryParse(json['id_lang']?.toString() ?? '0') ?? 1,
      idShop: int.tryParse(json['id_shop']?.toString() ?? '0'),
      idCustomer: int.tryParse(json['id_customer']?.toString() ?? '0'),
      idOrder: int.tryParse(json['id_order']?.toString() ?? '0'),
      idProduct: int.tryParse(json['id_product']?.toString() ?? '0'),
      idContact: int.tryParse(json['id_contact']?.toString() ?? '0') ?? 0,
      email: json['email']?.toString(),
      token: json['token']?.toString() ?? '',
      status: json['status']?.toString(),
      dateAdd:
          json['date_add'] != null && json['date_add'].toString().isNotEmpty
          ? DateTime.tryParse(json['date_add'].toString())
          : null,
      dateUpd:
          json['date_upd'] != null && json['date_upd'].toString().isNotEmpty
          ? DateTime.tryParse(json['date_upd'].toString())
          : null,
      customerMessageIds: parseMessageIds,
    );
  }

  /// Convertit le CustomerThread en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'id_lang': idLang.toString(),
      'id_contact': idContact.toString(),
      'token': token,
    };

    if (id != null) json['id'] = id.toString();
    if (idShop != null && idShop! > 0) json['id_shop'] = idShop.toString();
    if (idCustomer != null && idCustomer! > 0)
      json['id_customer'] = idCustomer.toString();
    if (idOrder != null && idOrder! > 0) json['id_order'] = idOrder.toString();
    if (idProduct != null && idProduct! > 0)
      json['id_product'] = idProduct.toString();
    if (email != null && email!.isNotEmpty) json['email'] = email;
    if (status != null && status!.isNotEmpty) json['status'] = status;

    return json;
  }

  /// Convertit le CustomerThread en format XML pour PrestaShop
  String toPrestaShopXml() {
    final buffer = StringBuffer();
    buffer.writeln('<customer_thread>');

    if (id != null) buffer.writeln('  <id><![CDATA[${id}]]></id>');
    buffer.writeln('  <id_lang><![CDATA[${idLang}]]></id_lang>');
    if (idShop != null && idShop! > 0)
      buffer.writeln('  <id_shop><![CDATA[${idShop}]]></id_shop>');
    if (idCustomer != null && idCustomer! > 0)
      buffer.writeln('  <id_customer><![CDATA[${idCustomer}]]></id_customer>');
    if (idOrder != null && idOrder! > 0)
      buffer.writeln('  <id_order><![CDATA[${idOrder}]]></id_order>');
    if (idProduct != null && idProduct! > 0)
      buffer.writeln('  <id_product><![CDATA[${idProduct}]]></id_product>');
    buffer.writeln('  <id_contact><![CDATA[${idContact}]]></id_contact>');

    if (email != null && email!.isNotEmpty)
      buffer.writeln('  <email><![CDATA[${email}]]></email>');
    buffer.writeln('  <token><![CDATA[${token}]]></token>');
    if (status != null && status!.isNotEmpty)
      buffer.writeln('  <status><![CDATA[${status}]]></status>');

    // Associations avec les messages
    if (customerMessageIds != null && customerMessageIds!.isNotEmpty) {
      buffer.writeln('  <associations>');
      buffer.writeln('    <customer_messages>');
      for (final messageId in customerMessageIds!) {
        buffer.writeln('      <customer_message>');
        buffer.writeln('        <id><![CDATA[${messageId}]]></id>');
        buffer.writeln('      </customer_message>');
      }
      buffer.writeln('    </customer_messages>');
      buffer.writeln('  </associations>');
    }

    buffer.writeln('</customer_thread>');
    return buffer.toString();
  }

  /// Type de sujet basé sur les associations
  String get threadType {
    if (idOrder != null && idOrder! > 0) return 'Commande';
    if (idProduct != null && idProduct! > 0) return 'Produit';
    if (idCustomer != null && idCustomer! > 0) return 'Client';
    return 'Général';
  }

  /// Statut formaté
  String get formattedStatus {
    if (status == null || status!.isEmpty) return 'Ouvert';
    switch (status!.toLowerCase()) {
      case 'open':
        return 'Ouvert';
      case 'closed':
        return 'Fermé';
      case 'pending1':
        return 'En attente client';
      case 'pending2':
        return 'En attente support';
      default:
        return status!;
    }
  }

  /// Vérifie si le thread est lié à une commande
  bool get isOrderRelated => idOrder != null && idOrder! > 0;

  /// Vérifie si le thread est lié à un produit
  bool get isProductRelated => idProduct != null && idProduct! > 0;

  /// Vérifie si le thread est lié à un client
  bool get isCustomerRelated => idCustomer != null && idCustomer! > 0;

  /// Vérifie si le thread a des messages
  bool get hasMessages =>
      customerMessageIds != null && customerMessageIds!.isNotEmpty;

  /// Nombre de messages
  int get messageCount => customerMessageIds?.length ?? 0;

  /// Vérifie si le thread est fermé
  bool get isClosed => status?.toLowerCase() == 'closed';

  /// Vérifie si le thread est ouvert
  bool get isOpen =>
      status == null || status!.isEmpty || status!.toLowerCase() == 'open';

  /// Date formatée d'ajout
  String get formattedDateAdd {
    if (dateAdd == null) return 'Date inconnue';
    return '${dateAdd!.day.toString().padLeft(2, '0')}/${dateAdd!.month.toString().padLeft(2, '0')}/${dateAdd!.year}';
  }

  /// Date formatée de dernière mise à jour
  String get formattedDateUpd {
    if (dateUpd == null) return 'Jamais modifié';
    return '${dateUpd!.day.toString().padLeft(2, '0')}/${dateUpd!.month.toString().padLeft(2, '0')}/${dateUpd!.year}';
  }

  @override
  String toString() {
    return 'CustomerThread(id: $id, type: $threadType, status: $formattedStatus, messages: $messageCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomerThread && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
