/// Modèle CustomerMessage pour PrestaShop API
/// Représente un message de service client
class CustomerMessage {
  final int? id;
  final int? idEmployee;
  final int? idCustomerThread;
  final String? ipAddress;
  final String message;
  final String? fileName;
  final String? userAgent;
  final bool isPrivate;
  final DateTime? dateAdd;
  final DateTime? dateUpd;
  final bool isRead;

  const CustomerMessage({
    this.id,
    this.idEmployee,
    this.idCustomerThread,
    this.ipAddress,
    required this.message,
    this.fileName,
    this.userAgent,
    this.isPrivate = false,
    this.dateAdd,
    this.dateUpd,
    this.isRead = false,
  });

  /// Crée un CustomerMessage à partir de la réponse JSON de PrestaShop
  factory CustomerMessage.fromPrestaShopJson(Map<String, dynamic> json) {
    return CustomerMessage(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idEmployee: int.tryParse(json['id_employee']?.toString() ?? '0'),
      idCustomerThread: int.tryParse(
        json['id_customer_thread']?.toString() ?? '0',
      ),
      ipAddress: json['ip_address']?.toString(),
      message: json['message']?.toString() ?? '',
      fileName: json['file_name']?.toString(),
      userAgent: json['user_agent']?.toString(),
      isPrivate: json['private']?.toString() == '1',
      dateAdd:
          json['date_add'] != null && json['date_add'].toString().isNotEmpty
          ? DateTime.tryParse(json['date_add'].toString())
          : null,
      dateUpd:
          json['date_upd'] != null && json['date_upd'].toString().isNotEmpty
          ? DateTime.tryParse(json['date_upd'].toString())
          : null,
      isRead: json['read']?.toString() == '1',
    );
  }

  /// Convertit le CustomerMessage en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'message': message,
      'private': isPrivate ? '1' : '0',
      'read': isRead ? '1' : '0',
    };

    if (id != null) json['id'] = id.toString();
    if (idEmployee != null && idEmployee! > 0)
      json['id_employee'] = idEmployee.toString();
    if (idCustomerThread != null && idCustomerThread! > 0)
      json['id_customer_thread'] = idCustomerThread.toString();
    if (ipAddress != null && ipAddress!.isNotEmpty)
      json['ip_address'] = ipAddress;
    if (fileName != null && fileName!.isNotEmpty) json['file_name'] = fileName;
    if (userAgent != null && userAgent!.isNotEmpty)
      json['user_agent'] = userAgent;

    return json;
  }

  /// Convertit le CustomerMessage en format XML pour PrestaShop
  String toPrestaShopXml() {
    final buffer = StringBuffer();
    buffer.writeln('<customer_message>');

    if (id != null) buffer.writeln('  <id><![CDATA[${id}]]></id>');
    if (idEmployee != null && idEmployee! > 0)
      buffer.writeln('  <id_employee><![CDATA[${idEmployee}]]></id_employee>');
    if (idCustomerThread != null && idCustomerThread! > 0)
      buffer.writeln(
        '  <id_customer_thread><![CDATA[${idCustomerThread}]]></id_customer_thread>',
      );
    if (ipAddress != null && ipAddress!.isNotEmpty)
      buffer.writeln('  <ip_address><![CDATA[${ipAddress}]]></ip_address>');

    buffer.writeln('  <message><![CDATA[${message}]]></message>');

    if (fileName != null && fileName!.isNotEmpty)
      buffer.writeln('  <file_name><![CDATA[${fileName}]]></file_name>');
    if (userAgent != null && userAgent!.isNotEmpty)
      buffer.writeln('  <user_agent><![CDATA[${userAgent}]]></user_agent>');

    buffer.writeln('  <private><![CDATA[${isPrivate ? '1' : '0'}]]></private>');
    buffer.writeln('  <read><![CDATA[${isRead ? '1' : '0'}]]></read>');

    buffer.writeln('</customer_message>');
    return buffer.toString();
  }

  /// Type de message (employé ou client)
  String get messageType => idEmployee != null && idEmployee! > 0
      ? 'Réponse support'
      : 'Message client';

  /// Statut de lecture
  String get readStatus => isRead ? 'Lu' : 'Non lu';

  /// Visibilité du message
  String get visibilityStatus => isPrivate ? 'Privé' : 'Public';

  /// Vérifie si le message a une pièce jointe
  bool get hasAttachment => fileName != null && fileName!.isNotEmpty;

  /// Vérifie si le message provient d'un employé
  bool get isFromEmployee => idEmployee != null && idEmployee! > 0;

  /// Date formatée d'ajout
  String get formattedDateAdd {
    if (dateAdd == null) return 'Date inconnue';
    return '${dateAdd!.day.toString().padLeft(2, '0')}/${dateAdd!.month.toString().padLeft(2, '0')}/${dateAdd!.year} à ${dateAdd!.hour.toString().padLeft(2, '0')}h${dateAdd!.minute.toString().padLeft(2, '0')}';
  }

  /// Aperçu du message (premiers mots)
  String get messagePreview {
    if (message.length <= 100) return message;
    return '${message.substring(0, 97)}...';
  }

  @override
  String toString() {
    return 'CustomerMessage(id: $id, messageType: $messageType, read: $isRead, preview: ${messagePreview})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomerMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
