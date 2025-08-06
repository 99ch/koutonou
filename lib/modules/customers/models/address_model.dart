/// Modèle Address pour PrestaShop API
/// Représente une adresse de client/fournisseur/fabricant
class Address {
  final int? id;
  final int? idCustomer;
  final int? idManufacturer;
  final int? idSupplier;
  final int? idWarehouse;
  final int idCountry;
  final int? idState;
  final String alias;
  final String? company;
  final String lastname;
  final String firstname;
  final String? vatNumber;
  final String address1;
  final String? address2;
  final String? postcode;
  final String city;
  final String? other;
  final String? phone;
  final String? phoneMobile;
  final String? dni; // Document d'identification national
  final bool deleted;
  final DateTime? dateAdd;
  final DateTime? dateUpd;

  const Address({
    this.id,
    this.idCustomer,
    this.idManufacturer,
    this.idSupplier,
    this.idWarehouse,
    required this.idCountry,
    this.idState,
    required this.alias,
    this.company,
    required this.lastname,
    required this.firstname,
    this.vatNumber,
    required this.address1,
    this.address2,
    this.postcode,
    required this.city,
    this.other,
    this.phone,
    this.phoneMobile,
    this.dni,
    this.deleted = false,
    this.dateAdd,
    this.dateUpd,
  });

  /// Crée une Address à partir de la réponse JSON de PrestaShop
  factory Address.fromPrestaShopJson(Map<String, dynamic> json) {
    return Address(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idCustomer: int.tryParse(json['id_customer']?.toString() ?? '0'),
      idManufacturer: int.tryParse(json['id_manufacturer']?.toString() ?? '0'),
      idSupplier: int.tryParse(json['id_supplier']?.toString() ?? '0'),
      idWarehouse: int.tryParse(json['id_warehouse']?.toString() ?? '0'),
      idCountry: int.tryParse(json['id_country']?.toString() ?? '0') ?? 0,
      idState: int.tryParse(json['id_state']?.toString() ?? '0'),
      alias: json['alias']?.toString() ?? '',
      company: json['company']?.toString(),
      lastname: json['lastname']?.toString() ?? '',
      firstname: json['firstname']?.toString() ?? '',
      vatNumber: json['vat_number']?.toString(),
      address1: json['address1']?.toString() ?? '',
      address2: json['address2']?.toString(),
      postcode: json['postcode']?.toString(),
      city: json['city']?.toString() ?? '',
      other: json['other']?.toString(),
      phone: json['phone']?.toString(),
      phoneMobile: json['phone_mobile']?.toString(),
      dni: json['dni']?.toString(),
      deleted: json['deleted']?.toString() == '1',
      dateAdd:
          json['date_add'] != null && json['date_add'].toString().isNotEmpty
          ? DateTime.tryParse(json['date_add'].toString())
          : null,
      dateUpd:
          json['date_upd'] != null && json['date_upd'].toString().isNotEmpty
          ? DateTime.tryParse(json['date_upd'].toString())
          : null,
    );
  }

  /// Convertit l'Address en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'id_country': idCountry.toString(),
      'alias': alias,
      'lastname': lastname,
      'firstname': firstname,
      'address1': address1,
      'city': city,
      'deleted': deleted ? '1' : '0',
    };

    if (id != null) json['id'] = id.toString();
    if (idCustomer != null && idCustomer! > 0)
      json['id_customer'] = idCustomer.toString();
    if (idManufacturer != null && idManufacturer! > 0)
      json['id_manufacturer'] = idManufacturer.toString();
    if (idSupplier != null && idSupplier! > 0)
      json['id_supplier'] = idSupplier.toString();
    if (idWarehouse != null && idWarehouse! > 0)
      json['id_warehouse'] = idWarehouse.toString();
    if (idState != null && idState! > 0) json['id_state'] = idState.toString();
    if (company != null && company!.isNotEmpty) json['company'] = company;
    if (vatNumber != null && vatNumber!.isNotEmpty)
      json['vat_number'] = vatNumber;
    if (address2 != null && address2!.isNotEmpty) json['address2'] = address2;
    if (postcode != null && postcode!.isNotEmpty) json['postcode'] = postcode;
    if (other != null && other!.isNotEmpty) json['other'] = other;
    if (phone != null && phone!.isNotEmpty) json['phone'] = phone;
    if (phoneMobile != null && phoneMobile!.isNotEmpty)
      json['phone_mobile'] = phoneMobile;
    if (dni != null && dni!.isNotEmpty) json['dni'] = dni;

    return json;
  }

  /// Convertit l'Address en format XML pour PrestaShop
  String toPrestaShopXml() {
    final buffer = StringBuffer();
    buffer.writeln('<address>');

    if (id != null) buffer.writeln('  <id><![CDATA[${id}]]></id>');
    if (idCustomer != null && idCustomer! > 0)
      buffer.writeln('  <id_customer><![CDATA[${idCustomer}]]></id_customer>');
    if (idManufacturer != null && idManufacturer! > 0)
      buffer.writeln(
        '  <id_manufacturer><![CDATA[${idManufacturer}]]></id_manufacturer>',
      );
    if (idSupplier != null && idSupplier! > 0)
      buffer.writeln('  <id_supplier><![CDATA[${idSupplier}]]></id_supplier>');
    if (idWarehouse != null && idWarehouse! > 0)
      buffer.writeln(
        '  <id_warehouse><![CDATA[${idWarehouse}]]></id_warehouse>',
      );
    buffer.writeln('  <id_country><![CDATA[${idCountry}]]></id_country>');
    if (idState != null && idState! > 0)
      buffer.writeln('  <id_state><![CDATA[${idState}]]></id_state>');

    buffer.writeln('  <alias><![CDATA[${alias}]]></alias>');
    if (company != null && company!.isNotEmpty)
      buffer.writeln('  <company><![CDATA[${company}]]></company>');
    buffer.writeln('  <lastname><![CDATA[${lastname}]]></lastname>');
    buffer.writeln('  <firstname><![CDATA[${firstname}]]></firstname>');
    if (vatNumber != null && vatNumber!.isNotEmpty)
      buffer.writeln('  <vat_number><![CDATA[${vatNumber}]]></vat_number>');
    buffer.writeln('  <address1><![CDATA[${address1}]]></address1>');
    if (address2 != null && address2!.isNotEmpty)
      buffer.writeln('  <address2><![CDATA[${address2}]]></address2>');
    if (postcode != null && postcode!.isNotEmpty)
      buffer.writeln('  <postcode><![CDATA[${postcode}]]></postcode>');
    buffer.writeln('  <city><![CDATA[${city}]]></city>');
    if (other != null && other!.isNotEmpty)
      buffer.writeln('  <other><![CDATA[${other}]]></other>');
    if (phone != null && phone!.isNotEmpty)
      buffer.writeln('  <phone><![CDATA[${phone}]]></phone>');
    if (phoneMobile != null && phoneMobile!.isNotEmpty)
      buffer.writeln(
        '  <phone_mobile><![CDATA[${phoneMobile}]]></phone_mobile>',
      );
    if (dni != null && dni!.isNotEmpty)
      buffer.writeln('  <dni><![CDATA[${dni}]]></dni>');
    buffer.writeln('  <deleted><![CDATA[${deleted ? '1' : '0'}]]></deleted>');

    buffer.writeln('</address>');
    return buffer.toString();
  }

  /// Nom complet de la personne
  String get fullName => '${firstname} ${lastname}'.trim();

  /// Adresse complète formatée
  String get fullAddress {
    final parts = <String>[
      address1,
      if (address2 != null && address2!.isNotEmpty) address2!,
      if (postcode != null && postcode!.isNotEmpty) postcode!,
      city,
    ];
    return parts.join(', ');
  }

  /// Type d'adresse basé sur l'association
  String get addressType {
    if (idCustomer != null && idCustomer! > 0) return 'Client';
    if (idManufacturer != null && idManufacturer! > 0) return 'Fabricant';
    if (idSupplier != null && idSupplier! > 0) return 'Fournisseur';
    if (idWarehouse != null && idWarehouse! > 0) return 'Entrepôt';
    return 'Générale';
  }

  /// Vérifie si l'adresse appartient à un client
  bool get isCustomerAddress => idCustomer != null && idCustomer! > 0;

  /// Vérifie si l'adresse appartient à un fabricant
  bool get isManufacturerAddress =>
      idManufacturer != null && idManufacturer! > 0;

  /// Vérifie si l'adresse appartient à un fournisseur
  bool get isSupplierAddress => idSupplier != null && idSupplier! > 0;

  /// Vérifie si l'adresse appartient à un entrepôt
  bool get isWarehouseAddress => idWarehouse != null && idWarehouse! > 0;

  /// Vérifie si l'adresse a une entreprise
  bool get hasCompany => company != null && company!.isNotEmpty;

  /// Vérifie si l'adresse a un numéro de TVA
  bool get hasVatNumber => vatNumber != null && vatNumber!.isNotEmpty;

  /// Vérifie si l'adresse a un téléphone
  bool get hasPhone => phone != null && phone!.isNotEmpty;

  /// Vérifie si l'adresse a un téléphone mobile
  bool get hasMobilePhone => phoneMobile != null && phoneMobile!.isNotEmpty;

  /// Téléphone principal (fixe ou mobile)
  String? get primaryPhone {
    if (hasPhone) return phone;
    if (hasMobilePhone) return phoneMobile;
    return null;
  }

  /// Téléphones disponibles
  List<String> get availablePhones {
    final phones = <String>[];
    if (hasPhone) phones.add(phone!);
    if (hasMobilePhone) phones.add(phoneMobile!);
    return phones;
  }

  @override
  String toString() {
    return 'Address(id: $id, fullName: $fullName, city: $city, type: $addressType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Address && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
