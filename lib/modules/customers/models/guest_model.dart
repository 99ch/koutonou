/// Modèle Guest pour PrestaShop API
/// Représente un visiteur/invité du site
class Guest {
  final int? id;
  final int? idCustomer;
  final int? idOperatingSystem;
  final int? idWebBrowser;
  final bool javascript;
  final int? screenResolutionX;
  final int? screenResolutionY;
  final int? screenColor;
  final bool sunJava;
  final bool adobeFlash;
  final bool adobeDirector;
  final bool appleQuicktime;
  final bool realPlayer;
  final bool windowsMedia;
  final String? acceptLanguage;
  final bool mobileTheme;

  const Guest({
    this.id,
    this.idCustomer,
    this.idOperatingSystem,
    this.idWebBrowser,
    this.javascript = false,
    this.screenResolutionX,
    this.screenResolutionY,
    this.screenColor,
    this.sunJava = false,
    this.adobeFlash = false,
    this.adobeDirector = false,
    this.appleQuicktime = false,
    this.realPlayer = false,
    this.windowsMedia = false,
    this.acceptLanguage,
    this.mobileTheme = false,
  });

  /// Crée un Guest à partir de la réponse JSON de PrestaShop
  factory Guest.fromPrestaShopJson(Map<String, dynamic> json) {
    return Guest(
      id: int.tryParse(json['id']?.toString() ?? '0'),
      idCustomer: int.tryParse(json['id_customer']?.toString() ?? '0'),
      idOperatingSystem: int.tryParse(
        json['id_operating_system']?.toString() ?? '0',
      ),
      idWebBrowser: int.tryParse(json['id_web_browser']?.toString() ?? '0'),
      javascript: json['javascript']?.toString() == '1',
      screenResolutionX: int.tryParse(
        json['screen_resolution_x']?.toString() ?? '0',
      ),
      screenResolutionY: int.tryParse(
        json['screen_resolution_y']?.toString() ?? '0',
      ),
      screenColor: int.tryParse(json['screen_color']?.toString() ?? '0'),
      sunJava: json['sun_java']?.toString() == '1',
      adobeFlash: json['adobe_flash']?.toString() == '1',
      adobeDirector: json['adobe_director']?.toString() == '1',
      appleQuicktime: json['apple_quicktime']?.toString() == '1',
      realPlayer: json['real_player']?.toString() == '1',
      windowsMedia: json['windows_media']?.toString() == '1',
      acceptLanguage: json['accept_language']?.toString(),
      mobileTheme: json['mobile_theme']?.toString() == '1',
    );
  }

  /// Convertit le Guest en format JSON pour PrestaShop
  Map<String, dynamic> toPrestaShopJson() {
    final json = <String, dynamic>{
      'javascript': javascript ? '1' : '0',
      'sun_java': sunJava ? '1' : '0',
      'adobe_flash': adobeFlash ? '1' : '0',
      'adobe_director': adobeDirector ? '1' : '0',
      'apple_quicktime': appleQuicktime ? '1' : '0',
      'real_player': realPlayer ? '1' : '0',
      'windows_media': windowsMedia ? '1' : '0',
      'mobile_theme': mobileTheme ? '1' : '0',
    };

    if (id != null) json['id'] = id.toString();
    if (idCustomer != null && idCustomer! > 0)
      json['id_customer'] = idCustomer.toString();
    if (idOperatingSystem != null && idOperatingSystem! > 0)
      json['id_operating_system'] = idOperatingSystem.toString();
    if (idWebBrowser != null && idWebBrowser! > 0)
      json['id_web_browser'] = idWebBrowser.toString();
    if (screenResolutionX != null && screenResolutionX! > 0)
      json['screen_resolution_x'] = screenResolutionX.toString();
    if (screenResolutionY != null && screenResolutionY! > 0)
      json['screen_resolution_y'] = screenResolutionY.toString();
    if (screenColor != null && screenColor! > 0)
      json['screen_color'] = screenColor.toString();
    if (acceptLanguage != null && acceptLanguage!.isNotEmpty)
      json['accept_language'] = acceptLanguage;

    return json;
  }

  /// Convertit le Guest en format XML pour PrestaShop
  String toPrestaShopXml() {
    final buffer = StringBuffer();
    buffer.writeln('<guest>');

    if (id != null) buffer.writeln('  <id><![CDATA[${id}]]></id>');
    if (idCustomer != null && idCustomer! > 0)
      buffer.writeln('  <id_customer><![CDATA[${idCustomer}]]></id_customer>');
    if (idOperatingSystem != null && idOperatingSystem! > 0)
      buffer.writeln(
        '  <id_operating_system><![CDATA[${idOperatingSystem}]]></id_operating_system>',
      );
    if (idWebBrowser != null && idWebBrowser! > 0)
      buffer.writeln(
        '  <id_web_browser><![CDATA[${idWebBrowser}]]></id_web_browser>',
      );

    buffer.writeln(
      '  <javascript><![CDATA[${javascript ? '1' : '0'}]]></javascript>',
    );
    if (screenResolutionX != null && screenResolutionX! > 0)
      buffer.writeln(
        '  <screen_resolution_x><![CDATA[${screenResolutionX}]]></screen_resolution_x>',
      );
    if (screenResolutionY != null && screenResolutionY! > 0)
      buffer.writeln(
        '  <screen_resolution_y><![CDATA[${screenResolutionY}]]></screen_resolution_y>',
      );
    if (screenColor != null && screenColor! > 0)
      buffer.writeln(
        '  <screen_color><![CDATA[${screenColor}]]></screen_color>',
      );

    buffer.writeln('  <sun_java><![CDATA[${sunJava ? '1' : '0'}]]></sun_java>');
    buffer.writeln(
      '  <adobe_flash><![CDATA[${adobeFlash ? '1' : '0'}]]></adobe_flash>',
    );
    buffer.writeln(
      '  <adobe_director><![CDATA[${adobeDirector ? '1' : '0'}]]></adobe_director>',
    );
    buffer.writeln(
      '  <apple_quicktime><![CDATA[${appleQuicktime ? '1' : '0'}]]></apple_quicktime>',
    );
    buffer.writeln(
      '  <real_player><![CDATA[${realPlayer ? '1' : '0'}]]></real_player>',
    );
    buffer.writeln(
      '  <windows_media><![CDATA[${windowsMedia ? '1' : '0'}]]></windows_media>',
    );

    if (acceptLanguage != null && acceptLanguage!.isNotEmpty)
      buffer.writeln(
        '  <accept_language><![CDATA[${acceptLanguage}]]></accept_language>',
      );
    buffer.writeln(
      '  <mobile_theme><![CDATA[${mobileTheme ? '1' : '0'}]]></mobile_theme>',
    );

    buffer.writeln('</guest>');
    return buffer.toString();
  }

  /// Résolution d'écran formatée
  String? get screenResolution {
    if (screenResolutionX != null && screenResolutionY != null) {
      return '${screenResolutionX}x${screenResolutionY}';
    }
    return null;
  }

  /// Type d'utilisateur
  String get userType {
    if (idCustomer != null && idCustomer! > 0) return 'Client connecté';
    return 'Visiteur anonyme';
  }

  /// Plateforme utilisée
  String get platform => mobileTheme ? 'Mobile' : 'Desktop';

  /// Capacités JavaScript
  String get javascriptSupport => javascript ? 'Activé' : 'Désactivé';

  /// Liste des plugins supportés
  List<String> get supportedPlugins {
    final plugins = <String>[];
    if (sunJava) plugins.add('Java');
    if (adobeFlash) plugins.add('Flash');
    if (adobeDirector) plugins.add('Director');
    if (appleQuicktime) plugins.add('QuickTime');
    if (realPlayer) plugins.add('RealPlayer');
    if (windowsMedia) plugins.add('Windows Media');
    return plugins;
  }

  /// Nombre de plugins supportés
  int get supportedPluginsCount => supportedPlugins.length;

  /// Vérifie si l'invité est lié à un client
  bool get isLinkedToCustomer => idCustomer != null && idCustomer! > 0;

  /// Vérifie si l'invité utilise un thème mobile
  bool get isMobileUser => mobileTheme;

  /// Vérifie si l'invité supporte JavaScript
  bool get supportsJavascript => javascript;

  /// Vérifie si l'invité a des informations d'écran
  bool get hasScreenInfo =>
      screenResolutionX != null && screenResolutionY != null;

  /// Profil technique de l'invité
  Map<String, dynamic> get technicalProfile {
    return {
      'javascript': supportsJavascript,
      'screen_resolution': screenResolution,
      'screen_color': screenColor,
      'platform': platform,
      'language': acceptLanguage,
      'plugins_count': supportedPluginsCount,
      'supported_plugins': supportedPlugins,
    };
  }

  @override
  String toString() {
    return 'Guest(id: $id, userType: $userType, platform: $platform, javascript: $supportsJavascript)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Guest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
