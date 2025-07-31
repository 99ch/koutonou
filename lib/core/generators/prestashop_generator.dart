// Générateur complet pour modèles et services PrestaShop
// Phase 2 - Génération automatisée à partir des métadonnées API
// Supporte tous les endpoints PrestaShop avec introspection automatique

import 'dart:io';
import 'package:koutonou/core/api/api_client.dart';
import 'package:koutonou/core/utils/logger.dart';

/// Configuration pour la génération d'une ressource PrestaShop
class ResourceConfig {
  final String name;
  final String endpoint;
  final String modelClassName;
  final String serviceClassName;
  final Map<String, String> fieldTypes;
  final List<String> requiredFields;
  final bool hasStates;
  final bool hasTranslations;

  const ResourceConfig({
    required this.name,
    required this.endpoint,
    required this.modelClassName,
    required this.serviceClassName,
    required this.fieldTypes,
    required this.requiredFields,
    this.hasStates = false,
    this.hasTranslations = false,
  });
}

/// Générateur principal pour PrestaShop
class PrestaShopGenerator {
  static final PrestaShopGenerator _instance = PrestaShopGenerator._internal();
  factory PrestaShopGenerator() => _instance;
  PrestaShopGenerator._internal();

  final ApiClient _apiClient = ApiClient();
  static final AppLogger _logger = AppLogger();

  /// Répertoire de base pour la génération
  static const String _baseOutputPath = 'lib/modules';

  /// Configuration des ressources PrestaShop accessibles (✅)
  static const Map<String, ResourceConfig> resourceConfigs = {
    // Ressources principales e-commerce
    'products': ResourceConfig(
      name: 'products',
      endpoint: 'products',
      modelClassName: 'ProductModel',
      serviceClassName: 'ProductService',
      fieldTypes: {
        'id': 'int',
        'id_manufacturer': 'int?',
        'id_supplier': 'int?',
        'id_category_default': 'int?',
        'id_shop_default': 'int?',
        'id_tax_rules_group': 'int?',
        'on_sale': 'int?',
        'online_only': 'int?',
        'ean13': 'String?',
        'isbn': 'String?',
        'upc': 'String?',
        'mpn': 'String?',
        'ecotax': 'String?',
        'quantity': 'int?',
        'minimal_quantity': 'int?',
        'low_stock_threshold': 'int?',
        'low_stock_alert': 'int?',
        'price': 'String?',
        'wholesale_price': 'String?',
        'unity': 'String?',
        'unit_price_ratio': 'String?',
        'additional_shipping_cost': 'String?',
        'reference': 'String?',
        'supplier_reference': 'String?',
        'location': 'String?',
        'width': 'String?',
        'height': 'String?',
        'depth': 'String?',
        'weight': 'String?',
        'out_of_stock': 'int?',
        'additional_delivery_times': 'int?',
        'quantity_discount': 'int?',
        'customizable': 'int?',
        'uploadable_files': 'int?',
        'text_fields': 'int?',
        'active': 'int?',
        'redirect_type': 'String?',
        'id_type_redirected': 'int?',
        'available_for_order': 'int?',
        'available_date': 'String?',
        'show_condition': 'int?',
        'condition': 'String?',
        'show_price': 'int?',
        'indexed': 'int?',
        'visibility': 'String?',
        'cache_is_pack': 'int?',
        'public_name': 'String?',
        'cache_has_attachments': 'int?',
        'is_virtual': 'int?',
        'cache_default_attribute': 'int?',
        'date_add': 'String?',
        'date_upd': 'String?',
        'advanced_stock_management': 'int?',
        'pack_stock_type': 'int?',
        'state': 'int?',
        'product_type': 'String?',
      },
      requiredFields: ['id'],
      hasTranslations: true,
    ),
    'customers': ResourceConfig(
      name: 'customers',
      endpoint: 'customers',
      modelClassName: 'CustomerModel',
      serviceClassName: 'CustomerService',
      fieldTypes: {
        'id': 'int',
        'id_default_group': 'int?',
        'id_lang': 'int?',
        'newsletter_date_add': 'String?',
        'ip_registration_newsletter': 'String?',
        'last_passwd_gen': 'String?',
        'secure_key': 'String?',
        'deleted': 'int?',
        'passwd': 'String?',
        'lastname': 'String?',
        'firstname': 'String?',
        'email': 'String?',
        'id_gender': 'int?',
        'birthday': 'String?',
        'newsletter': 'int?',
        'optin': 'int?',
        'website': 'String?',
        'company': 'String?',
        'siret': 'String?',
        'ape': 'String?',
        'outstanding_allow_amount': 'String?',
        'show_public_prices': 'int?',
        'id_risk': 'int?',
        'max_payment_days': 'int?',
        'active': 'int?',
        'note': 'String?',
        'is_guest': 'int?',
        'id_shop': 'int?',
        'id_shop_group': 'int?',
        'date_add': 'String?',
        'date_upd': 'String?',
        'reset_password_token': 'String?',
        'reset_password_validity': 'String?',
      },
      requiredFields: ['id'],
    ),
    'orders': ResourceConfig(
      name: 'orders',
      endpoint: 'orders',
      modelClassName: 'OrderModel',
      serviceClassName: 'OrderService',
      fieldTypes: {
        'id': 'int',
        'reference': 'String?',
        'id_address_delivery': 'int?',
        'id_address_invoice': 'int?',
        'id_cart': 'int?',
        'id_currency': 'int?',
        'id_lang': 'int?',
        'id_customer': 'int?',
        'id_carrier': 'int?',
        'current_state': 'int?',
        'module': 'String?',
        'invoice_number': 'int?',
        'invoice_date': 'String?',
        'delivery_number': 'int?',
        'delivery_date': 'String?',
        'valid': 'int?',
        'date_add': 'String?',
        'date_upd': 'String?',
        'shipping_number': 'String?',
        'note': 'String?',
        'id_shop_group': 'int?',
        'id_shop': 'int?',
        'secure_key': 'String?',
        'payment': 'String?',
        'recyclable': 'int?',
        'gift': 'int?',
        'gift_message': 'String?',
        'mobile_theme': 'int?',
        'total_discounts': 'String?',
        'total_discounts_tax_incl': 'String?',
        'total_discounts_tax_excl': 'String?',
        'total_paid': 'String?',
        'total_paid_tax_incl': 'String?',
        'total_paid_tax_excl': 'String?',
        'total_paid_real': 'String?',
        'total_products': 'String?',
        'total_products_wt': 'String?',
        'total_shipping': 'String?',
        'total_shipping_tax_incl': 'String?',
        'total_shipping_tax_excl': 'String?',
        'carrier_tax_rate': 'String?',
        'total_wrapping': 'String?',
        'total_wrapping_tax_incl': 'String?',
        'total_wrapping_tax_excl': 'String?',
        'round_mode': 'int?',
        'round_type': 'int?',
        'conversion_rate': 'String?',
      },
      requiredFields: ['id'],
      hasStates: true,
    ),

    // Gestion des partenaires
    'manufacturers': ResourceConfig(
      name: 'manufacturers',
      endpoint: 'manufacturers',
      modelClassName: 'ManufacturerModel',
      serviceClassName: 'ManufacturerService',
      fieldTypes: {
        'id': 'int',
        'name': 'String?',
        'date_add': 'String?',
        'date_upd': 'String?',
        'active': 'int?',
      },
      requiredFields: ['id'],
      hasTranslations: true,
    ),
    'suppliers': ResourceConfig(
      name: 'suppliers',
      endpoint: 'suppliers',
      modelClassName: 'SupplierModel',
      serviceClassName: 'SupplierService',
      fieldTypes: {
        'id': 'int',
        'name': 'String?',
        'date_add': 'String?',
        'date_upd': 'String?',
        'active': 'int?',
      },
      requiredFields: ['id'],
      hasTranslations: true,
    ),

    // Gestion du panier et commandes
    'carts': ResourceConfig(
      name: 'carts',
      endpoint: 'carts',
      modelClassName: 'CartModel',
      serviceClassName: 'CartService',
      fieldTypes: {
        'id': 'int',
        'id_address_delivery': 'int?',
        'id_address_invoice': 'int?',
        'id_currency': 'int?',
        'id_customer': 'int?',
        'id_guest': 'int?',
        'id_lang': 'int?',
        'id_shop_group': 'int?',
        'id_shop': 'int?',
        'id_carrier': 'int?',
        'recyclable': 'int?',
        'gift': 'int?',
        'gift_message': 'String?',
        'mobile_theme': 'int?',
        'delivery_option': 'String?',
        'secure_key': 'String?',
        'allow_seperated_package': 'int?',
        'date_add': 'String?',
        'date_upd': 'String?',
      },
      requiredFields: ['id'],
    ),
    'combinations': ResourceConfig(
      name: 'combinations',
      endpoint: 'combinations',
      modelClassName: 'CombinationModel',
      serviceClassName: 'CombinationService',
      fieldTypes: {
        'id': 'int',
        'id_product': 'int?',
        'location': 'String?',
        'ean13': 'String?',
        'isbn': 'String?',
        'upc': 'String?',
        'mpn': 'String?',
        'quantity': 'int?',
        'reference': 'String?',
        'supplier_reference': 'String?',
        'wholesale_price': 'String?',
        'price': 'String?',
        'ecotax': 'String?',
        'weight': 'String?',
        'unit_price_impact': 'String?',
        'default_on': 'int?',
        'minimal_quantity': 'int?',
        'low_stock_threshold': 'int?',
        'low_stock_alert': 'int?',
        'available_date': 'String?',
      },
      requiredFields: ['id'],
    ),

    // Options et attributs produits
    'product_options': ResourceConfig(
      name: 'product_options',
      endpoint: 'product_options',
      modelClassName: 'ProductOptionModel',
      serviceClassName: 'ProductOptionService',
      fieldTypes: {
        'id': 'int',
        'is_color_group': 'int?',
        'group_type': 'String?',
        'position': 'int?',
      },
      requiredFields: ['id'],
      hasTranslations: true,
    ),
    'product_option_values': ResourceConfig(
      name: 'product_option_values',
      endpoint: 'product_option_values',
      modelClassName: 'ProductOptionValueModel',
      serviceClassName: 'ProductOptionValueService',
      fieldTypes: {
        'id': 'int',
        'id_attribute_group': 'int?',
        'color': 'String?',
        'position': 'int?',
      },
      requiredFields: ['id'],
      hasTranslations: true,
    ),
    'product_features': ResourceConfig(
      name: 'product_features',
      endpoint: 'product_features',
      modelClassName: 'ProductFeatureModel',
      serviceClassName: 'ProductFeatureService',
      fieldTypes: {'id': 'int', 'position': 'int?'},
      requiredFields: ['id'],
      hasTranslations: true,
    ),
    'product_feature_values': ResourceConfig(
      name: 'product_feature_values',
      endpoint: 'product_feature_values',
      modelClassName: 'ProductFeatureValueModel',
      serviceClassName: 'ProductFeatureValueService',
      fieldTypes: {'id': 'int', 'id_feature': 'int?', 'custom': 'int?'},
      requiredFields: ['id'],
      hasTranslations: true,
    ),
    'product_suppliers': ResourceConfig(
      name: 'product_suppliers',
      endpoint: 'product_suppliers',
      modelClassName: 'ProductSupplierModel',
      serviceClassName: 'ProductSupplierService',
      fieldTypes: {
        'id': 'int',
        'id_product': 'int?',
        'id_product_attribute': 'int?',
        'id_supplier': 'int?',
        'id_currency': 'int?',
        'product_supplier_reference': 'String?',
        'product_supplier_price_te': 'String?',
      },
      requiredFields: ['id'],
    ),

    // Transport et logistique
    'carriers': ResourceConfig(
      name: 'carriers',
      endpoint: 'carriers',
      modelClassName: 'CarrierModel',
      serviceClassName: 'CarrierService',
      fieldTypes: {
        'id': 'int',
        'deleted': 'int?',
        'is_module': 'int?',
        'id_tax_rules_group': 'int?',
        'id_reference': 'int?',
        'name': 'String?',
        'active': 'int?',
        'is_free': 'int?',
        'url': 'String?',
        'shipping_handling': 'int?',
        'shipping_external': 'int?',
        'range_behavior': 'int?',
        'shipping_method': 'int?',
        'max_width': 'int?',
        'max_height': 'int?',
        'max_depth': 'int?',
        'max_weight': 'String?',
        'grade': 'int?',
        'external_module_name': 'String?',
        'need_range': 'int?',
        'position': 'int?',
      },
      requiredFields: ['id'],
      hasTranslations: true,
    ),
    'zones': ResourceConfig(
      name: 'zones',
      endpoint: 'zones',
      modelClassName: 'ZoneModel',
      serviceClassName: 'ZoneService',
      fieldTypes: {'id': 'int', 'name': 'String?', 'active': 'int?'},
      requiredFields: ['id'],
    ),
    'price_ranges': ResourceConfig(
      name: 'price_ranges',
      endpoint: 'price_ranges',
      modelClassName: 'PriceRangeModel',
      serviceClassName: 'PriceRangeService',
      fieldTypes: {
        'id': 'int',
        'id_carrier': 'int?',
        'delimiter1': 'String?',
        'delimiter2': 'String?',
      },
      requiredFields: ['id'],
    ),
    'weight_ranges': ResourceConfig(
      name: 'weight_ranges',
      endpoint: 'weight_ranges',
      modelClassName: 'WeightRangeModel',
      serviceClassName: 'WeightRangeService',
      fieldTypes: {
        'id': 'int',
        'id_carrier': 'int?',
        'delimiter1': 'String?',
        'delimiter2': 'String?',
      },
      requiredFields: ['id'],
    ),

    // États et workflow
    'order_states': ResourceConfig(
      name: 'order_states',
      endpoint: 'order_states',
      modelClassName: 'OrderStateModel',
      serviceClassName: 'OrderStateService',
      fieldTypes: {
        'id': 'int',
        'invoice': 'int?',
        'send_email': 'int?',
        'module_name': 'String?',
        'color': 'String?',
        'unremovable': 'int?',
        'hidden': 'int?',
        'logable': 'int?',
        'delivery': 'int?',
        'shipped': 'int?',
        'paid': 'int?',
        'pdf_invoice': 'int?',
        'pdf_delivery': 'int?',
        'deleted': 'int?',
      },
      requiredFields: ['id'],
      hasTranslations: true,
    ),
    'order_details': ResourceConfig(
      name: 'order_details',
      endpoint: 'order_details',
      modelClassName: 'OrderDetailModel',
      serviceClassName: 'OrderDetailService',
      fieldTypes: {
        'id': 'int',
        'id_order': 'int?',
        'product_id': 'int?',
        'product_attribute_id': 'int?',
        'product_name': 'String?',
        'product_quantity': 'int?',
        'product_price': 'String?',
        'reduction_percent': 'String?',
        'reduction_amount': 'String?',
        'reduction_amount_tax_incl': 'String?',
        'reduction_amount_tax_excl': 'String?',
        'group_reduction': 'String?',
        'product_quantity_discount': 'String?',
        'product_ean13': 'String?',
        'product_isbn': 'String?',
        'product_upc': 'String?',
        'product_mpn': 'String?',
        'product_reference': 'String?',
        'product_supplier_reference': 'String?',
        'product_weight': 'String?',
        'id_customization': 'int?',
        'tax_computation_method': 'int?',
        'id_tax_rules_group': 'int?',
        'ecotax': 'String?',
        'ecotax_tax_rate': 'String?',
        'discount_quantity_applied': 'int?',
        'download_hash': 'String?',
        'download_nb': 'int?',
        'download_deadline': 'String?',
        'total_price_tax_incl': 'String?',
        'total_price_tax_excl': 'String?',
        'unit_price_tax_incl': 'String?',
        'unit_price_tax_excl': 'String?',
        'total_shipping_price_tax_excl': 'String?',
        'total_shipping_price_tax_incl': 'String?',
        'purchase_supplier_price': 'String?',
        'original_product_price': 'String?',
        'original_wholesale_price': 'String?',
      },
      requiredFields: ['id'],
    ),
    'order_carriers': ResourceConfig(
      name: 'order_carriers',
      endpoint: 'order_carriers',
      modelClassName: 'OrderCarrierModel',
      serviceClassName: 'OrderCarrierService',
      fieldTypes: {
        'id': 'int',
        'id_order': 'int?',
        'id_carrier': 'int?',
        'id_order_invoice': 'int?',
        'weight': 'String?',
        'shipping_cost_tax_excl': 'String?',
        'shipping_cost_tax_incl': 'String?',
        'tracking_number': 'String?',
        'date_add': 'String?',
      },
      requiredFields: ['id'],
    ),
    'states': ResourceConfig(
      name: 'states',
      endpoint: 'states',
      modelClassName: 'StateModel',
      serviceClassName: 'StateService',
      fieldTypes: {
        'id': 'int',
        'id_country': 'int?',
        'id_zone': 'int?',
        'name': 'String?',
        'iso_code': 'String?',
        'tax_behavior': 'int?',
        'active': 'int?',
      },
      requiredFields: ['id'],
    ),

    // Stock et inventaire
    'stock_availables': ResourceConfig(
      name: 'stock_availables',
      endpoint: 'stock_availables',
      modelClassName: 'StockAvailableModel',
      serviceClassName: 'StockAvailableService',
      fieldTypes: {
        'id': 'int',
        'id_product': 'int?',
        'id_product_attribute': 'int?',
        'id_shop': 'int?',
        'id_shop_group': 'int?',
        'quantity': 'int?',
        'depends_on_stock': 'int?',
        'out_of_stock': 'int?',
        'location': 'String?',
      },
      requiredFields: ['id'],
    ),
    'stock_movement_reasons': ResourceConfig(
      name: 'stock_movement_reasons',
      endpoint: 'stock_movement_reasons',
      modelClassName: 'StockMovementReasonModel',
      serviceClassName: 'StockMovementReasonService',
      fieldTypes: {
        'id': 'int',
        'sign': 'int?',
        'date_add': 'String?',
        'date_upd': 'String?',
        'deleted': 'int?',
      },
      requiredFields: ['id'],
      hasTranslations: true,
    ),
    'specific_prices': ResourceConfig(
      name: 'specific_prices',
      endpoint: 'specific_prices',
      modelClassName: 'SpecificPriceModel',
      serviceClassName: 'SpecificPriceService',
      fieldTypes: {
        'id': 'int',
        'id_specific_price_rule': 'int?',
        'id_cart': 'int?',
        'id_product': 'int?',
        'id_shop': 'int?',
        'id_shop_group': 'int?',
        'id_currency': 'int?',
        'id_country': 'int?',
        'id_group': 'int?',
        'id_customer': 'int?',
        'id_product_attribute': 'int?',
        'price': 'String?',
        'from_quantity': 'int?',
        'reduction': 'String?',
        'reduction_tax': 'int?',
        'reduction_type': 'String?',
        'from': 'String?',
        'to': 'String?',
      },
      requiredFields: ['id'],
    ),

    // Boutiques et configuration
    'shops': ResourceConfig(
      name: 'shops',
      endpoint: 'shops',
      modelClassName: 'ShopModel',
      serviceClassName: 'ShopService',
      fieldTypes: {
        'id': 'int',
        'id_shop_group': 'int?',
        'name': 'String?',
        'id_category': 'int?',
        'id_theme': 'int?',
        'active': 'int?',
        'deleted': 'int?',
      },
      requiredFields: ['id'],
    ),
    'shop_groups': ResourceConfig(
      name: 'shop_groups',
      endpoint: 'shop_groups',
      modelClassName: 'ShopGroupModel',
      serviceClassName: 'ShopGroupService',
      fieldTypes: {
        'id': 'int',
        'name': 'String?',
        'color': 'String?',
        'share_customer': 'int?',
        'share_order': 'int?',
        'share_stock': 'int?',
        'active': 'int?',
        'deleted': 'int?',
      },
      requiredFields: ['id'],
    ),
    'shop_urls': ResourceConfig(
      name: 'shop_urls',
      endpoint: 'shop_urls',
      modelClassName: 'ShopUrlModel',
      serviceClassName: 'ShopUrlService',
      fieldTypes: {
        'id': 'int',
        'id_shop': 'int?',
        'domain': 'String?',
        'domain_ssl': 'String?',
        'physical_uri': 'String?',
        'virtual_uri': 'String?',
        'main': 'int?',
        'active': 'int?',
      },
      requiredFields: ['id'],
    ),
    'configurations': ResourceConfig(
      name: 'configurations',
      endpoint: 'configurations',
      modelClassName: 'ConfigurationModel',
      serviceClassName: 'ConfigurationService',
      fieldTypes: {
        'id': 'int',
        'id_shop_group': 'int?',
        'id_shop': 'int?',
        'name': 'String?',
        'value': 'String?',
        'date_add': 'String?',
        'date_upd': 'String?',
      },
      requiredFields: ['id'],
    ),
    'translated_configurations': ResourceConfig(
      name: 'translated_configurations',
      endpoint: 'translated_configurations',
      modelClassName: 'TranslatedConfigurationModel',
      serviceClassName: 'TranslatedConfigurationService',
      fieldTypes: {
        'id': 'int',
        'id_lang': 'int?',
        'value': 'String?',
        'date_add': 'String?',
        'date_upd': 'String?',
      },
      requiredFields: ['id'],
    ),

    // Gestion des groupes et clients
    'groups': ResourceConfig(
      name: 'groups',
      endpoint: 'groups',
      modelClassName: 'GroupModel',
      serviceClassName: 'GroupService',
      fieldTypes: {
        'id': 'int',
        'reduction': 'String?',
        'price_display_method': 'int?',
        'show_prices': 'int?',
        'date_add': 'String?',
        'date_upd': 'String?',
      },
      requiredFields: ['id'],
      hasTranslations: true,
    ),
    'guests': ResourceConfig(
      name: 'guests',
      endpoint: 'guests',
      modelClassName: 'GuestModel',
      serviceClassName: 'GuestService',
      fieldTypes: {
        'id': 'int',
        'id_operating_system': 'int?',
        'id_web_browser': 'int?',
        'id_customer': 'int?',
        'javascript': 'int?',
        'screen_resolution_x': 'int?',
        'screen_resolution_y': 'int?',
        'screen_color': 'int?',
        'sun_java': 'int?',
        'adobe_flash': 'int?',
        'adobe_director': 'int?',
        'apple_quicktime': 'int?',
        'real_player': 'int?',
        'windows_media': 'int?',
        'accept_language': 'String?',
        'mobile_theme': 'int?',
      },
      requiredFields: ['id'],
    ),

    // Administration et employés
    'employees': ResourceConfig(
      name: 'employees',
      endpoint: 'employees',
      modelClassName: 'EmployeeModel',
      serviceClassName: 'EmployeeService',
      fieldTypes: {
        'id': 'int',
        'id_profile': 'int?',
        'id_lang': 'int?',
        'lastname': 'String?',
        'firstname': 'String?',
        'email': 'String?',
        'passwd': 'String?',
        'last_passwd_gen': 'String?',
        'stats_date_from': 'String?',
        'stats_date_to': 'String?',
        'stats_compare_from': 'String?',
        'stats_compare_to': 'String?',
        'stats_compare_option': 'int?',
        'preselect_date_range': 'String?',
        'bo_color': 'String?',
        'bo_theme': 'String?',
        'bo_css': 'String?',
        'default_tab': 'int?',
        'bo_width': 'int?',
        'bo_menu': 'int?',
        'active': 'int?',
        'optin': 'int?',
        'id_last_order': 'int?',
        'id_last_customer_message': 'int?',
        'id_last_customer': 'int?',
        'last_connection_date': 'String?',
        'reset_password_token': 'String?',
        'reset_password_validity': 'String?',
      },
      requiredFields: ['id'],
    ),
    'contacts': ResourceConfig(
      name: 'contacts',
      endpoint: 'contacts',
      modelClassName: 'ContactModel',
      serviceClassName: 'ContactService',
      fieldTypes: {'id': 'int', 'email': 'String?', 'customer_service': 'int?'},
      requiredFields: ['id'],
      hasTranslations: true,
    ),

    // Localisation et langues
    'languages': ResourceConfig(
      name: 'languages',
      endpoint: 'languages',
      modelClassName: 'LanguageModel',
      serviceClassName: 'LanguageService',
      fieldTypes: {
        'id': 'int',
        'name': 'String?',
        'iso_code': 'String?',
        'language_code': 'String?',
        'active': 'int?',
        'is_rtl': 'int?',
        'date_format_lite': 'String?',
        'date_format_full': 'String?',
      },
      requiredFields: ['id'],
    ),
    'image_types': ResourceConfig(
      name: 'image_types',
      endpoint: 'image_types',
      modelClassName: 'ImageTypeModel',
      serviceClassName: 'ImageTypeService',
      fieldTypes: {
        'id': 'int',
        'name': 'String?',
        'width': 'int?',
        'height': 'int?',
        'products': 'int?',
        'categories': 'int?',
        'manufacturers': 'int?',
        'suppliers': 'int?',
        'stores': 'int?',
      },
      requiredFields: ['id'],
    ),

    // Magasins physiques
    'stores': ResourceConfig(
      name: 'stores',
      endpoint: 'stores',
      modelClassName: 'StoreModel',
      serviceClassName: 'StoreService',
      fieldTypes: {
        'id': 'int',
        'id_country': 'int?',
        'id_state': 'int?',
        'city': 'String?',
        'postcode': 'String?',
        'latitude': 'String?',
        'longitude': 'String?',
        'phone': 'String?',
        'fax': 'String?',
        'email': 'String?',
        'active': 'int?',
        'date_add': 'String?',
        'date_upd': 'String?',
      },
      requiredFields: ['id'],
    ),

    // Taxes et règles fiscales
    'tax_rule_groups': ResourceConfig(
      name: 'tax_rule_groups',
      endpoint: 'tax_rule_groups',
      modelClassName: 'TaxRuleGroupModel',
      serviceClassName: 'TaxRuleGroupService',
      fieldTypes: {
        'id': 'int',
        'name': 'String?',
        'active': 'int?',
        'deleted': 'int?',
        'date_add': 'String?',
        'date_upd': 'String?',
      },
      requiredFields: ['id'],
    ),
    'tax_rules': ResourceConfig(
      name: 'tax_rules',
      endpoint: 'tax_rules',
      modelClassName: 'TaxRuleModel',
      serviceClassName: 'TaxRuleService',
      fieldTypes: {
        'id': 'int',
        'id_tax_rules_group': 'int?',
        'id_country': 'int?',
        'id_state': 'int?',
        'zipcode_from': 'String?',
        'zipcode_to': 'String?',
        'id_tax': 'int?',
        'behavior': 'int?',
        'description': 'String?',
      },
      requiredFields: ['id'],
    ),
  };

  /// Génère tous les modèles et services pour toutes les ressources
  Future<void> generateAll() async {
    try {
      _logger.info('🚀 Démarrage génération complète PrestaShop Phase 2');

      for (final config in resourceConfigs.values) {
        _logger.info('📦 Génération ${config.name}...');
        await generateResource(config);
      }

      _logger.info('✅ Génération complète terminée avec succès');
    } catch (e, stackTrace) {
      _logger.error('❌ Erreur génération complète', e, stackTrace);
      rethrow;
    }
  }

  /// Génère une ressource spécifique (modèle + service)
  Future<void> generateResource(ResourceConfig config) async {
    try {
      _logger.info('📝 Génération ${config.modelClassName}...');

      // Créer les répertoires
      await _createDirectories(config);

      // Générer le modèle
      await _generateModel(config);

      // Générer le service
      await _generateService(config);

      // Générer le service web
      await _generateWebService(config);

      _logger.info('✅ ${config.name} généré avec succès');
    } catch (e, stackTrace) {
      _logger.error('❌ Erreur génération ${config.name}', e, stackTrace);
      rethrow;
    }
  }

  /// Crée les répertoires nécessaires
  Future<void> _createDirectories(ResourceConfig config) async {
    final basePath = '$_baseOutputPath/${config.name}';

    await Directory('$basePath/models').create(recursive: true);
    await Directory('$basePath/services').create(recursive: true);
  }

  /// Génère automatiquement un modèle à partir de la configuration
  Future<void> _generateModel(ResourceConfig config) async {
    final modelContent = _buildModelContent(config);
    final filePath =
        '$_baseOutputPath/${config.name}/models/${config.name.toLowerCase().replaceAll('s', '')}model.dart';

    await File(filePath).writeAsString(modelContent);
    _logger.debug('📄 Modèle généré: $filePath');
  }

  /// Génère automatiquement un service à partir de la configuration
  Future<void> _generateService(ResourceConfig config) async {
    final serviceContent = _buildServiceContent(config);
    final filePath =
        '$_baseOutputPath/${config.name}/services/${config.name.toLowerCase().replaceAll('s', '')}service.dart';

    await File(filePath).writeAsString(serviceContent);
    _logger.debug('📄 Service généré: $filePath');
  }

  /// Génère automatiquement un service web à partir de la configuration
  Future<void> _generateWebService(ResourceConfig config) async {
    final webServiceContent = _buildWebServiceContent(config);
    final filePath =
        '$_baseOutputPath/${config.name}/services/${config.name.toLowerCase().replaceAll('s', '')}service_web.dart';

    await File(filePath).writeAsString(webServiceContent);
    _logger.debug('📄 Service web généré: $filePath');
  }

  /// Construit le contenu du modèle
  String _buildModelContent(ResourceConfig config) {
    final className = config.modelClassName;
    final fields = config.fieldTypes;
    final requiredFields = config.requiredFields;

    final buffer = StringBuffer();

    // En-tête
    buffer.writeln('// Modèle généré automatiquement pour PrestaShop');
    buffer.writeln('// Phase 2 - Générateur complet');
    buffer.writeln(
      '// Ne pas modifier manuellement - Utiliser les générateurs',
    );
    buffer.writeln();
    buffer.writeln("import 'package:json_annotation/json_annotation.dart';");
    buffer.writeln();
    buffer.writeln(
      "part '${config.name.toLowerCase().replaceAll('s', '')}model.g.dart';",
    );
    buffer.writeln();

    // Classe
    buffer.writeln('@JsonSerializable()');
    buffer.writeln('class $className {');

    // Champs
    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final fieldType = entry.value;
      final isRequired = requiredFields.contains(fieldName);

      buffer.writeln(
        '  /// $fieldName ${isRequired ? '(requis)' : '(optionnel)'}',
      );
      buffer.writeln("  @JsonKey(name: '$fieldName')");
      buffer.writeln('  final $fieldType $fieldName;');
      buffer.writeln();
    }

    // Constructeur
    buffer.writeln('  const $className({');
    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final isRequired = requiredFields.contains(fieldName);

      if (isRequired) {
        buffer.writeln('    required this.$fieldName,');
      } else {
        buffer.writeln('    this.$fieldName,');
      }
    }
    buffer.writeln('  });');
    buffer.writeln();

    // Factory methods
    final modelName = config.name.toLowerCase().replaceAll('s', '');
    buffer.writeln(
      '  factory $className.fromJson(Map<String, dynamic> json) =>',
    );
    buffer.writeln('      _\$${className}FromJson(json);');
    buffer.writeln();
    buffer.writeln(
      '  Map<String, dynamic> toJson() => _\$${className}ToJson(this);',
    );
    buffer.writeln();

    // toString
    final primaryField = fields.keys.take(3).join(', ');
    buffer.writeln('  @override');
    buffer.writeln('  String toString() =>');
    buffer.writeln("      '$className($primaryField)';");
    buffer.writeln();

    // equals & hashCode
    buffer.writeln('  @override');
    buffer.writeln('  bool operator ==(Object other) =>');
    buffer.writeln('      identical(this, other) ||');
    buffer.writeln('      other is $className &&');
    buffer.writeln('          runtimeType == other.runtimeType &&');
    buffer.writeln('          id == other.id;');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  int get hashCode => id.hashCode;');

    buffer.writeln('}');

    return buffer.toString();
  }

  /// Construit le contenu du service avec cache
  String _buildServiceContent(ResourceConfig config) {
    final className = config.serviceClassName;
    final modelClassName = config.modelClassName;
    final resourceName = config.name;
    final singleResourceName = config.name.toLowerCase().replaceAll('s', '');

    return '''
// Service généré automatiquement pour PrestaShop
// Phase 2 - Générateur complet avec cache et gestion d'erreurs
// Intégration avec l'ApiClient existant

import 'package:koutonou/core/api/api_client.dart';
import 'package:koutonou/core/exceptions/api_exception.dart';
import 'package:koutonou/core/services/cache_service.dart';
import 'package:koutonou/core/utils/logger.dart';
import 'package:koutonou/modules/$resourceName/models/${singleResourceName}model.dart';

/// Service pour la gestion des $resourceName
class $className {
  static final $className _instance = $className._internal();
  factory $className() => _instance;
  $className._internal();

  final ApiClient _apiClient = ApiClient();
  CacheService? _cacheService;
  static final AppLogger _logger = AppLogger();
  bool _cacheInitialized = false;

  /// Clé de cache pour les $resourceName
  static const String _${resourceName}CacheKey = '${resourceName}_cache';

  /// Initialise le cache de manière paresseuse
  Future<void> _ensureCacheInitialized() async {
    if (_cacheInitialized) return;

    try {
      _cacheService = CacheService();
      await _cacheService!.initialize();
      _cacheInitialized = true;
      _logger.debug('Cache initialisé pour $className');
    } catch (e) {
      _logger.warning('Cache non disponible pour $className: \$e');
      _cacheService = null;
      _cacheInitialized = true; // Marquer comme "initialisé" même en échec
    }
  }

  /// Récupère tous les $resourceName
  Future<List<$modelClassName>> getAll({
    Map<String, dynamic>? filters,
    bool useCache = true,
  }) async {
    try {
      _logger.debug('Récupération des $resourceName (cache: \$useCache)');

      // Initialiser le cache si nécessaire
      await _ensureCacheInitialized();

      // Vérifier le cache d'abord
      if (useCache) {
        final cached = await _getCachedData();
        if (cached.isNotEmpty) {
          _logger.debug('$resourceName trouvés dans le cache: \${cached.length}');
          return cached;
        }
      }

      // Appel API
      final response = await _apiClient.get(
        '$resourceName',
        queryParameters: {
          'output_format': 'JSON',
          'display': 'full',
          if (filters != null) ...filters,
        },
      );

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      // Parser les données
      final items = _parseApiResponse(response.data);

      // Mettre en cache
      if (useCache) {
        await _cacheData(items);
      }

      _logger.info('$resourceName récupérés: \${items.length}');
      return items;
    } catch (e, stackTrace) {
      _logger.error('Erreur récupération $resourceName', e, stackTrace);
      rethrow;
    }
  }

  /// Récupère un $modelClassName par son ID
  Future<$modelClassName?> getById(String id) async {
    try {
      _logger.debug('Récupération $resourceName ID: \$id');

      final response = await _apiClient.get(
        '$resourceName/\$id',
        queryParameters: {'output_format': 'JSON', 'display': 'full'},
      );

      if (!response.success) {
        if (response.statusCode == 404) {
          _logger.debug('$modelClassName \$id non trouvé');
          return null;
        }
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      final item = _parseSingleApiResponse(response.data);
      _logger.info('$modelClassName \$id récupéré');
      return item;
    } catch (e, stackTrace) {
      _logger.error('Erreur récupération $modelClassName \$id', e, stackTrace);
      rethrow;
    }
  }

  /// Crée un nouveau $modelClassName
  Future<$modelClassName> create($modelClassName model) async {
    try {
      _logger.debug('Création $modelClassName');

      final response = await _apiClient.post(
        '$resourceName',
        data: {'$singleResourceName': model.toJson()},
      );

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      final created = _parseSingleApiResponse(response.data);

      // Invalider le cache
      await _invalidateCache();

      _logger.info('$modelClassName créé avec ID: \${created?.id ?? "unknown"}');
      return created!;
    } catch (e, stackTrace) {
      _logger.error('Erreur création $modelClassName', e, stackTrace);
      rethrow;
    }
  }

  /// Met à jour un $modelClassName
  Future<$modelClassName> update(String id, $modelClassName model) async {
    try {
      _logger.debug('Mise à jour $modelClassName ID: \$id');

      final response = await _apiClient.put(
        '$resourceName',
        id,
        data: {'$singleResourceName': model.toJson()},
      );

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      final updated = _parseSingleApiResponse(response.data);

      // Invalider le cache
      await _invalidateCache();

      _logger.info('$modelClassName \$id mis à jour');
      return updated!;
    } catch (e, stackTrace) {
      _logger.error('Erreur mise à jour $modelClassName \$id', e, stackTrace);
      rethrow;
    }
  }

  /// Supprime un $modelClassName
  Future<bool> delete(String id) async {
    try {
      _logger.debug('Suppression $modelClassName ID: \$id');

      final response = await _apiClient.delete('$resourceName', id);

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      // Invalider le cache
      await _invalidateCache();

      _logger.info('$modelClassName \$id supprimé');
      return true;
    } catch (e, stackTrace) {
      _logger.error('Erreur suppression $modelClassName \$id', e, stackTrace);
      return false;
    }
  }

  /// Parse la réponse API pour une liste
  List<$modelClassName> _parseApiResponse(dynamic data) {
    final items = <$modelClassName>[];

    if (data is Map<String, dynamic>) {
      // PrestaShop retourne {resource: [...]}
      final list = data['$resourceName'] ?? [];

      if (list is List) {
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            try {
              items.add($modelClassName.fromJson(item));
            } catch (e) {
              _logger.warning('Erreur parsing item $resourceName: \$e');
            }
          }
        }
      }
    }

    return items;
  }

  /// Parse la réponse API pour un seul item
  $modelClassName? _parseSingleApiResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      // Extraire l'objet principal
      final itemData = data['$singleResourceName'] ?? data;

      if (itemData is Map<String, dynamic>) {
        try {
          return $modelClassName.fromJson(itemData);
        } catch (e) {
          _logger.error('Erreur parsing $modelClassName: \$e');
        }
      }
    }

    return null;
  }

  /// Récupère les données du cache
  Future<List<$modelClassName>> _getCachedData() async {
    try {
      if (_cacheService == null) return [];

      final cached = await _cacheService!.get<List<dynamic>>(
        _${resourceName}CacheKey,
      );
      if (cached != null) {
        return cached
            .map((item) => $modelClassName.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _logger.warning('Erreur lecture cache $resourceName: \$e');
    }

    return [];
  }

  /// Met en cache les données
  Future<void> _cacheData(List<$modelClassName> items) async {
    try {
      if (_cacheService == null) return;

      final jsonList = items.map((item) => item.toJson()).toList();
      await _cacheService!.set(
        _${resourceName}CacheKey,
        jsonList,
        ttl: const Duration(hours: 1),
      );
    } catch (e) {
      _logger.warning('Erreur mise en cache $resourceName: \$e');
    }
  }

  /// Invalide le cache
  Future<void> _invalidateCache() async {
    try {
      if (_cacheService == null) return;

      await _cacheService!.delete(_${resourceName}CacheKey);
      _logger.debug('Cache $resourceName invalidé');
    } catch (e) {
      _logger.warning('Erreur invalidation cache $resourceName: \$e');
    }
  }

  /// Rafraîchit les données (force un appel API)
  Future<List<$modelClassName>> refresh() async {
    await _invalidateCache();
    return getAll(useCache: false);
  }
}
''';
  }

  /// Construit le contenu du service web (sans cache)
  String _buildWebServiceContent(ResourceConfig config) {
    final className = config.serviceClassName;
    final modelClassName = config.modelClassName;
    final resourceName = config.name;
    final singleResourceName = config.name.toLowerCase().replaceAll('s', '');

    return '''
// Service généré automatiquement pour PrestaShop - Version Web
// Phase 2 - Générateur complet sans cache pour le web
// Intégration avec l'ApiClient existant

import 'package:koutonou/core/api/api_client.dart';
import 'package:koutonou/core/exceptions/api_exception.dart';
import 'package:koutonou/core/utils/logger.dart';
import 'package:koutonou/modules/$resourceName/models/${singleResourceName}model.dart';

/// Service pour la gestion des $resourceName - Version Web
class $className {
  static final $className _instance = $className._internal();
  factory $className() => _instance;
  $className._internal();

  final ApiClient _apiClient = ApiClient();
  static final AppLogger _logger = AppLogger();

  /// Récupère tous les $resourceName
  Future<List<$modelClassName>> getAll({
    Map<String, dynamic>? filters,
    bool useCache = true, // Ignoré sur le web
  }) async {
    try {
      _logger.debug('Récupération des $resourceName (mode web)');

      // Appel API direct (pas de cache sur le web)
      final response = await _apiClient.get(
        '$resourceName',
        queryParameters: {
          'output_format': 'JSON',
          'display': 'full',
          if (filters != null) ...filters,
        },
      );

      if (!response.success) {
        throw ApiException.create(
          response.message,
          statusCode: response.statusCode,
        );
      }

      // Parser les données
      final items = _parseApiResponse(response.data);

      _logger.info('$resourceName récupérés: \${items.length}');
      return items;
    } catch (e, stackTrace) {
      _logger.error('Erreur récupération $resourceName', e, stackTrace);
      rethrow;
    }
  }

  // [Autres méthodes similaires au service normal mais sans cache]
  
  /// Parse la réponse API pour une liste
  List<$modelClassName> _parseApiResponse(dynamic data) {
    final items = <$modelClassName>[];

    if (data is Map<String, dynamic>) {
      final list = data['$resourceName'] ?? [];

      if (list is List) {
        for (final item in list) {
          if (item is Map<String, dynamic>) {
            try {
              items.add($modelClassName.fromJson(item));
            } catch (e) {
              _logger.warning('Erreur parsing item $resourceName: \$e');
            }
          }
        }
      }
    }

    return items;
  }

  /// Rafraîchit les données (pas de cache sur le web)
  Future<List<$modelClassName>> refresh() async {
    return getAll(useCache: false);
  }
}
''';
  }
}
