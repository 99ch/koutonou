import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/services.dart';

/// Provider for managing geography-related state in the application
class GeographyProvider with ChangeNotifier {
  final CountryService _countryService;
  final StateService _stateService;
  final GeographicZoneService _zoneService;

  GeographyProvider({
    required CountryService countryService,
    required StateService stateService,
    required GeographicZoneService zoneService,
  }) : _countryService = countryService,
       _stateService = stateService,
       _zoneService = zoneService;

  // ========== STATE VARIABLES ==========

  // Countries
  List<Country> _countries = [];
  bool _isLoadingCountries = false;
  String? _countriesError;

  // States
  List<State> _states = [];
  bool _isLoadingStates = false;
  String? _statesError;

  // Geographic Zones
  List<GeographicZone> _zones = [];
  bool _isLoadingZones = false;
  String? _zonesError;

  // Selected items
  Country? _selectedCountry;
  State? _selectedState;
  GeographicZone? _selectedZone;

  // ========== GETTERS ==========

  // Countries
  List<Country> get countries => _countries;
  bool get isLoadingCountries => _isLoadingCountries;
  String? get countriesError => _countriesError;

  // States
  List<State> get states => _states;
  bool get isLoadingStates => _isLoadingStates;
  String? get statesError => _statesError;

  // Geographic Zones
  List<GeographicZone> get zones => _zones;
  bool get isLoadingZones => _isLoadingZones;
  String? get zonesError => _zonesError;

  // Selected items
  Country? get selectedCountry => _selectedCountry;
  State? get selectedState => _selectedState;
  GeographicZone? get selectedZone => _selectedZone;

  // Computed properties
  List<Country> get activeCountries =>
      _countries.where((c) => c.isActive).toList();
  List<State> get activeStates => _states.where((s) => s.isActive).toList();
  List<GeographicZone> get activeZones =>
      _zones.where((z) => z.isActive).toList();

  // ========== COUNTRY METHODS ==========

  /// Load all countries
  Future<void> loadCountries({bool forceRefresh = false}) async {
    if (_isLoadingCountries && !forceRefresh) return;

    _isLoadingCountries = true;
    _countriesError = null;
    notifyListeners();

    try {
      final response = await _countryService.getCountries();

      if (response.success) {
        _countries = response.data ?? [];
        _countriesError = null;
      } else {
        _countriesError = response.message;
        _countries = [];
      }
    } catch (e) {
      _countriesError = 'Erreur lors du chargement des pays: $e';
      _countries = [];
    }

    _isLoadingCountries = false;
    notifyListeners();
  }

  /// Load countries by zone
  Future<void> loadCountriesByZone(int zoneId) async {
    _isLoadingCountries = true;
    _countriesError = null;
    notifyListeners();

    try {
      final response = await _countryService.getCountriesByZone(zoneId);

      if (response.success) {
        _countries = response.data ?? [];
        _countriesError = null;
      } else {
        _countriesError = response.message;
        _countries = [];
      }
    } catch (e) {
      _countriesError = 'Erreur lors du chargement des pays: $e';
      _countries = [];
    }

    _isLoadingCountries = false;
    notifyListeners();
  }

  /// Create country
  Future<bool> createCountry(Country country) async {
    try {
      final response = await _countryService.createCountry(country);

      if (response.success && response.data != null) {
        _countries.add(response.data!);
        notifyListeners();
        return true;
      } else {
        _countriesError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _countriesError = 'Erreur lors de la création du pays: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update country
  Future<bool> updateCountry(Country country) async {
    try {
      final response = await _countryService.updateCountry(country);

      if (response.success && response.data != null) {
        final index = _countries.indexWhere((c) => c.id == country.id);
        if (index != -1) {
          _countries[index] = response.data!;
        }
        notifyListeners();
        return true;
      } else {
        _countriesError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _countriesError = 'Erreur lors de la mise à jour du pays: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete country
  Future<bool> deleteCountry(int countryId) async {
    try {
      final response = await _countryService.deleteCountry(countryId);

      if (response.success) {
        _countries.removeWhere((c) => c.id == countryId);
        notifyListeners();
        return true;
      } else {
        _countriesError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _countriesError = 'Erreur lors de la suppression du pays: $e';
      notifyListeners();
      return false;
    }
  }

  /// Search countries
  Future<void> searchCountries(String query) async {
    _isLoadingCountries = true;
    _countriesError = null;
    notifyListeners();

    try {
      final response = await _countryService.searchCountries(query);

      if (response.success) {
        _countries = response.data ?? [];
        _countriesError = null;
      } else {
        _countriesError = response.message;
        _countries = [];
      }
    } catch (e) {
      _countriesError = 'Erreur lors de la recherche: $e';
      _countries = [];
    }

    _isLoadingCountries = false;
    notifyListeners();
  }

  // ========== STATE METHODS ==========

  /// Load all states
  Future<void> loadStates({bool forceRefresh = false}) async {
    if (_isLoadingStates && !forceRefresh) return;

    _isLoadingStates = true;
    _statesError = null;
    notifyListeners();

    try {
      final response = await _stateService.getStates();

      if (response.success) {
        _states = response.data ?? [];
        _statesError = null;
      } else {
        _statesError = response.message;
        _states = [];
      }
    } catch (e) {
      _statesError = 'Erreur lors du chargement des états: $e';
      _states = [];
    }

    _isLoadingStates = false;
    notifyListeners();
  }

  /// Load states by country
  Future<void> loadStatesByCountry(int countryId) async {
    _isLoadingStates = true;
    _statesError = null;
    notifyListeners();

    try {
      final response = await _stateService.getStatesByCountry(countryId);

      if (response.success) {
        _states = response.data ?? [];
        _statesError = null;
      } else {
        _statesError = response.message;
        _states = [];
      }
    } catch (e) {
      _statesError = 'Erreur lors du chargement des états: $e';
      _states = [];
    }

    _isLoadingStates = false;
    notifyListeners();
  }

  /// Load states by zone
  Future<void> loadStatesByZone(int zoneId) async {
    _isLoadingStates = true;
    _statesError = null;
    notifyListeners();

    try {
      final response = await _stateService.getStatesByZone(zoneId);

      if (response.success) {
        _states = response.data ?? [];
        _statesError = null;
      } else {
        _statesError = response.message;
        _states = [];
      }
    } catch (e) {
      _statesError = 'Erreur lors du chargement des états: $e';
      _states = [];
    }

    _isLoadingStates = false;
    notifyListeners();
  }

  /// Create state
  Future<bool> createState(State state) async {
    try {
      final response = await _stateService.createState(state);

      if (response.success && response.data != null) {
        _states.add(response.data!);
        notifyListeners();
        return true;
      } else {
        _statesError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _statesError = 'Erreur lors de la création de l\'état: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update state
  Future<bool> updateState(State state) async {
    try {
      final response = await _stateService.updateState(state);

      if (response.success && response.data != null) {
        final index = _states.indexWhere((s) => s.id == state.id);
        if (index != -1) {
          _states[index] = response.data!;
        }
        notifyListeners();
        return true;
      } else {
        _statesError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _statesError = 'Erreur lors de la mise à jour de l\'état: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete state
  Future<bool> deleteState(int stateId) async {
    try {
      final response = await _stateService.deleteState(stateId);

      if (response.success) {
        _states.removeWhere((s) => s.id == stateId);
        notifyListeners();
        return true;
      } else {
        _statesError = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _statesError = 'Erreur lors de la suppression de l\'état: $e';
      notifyListeners();
      return false;
    }
  }

  // ========== GEOGRAPHIC ZONE METHODS ==========

  /// Load all zones
  Future<void> loadZones({bool forceRefresh = false}) async {
    if (_isLoadingZones && !forceRefresh) return;

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
  Future<bool> createZone(GeographicZone zone) async {
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
  Future<bool> updateZone(GeographicZone zone) async {
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

  // ========== SELECTION METHODS ==========

  /// Set selected country
  void setSelectedCountry(Country? country) {
    _selectedCountry = country;
    // Clear states when country changes
    if (country == null) {
      _states = [];
      _selectedState = null;
    } else {
      // Load states for the selected country
      loadStatesByCountry(country.id!);
    }
    notifyListeners();
  }

  /// Set selected state
  void setSelectedState(State? state) {
    _selectedState = state;
    notifyListeners();
  }

  /// Set selected zone
  void setSelectedZone(GeographicZone? zone) {
    _selectedZone = zone;
    // Load countries for the selected zone
    if (zone != null) {
      loadCountriesByZone(zone.id!);
    }
    notifyListeners();
  }

  // ========== HELPER METHODS ==========

  /// Clear all errors
  void clearErrors() {
    _countriesError = null;
    _statesError = null;
    _zonesError = null;
    notifyListeners();
  }

  /// Get country by ID
  Country? getCountryById(int id) {
    try {
      return _countries.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get state by ID
  State? getStateById(int id) {
    try {
      return _states.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get zone by ID
  GeographicZone? getZoneById(int id) {
    try {
      return _zones.firstWhere((z) => z.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get countries that have states
  List<Country> get countriesWithStates =>
      _countries.where((c) => c.containsStates).toList();

  /// Get states for a specific country
  List<State> getStatesForCountry(int countryId) {
    return _states.where((s) => s.idCountry == countryId).toList();
  }

  /// Get countries for a specific zone
  List<Country> getCountriesForZone(int zoneId) {
    return _countries.where((c) => c.idZone == zoneId).toList();
  }
}
