/// Modèle OrderState pour PrestaShop API
/// Représente un état de commande avec tous ses attributs
class OrderState {
  final int? id;
  final bool unremovable;
  final bool delivery;
  final bool hidden;
  final bool sendEmail;
  final String? moduleName;
  final bool invoice;
  final String? color;
  final bool logable;
  final bool shipped;
  final bool paid;
  final bool pdfDelivery;
  final bool pdfInvoice;
  final bool deleted;
  final String name;
  final String? template;

  const OrderState({
    this.id,
    this.unremovable = false,
    this.delivery = false,
    this.hidden = false,
    this.sendEmail = false,
    this.moduleName,
    this.invoice = false,
    this.color,
    this.logable = false,
    this.shipped = false,
    this.paid = false,
    this.pdfDelivery = false,
    this.pdfInvoice = false,
    this.deleted = false,
    required this.name,
    this.template,
  });

  /// Crée un OrderState à partir de la réponse JSON de PrestaShop
  factory OrderState.fromPrestaShopJson(Map<String, dynamic> json) {
    // Extraction du nom (gérer le format multilingue)
    String name = '';
    if (json['name'] is String) {
      name = json['name'] as String;
    } else if (json['name'] is Map) {
      final nameData = json['name'] as Map<String, dynamic>;
      if (nameData['language'] is List) {
        final languages = nameData['language'] as List;
        if (languages.isNotEmpty) {
          name = languages.first['value']?.toString() ?? '';
        }
      }
    }

    // Extraction du template (gérer le format multilingue)
    String? template;
    if (json['template'] is String) {
      template = json['template'] as String;
    } else if (json['template'] is Map) {
      final templateData = json['template'] as Map<String, dynamic>;
      if (templateData['language'] is List) {
        final languages = templateData['language'] as List;
        if (languages.isNotEmpty) {
          template = languages.first['value']?.toString();
        }
      }
    }

    return OrderState(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      unremovable: json['unremovable']?.toString() == '1',
      delivery: json['delivery']?.toString() == '1',
      hidden: json['hidden']?.toString() == '1',
      sendEmail: json['send_email']?.toString() == '1',
      moduleName: json['module_name']?.toString(),
      invoice: json['invoice']?.toString() == '1',
      color: json['color']?.toString(),
      logable: json['logable']?.toString() == '1',
      shipped: json['shipped']?.toString() == '1',
      paid: json['paid']?.toString() == '1',
      pdfDelivery: json['pdf_delivery']?.toString() == '1',
      pdfInvoice: json['pdf_invoice']?.toString() == '1',
      deleted: json['deleted']?.toString() == '1',
      name: name,
      template: template,
    );
  }

  /// Convertit l'OrderState en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson({int languageId = 1}) {
    final json = <String, dynamic>{
      'unremovable': unremovable ? '1' : '0',
      'delivery': delivery ? '1' : '0',
      'hidden': hidden ? '1' : '0',
      'send_email': sendEmail ? '1' : '0',
      'invoice': invoice ? '1' : '0',
      'logable': logable ? '1' : '0',
      'shipped': shipped ? '1' : '0',
      'paid': paid ? '1' : '0',
      'pdf_delivery': pdfDelivery ? '1' : '0',
      'pdf_invoice': pdfInvoice ? '1' : '0',
      'deleted': deleted ? '1' : '0',
      'name': {
        'language': [
          {'id': languageId.toString(), 'value': name},
        ],
      },
    };

    if (moduleName != null) json['module_name'] = moduleName;
    if (color != null) json['color'] = color;

    if (template != null) {
      json['template'] = {
        'language': [
          {'id': languageId.toString(), 'value': template},
        ],
      };
    }

    return json;
  }

  /// Copie cet OrderState avec des modifications
  OrderState copyWith({
    int? id,
    bool? unremovable,
    bool? delivery,
    bool? hidden,
    bool? sendEmail,
    String? moduleName,
    bool? invoice,
    String? color,
    bool? logable,
    bool? shipped,
    bool? paid,
    bool? pdfDelivery,
    bool? pdfInvoice,
    bool? deleted,
    String? name,
    String? template,
  }) {
    return OrderState(
      id: id ?? this.id,
      unremovable: unremovable ?? this.unremovable,
      delivery: delivery ?? this.delivery,
      hidden: hidden ?? this.hidden,
      sendEmail: sendEmail ?? this.sendEmail,
      moduleName: moduleName ?? this.moduleName,
      invoice: invoice ?? this.invoice,
      color: color ?? this.color,
      logable: logable ?? this.logable,
      shipped: shipped ?? this.shipped,
      paid: paid ?? this.paid,
      pdfDelivery: pdfDelivery ?? this.pdfDelivery,
      pdfInvoice: pdfInvoice ?? this.pdfInvoice,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      template: template ?? this.template,
    );
  }

  @override
  String toString() =>
      'OrderState(id: $id, name: $name, shipped: $shipped, paid: $paid)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderState && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
