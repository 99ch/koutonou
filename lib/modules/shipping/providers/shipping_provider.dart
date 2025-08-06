import 'package:flutter/foundation.dart';
import '../../../core/models/base_response.dart';
import '../models/carrier_model.dart';
import '../models/delivery_model.dart';
import '../models/price_range_model.dart';
import '../models/weight_range_model.dart';
import '../models/zone_model.dart';
import '../services/carrier_service.dart';
import '../services/delivery_service.dart';
import '../services/range_service.dart';
import '../services/zone_service.dart';

class ShippingProvider with ChangeNotifier {
  final CarrierService _carrierService;
  final DeliveryService _deliveryService;
  final RangeService _rangeService;
  final ZoneService _zoneService;

  ShippingProvider(
    this._carrierService,
    this._deliveryService,
    this._rangeService,
    this._zoneService,
  );

  // ========== STATE ==========

  // Carriers
  List<Carrier> _carriers = [];
  Carrier? _currentCarrier;
  bool _isLoadingCarriers = false;
  String? _carriersError;

  // Deliveries
  List<Delivery> _deliveries = [];
  bool _isLoadingDeliveries = false;
  String? _deliveriesError;

  // Price Ranges
  List<PriceRange> _priceRanges = [];
  bool _isLoadingPriceRanges = false;
  String? _priceRangesError;

  // Weight Ranges
  List<WeightRange> _weightRanges = [];
  bool _isLoadingWeightRanges = false;
  String? _weightRangesError;

  // Zones
  List<Zone> _zones = [];
  bool _isLoadingZones = false;
  String? _zonesError;

  // ========== GETTERS ==========

  // Carriers
  List<Carrier> get carriers => _carriers;
  Carrier? get currentCarrier => _currentCarrier;
  bool get isLoadingCarriers => _isLoadingCarriers;
  String? get carriersError => _carriersError;

  // Deliveries
  List<Delivery> get deliveries => _deliveries;
  bool get isLoadingDeliveries => _isLoadingDeliveries;
  String? get deliveriesError => _deliveriesError;

  // Price Ranges
  List<PriceRange> get priceRanges => _priceRanges;
  bool get isLoadingPriceRanges => _isLoadingPriceRanges;
  String? get priceRangesError => _priceRangesError;

  // Weight Ranges
  List<WeightRange> get weightRanges => _weightRanges;
  bool get isLoadingWeightRanges => _isLoadingWeightRanges;
  String? get weightRangesError => _weightRangesError;

  // Zones
  List<Zone> get zones => _zones;
  bool get isLoadingZones => _isLoadingZones;
  String? get zonesError => _zonesError;

  // Computed getters
  List<Carrier> get activeCarriers =>
      _carriers.where((c) => c.isActive).toList();
  List<Carrier> get freeCarriers =>
      _carriers.where((c) => c.isFreeShipping).toList();
  List<Zone> get activeZones => _zones.where((z) => z.isActive).toList();

  // ========== CARRIER METHODS ==========

  /// Load all carriers
  Future<void> loadCarriers() async {
    _isLoadingCarriers = true;
    _carriersError = null;
    notifyListeners();

    try {
      final response = await _carrierService.getCarriers(display: 'full');

      if (response.success) {
        _carriers = response.data ?? [];
        _carriersError = null;
      } else {
        _carriersError = response.message;
        _carriers = [];
      }
    } catch (e) {
      _carriersError = 'Erreur lors du chargement des transporteurs: $e';
      _carriers = [];
    }

    _isLoadingCarriers = false;
    notifyListeners();
  }

  /// Load carrier by ID
  Future<bool> loadCarrier(int carrierId) async {
    try {
      final response = await _carrierService.getCarrier(
        carrierId,
        display: 'full',
      );

      if (response.success && response.data != null) {
        _currentCarrier = response.data;

        // Update in list if exists
        final index = _carriers.indexWhere((c) => c.id == carrierId);
        if (index != -1) {
          _carriers[index] = response.data!;
        }

        notifyListeners();
        return true;
      } else {
        _carriersError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _carriersError = 'Erreur lors du chargement du transporteur: $e';
      notifyListeners();
      return false;
    }
  }

  /// Create carrier
  Future<bool> createCarrier(Carrier carrier) async {
    try {
      final response = await _carrierService.createCarrier(carrier);

      if (response.success && response.data != null) {
        _carriers.add(response.data!);
        _currentCarrier = response.data;
        notifyListeners();
        return true;
      } else {
        _carriersError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _carriersError = 'Erreur lors de la création du transporteur: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update carrier
  Future<bool> updateCarrier(Carrier carrier) async {
    try {
      final response = await _carrierService.updateCarrier(carrier);

      if (response.success && response.data != null) {
        final index = _carriers.indexWhere((c) => c.id == carrier.id);
        if (index != -1) {
          _carriers[index] = response.data!;
        }

        if (_currentCarrier?.id == carrier.id) {
          _currentCarrier = response.data;
        }

        notifyListeners();
        return true;
      } else {
        _carriersError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _carriersError = 'Erreur lors de la mise à jour du transporteur: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete carrier
  Future<bool> deleteCarrier(int carrierId) async {
    try {
      final response = await _carrierService.deleteCarrier(carrierId);

      if (response.success) {
        _carriers.removeWhere((c) => c.id == carrierId);

        if (_currentCarrier?.id == carrierId) {
          _currentCarrier = null;
        }

        notifyListeners();
        return true;
      } else {
        _carriersError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _carriersError = 'Erreur lors de la suppression du transporteur: $e';
      notifyListeners();
      return false;
    }
  }

  // ========== ZONE METHODS ==========

  /// Load all zones
  Future<void> loadZones() async {
    _isLoadingZones = true;
    _zonesError = null;
    notifyListeners();

    try {
      final response = await _zoneService.getZones();

      if (response.success) {
        _zones = response.data ?? [];
        _zonesError = null;
      } else {
        _zonesError = response.message;
        _zones = [];
      }
    } catch (e) {
      _zonesError = 'Erreur lors du chargement des zones: $e';
      _zones = [];
    }

    _isLoadingZones = false;
    notifyListeners();
  }

  /// Create zone
  Future<bool> createZone(Zone zone) async {
    try {
      final response = await _zoneService.createZone(zone);

      if (response.success && response.data != null) {
        _zones.add(response.data!);
        notifyListeners();
        return true;
      } else {
        _zonesError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _zonesError = 'Erreur lors de la création de la zone: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update zone
  Future<bool> updateZone(Zone zone) async {
    try {
      final response = await _zoneService.updateZone(zone);

      if (response.success && response.data != null) {
        final index = _zones.indexWhere((z) => z.id == zone.id);
        if (index != -1) {
          _zones[index] = response.data!;
        }

        notifyListeners();
        return true;
      } else {
        _zonesError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _zonesError = 'Erreur lors de la mise à jour de la zone: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete zone
  Future<bool> deleteZone(int zoneId) async {
    try {
      final response = await _zoneService.deleteZone(zoneId);

      if (response.success) {
        _zones.removeWhere((z) => z.id == zoneId);
        notifyListeners();
        return true;
      } else {
        _zonesError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _zonesError = 'Erreur lors de la suppression de la zone: $e';
      notifyListeners();
      return false;
    }
  }

  // ========== DELIVERY METHODS ==========

  /// Load deliveries
  Future<void> loadDeliveries() async {
    _isLoadingDeliveries = true;
    _deliveriesError = null;
    notifyListeners();

    try {
      final response = await _deliveryService.getDeliveries();

      if (response.success) {
        _deliveries = response.data ?? [];
        _deliveriesError = null;
      } else {
        _deliveriesError = response.message;
        _deliveries = [];
      }
    } catch (e) {
      _deliveriesError = 'Erreur lors du chargement des livraisons: $e';
      _deliveries = [];
    }

    _isLoadingDeliveries = false;
    notifyListeners();
  }

  /// Load deliveries by carrier
  Future<void> loadDeliveriesByCarrier(int carrierId) async {
    _isLoadingDeliveries = true;
    _deliveriesError = null;
    notifyListeners();

    try {
      final response = await _deliveryService.getDeliveriesByCarrier(carrierId);

      if (response.success) {
        _deliveries = response.data ?? [];
        _deliveriesError = null;
      } else {
        _deliveriesError = response.message;
        _deliveries = [];
      }
    } catch (e) {
      _deliveriesError = 'Erreur lors du chargement des livraisons: $e';
      _deliveries = [];
    }

    _isLoadingDeliveries = false;
    notifyListeners();
  }

  // ========== RANGE METHODS ==========

  /// Load price ranges
  Future<void> loadPriceRanges({int? carrierId}) async {
    _isLoadingPriceRanges = true;
    _priceRangesError = null;
    notifyListeners();

    try {
      final BaseResponse<List<PriceRange>> response;
      if (carrierId != null) {
        response = await _rangeService.getPriceRangesByCarrier(carrierId);
      } else {
        response = await _rangeService.getPriceRanges();
      }

      if (response.success) {
        _priceRanges = response.data ?? [];
        _priceRangesError = null;
      } else {
        _priceRangesError = response.message;
        _priceRanges = [];
      }
    } catch (e) {
      _priceRangesError = 'Erreur lors du chargement des tranches de prix: $e';
      _priceRanges = [];
    }

    _isLoadingPriceRanges = false;
    notifyListeners();
  }

  /// Load weight ranges
  Future<void> loadWeightRanges({int? carrierId}) async {
    _isLoadingWeightRanges = true;
    _weightRangesError = null;
    notifyListeners();

    try {
      final BaseResponse<List<WeightRange>> response;
      if (carrierId != null) {
        response = await _rangeService.getWeightRangesByCarrier(carrierId);
      } else {
        response = await _rangeService.getWeightRanges();
      }

      if (response.success) {
        _weightRanges = response.data ?? [];
        _weightRangesError = null;
      } else {
        _weightRangesError = response.message;
        _weightRanges = [];
      }
    } catch (e) {
      _weightRangesError =
          'Erreur lors du chargement des tranches de poids: $e';
      _weightRanges = [];
    }

    _isLoadingWeightRanges = false;
    notifyListeners();
  }

  // ========== PRICE RANGE CRUD METHODS ==========

  /// Create price range
  Future<bool> createPriceRange(PriceRange range) async {
    try {
      final response = await _rangeService.createPriceRange(range);

      if (response.success && response.data != null) {
        _priceRanges.add(response.data!);
        notifyListeners();
        return true;
      } else {
        _priceRangesError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _priceRangesError =
          'Erreur lors de la création de la tranche de prix: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete price range
  Future<bool> deletePriceRange(int rangeId) async {
    try {
      final response = await _rangeService.deletePriceRange(rangeId);

      if (response.success) {
        _priceRanges.removeWhere((r) => r.id == rangeId);
        notifyListeners();
        return true;
      } else {
        _priceRangesError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _priceRangesError =
          'Erreur lors de la suppression de la tranche de prix: $e';
      notifyListeners();
      return false;
    }
  }

  // ========== WEIGHT RANGE CRUD METHODS ==========

  /// Create weight range
  Future<bool> createWeightRange(WeightRange range) async {
    try {
      final response = await _rangeService.createWeightRange(range);

      if (response.success && response.data != null) {
        _weightRanges.add(response.data!);
        notifyListeners();
        return true;
      } else {
        _weightRangesError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _weightRangesError =
          'Erreur lors de la création de la tranche de poids: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete weight range
  Future<bool> deleteWeightRange(int rangeId) async {
    try {
      final response = await _rangeService.deleteWeightRange(rangeId);

      if (response.success) {
        _weightRanges.removeWhere((r) => r.id == rangeId);
        notifyListeners();
        return true;
      } else {
        _weightRangesError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _weightRangesError =
          'Erreur lors de la suppression de la tranche de poids: $e';
      notifyListeners();
      return false;
    }
  }

  // ========== DELIVERY CRUD METHODS ==========

  /// Create a new delivery
  Future<bool> createDelivery(Map<String, dynamic> deliveryData) async {
    try {
      final delivery = Delivery(
        idCarrier: deliveryData['id_carrier'],
        idRangePrice: deliveryData['id_range_price'],
        idRangeWeight: deliveryData['id_range_weight'],
        idZone: deliveryData['id_zone'],
        price: deliveryData['price'],
        idShop: deliveryData['id_shop'],
        idShopGroup: deliveryData['id_shop_group'],
      );

      final response = await _deliveryService.createDelivery(delivery);
      if (response.success && response.data != null) {
        _deliveries.add(response.data!);
        notifyListeners();
        return true;
      }
      _deliveriesError = response.message;
      notifyListeners();
      return false;
    } catch (e) {
      _deliveriesError = 'Erreur lors de la création de la livraison: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update a delivery
  Future<bool> updateDelivery(int id, Map<String, dynamic> deliveryData) async {
    try {
      final delivery = Delivery(
        id: id,
        idCarrier: deliveryData['id_carrier'],
        idRangePrice: deliveryData['id_range_price'],
        idRangeWeight: deliveryData['id_range_weight'],
        idZone: deliveryData['id_zone'],
        price: deliveryData['price'],
        idShop: deliveryData['id_shop'],
        idShopGroup: deliveryData['id_shop_group'],
      );

      final response = await _deliveryService.updateDelivery(delivery);
      if (response.success && response.data != null) {
        final index = _deliveries.indexWhere((d) => d.id == id);
        if (index != -1) {
          _deliveries[index] = response.data!;
          notifyListeners();
        }
        return true;
      }
      _deliveriesError = response.message;
      notifyListeners();
      return false;
    } catch (e) {
      _deliveriesError = 'Erreur lors de la mise à jour de la livraison: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete a delivery
  Future<bool> deleteDelivery(int id) async {
    try {
      final response = await _deliveryService.deleteDelivery(id);
      if (response.success) {
        _deliveries.removeWhere((d) => d.id == id);
        notifyListeners();
        return true;
      }
      _deliveriesError = response.message;
      notifyListeners();
      return false;
    } catch (e) {
      _deliveriesError = 'Erreur lors de la suppression de la livraison: $e';
      notifyListeners();
      return false;
    }
  }

  // ========== HELPER METHODS ==========

  /// Set current carrier
  void setCurrentCarrier(Carrier? carrier) {
    _currentCarrier = carrier;
    notifyListeners();
  }

  /// Clear all errors
  void clearErrors() {
    _carriersError = null;
    _deliveriesError = null;
    _priceRangesError = null;
    _weightRangesError = null;
    _zonesError = null;
    notifyListeners();
  }

  /// Get carrier by ID
  Carrier? getCarrierById(int id) {
    try {
      return _carriers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get zone by ID
  Zone? getZoneById(int id) {
    try {
      return _zones.firstWhere((z) => z.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Calculate shipping cost (basic logic)
  double calculateShippingCost(
    Carrier carrier,
    double weight,
    double price,
    Zone zone,
  ) {
    if (carrier.isFreeShipping) {
      return 0.0;
    }

    // This is a simplified calculation - in real life it would be more complex
    // using the delivery tables, price ranges, and weight ranges

    double baseCost = 5.0; // Base shipping cost

    if (carrier.shippingMethod == 1) {
      // By weight
      baseCost += weight * 1.5;
    } else if (carrier.shippingMethod == 2) {
      // By price
      baseCost += price * 0.05;
    }

    if (carrier.shippingHandling) {
      baseCost += 2.0; // Additional handling cost
    }

    return baseCost;
  }
}
