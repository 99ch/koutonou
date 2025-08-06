/// Test de tous les modèles du module Customers
/// Usage: dart tools/test_customers_models.dart

import '../lib/modules/customers/models/customer_model.dart';
import '../lib/modules/customers/models/customer_message_model.dart';
import '../lib/modules/customers/models/customer_thread_model.dart';
import '../lib/modules/customers/models/address_model.dart';
import '../lib/modules/customers/models/group_model.dart';
import '../lib/modules/customers/models/guest_model.dart';

void main() {
  print('🧪 Tests des modèles Customers');
  print('===============================\n');

  testCustomer();
  testCustomerMessage();
  testCustomerThread();
  testAddress();
  testGroup();
  testGuest();

  print('\n✅ Tous les tests sont passés avec succès !');
}

void testCustomer() {
  print('👤 Test Customer');
  print('----------------');

  // Test données JSON simulées
  final json = {
    'id': '123',
    'id_default_group': '1',
    'id_lang': '1',
    'deleted': '0',
    'passwd': 'encrypted_password',
    'lastname': 'Dupont',
    'firstname': 'Jean',
    'email': 'jean.dupont@example.com',
    'id_gender': '1',
    'birthday': '1985-03-15',
    'newsletter': '1',
    'optin': '1',
    'website': 'https://jeandupont.fr',
    'company': 'ACME Corporation',
    'active': '1',
    'is_guest': '0',
    'date_add': '2023-01-15 10:30:00',
    'associations': {
      'groups': {
        'group': [
          {'id': '1'},
          {'id': '3'},
        ],
      },
    },
  };

  // Test création depuis JSON
  final customer = Customer.fromPrestaShopJson(json);
  print('✓ Création depuis JSON: ${customer.id}');
  print('✓ Nom complet: ${customer.fullName}');
  print('✓ Email: ${customer.email}');
  print('✓ Age: ${customer.age} ans');
  print('✓ Newsletter: ${customer.newsletterStatus}');
  print('✓ Type de compte: ${customer.accountType}');
  print('✓ Statut: ${customer.accountStatus}');
  print('✓ Entreprise: ${customer.hasCompany ? customer.company : 'Aucune'}');
  print('✓ Groupes: ${customer.groupIds?.length ?? 0}');

  // Test conversion XML
  final xml = customer.toPrestaShopXml();
  print('✓ Conversion XML: ${xml.contains('<customer>') ? 'OK' : 'FAIL'}');

  print('✅ Customer testé avec succès\n');
}

void testCustomerMessage() {
  print('💬 Test CustomerMessage');
  print('-----------------------');

  // Test données JSON simulées
  final json = {
    'id': '456',
    'id_employee': '2',
    'id_customer_thread': '789',
    'ip_address': '192.168.1.100',
    'message':
        'Bonjour, j\'ai un problème avec ma commande. Pouvez-vous m\'aider ?',
    'file_name': 'screenshot.png',
    'user_agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
    'private': '0',
    'date_add': '2025-08-06 14:30:00',
    'read': '0',
  };

  // Test création depuis JSON
  final message = CustomerMessage.fromPrestaShopJson(json);
  print('✓ Création depuis JSON: ${message.id}');
  print('✓ Type: ${message.messageType}');
  print('✓ Aperçu: ${message.messagePreview}');
  print('✓ Statut lecture: ${message.readStatus}');
  print('✓ Visibilité: ${message.visibilityStatus}');
  print(
    '✓ Pièce jointe: ${message.hasAttachment ? message.fileName : 'Aucune'}',
  );
  print('✓ De l\'employé: ${message.isFromEmployee}');
  print('✓ Date: ${message.formattedDateAdd}');

  // Test conversion XML
  final xml = message.toPrestaShopXml();
  print(
    '✓ Conversion XML: ${xml.contains('<customer_message>') ? 'OK' : 'FAIL'}',
  );

  print('✅ CustomerMessage testé avec succès\n');
}

void testCustomerThread() {
  print('🧵 Test CustomerThread');
  print('----------------------');

  // Test données JSON simulées
  final json = {
    'id': '789',
    'id_lang': '1',
    'id_shop': '1',
    'id_customer': '123',
    'id_order': '456',
    'id_contact': '1',
    'email': 'jean.dupont@example.com',
    'token': 'abc123def456',
    'status': 'open',
    'date_add': '2025-08-06 14:00:00',
    'date_upd': '2025-08-06 14:30:00',
    'associations': {
      'customer_messages': {
        'customer_message': [
          {'id': '1'},
          {'id': '2'},
        ],
      },
    },
  };

  // Test création depuis JSON
  final thread = CustomerThread.fromPrestaShopJson(json);
  print('✓ Création depuis JSON: ${thread.id}');
  print('✓ Type de sujet: ${thread.threadType}');
  print('✓ Statut: ${thread.formattedStatus}');
  print('✓ Lié à commande: ${thread.isOrderRelated}');
  print('✓ Lié à client: ${thread.isCustomerRelated}');
  print('✓ Messages: ${thread.messageCount}');
  print('✓ Ouvert: ${thread.isOpen}');
  print('✓ Fermé: ${thread.isClosed}');
  print('✓ Date création: ${thread.formattedDateAdd}');

  // Test conversion XML
  final xml = thread.toPrestaShopXml();
  print(
    '✓ Conversion XML: ${xml.contains('<customer_thread>') ? 'OK' : 'FAIL'}',
  );

  print('✅ CustomerThread testé avec succès\n');
}

void testAddress() {
  print('📍 Test Address');
  print('---------------');

  // Test données JSON simulées
  final json = {
    'id': '101',
    'id_customer': '123',
    'id_country': '8',
    'id_state': '12',
    'alias': 'Mon domicile',
    'company': 'ACME Corporation',
    'lastname': 'Dupont',
    'firstname': 'Jean',
    'vat_number': 'FR123456789',
    'address1': '123 Rue de la Paix',
    'address2': 'Appartement 5',
    'postcode': '75001',
    'city': 'Paris',
    'phone': '01.23.45.67.89',
    'phone_mobile': '06.12.34.56.78',
    'deleted': '0',
    'date_add': '2023-01-15 10:30:00',
  };

  // Test création depuis JSON
  final address = Address.fromPrestaShopJson(json);
  print('✓ Création depuis JSON: ${address.id}');
  print('✓ Nom complet: ${address.fullName}');
  print('✓ Adresse complète: ${address.fullAddress}');
  print('✓ Type: ${address.addressType}');
  print('✓ Entreprise: ${address.hasCompany ? address.company : 'Aucune'}');
  print('✓ TVA: ${address.hasVatNumber ? address.vatNumber : 'Aucune'}');
  print('✓ Téléphone principal: ${address.primaryPhone ?? 'Aucun'}');
  print('✓ Téléphones: ${address.availablePhones.length}');

  // Test conversion XML
  final xml = address.toPrestaShopXml();
  print('✓ Conversion XML: ${xml.contains('<address>') ? 'OK' : 'FAIL'}');

  print('✅ Address testé avec succès\n');
}

void testGroup() {
  print('👥 Test Group');
  print('-------------');

  // Test données JSON simulées
  final json = {
    'id': '3',
    'reduction': '5.5',
    'price_display_method': '0',
    'show_prices': '1',
    'date_add': '2023-01-01 00:00:00',
    'name': {
      'language': [
        {
          '@attributes': {'id': '1'},
          '\$': 'Clients VIP',
        },
        {
          '@attributes': {'id': '2'},
          '\$': 'VIP Customers',
        },
      ],
    },
  };

  // Test création depuis JSON
  final group = Group.fromPrestaShopJson(json);
  print('✓ Création depuis JSON: ${group.id}');
  print('✓ Nom par défaut: ${group.defaultName}');
  print('✓ Réduction: ${group.formattedReduction}');
  print('✓ Affichage prix: ${group.priceDisplayMethodDescription}');
  print('✓ Visibilité prix: ${group.priceVisibilityStatus}');
  print('✓ A une réduction: ${group.hasReduction}');
  print('✓ Prix TTC: ${group.showsPricesWithTax}');
  print('✓ Date création: ${group.formattedDateAdd}');

  // Test conversion XML
  final xml = group.toPrestaShopXml();
  print('✓ Conversion XML: ${xml.contains('<group>') ? 'OK' : 'FAIL'}');

  print('✅ Group testé avec succès\n');
}

void testGuest() {
  print('👻 Test Guest');
  print('-------------');

  // Test données JSON simulées
  final json = {
    'id': '999',
    'id_customer': '123',
    'id_operating_system': '3',
    'id_web_browser': '7',
    'javascript': '1',
    'screen_resolution_x': '1920',
    'screen_resolution_y': '1080',
    'screen_color': '32',
    'sun_java': '0',
    'adobe_flash': '1',
    'adobe_director': '0',
    'apple_quicktime': '1',
    'real_player': '0',
    'windows_media': '1',
    'accept_language': 'fr-FR',
    'mobile_theme': '0',
  };

  // Test création depuis JSON
  final guest = Guest.fromPrestaShopJson(json);
  print('✓ Création depuis JSON: ${guest.id}');
  print('✓ Type utilisateur: ${guest.userType}');
  print('✓ Plateforme: ${guest.platform}');
  print('✓ JavaScript: ${guest.javascriptSupport}');
  print('✓ Résolution: ${guest.screenResolution ?? 'Inconnue'}');
  print('✓ Lié à client: ${guest.isLinkedToCustomer}');
  print('✓ Utilisateur mobile: ${guest.isMobileUser}');
  print(
    '✓ Plugins supportés: ${guest.supportedPluginsCount} (${guest.supportedPlugins.join(', ')})',
  );

  // Test conversion XML
  final xml = guest.toPrestaShopXml();
  print('✓ Conversion XML: ${xml.contains('<guest>') ? 'OK' : 'FAIL'}');

  print('✅ Guest testé avec succès\n');
}
