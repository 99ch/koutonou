/// Modèle Customer pour PrestaShop API
/// Représente un client/utilisateur dans PrestaShop
class Customer {
  final int? id;
  final int? idDefaultGroup;
  final int? idLang;
  final DateTime? newsletterDateAdd;
  final String? ipRegistrationNewsletter;
  final DateTime? lastPasswdGen;
  final String? secureKey;
  final bool deleted;
  final String passwd;
  final String lastname;
  final String firstname;
  final String email;
  final int? idGender;
  final DateTime? birthday;
  final bool newsletter;
  final bool optin;
  final String? website;
  final String? company;
  final String? siret;
  final String? ape;
  final double? outstandingAllowAmount;
  final bool? showPublicPrices;
  final int? idRisk;
  final int? maxPaymentDays;
  final bool active;
  final String? note;
  final bool isGuest;
  final int? idShop;
  final int? idShopGroup;
  final DateTime? dateAdd;
  final DateTime? dateUpd;
  final String? resetPasswordToken;
  final DateTime? resetPasswordValidity;
  final List<int>? groupIds; // Associations avec les groupes

  const Customer({
    this.id,
    this.idDefaultGroup,
    this.idLang,
    this.newsletterDateAdd,
    this.ipRegistrationNewsletter,
    this.lastPasswdGen,
    this.secureKey,
    this.deleted = false,
    required this.passwd,
    required this.lastname,
    required this.firstname,
    required this.email,
    this.idGender,
    this.birthday,
    this.newsletter = false,
    this.optin = false,
    this.website,
    this.company,
    this.siret,
    this.ape,
    this.outstandingAllowAmount,
    this.showPublicPrices,
    this.idRisk,
    this.maxPaymentDays,
    this.active = true,
    this.note,
    this.isGuest = false,
    this.idShop,
    this.idShopGroup,
    this.dateAdd,
    this.dateUpd,
    this.resetPasswordToken,
    this.resetPasswordValidity,
    this.groupIds,
  });

  /// Crée un Customer à partir de la réponse JSON de PrestaShop
  factory Customer.fromPrestaShopJson(Map<String, dynamic> json) {
    // Parse les associations de groupes
    List<int>? parseGroupIds;
    if (json['associations'] != null) {
      final associations = json['associations'] as Map<String, dynamic>;
      if (associations['groups'] != null) {
        final groupsData = associations['groups'];
        if (groupsData['group'] is List) {
          final groupsList = groupsData['group'] as List;
          parseGroupIds = groupsList
              .map((group) => int.tryParse(group['id']?.toString() ?? '0'))
              .where((id) => id != null && id > 0)
              .cast<int>()
              .toList();
        } else if (groupsData['group'] is Map) {
          final groupData = groupsData['group'] as Map<String, dynamic>;
          final groupId = int.tryParse(groupData['id']?.toString() ?? '0');
          if (groupId != null && groupId > 0) {
            parseGroupIds = [groupId];
          }
        }
      }
    }

    return Customer(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idDefaultGroup: int.tryParse(json['id_default_group']?.toString() ?? '0'),
      idLang: int.tryParse(json['id_lang']?.toString() ?? '0'),
      newsletterDateAdd:
          json['newsletter_date_add'] != null &&
              json['newsletter_date_add'].toString().isNotEmpty
          ? DateTime.tryParse(json['newsletter_date_add'].toString())
          : null,
      ipRegistrationNewsletter: json['ip_registration_newsletter']?.toString(),
      lastPasswdGen:
          json['last_passwd_gen'] != null &&
              json['last_passwd_gen'].toString().isNotEmpty
          ? DateTime.tryParse(json['last_passwd_gen'].toString())
          : null,
      secureKey: json['secure_key']?.toString(),
      deleted: json['deleted']?.toString() == '1',
      passwd: json['passwd']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
      firstname: json['firstname']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      idGender: int.tryParse(json['id_gender']?.toString() ?? '0'),
      birthday:
          json['birthday'] != null &&
              json['birthday'].toString().isNotEmpty &&
              json['birthday'].toString() != '0000-00-00'
          ? DateTime.tryParse(json['birthday'].toString())
          : null,
      newsletter: json['newsletter']?.toString() == '1',
      optin: json['optin']?.toString() == '1',
      website: json['website']?.toString(),
      company: json['company']?.toString(),
      siret: json['siret']?.toString(),
      ape: json['ape']?.toString(),
      outstandingAllowAmount: double.tryParse(
        json['outstanding_allow_amount']?.toString() ?? '0',
      ),
      showPublicPrices: json['show_public_prices']?.toString() == '1',
      idRisk: int.tryParse(json['id_risk']?.toString() ?? '0'),
      maxPaymentDays: int.tryParse(json['max_payment_days']?.toString() ?? '0'),
      active: json['active']?.toString() == '1',
      note: json['note']?.toString(),
      isGuest: json['is_guest']?.toString() == '1',
      idShop: int.tryParse(json['id_shop']?.toString() ?? '0'),
      idShopGroup: int.tryParse(json['id_shop_group']?.toString() ?? '0'),
      dateAdd:
          json['date_add'] != null && json['date_add'].toString().isNotEmpty
          ? DateTime.tryParse(json['date_add'].toString())
          : null,
      dateUpd:
          json['date_upd'] != null && json['date_upd'].toString().isNotEmpty
          ? DateTime.tryParse(json['date_upd'].toString())
          : null,
      resetPasswordToken: json['reset_password_token']?.toString(),
      resetPasswordValidity:
          json['reset_password_validity'] != null &&
              json['reset_password_validity'].toString().isNotEmpty
          ? DateTime.tryParse(json['reset_password_validity'].toString())
          : null,
      groupIds: parseGroupIds,
    );
  }

  /// Convertit le Customer en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'passwd': passwd,
      'lastname': lastname,
      'firstname': firstname,
      'email': email,
      'deleted': deleted ? '1' : '0',
      'newsletter': newsletter ? '1' : '0',
      'optin': optin ? '1' : '0',
      'active': active ? '1' : '0',
      'is_guest': isGuest ? '1' : '0',
    };

    if (id != null) json['id'] = id.toString();
    if (idDefaultGroup != null && idDefaultGroup! > 0)
      json['id_default_group'] = idDefaultGroup.toString();
    if (idLang != null && idLang! > 0) json['id_lang'] = idLang.toString();
    if (idGender != null && idGender! > 0)
      json['id_gender'] = idGender.toString();
    if (birthday != null)
      json['birthday'] = birthday!.toIso8601String().split('T')[0];
    if (website != null && website!.isNotEmpty) json['website'] = website;
    if (company != null && company!.isNotEmpty) json['company'] = company;
    if (siret != null && siret!.isNotEmpty) json['siret'] = siret;
    if (ape != null && ape!.isNotEmpty) json['ape'] = ape;
    if (outstandingAllowAmount != null)
      json['outstanding_allow_amount'] = outstandingAllowAmount.toString();
    if (showPublicPrices != null)
      json['show_public_prices'] = showPublicPrices! ? '1' : '0';
    if (idRisk != null && idRisk! > 0) json['id_risk'] = idRisk.toString();
    if (maxPaymentDays != null && maxPaymentDays! > 0)
      json['max_payment_days'] = maxPaymentDays.toString();
    if (note != null && note!.isNotEmpty) json['note'] = note;
    if (idShop != null && idShop! > 0) json['id_shop'] = idShop.toString();
    if (idShopGroup != null && idShopGroup! > 0)
      json['id_shop_group'] = idShopGroup.toString();
    if (resetPasswordToken != null && resetPasswordToken!.isNotEmpty)
      json['reset_password_token'] = resetPasswordToken;

    return json;
  }

  /// Convertit le Customer en format XML pour PrestaShop
  String toPrestaShopXml() {
    final buffer = StringBuffer();
    buffer.writeln('<customer>');

    if (id != null) buffer.writeln('  <id><![CDATA[${id}]]></id>');
    if (idDefaultGroup != null && idDefaultGroup! > 0)
      buffer.writeln(
        '  <id_default_group><![CDATA[${idDefaultGroup}]]></id_default_group>',
      );
    if (idLang != null && idLang! > 0)
      buffer.writeln('  <id_lang><![CDATA[${idLang}]]></id_lang>');
    buffer.writeln('  <deleted><![CDATA[${deleted ? '1' : '0'}]]></deleted>');
    buffer.writeln('  <passwd><![CDATA[${passwd}]]></passwd>');
    buffer.writeln('  <lastname><![CDATA[${lastname}]]></lastname>');
    buffer.writeln('  <firstname><![CDATA[${firstname}]]></firstname>');
    buffer.writeln('  <email><![CDATA[${email}]]></email>');

    if (idGender != null && idGender! > 0)
      buffer.writeln('  <id_gender><![CDATA[${idGender}]]></id_gender>');
    if (birthday != null)
      buffer.writeln(
        '  <birthday><![CDATA[${birthday!.toIso8601String().split('T')[0]}]]></birthday>',
      );
    buffer.writeln(
      '  <newsletter><![CDATA[${newsletter ? '1' : '0'}]]></newsletter>',
    );
    buffer.writeln('  <optin><![CDATA[${optin ? '1' : '0'}]]></optin>');

    if (website != null && website!.isNotEmpty)
      buffer.writeln('  <website><![CDATA[${website}]]></website>');
    if (company != null && company!.isNotEmpty)
      buffer.writeln('  <company><![CDATA[${company}]]></company>');
    if (siret != null && siret!.isNotEmpty)
      buffer.writeln('  <siret><![CDATA[${siret}]]></siret>');
    if (ape != null && ape!.isNotEmpty)
      buffer.writeln('  <ape><![CDATA[${ape}]]></ape>');
    if (outstandingAllowAmount != null)
      buffer.writeln(
        '  <outstanding_allow_amount><![CDATA[${outstandingAllowAmount}]]></outstanding_allow_amount>',
      );
    if (showPublicPrices != null)
      buffer.writeln(
        '  <show_public_prices><![CDATA[${showPublicPrices! ? '1' : '0'}]]></show_public_prices>',
      );
    if (idRisk != null && idRisk! > 0)
      buffer.writeln('  <id_risk><![CDATA[${idRisk}]]></id_risk>');
    if (maxPaymentDays != null && maxPaymentDays! > 0)
      buffer.writeln(
        '  <max_payment_days><![CDATA[${maxPaymentDays}]]></max_payment_days>',
      );

    buffer.writeln('  <active><![CDATA[${active ? '1' : '0'}]]></active>');
    if (note != null && note!.isNotEmpty)
      buffer.writeln('  <note><![CDATA[${note}]]></note>');
    buffer.writeln('  <is_guest><![CDATA[${isGuest ? '1' : '0'}]]></is_guest>');

    if (idShop != null && idShop! > 0)
      buffer.writeln('  <id_shop><![CDATA[${idShop}]]></id_shop>');
    if (idShopGroup != null && idShopGroup! > 0)
      buffer.writeln(
        '  <id_shop_group><![CDATA[${idShopGroup}]]></id_shop_group>',
      );

    // Associations avec les groupes
    if (groupIds != null && groupIds!.isNotEmpty) {
      buffer.writeln('  <associations>');
      buffer.writeln('    <groups>');
      for (final groupId in groupIds!) {
        buffer.writeln('      <group>');
        buffer.writeln('        <id><![CDATA[${groupId}]]></id>');
        buffer.writeln('      </group>');
      }
      buffer.writeln('    </groups>');
      buffer.writeln('  </associations>');
    }

    buffer.writeln('</customer>');
    return buffer.toString();
  }

  /// Nom complet du client
  String get fullName => '${firstname} ${lastname}'.trim();

  /// Age du client si date de naissance disponible
  int? get age {
    if (birthday == null) return null;
    final now = DateTime.now();
    int age = now.year - birthday!.year;
    if (now.month < birthday!.month ||
        (now.month == birthday!.month && now.day < birthday!.day)) {
      age--;
    }
    return age;
  }

  /// Statut de newsletter (description)
  String get newsletterStatus => newsletter ? 'Abonné' : 'Non abonné';

  /// Type de compte
  String get accountType => isGuest ? 'Invité' : 'Compte client';

  /// Statut du compte
  String get accountStatus => active ? 'Actif' : 'Inactif';

  /// Vérifie si le client a une entreprise
  bool get hasCompany => company != null && company!.isNotEmpty;

  /// Vérifie si le client a un site web
  bool get hasWebsite => website != null && website!.isNotEmpty;

  /// Vérifie si le client peut réinitialiser son mot de passe
  bool get canResetPassword =>
      resetPasswordToken != null &&
      resetPasswordValidity != null &&
      DateTime.now().isBefore(resetPasswordValidity!);

  @override
  String toString() {
    return 'Customer(id: $id, fullName: $fullName, email: $email, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Customer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
