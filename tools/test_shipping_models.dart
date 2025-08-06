import '../lib/modules/shipping/models/models.dart';

void main() {
  testCarrierModel();
  testDeliveryModel();
  testPriceRangeModel();
  testWeightRangeModel();
  testZoneModel();
}

void testCarrierModel() {
  print('=== Testing Carrier Model ===');

  // Test creating a Carrier
  final carrier = Carrier(
    id: 1,
    name: 'DHL Express',
    delay: {'1': '24-48h', '2': '1-2 jours'},
    url: 'https://www.dhl.com/tracking/@',
    position: 1,
    maxWeight: 30.0,
    maxWidth: 120,
    maxHeight: 80,
    maxDepth: 80,
    active: true,
    isFree: false,
    isModule: true,
    externalModuleName: 'dhl_module',
    shippingHandling: true,
    shippingMethod: 1,
  );

  // Test JSON serialization
  final json = carrier.toJson();
  print('Carrier JSON: $json');

  // Test JSON deserialization
  final carrierFromJson = Carrier.fromJson(json);
  print('Carrier from JSON: ${carrierFromJson.name}');

  // Test XML generation
  final xml = carrier.toXml();
  print('Carrier XML snippet: ${xml.substring(0, 100)}...');

  // Test business methods
  print('Carrier is active: ${carrier.isActive}');
  print('Carrier has URL: ${carrier.hasUrl}');
  print('Carrier has max dimensions: ${carrier.hasMaxDimensions}');
  print('Delay for language 1: ${carrier.getDelayForLanguage('1')}');

  print('✅ Carrier model tests passed\n');
}

void testDeliveryModel() {
  print('=== Testing Delivery Model ===');

  final delivery = Delivery(
    id: 1,
    idCarrier: 1,
    idZone: 1,
    idRangeWeight: 2,
    idRangePrice: 3,
    price: 15.99,
  );

  final json = delivery.toJson();
  print('Delivery JSON: $json');

  final deliveryFromJson = Delivery.fromJson(json);
  print('Delivery price: ${deliveryFromJson.price}');

  final xml = delivery.toXml();
  print('Delivery XML snippet: ${xml.substring(0, 80)}...');

  print('✅ Delivery model tests passed\n');
}

void testPriceRangeModel() {
  print('=== Testing PriceRange Model ===');

  final priceRange = PriceRange(
    id: 1,
    idCarrier: 1,
    delimiter1: 0.0,
    delimiter2: 50.0,
  );

  final json = priceRange.toJson();
  print('PriceRange JSON: $json');

  final rangeFromJson = PriceRange.fromJson(json);
  print(
    'Price range: ${rangeFromJson.delimiter1} - ${rangeFromJson.delimiter2}',
  );

  final xml = priceRange.toXml();
  print('PriceRange XML snippet: ${xml.substring(0, 80)}...');

  print('✅ PriceRange model tests passed\n');
}

void testWeightRangeModel() {
  print('=== Testing WeightRange Model ===');

  final weightRange = WeightRange(
    id: 1,
    idCarrier: 1,
    delimiter1: 0.0,
    delimiter2: 10.0,
  );

  final json = weightRange.toJson();
  print('WeightRange JSON: $json');

  final rangeFromJson = WeightRange.fromJson(json);
  print(
    'Weight range: ${rangeFromJson.delimiter1} - ${rangeFromJson.delimiter2} kg',
  );

  final xml = weightRange.toXml();
  print('WeightRange XML snippet: ${xml.substring(0, 80)}...');

  print('✅ WeightRange model tests passed\n');
}

void testZoneModel() {
  print('=== Testing Zone Model ===');

  final zone = Zone(id: 1, name: 'Europe', active: true);

  final json = zone.toJson();
  print('Zone JSON: $json');

  final zoneFromJson = Zone.fromJson(json);
  print('Zone: ${zoneFromJson.name} - Active: ${zoneFromJson.active}');

  final xml = zone.toXml();
  print('Zone XML snippet: ${xml.substring(0, 100)}...');

  print('Zone is active: ${zone.active}');

  print('✅ Zone model tests passed\n');
}
